import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'netcoresync_exceptions.dart';
import 'data_access.dart';

abstract class SyncBaseTable {
  Type get type;
}

@sealed
abstract class SyncUpsertClause<T extends Table, D> {
  UpsertClause<T, D> resolve(int obtainedTimeStamp, DataAccess dataAccess);
}

class SyncDoUpdate<T extends Table, D> extends SyncUpsertClause<T, D> {
  final Insertable<D> Function(T old) _creator;
  final List<Column>? target;

  SyncDoUpdate(Insertable<D> Function(T old) update, {this.target})
      : _creator = update;

  @internal
  @override
  DoUpdate<T, D> resolve(int obtainedTimeStamp, DataAccess dataAccess) {
    Insertable<D> Function(T old) wrap = (old) {
      Insertable<D> result = _creator(old);
      if (!dataAccess.engine.tables.containsKey(D))
        throw NetCoreSyncTypeNotRegisteredException(D);
      if ((result as RawValuesInsertable<D>).data.containsKey(
          dataAccess.engine.tables[D]!.tableAnnotation.idFieldName))
        throw NetCoreSyncException(
            "Changing the 'id' (as primary key) value is prohibited. This error is raised because your 'DoUpdate' contains actions that have altered your 'id' field: ${dataAccess.engine.tables[D]!.tableAnnotation.idFieldName}");
      Insertable<D> syncResult = dataAccess.engine
          .updateSyncColumns(result, timeStamp: obtainedTimeStamp);
      return syncResult;
    };
    return DoUpdate(wrap, target: target);
  }
}

class SyncUpsertMultiple<T extends Table, D> extends SyncUpsertClause<T, D> {
  final List<SyncDoUpdate<T, D>> clauses;

  SyncUpsertMultiple(this.clauses);

  @internal
  @override
  UpsertMultiple<T, D> resolve(int obtainedTimeStamp, DataAccess dataAccess) {
    List<DoUpdate<T, D>> syncClauses = [];
    clauses.forEach((element) {
      syncClauses.add(element.resolve(obtainedTimeStamp, dataAccess));
    });
    return UpsertMultiple(syncClauses);
  }
}
