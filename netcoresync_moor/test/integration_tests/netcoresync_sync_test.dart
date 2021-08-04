import 'package:test/test.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dotnet_test_server.dart';
import '../data/database.dart';
import '../utils/helper.dart';

void main() {
  // TODO: Planned tests:
  // OK - Wrong Server url
  // OK - Wrong Server url's path (not upgraded to websocket)
  // - Server shutdown on active connection
  // - Client shutdown on active connection
  // - Perform actions without connect first
  // - Perform connect more than once
  // - Client launches multiple instances (Server: Connection still active)
  // - Server throws uncaught Exceptions
  // - Client throws uncaught Exception on session (without operations)
  // - Client throws uncaught Exception during operations
  // - Handshake user's custom error (checking old schemaVersion)
  // - Operation return error messages
  // - Server return error on concurrent SyncIdInfo and Client retries
  // - [TBD]

  bool dotnetPrintStdout = true;
  String dotnetProjectRootDirectory = "../Samples/ServerTimeStamp/WebSample";
  String dotnetDllFileName = "WebSample.dll";
  String dotnetDllDirectory =
      "../Samples/ServerTimeStamp/WebSample/bin/Debug/net5.0";
  late String dotnetExecutablePath;

  // Client related variables
  String testFilesFolder = ".test_files";
  bool useInMemoryDatabase = true;
  bool logSqlStatements = false;

  // Test helpers
  bool testPrint = true;
  void log(Object? object) {
    if (testPrint) {
      print(object);
    }
  }

  // For obtaining unique dotnet server port (avoid port reuse)
  int currentPort = 5000;
  int getDotnetUrlPort() => ++currentPort;

  setUpAll(() async {
    String? dotnetPathResult = await DotnetTestServer.getDotnetExecutablePath();
    expect(dotnetPathResult, isNot(equals(null)),
        reason: "dotnet may not be installed yet");
    dotnetExecutablePath = dotnetPathResult!;

    bool buildResult = await DotnetTestServer.build(
      dotnetExecutablePath: dotnetExecutablePath,
      projectRootDirectory: dotnetProjectRootDirectory,
      printStdout: dotnetPrintStdout,
    );
    expect(buildResult, equals(true),
        reason: "dotnet build has failed, check the print output.");
  });

  group("Basic Tests", () {
    late DotnetTestServer dotnetTestServer;
    late SyncEvent syncEvent;

    // Client related variables
    late Database database;
    String databaseFileName = "netcoresync_sync_test_main.db";
    late String wsUrl;

    setUpAll(() async {
      int dotnetUrlPort = getDotnetUrlPort();
      String urls = "https://localhost:$dotnetUrlPort";
      wsUrl = "wss://localhost:$dotnetUrlPort/netcoresyncserver";

      dotnetTestServer = DotnetTestServer(
        dotnetExecutablePath: dotnetExecutablePath,
        dllFileName: dotnetDllFileName,
        dllDirectory: dotnetDllDirectory,
        aspNetCoreUrls: urls,
        printStdout: dotnetPrintStdout,
        printPrefixAdditionalText: "[MAIN] ",
      );
      bool started = await dotnetTestServer.start();
      expect(started, equals(true),
          reason: "Cannot launch DotNetTestServer. Check the print output.");

      syncEvent = SyncEvent(
        progressEvent: (message, current, min, max) =>
            log("Progress message: $message, current: $current, min: $min, "
                "max: $max"),
      );
    });

    setUp(() async {
      database = await Helper.setUpDatabase(
        testFilesFolder: testFilesFolder,
        databaseFileName: databaseFileName,
        useInMemoryDatabase: useInMemoryDatabase,
        logSqlStatements: logSqlStatements,
      );
      await database.netCoreSyncInitialize();
      database.netCoreSyncSetSyncIdInfo(SyncIdInfo(
        syncId: "abc",
      ));
    });

    tearDown(() async {
      await Helper.tearDownDatabase(database);
    });

    tearDownAll(() async {
      await dotnetTestServer.stop();
    });

    test("Connect to wrong url", () async {
      SyncResult syncResult = await database.netCoreSyncSynchronize(
        url: "wss://non-existent-url-12345678.xyz",
        syncEvent: syncEvent,
      );
      log("errorMessage: ${syncResult.errorMessage}");
      expect(syncResult.error, isA<WebSocketChannelException>());
    });

    test("Connect to correct url but wrong path", () async {
      SyncResult syncResult = await database.netCoreSyncSynchronize(
        url: wsUrl + "/nonexistentpath",
        syncEvent: syncEvent,
      );
      log("errorMessage: ${syncResult.errorMessage}");
      expect(syncResult.error, isA<WebSocketChannelException>());
    });

    // test("Test Concepts", () async {
    //   final syncEvent = SyncEvent(
    //     progressEvent: (message, current, min, max) =>
    //         print("Progress message: $message, current: $current, min: $min, "
    //             "max: $max"),
    //   );
    //   final captureId = dotnetTestServer.startCaptureOutput(
    //     waitIdleInMs: 500,
    //     onlyWithRegex: "\\[LOREM-IPSUM\\]",
    //   );
    //   var syncResult = await database.netCoreSyncSynchronize(
    //     url: wsUrl,
    //     syncEvent: syncEvent,
    //   );
    //   List<String>? captureResult =
    //       await dotnetTestServer.stopCaptureOutput(captureId);
    //   print("capturedLines Count: ${captureResult?.length ?? "null"}");
    //   if (captureResult != null) {
    //     for (var i = 0; i < captureResult.length; i++) {
    //       print(
    //           "LINE #${i + 1} OF #${captureResult.length}: ${captureResult[i]}");
    //     }
    //   }
    //   print("errorMessage: ${syncResult.errorMessage}");
    // });
  });
}
