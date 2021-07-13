import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'netcoresync_exceptions.dart';
import 'netcoresync_engine.dart';
import 'data_access.dart';

mixin NetCoreSyncClient on GeneratedDatabase {
  static bool _initialized = false;
  static late NetCoreSyncClient instance;

  @internal
  late DataAccess dataAccess;

  Future<void> netCoreSync_initializeImpl(NetCoreSyncEngine engine) async {
    if (_initialized)
      throw NetCoreSyncException("Client is already initialized");
    dataAccess = DataAccess(this, engine);
    instance = this;
    _initialized = true;
  }

  @internal
  static void throwIfNotInitialized() {
    if (!_initialized)
      throw NetCoreSyncException("Client is not initialized yet");
  }
}
