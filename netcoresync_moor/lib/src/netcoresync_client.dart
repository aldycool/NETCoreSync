import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'netcoresync_exceptions.dart';
import 'netcoresync_engine.dart';
import 'data_access.dart';
import 'client_select.dart';
import 'client_insert.dart';
import 'client_update.dart';
import 'client_delete.dart';

mixin NetCoreSyncClient on GeneratedDatabase {
  DataAccess? _dataAccess = null;

  bool get initialized => _dataAccess != null;

  @internal
  DataAccess get dataAccess {
    if (_dataAccess == null) throw NetCoreSyncNotInitializedException();
    return _dataAccess!;
  }

  Future<void> netCoreSync_initializeImpl(
    NetCoreSyncEngine engine,
  ) async {
    _dataAccess = DataAccess(this, engine);
  }

  SyncResultSetImplementation<T, R> syncTable<T extends HasResultSet, R>(
          ResultSetImplementation<T, R> table) =>
      SyncResultSetImplementation(dataAccess, table);

  SyncInsertStatement<T, D> syncInto<T extends Table, D>(
          TableInfo<T, D> table) =>
      SyncInsertStatement<T, D>(dataAccess, table);

  SyncUpdateStatement<T, D> syncUpdate<T extends Table, D>(
          TableInfo<T, D> table) =>
      SyncUpdateStatement<T, D>(dataAccess, table);

  SyncDeleteStatement<T, D> syncDelete<T extends Table, D>(
          TableInfo<T, D> table) =>
      SyncDeleteStatement<T, D>(dataAccess, table);
}
