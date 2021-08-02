import 'package:test/test.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'data/database.dart';
import 'utils/helper.dart';

void main() async {
  String testFilesFolder = ".test_files";
  String databaseFileName = "netcoresync_moor_test.db";
  bool useInMemoryDatabase = true;
  bool logSqlStatements = false;

  group("Synchronization Tests", () {
    late Database database;

    setUp(() async {
      database = await Helper.setUpDatabase(
        testFilesFolder: testFilesFolder,
        databaseFileName: databaseFileName,
        useInMemoryDatabase: useInMemoryDatabase,
        logSqlStatements: logSqlStatements,
      );
      await database.netCoreSyncInitialize();
    });

    tearDown(() async {
      await Helper.tearDownDatabase(database);
    });

    test("Test Concepts", () async {
      database.netCoreSyncSetSyncIdInfo(SyncIdInfo(
        syncId: "abc",
      ));

      final syncEvent = SyncEvent(
        progressEvent: (message, current, min, max) =>
            print("Progress message: $message, current: $current, min: $min, "
                "max: $max"),
      );

      final syncResult = await database.netCoreSyncSynchronize(
        url: "wss://localhost:5001/netcoresyncserver",
        syncEvent: syncEvent,
      );

      print("errorMessage: ${syncResult.errorMessage}");
    });
  });
}
