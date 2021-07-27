import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'netcoresync_exceptions.dart';
import 'data_access.dart';

class SyncIdInfo {
  late String syncId;
  late List<String> linkedSyncIds;

  SyncIdInfo({required this.syncId, this.linkedSyncIds = const []});

  String get allSyncIds {
    StringBuffer buffer = StringBuffer();
    buffer.write("'$syncId'");
    for (var i = 0; i < linkedSyncIds.length; i++) {
      buffer.write(", '${linkedSyncIds[i]}'");
    }
    return buffer.toString();
  }
}

abstract class SyncBaseTable {
  Type get type;
}

@sealed
abstract class SyncUpsertClause<T extends Table, D> {
  UpsertClause<T, D> resolve(DataAccess dataAccess, String obtainedKnowledgeId);
}

class SyncDoUpdate<T extends Table, D> extends SyncUpsertClause<T, D> {
  final Insertable<D> Function(T old) _creator;
  final List<Column>? target;

  SyncDoUpdate(Insertable<D> Function(T old) update, {this.target})
      : _creator = update;

  @internal
  @override
  DoUpdate<T, D> resolve(DataAccess dataAccess, String obtainedKnowledgeId) {
    return DoUpdate(
      (T old) {
        Insertable<D> result = _creator(old);
        if (!dataAccess.engine.tables.containsKey(D)) {
          throw NetCoreSyncTypeNotRegisteredException(D);
        }
        if ((result as RawValuesInsertable<D>).data.containsKey(
            dataAccess.engine.tables[D]!.tableAnnotation.idFieldName)) {
          throw NetCoreSyncException(
              "Changing the 'id' (as primary key) value is prohibited. This error is raised because your 'DoUpdate' contains actions that have altered your 'id' field: ${dataAccess.engine.tables[D]!.tableAnnotation.idFieldName}");
        }
        Insertable<D> syncResult = dataAccess.engine.updateSyncColumns(
          result,
          synced: false,
          syncId: dataAccess.activeSyncId,
          knowledgeId: obtainedKnowledgeId,
        );
        return syncResult;
      },
      target: target,
    );
  }
}

class SyncUpsertMultiple<T extends Table, D> extends SyncUpsertClause<T, D> {
  final List<SyncDoUpdate<T, D>> clauses;

  SyncUpsertMultiple(this.clauses);

  @internal
  @override
  UpsertMultiple<T, D> resolve(
      DataAccess dataAccess, String obtainedKnowledgeId) {
    List<DoUpdate<T, D>> syncClauses = [];
    for (var element in clauses) {
      syncClauses.add(element.resolve(dataAccess, obtainedKnowledgeId));
    }
    return UpsertMultiple(syncClauses);
  }
}
