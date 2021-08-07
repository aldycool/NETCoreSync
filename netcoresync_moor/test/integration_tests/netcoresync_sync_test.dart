import 'dart:async';
import 'dart:convert';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'package:test/test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:netcoresync_moor/src/netcoresync_classes.dart';
import 'package:netcoresync_moor/src/sync_messages.dart';
import 'package:netcoresync_moor/src/sync_socket.dart';
import '../utils/net_core_test_server.dart';
import '../data/database.dart';
import '../utils/helper.dart';

void main() {
  // TODO: Unimplemented tests:
  // SyncSession: Server return error on concurrent SyncIdInfo and Client retries
  // - [TBD - SyncSession related-tests]

  bool testPrint = true;
  void logTest(Object? object) {
    if (testPrint) {
      print("\x1B[1;93mTest:\x1B[0m " + object.toString());
    }
  }

  bool netCorePrintStdout = true;
  String netCoreProjectRootDirectory = "../Samples/ServerTimeStamp/WebSample";
  String netCoreDllFileName = "WebSample.dll";
  String netCoreDllDirectory =
      "../Samples/ServerTimeStamp/WebSample/bin/Debug/net5.0";
  late String dotnetExecutablePath;

  String testFilesFolder = ".test_files";
  bool useInMemoryDatabase = true;
  bool logSqlStatements = false;

  // For obtaining unique .NET Core server port (to avoid port already used)
  int currentPort = 5000;
  int getNetCoreUrlPort() => ++currentPort;

  setUpAll(() async {
    String? dotnetPathResult =
        await NetCoreTestServer.getDotnetExecutablePath();
    expect(dotnetPathResult, isNot(equals(null)),
        reason: "dotnet may not be installed yet");
    dotnetExecutablePath = dotnetPathResult!;

    bool buildResult = await NetCoreTestServer.build(
      dotnetExecutablePath: dotnetExecutablePath,
      projectRootDirectory: netCoreProjectRootDirectory,
      printStdout: netCorePrintStdout,
    );
    expect(buildResult, equals(true),
        reason: "dotnet build has failed, check the print output.");
  });

  group("Auto Server with SyncSocket Tests", () {
    String printPrefixAdditionalText = "[AUTO] ";

    void log(Object? object) {
      logTest(printPrefixAdditionalText + object.toString());
    }

    late NetCoreTestServer netCoreTestServer;

    late Database database;
    String databaseFileName = "netcoresync_sync_test_auto.db";
    late String wsUrl;
    TestCaptureLog? groupCaptureLog;
    void logClient(Object? object, TestCaptureLog? captureLog) {
      if (captureLog != null && object != null) {
        captureLog.logs.add(object as Map<String, dynamic>);
      }
      log("[CLIENT] " + object.toString());
    }

    setUpAll(() async {
      int netCoreUrlPort = getNetCoreUrlPort();
      String urls = "https://localhost:$netCoreUrlPort";
      wsUrl = "wss://localhost:$netCoreUrlPort/netcoresyncserver";

      netCoreTestServer = NetCoreTestServer(
        dotnetExecutablePath: dotnetExecutablePath,
        dllFileName: netCoreDllFileName,
        dllDirectory: netCoreDllDirectory,
        aspNetCoreUrls: urls,
        printStdout: netCorePrintStdout,
        printPrefixAdditionalText: printPrefixAdditionalText,
      );
      bool started = await netCoreTestServer.start();
      expect(started, equals(true),
          reason: "Cannot launch NetCoreTestServer. Check the print output.");
    });

    setUp(() async {
      database = await Helper.setUpDatabase(
        testFilesFolder: testFilesFolder,
        databaseFileName: databaseFileName,
        useInMemoryDatabase: useInMemoryDatabase,
        logSqlStatements: logSqlStatements,
      );
      await database.netCoreSyncInitialize();
      database.netCoreSyncSetLogger(
        (object) => logClient(
          object,
          groupCaptureLog,
        ),
      );
      database.netCoreSyncSetSyncIdInfo(SyncIdInfo(
        syncId: "abc",
      ));
    });

    tearDown(() async {
      await Helper.tearDownDatabase(database);
    });

    tearDownAll(() async {
      await netCoreTestServer.stop();
    });

    test("SyncSocket requests without connect", () async {
      SyncSocket syncSocket = SyncSocket(
        url: wsUrl,
      );
      expect(
        () => syncSocket.request(payload: CommandRequestPayload(data: {})),
        throwsA(predicate((e) =>
            e is NetCoreSyncSocketException &&
            e.message
                .endsWith(SyncSocket.defaultErrorMessageSocketNotConnected))),
      );
    });

    test("SyncSocket connects twice in a row", () async {
      SyncSocket syncSocket = SyncSocket(
        url: wsUrl,
      );
      expect(
        () {
          syncSocket.connect();
          syncSocket.connect();
        },
        throwsA(predicate((e) =>
            e is NetCoreSyncSocketException &&
            e.message.endsWith(
                SyncSocket.defaultErrorMessageStillWaitingConnection))),
      );
    });

    test("SyncSocket connected and connect again", () async {
      SyncSocket syncSocket = SyncSocket(
        url: wsUrl,
        logger: (object) => logClient(object, null),
      );
      await syncSocket.connect();
      try {
        await syncSocket.connect();
      } catch (e) {
        expect(
          e,
          predicate(
            (e) =>
                e is NetCoreSyncSocketException &&
                e.message.endsWith(
                    SyncSocket.defaultErrorMessageSocketAlreadyConnected),
          ),
        );
      }
    });

    test("SyncSocket connects to wrong url", () async {
      TestCaptureLog captureLog = TestCaptureLog();
      SyncSocket syncSocket = SyncSocket(
        url: "wss://nonexistenturl123456.com",
        logger: (object) => logClient(object, captureLog),
      );
      final connectResult = await syncSocket.connect();
      await pumpEventQueue();
      expect(connectResult.error, isA<WebSocketChannelException>());
      expect(connectResult.errorMessage,
          equals(ConnectResult.defaultErrorMessage));
      expect(captureLog.logs.last["type"], equals("ConnectionState"));
      expect(captureLog.logs.last["state"], equals("Closed"));
    });

    test("SyncSocket connected but with wrong path", () async {
      TestCaptureLog captureLog = TestCaptureLog();
      SyncSocket syncSocket = SyncSocket(
        url: wsUrl + "/nonexistentpath",
        logger: (object) => logClient(object, captureLog),
      );
      final connectResult = await syncSocket.connect();
      await pumpEventQueue();
      expect(connectResult.error, isA<WebSocketChannelException>());
      expect(connectResult.errorMessage,
          equals(ConnectResult.defaultErrorMessage));
      expect(captureLog.logs.last["type"], equals("ConnectionState"));
      expect(captureLog.logs.last["state"], equals("Closed"));
    });

    test("SyncSocket connected and close normally", () async {
      TestCaptureLog captureLog = TestCaptureLog();
      SyncSocket syncSocket = SyncSocket(
        url: wsUrl,
        logger: (object) => logClient(object, captureLog),
      );
      final connectResult = await syncSocket.connect();
      String captureId = netCoreTestServer.startCaptureOutput(
        waitIdleInMs: 500,
        onlyWithRegex: '"connectionId":"${connectResult.connectionId!}"',
      );
      await syncSocket.close();
      await pumpEventQueue();
      final serverLogs = await netCoreTestServer.stopCaptureOutput(captureId);
      expect(connectResult.error, isNull);
      expect(connectResult.errorMessage, isNull);
      expect(captureLog.logs.last["type"], equals("ConnectionState"));
      expect(captureLog.logs.last["state"], equals("Closed"));
      final lastServerLog = jsonDecode(serverLogs!.last);
      expect(lastServerLog["type"], equals("ConnectionState"));
      expect(lastServerLog["state"], equals("Closed"));
    });

    test("SyncSocket safe and re-entrant close", () async {
      TestCaptureLog captureLog = TestCaptureLog();
      SyncSocket syncSocket = SyncSocket(
        url: wsUrl,
        logger: (object) => logClient(object, captureLog),
      );
      await syncSocket.close();
      await syncSocket.close();
      final connectResult = await syncSocket.connect();
      String captureId = netCoreTestServer.startCaptureOutput(
        waitIdleInMs: 500,
        onlyWithRegex: '"connectionId":"${connectResult.connectionId!}"',
      );
      await syncSocket.close();
      await syncSocket.close();
      await pumpEventQueue();
      final serverLogs = await netCoreTestServer.stopCaptureOutput(captureId);
      expect(captureLog.logs.last["type"], equals("ConnectionState"));
      expect(captureLog.logs.last["state"], equals("Closed"));
      final lastServerLog = jsonDecode(serverLogs!.last);
      expect(lastServerLog["type"], equals("ConnectionState"));
      expect(lastServerLog["state"], equals("Closed"));
    });

    test("SyncSocket close while connected", () async {
      TestCaptureLog captureLog = TestCaptureLog();
      SyncSocket syncSocket = SyncSocket(
        url: wsUrl,
        logger: (object) => logClient(object, captureLog),
      );
      final connectResult = await syncSocket.connect();
      String captureId = netCoreTestServer.startCaptureOutput(
        waitIdleInMs: 500,
        onlyWithRegex: '"connectionId":"${connectResult.connectionId!}"',
      );
      syncSocket.request(
          payload: CommandRequestPayload(data: {
        "commandName": "delay",
        "delayInMs": 10000,
      }));
      final serverLogs = await netCoreTestServer.stopCaptureOutput(captureId);
      final lastServerLog = jsonDecode(serverLogs!.last);
      expect(lastServerLog["type"], equals("RequestState"));
      expect(lastServerLog["action"], equals("commandRequest"));
      expect(lastServerLog["state"], equals("Started"));
      await syncSocket.close();
      expect(captureLog.logs.last["type"], equals("ConnectionState"));
      expect(captureLog.logs.last["state"], equals("Closed"));
    });

    test("Server throws error while SyncSocket connected", () async {
      // The reverse (SyncSocket throws error) is not necessary to be tested,
      // It is the responsiblity of the caller to wrap with try. This is by-
      // design, to be identical with the error handling of ConnectResult.
      TestCaptureLog captureLog = TestCaptureLog();
      SyncSocket syncSocket = SyncSocket(
        url: wsUrl,
        logger: (object) => logClient(object, captureLog),
      );
      final connectResult = await syncSocket.connect();
      String captureId = netCoreTestServer.startCaptureOutput(
        waitIdleInMs: 500,
        onlyWithRegex: '"connectionId":"${connectResult.connectionId!}"',
      );
      final response = await syncSocket.request(
          payload: CommandRequestPayload(data: {
        "commandName": "exception",
        "errorMessage": "Test Error",
      }));
      final serverLogs = await netCoreTestServer.stopCaptureOutput(captureId);
      expect(response.errorMessage, equals(ResponseResult.defaultErrorMessage));
      expect(captureLog.logs.last["type"], equals("ConnectionState"));
      expect(captureLog.logs.last["state"], equals("Closed"));
      final lastServerLog = jsonDecode(serverLogs!.last);
      expect(lastServerLog["type"], equals("ConnectionState"));
      expect(lastServerLog["state"], equals("Closed"));
    });
  });

  group("Manual Server with SyncSocket Tests", () {
    String printPrefixAdditionalText = "[MANUAL] ";

    void log(Object? object) {
      logTest(printPrefixAdditionalText + object.toString());
    }

    late NetCoreTestServer netCoreTestServer;

    late Database database;
    String databaseFileName = "netcoresync_sync_test_manual.db";
    late String wsUrl;
    TestCaptureLog? groupCaptureLog;
    void logClient(Object? object, TestCaptureLog? captureLog) {
      if (captureLog != null && object != null) {
        captureLog.logs.add(object as Map<String, dynamic>);
      }
      log("[CLIENT] " + object.toString());
    }

    Future<void> startServer({List<String> args = const []}) async {
      int netCoreUrlPort = getNetCoreUrlPort();
      String urls = "https://localhost:$netCoreUrlPort";
      wsUrl = "wss://localhost:$netCoreUrlPort/netcoresyncserver";

      netCoreTestServer = NetCoreTestServer(
        dotnetExecutablePath: dotnetExecutablePath,
        dllFileName: netCoreDllFileName,
        dllDirectory: netCoreDllDirectory,
        aspNetCoreUrls: urls,
        printStdout: netCorePrintStdout,
        printPrefixAdditionalText: printPrefixAdditionalText,
      );
      bool started = await netCoreTestServer.start(args: args);
      expect(started, equals(true),
          reason: "Cannot launch NetCoreTestServer. Check the print output.");
    }

    setUp(() async {
      database = await Helper.setUpDatabase(
        testFilesFolder: testFilesFolder,
        databaseFileName: databaseFileName,
        useInMemoryDatabase: useInMemoryDatabase,
        logSqlStatements: logSqlStatements,
      );
      await database.netCoreSyncInitialize();
      database.netCoreSyncSetLogger(
        (object) => logClient(
          object,
          groupCaptureLog,
        ),
      );
      database.netCoreSyncSetSyncIdInfo(SyncIdInfo(
        syncId: "abc",
      ));
    });

    tearDown(() async {
      await Helper.tearDownDatabase(database);
    });

    Future<void> stopServer() async {
      await netCoreTestServer.stop();
    }

    test("Server stopped while SyncSocket connected", () async {
      await startServer();
      try {
        TestCaptureLog captureLog = TestCaptureLog();
        SyncSocket syncSocket = SyncSocket(
          url: wsUrl,
          logger: (object) => logClient(object, captureLog),
        );
        final connectResult = await syncSocket.connect();
        String captureId = netCoreTestServer.startCaptureOutput(
          waitIdleInMs: 500,
          onlyWithRegex: '"connectionId":"${connectResult.connectionId!}"',
        );
        await netCoreTestServer.stop();
        final serverLogs = await netCoreTestServer.stopCaptureOutput(captureId);
        expect(captureLog.logs.last["type"], equals("ConnectionState"));
        expect(captureLog.logs.last["state"], equals("Closed"));
        final lastServerLog = jsonDecode(serverLogs!.last);
        expect(lastServerLog["type"], equals("ConnectionState"));
        expect(lastServerLog["state"], equals("Closed"));
      } catch (e) {
        rethrow;
      } finally {
        await stopServer();
      }
    });

    test("Custom OnHandshake Check on Server", () async {
      await startServer(
        args: [
          "minimumSchemaVersion=2",
        ],
      );
      try {
        SyncSocket syncSocket = SyncSocket(
          url: wsUrl,
        );
        await syncSocket.connect();
        final responseResult = await syncSocket.request(
          payload: HandshakeRequestPayload(
            schemaVersion: 1,
            syncIdInfo: database.dataAccess.syncIdInfo!,
          ),
        );
        expect(responseResult.errorMessage, isNotEmpty);
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
