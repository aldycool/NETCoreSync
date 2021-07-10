import 'package:moor/moor.dart';
import 'netcoresync_exceptions.dart';
import 'database.dart';

class NetCoreSyncClient {
  static Future<NetCoreSyncClient> initialize({
    required GeneratedDatabase generatedDatabase,
  }) async {
    bool isOpened =
        await generatedDatabase.executor.ensureOpen(generatedDatabase);
    if (!isOpened) throw NetCoreSyncUnableToOpenDatabaseException();
    return NetCoreSyncClient._(generatedDatabase: generatedDatabase);
  }

  late final Database _database;

  NetCoreSyncClient._({required GeneratedDatabase generatedDatabase}) {
    _database = Database(
      queryExecutor: generatedDatabase.executor,
      schemaVersion: generatedDatabase.schemaVersion,
    );
  }
}
