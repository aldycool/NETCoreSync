import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'netcoresync_exceptions.dart';
import 'netcoresync_engine.dart';
import 'data_access.dart';

mixin NetCoreSyncClient on GeneratedDatabase {
  @internal
  static NetCoreSyncClient? instance;

  @internal
  late DataAccess dataAccess;

  Future<void> netCoreSync_initializeImpl(
    NetCoreSyncEngine engine,
  ) async {
    dataAccess = DataAccess(this, engine);
    instance = this;
  }

  static bool get initialized => instance != null;

  @internal
  static void throwIfNotInitialized() {
    if (!initialized) throw NetCoreSyncNotInitializedException();
  }
}
