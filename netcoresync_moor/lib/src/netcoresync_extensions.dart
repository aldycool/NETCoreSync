import 'package:moor/moor.dart';
import 'netcoresync_client.dart';

extension NetCoreSyncInsertStatementExtension<T extends Table, D>
    on InsertStatement<T, D> {
  Future<int> syncInsert(
    Insertable<D> entity, {
    InsertMode? mode,
    UpsertClause<T, D>? onConflict,
  }) async {
    NetCoreSyncClient.throwIfNotInitialized();
    return NetCoreSyncClient.instance.dataAccess.syncAction(
      entity,
      (syncEntity) => insert(
        syncEntity,
        mode: mode,
        onConflict: onConflict,
      ),
    );
  }

  Future<int> syncInsertOnConflictUpdate(Insertable<D> entity) async {
    NetCoreSyncClient.throwIfNotInitialized();
    return NetCoreSyncClient.instance.dataAccess.syncAction(
      entity,
      (syncEntity) => insertOnConflictUpdate(
        syncEntity,
      ),
    );
  }

  Future<D> syncInsertReturning(Insertable<D> entity,
      {InsertMode? mode, UpsertClause<T, D>? onConflict}) async {
    NetCoreSyncClient.throwIfNotInitialized();
    return NetCoreSyncClient.instance.dataAccess.syncAction(
      entity,
      (syncEntity) => insertReturning(
        syncEntity,
        mode: mode,
        onConflict: onConflict,
      ),
    );
  }
}
