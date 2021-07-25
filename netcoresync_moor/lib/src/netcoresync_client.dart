import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'netcoresync_exceptions.dart';
import 'netcoresync_engine.dart';
import 'data_access.dart';
import 'client_select.dart';
import 'client_insert.dart';
import 'client_update.dart';
import 'client_delete.dart';
import 'sync_handler.dart';

enum SynchronizeDirection {
  pushThenPull,
  pullThenPush,
}

mixin NetCoreSyncClient on GeneratedDatabase {
  DataAccess? _dataAccess;

  bool get initialized => _dataAccess != null;

  @internal
  DataAccess get dataAccess {
    if (_dataAccess == null) throw NetCoreSyncNotInitializedException();
    return _dataAccess!;
  }

  Future<void> netCoreSyncInitializeClient(
    NetCoreSyncEngine engine,
  ) async {
    _dataAccess = DataAccess(
      this,
      engine,
    );
  }

  dynamic get resolvedEngine => dataAccess.resolvedEngine;

  Future<void> netCoreSyncSynchronize({
    required String synchronizationId,
    required String url,
    SynchronizeDirection synchronizeDirection =
        SynchronizeDirection.pushThenPull,
    Map<String, dynamic> customInfo = const {},
  }) async {
    final syncHandler = SyncHandler(dataAccess);
    await syncHandler.synchronize(
      synchronizationId: synchronizationId,
      url: url,
      synchronizeDirection: synchronizeDirection,
      customInfo: customInfo,
    );
  }

  SyncSimpleSelectStatement<T, R> syncSelect<T extends HasResultSet, R>(
    ResultSetImplementation<T, R> table, {
    bool distinct = false,
  }) =>
      SyncSimpleSelectStatement(
        dataAccess,
        table,
        distinct: distinct,
      );

  SyncJoinedSelectStatement<T, R> syncSelectOnly<T extends HasResultSet, R>(
    ResultSetImplementation<T, R> table, {
    bool distinct = false,
  }) =>
      SyncJoinedSelectStatement<T, R>(
        dataAccess,
        table,
        [],
        distinct,
        false,
      );

  SyncInsertStatement<T, D> syncInto<T extends Table, D>(
    TableInfo<T, D> table,
  ) =>
      SyncInsertStatement<T, D>(
        dataAccess,
        table,
      );

  SyncUpdateStatement<T, D> syncUpdate<T extends Table, D>(
    TableInfo<T, D> table,
  ) =>
      SyncUpdateStatement<T, D>(
        dataAccess,
        table,
      );

  SyncDeleteStatement<T, D> syncDelete<T extends Table, D>(
    TableInfo<T, D> table,
  ) =>
      SyncDeleteStatement<T, D>(
        dataAccess,
        table,
      );
}
