import 'package:moor/moor.dart';
import 'netcoresync_client.dart';
import 'data_access.dart';
import 'netcoresync_exceptions.dart';

extension NetCoreSyncInsertStatementExtension<T extends Table, D>
    on InsertStatement<T, D> {
  Future<int> syncInsert(
    Insertable<D> entity, {
    InsertMode? mode,
    UpsertClause<T, D>? onConflict,
  }) async {
    NetCoreSyncClient.throwIfNotInitialized();
    DataAccess dataAccess = NetCoreSyncClient.instance.dataAccess;
    if (!dataAccess.inTransaction())
      throw NetCoreSyncMustInsideTransactionException();
    int timeStamp = await dataAccess.getNextTimeStamp();
    final syncEntity =
        dataAccess.engine.updateSyncColumns(entity, timeStamp: timeStamp);
    int result = await insert(syncEntity, mode: mode, onConflict: onConflict);
    return result;
  }
}
