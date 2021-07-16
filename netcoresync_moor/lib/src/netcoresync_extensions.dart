import 'package:moor/moor.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'netcoresync_client.dart';
import 'data_access.dart';

extension NetCoreSyncInsertStatementExtension<T extends Table, D>
    on InsertStatement<T, D> {
  static DataAccess dataAccess = NetCoreSyncClient.instance.dataAccess;

  Future<int> syncInsert(
    Insertable<D> entity, {
    InsertMode? mode,
    SyncUpsertClause<T, D>? onConflict,
  }) async {
    return _syncActionInsert(
      entity,
      mode: mode,
      onConflict: onConflict,
      implementation: (
        syncEntity,
        _mode,
        _onConflict,
      ) =>
          insert(
        syncEntity,
        mode: _mode,
        onConflict: _onConflict,
      ),
    );
  }

  Future<D> syncInsertReturning(Insertable<D> entity,
      {InsertMode? mode, SyncUpsertClause<T, D>? onConflict}) async {
    return _syncActionInsert(
      entity,
      mode: mode,
      onConflict: onConflict,
      implementation: (
        syncEntity,
        _mode,
        _onConflict,
      ) =>
          insertReturning(
        syncEntity,
        mode: _mode,
        onConflict: _onConflict,
      ),
    );
  }

  Future<int> syncInsertOnConflictUpdate(Insertable<D> entity) async {
    return _syncActionInsert(
      entity,
      implementation: (
        syncEntity,
        _,
        __,
      ) =>
          insertOnConflictUpdate(
        syncEntity,
      ),
    );
  }

  Future<V> _syncActionInsert<V>(
    Insertable<D> entity, {
    InsertMode? mode,
    SyncUpsertClause<T, D>? onConflict,
    required Future<V> Function(
      Insertable<D> syncEntity,
      InsertMode? mode,
      UpsertClause<T, D>? onConflict,
    )
        implementation,
  }) async {
    if (mode != null &&
        (mode == InsertMode.replace || mode == InsertMode.insertOrReplace))
      throw NetCoreSyncException(
          "Unsupported mode: $mode. This mode is disabled because it may physically delete an existing already-synchronized row.");

    NetCoreSyncClient.throwIfNotInitialized();

    return dataAccess.syncAction(
      entity,
      (syncEntity, obtainedTimeStamp) => implementation(
        syncEntity,
        mode,
        onConflict?.resolve(obtainedTimeStamp, dataAccess),
      ),
    );
  }
}

abstract class SyncUpsertClause<T extends Table, D> {
  UpsertClause<T, D> resolve(int obtainedTimeStamp, DataAccess dataAccess);
}

class SyncDoUpdate<T extends Table, D> extends SyncUpsertClause<T, D> {
  final Insertable<D> Function(T old) _creator;
  final List<Column>? target;

  SyncDoUpdate(Insertable<D> Function(T old) update, {this.target})
      : _creator = update;

  @override
  DoUpdate<T, D> resolve(int obtainedTimeStamp, DataAccess dataAccess) {
    Insertable<D> Function(T old) wrap = (old) {
      Insertable<D> result = _creator(old);
      if (!dataAccess.tables.containsKey(D))
        throw NetCoreSyncException(
            "The type: ${D} is not registered correctly in NetCoreSync. Please check your @NetCoreSyncTable annotation on its Table class.");
      if ((result as RawValuesInsertable<D>)
          .data
          .containsKey(dataAccess.tables[D]!.tableAnnotation.idFieldName))
        throw NetCoreSyncException(
            "Changing the 'id' (as primary key) value is prohibited. This error is raised because your 'DoUpdate' contains actions that have altered your 'id' field: ${dataAccess.tables[D]!.tableAnnotation.idFieldName}");
      Insertable<D> syncResult = NetCoreSyncClient.instance.dataAccess.engine
          .updateSyncColumns(result, timeStamp: obtainedTimeStamp);
      return syncResult;
    };
    return DoUpdate(wrap, target: target);
  }
}

class SyncUpsertMultiple<T extends Table, D> extends SyncUpsertClause<T, D> {
  final List<SyncDoUpdate<T, D>> clauses;

  SyncUpsertMultiple(this.clauses);

  @override
  UpsertMultiple<T, D> resolve(int obtainedTimeStamp, DataAccess dataAccess) {
    List<DoUpdate<T, D>> syncClauses = [];
    clauses.forEach((element) {
      syncClauses.add(element.resolve(obtainedTimeStamp, dataAccess));
    });
    return UpsertMultiple(syncClauses);
  }
}
