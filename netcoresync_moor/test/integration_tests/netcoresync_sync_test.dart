import 'dart:convert';

import 'package:test/test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'package:netcoresync_moor/src/sync_messages.dart';
import 'package:netcoresync_moor/src/sync_session.dart';
import 'dotnet_test_server.dart';
import '../data/database.dart';
import '../utils/helper.dart';

void main() {
  // TODO: Planned tests:
  // OK - Wrong Server url
  // OK - Wrong Server url's path (not upgraded to websocket)
  // OK - Client shutdown on active connection
  // OK - Server shutdown on active connection
  // OK - Server throws uncaught Exception
  // OK - Client throws uncaught Exception
  // OK - Handshake user's custom error (checking old schemaVersion)
  // - Server return error on concurrent SyncIdInfo and Client retries
  // - [TBD - Sync related]

  bool testPrint = true;
  void logTest(Object? object) {
    if (testPrint) {
      print("\x1B[1;93mTest:\x1B[0m " + object.toString());
    }
  }

  bool dotnetPrintStdout = true;
  String dotnetProjectRootDirectory = "../Samples/ServerTimeStamp/WebSample";
  String dotnetDllFileName = "WebSample.dll";
  String dotnetDllDirectory =
      "../Samples/ServerTimeStamp/WebSample/bin/Debug/net5.0";
  late String dotnetExecutablePath;

  String testFilesFolder = ".test_files";
  bool useInMemoryDatabase = true;
  bool logSqlStatements = false;

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
    String printPrefixAdditionalText = "[BASIC] ";

    void log(Object? object) {
      logTest(printPrefixAdditionalText + object.toString());
    }

    late DotnetTestServer dotnetTestServer;

    late Database database;
    String databaseFileName = "netcoresync_sync_test_basic.db";
    late String wsUrl;
    SyncEvent syncEvent = SyncEvent(
        progressEvent: (message, current, min, max) =>
            log("[PROGRESS] $message, current: $current, min: $min, "
                "max: $max"));
    TestCaptureLog? testCaptureLog;

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
        printPrefixAdditionalText: printPrefixAdditionalText,
      );
      bool started = await dotnetTestServer.start();
      expect(started, equals(true),
          reason: "Cannot launch DotNetTestServer. Check the print output.");
    });

    setUp(() async {
      database = await Helper.setUpDatabase(
        testFilesFolder: testFilesFolder,
        databaseFileName: databaseFileName,
        useInMemoryDatabase: useInMemoryDatabase,
        logSqlStatements: logSqlStatements,
      );
      await database.netCoreSyncInitialize();
      database.netCoreSyncSetLogger((object) {
        if (testCaptureLog != null && object != null) {
          testCaptureLog!.logs.add(object as Map<String, dynamic>);
        }
        log("[CLIENT] " + object.toString());
      });
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
      testCaptureLog = TestCaptureLog();
      final syncResult = await database.netCoreSyncSynchronize(
        url: "wss://non-existent-url-12345678.xyz",
        syncEvent: syncEvent,
      );
      expect(testCaptureLog!.logs.length, equals(2));
      expect(testCaptureLog!.logs[0]["connectRequested"], equals(true));
      expect(testCaptureLog!.logs[1]["connected"], equals(false));
      log("syncResult.errorMessage: ${syncResult.errorMessage}");
      expect(syncResult.error, isA<WebSocketChannelException>());
    });

    test("Connect to correct url but wrong path", () async {
      testCaptureLog = TestCaptureLog();
      final syncResult = await database.netCoreSyncSynchronize(
        url: wsUrl + "/nonexistentpath",
        syncEvent: syncEvent,
      );
      expect(testCaptureLog!.logs.length, equals(2));
      expect(testCaptureLog!.logs[0]["connectRequested"], equals(true));
      expect(testCaptureLog!.logs[1]["connected"], equals(false));
      log("syncResult.errorMessage: ${syncResult.errorMessage}");
      expect(syncResult.error, isA<WebSocketChannelException>());
    });

    test("Client tries launching multiple instances", () async {
      final syncSession = SyncSession(
        dataAccess: database.dataAccess,
        url: wsUrl,
        syncEvent: syncEvent,
      );
      final delayRequest = DelayRequestPayload(delayInMs: 3000);
      syncSession.request(payload: delayRequest);
      await expectLater(
        () async {
          await syncSession.request(payload: delayRequest);
        },
        throwsA(isA<NetCoreSyncException>()),
      );
    });

    test("Client throws Exception", () async {
      final syncSession = SyncSession(
        dataAccess: database.dataAccess,
        url: wsUrl,
        syncEvent: syncEvent,
      );
      final exceptionRequest = ExceptionRequestPayload(
        raiseOnRemote: false,
        errorMessage: "Client Throws Exception",
      );
      testCaptureLog = TestCaptureLog();
      try {
        await syncSession.request(payload: exceptionRequest);
      } catch (e) {
        expect(e.toString(), equals("Exception: Client Throws Exception"));
      }
      final filteredLogs = testCaptureLog!.logs
          .where((map) => map["connectionId"] == syncSession.connectionId)
          .toList();
      expect(filteredLogs.length, equals(3));
      expect(filteredLogs[0]["connectRequested"], equals(true));
      expect(filteredLogs[1]["connected"], equals(true));
      expect(filteredLogs[2]["connected"], equals(false));
      await Future.delayed(Duration(milliseconds: 1000));
      String serverLog = dotnetTestServer.logs.firstWhere(
          (w) => w.contains('"type":"RegistrationState","state":"Unregistered",'
              '"connectionId":"${syncSession.connectionId}"'),
          orElse: () => "");
      expect(serverLog, isNotEmpty);
    });

    test("Server throws Exception", () async {
      final syncSession = SyncSession(
        dataAccess: database.dataAccess,
        url: wsUrl,
        syncEvent: syncEvent,
      );
      final exceptionRequest = ExceptionRequestPayload(
        raiseOnRemote: true,
        errorMessage: "Server Throws Exception",
      );
      testCaptureLog = TestCaptureLog();
      final syncResult = await syncSession.request(payload: exceptionRequest);
      expect(syncResult.errorMessage,
          equals("Server is unresponsive by an unknown reason"));
      final filteredLogs = testCaptureLog!.logs
          .where((map) => map["connectionId"] == syncSession.connectionId)
          .toList();
      expect(filteredLogs.length, equals(3));
      expect(filteredLogs[0]["connectRequested"], equals(true));
      expect(filteredLogs[1]["connected"], equals(true));
      expect(filteredLogs[2]["connected"], equals(false));
      String serverLog = dotnetTestServer.logs.firstWhere(
          (w) => w.contains('"type":"RegistrationState","state":"Unregistered",'
              '"connectionId":"${syncSession.connectionId}"'),
          orElse: () => "");
      expect(serverLog, isNotEmpty);
    });
  });

  group("Manual Server Tests", () {
    String printPrefixAdditionalText = "[MANUAL-SERVER] ";

    void log(Object? object) {
      logTest(printPrefixAdditionalText + object.toString());
    }

    late DotnetTestServer dotnetTestServer;

    late Database database;
    String databaseFileName = "netcoresync_sync_test_manual_server.db";
    late String wsUrl;
    SyncEvent syncEvent = SyncEvent(
        progressEvent: (message, current, min, max) =>
            log("[PROGRESS] $message, current: $current, min: $min, "
                "max: $max"));
    TestCaptureLog? testCaptureLog;

    Future<void> startServer({List<String> args = const []}) async {
      int dotnetUrlPort = getDotnetUrlPort();
      String urls = "https://localhost:$dotnetUrlPort";
      wsUrl = "wss://localhost:$dotnetUrlPort/netcoresyncserver";

      dotnetTestServer = DotnetTestServer(
        dotnetExecutablePath: dotnetExecutablePath,
        dllFileName: dotnetDllFileName,
        dllDirectory: dotnetDllDirectory,
        aspNetCoreUrls: urls,
        printStdout: dotnetPrintStdout,
        printPrefixAdditionalText: printPrefixAdditionalText,
      );
      bool started = await dotnetTestServer.start(args: args);
      expect(started, equals(true),
          reason: "Cannot launch DotNetTestServer. Check the print output.");
    }

    setUp(() async {
      database = await Helper.setUpDatabase(
        testFilesFolder: testFilesFolder,
        databaseFileName: databaseFileName,
        useInMemoryDatabase: useInMemoryDatabase,
        logSqlStatements: logSqlStatements,
      );
      await database.netCoreSyncInitialize();
      database.netCoreSyncSetLogger((object) {
        if (testCaptureLog != null && object != null) {
          testCaptureLog!.logs.add(object as Map<String, dynamic>);
        }
        log("[CLIENT] " + object.toString());
      });
      database.netCoreSyncSetSyncIdInfo(SyncIdInfo(
        syncId: "abc",
      ));
    });

    tearDown(() async {
      await Helper.tearDownDatabase(database);
    });

    Future<void> stopServer() async {
      await dotnetTestServer.stop();
    }

    test("Client disconnect on active request", () async {
      // This test generates interesting server info, the same as the test:
      // "Server disconnect while Client connected" in this group. Read more
      // about it there.
      await startServer();
      try {
        final syncSession = SyncSession(
          dataAccess: database.dataAccess,
          url: wsUrl,
          syncEvent: syncEvent,
        );
        final delayRequest = DelayRequestPayload(delayInMs: 5000);
        testCaptureLog = TestCaptureLog();
        final futureSyncResult = syncSession.request(payload: delayRequest);

        await Future.delayed(Duration(milliseconds: 1000));
        await syncSession.disconnect();

        final syncResult = await futureSyncResult;
        expect(testCaptureLog!.logs.length, equals(3));
        expect(testCaptureLog!.logs[0]["connectRequested"], equals(true));
        expect(testCaptureLog!.logs[1]["connected"], equals(true));
        expect(testCaptureLog!.logs[2]["connected"], equals(false));
        log("syncResult.errorMessage: ${syncResult.errorMessage}");
        expect(syncResult.errorMessage,
            equals("Server is unresponsive by an unknown reason"));

        await Future.delayed(Duration(milliseconds: 8000));
        expect(jsonDecode(dotnetTestServer.logs.last)["activeConnections"],
            equals(0));
      } catch (e) {
        rethrow;
      } finally {
        await stopServer();
      }
    });

    test("Server disconnect while Client connected", () async {
      // While await stopServer(), this test generates interesting server's
      // info:
      // "Waiting for the host to be disposed. Ensure all 'IHost' instances are
      // wrapped in 'using' blocks."
      // Ref: https://github.com/aspnetboilerplate/aspnetboilerplate/issues/5367
      // We can consider this is fine for now, as there are no dangling / left-
      // over dotnet processes after the test has finished. Probably this is
      // caused by waiting for a thread is still running on the server's
      // middleware handler to finished.
      await startServer();
      try {
        final syncSession = SyncSession(
          dataAccess: database.dataAccess,
          url: wsUrl,
          syncEvent: syncEvent,
        );
        // long delay seconds (i.e. 10 seconds as below) is required to ensure
        // server does not have time to respond back to client
        final delayRequest = DelayRequestPayload(delayInMs: 10000);
        testCaptureLog = TestCaptureLog();
        final futureSyncResult = syncSession.request(payload: delayRequest);

        await Future.delayed(Duration(milliseconds: 1000));
        await stopServer();

        final syncResult = await futureSyncResult;
        expect(testCaptureLog!.logs.length, equals(3));
        expect(testCaptureLog!.logs[0]["connectRequested"], equals(true));
        expect(testCaptureLog!.logs[1]["connected"], equals(true));
        expect(testCaptureLog!.logs[2]["connected"], equals(false));
        log("syncResult.errorMessage: ${syncResult.errorMessage}");
        expect(syncResult.errorMessage,
            equals("Server is unresponsive by an unknown reason"));
      } catch (e) {
        rethrow;
      } finally {
        // Stop the server (this is re-entrant and safe) just in case
        // exceptions happens
        await stopServer();
      }
    });

    test("Custom Server OnHandshake check", () async {
      await startServer(
        args: [
          "minimumSchemaVersion=100",
        ],
      );
      try {
        final syncResult = await database.netCoreSyncSynchronize(
          url: wsUrl,
          syncEvent: syncEvent,
        );
        expect(
            syncResult.errorMessage,
            equals("Please update your application first before performing "
                "synchronization"));
        await Future.delayed(Duration(milliseconds: 1000));
        expect(jsonDecode(dotnetTestServer.logs.last)["activeConnections"],
            equals(0));
      } catch (e) {
        rethrow;
      } finally {
        await stopServer();
      }
    });

    test("Multi users try to sync with overlapped syncIdInfo", () async {
      await startServer();
      try {
        // TODO: Server's SyncMiddleware.RegisterConnection is the perfect place
        // to check this, but the easiest way to validate there is throwing
        // Exception, but, doing this will make the connectionId registration
        // in server becomes unstable, and it may be difficult to follow the
        // proven-safe way to disconnect from handshale, like implemented in
        // the custom OnHandshake, where we let the handshake successful +
        // connected first, and then returns the errorMessage, so the handshake
        // can safely disconnect.
      } catch (e) {
        rethrow;
      } finally {
        await stopServer();
      }
    });
  });
}

class TestCaptureLog {
  List<Map<String, dynamic>> logs = [];
}
