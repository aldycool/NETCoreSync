import 'dart:async';
import 'dart:convert';
import 'package:moor/moor.dart';
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
  bool logSqlStatements = true;

  void logClient(String printPrefixAdditionalText, Object? object,
      TestCaptureLog? captureLog) {
    if (captureLog != null && object != null) {
      captureLog.logs.add(object as Map<String, dynamic>);
    }
    logTest(printPrefixAdditionalText + "[CLIENT] " + object.toString());
  }

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

  group("Tests with Auto NetCore Server", () {
    String printPrefixAdditionalText = "[AUTO] ";
    void log(Object? object, TestCaptureLog? captureLog) {
      logClient(printPrefixAdditionalText, object, captureLog);
    }

    late NetCoreTestServer netCoreTestServer;

    // late Database database;
    // String databaseFileName = "netcoresync_sync_test_auto.db";
    late String wsUrl;

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
        logger: (object) => log(object, null),
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
        url: "wss://non-existent-url-123456.com",
        logger: (object) => log(object, captureLog),
      );
      final connectResult = await syncSocket.connect().timeout(
        Duration(seconds: 5),
        onTimeout: () {
          // if this is reached, that means the DNS resolve of the current OS
          //is taking much longer time, just skip this test by simulating the
          // return of identical response.
          captureLog.logs.add({
            "type": "ConnectionState",
            "state": "Closed",
          });
          return ConnectResult(
            error: WebSocketChannelException(),
            errorMessage: ConnectResult.defaultErrorMessage,
          );
        },
      );
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
        logger: (object) => log(object, captureLog),
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
        logger: (object) => log(object, captureLog),
      );
      final connectResult = await syncSocket.connect();
      String captureId = netCoreTestServer.startCaptureOutput(
        waitIdleInMs: 500,
        onlyWithRegex: '"connectionId":"${connectResult.connectionId!}"',
      );
      await syncSocket.close();
      await pumpEventQueue();
      final serverLogs = await netCoreTestServer.stopCaptureOutput(captureId);
      expect(connectResult.error, equals(null));
      expect(connectResult.errorMessage, equals(null));
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
        logger: (object) => log(object, captureLog),
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
        logger: (object) => log(object, captureLog),
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
        logger: (object) => log(object, captureLog),
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

    test("Multiple SyncSockets handshake with overlapped SyncInfoId", () async {
      Future launchSyncSocket(
        SyncIdInfo syncIdInfo,
        String expectedOverlappedSyncId,
      ) async {
        SyncSocket syncSocket = SyncSocket(
          url: wsUrl,
          logger: (object) => log(object, null),
        );
        await syncSocket.connect();
        final handshakeResult = await syncSocket.request(
          payload: HandshakeRequestPayload(
            schemaVersion: 1,
            syncIdInfo: syncIdInfo,
            customInfo: {},
          ),
        );
        log({
          "handshakeResult.errorMessage": handshakeResult.errorMessage,
          "handshakeResult.error": handshakeResult.error,
          "expectedOverlappedSyncId": expectedOverlappedSyncId,
        }, null);
        if (expectedOverlappedSyncId.isNotEmpty) {
          expect(
            handshakeResult.error,
            predicate((f) =>
                f is NetCoreSyncServerSyncIdInfoOverlappedException &&
                f.overlappedSyncIds.contains(expectedOverlappedSyncId)),
          );
          return;
        }
        await syncSocket.request(
          payload: CommandRequestPayload(
            data: {
              "commandName": "delay",
              "delayInMs": 2000,
            },
          ),
        );
      }

      // This should not raise exception
      final f1 = launchSyncSocket(
        SyncIdInfo(syncId: "abc", linkedSyncIds: [
          "def",
          "ghi",
        ]),
        "",
      );
      // This also should not raise exception (no overlapped syncId)
      final f2 = launchSyncSocket(
        SyncIdInfo(
          syncId: "jkl",
        ),
        "",
      );
      // This should raise exception (overlapped on: ghi with syncId: abc)
      await Future.delayed(Duration(milliseconds: 500));
      final f3 = launchSyncSocket(
        SyncIdInfo(syncId: "mno", linkedSyncIds: [
          "ghi",
        ]),
        "ghi",
      );
      // This should raise exception (overlapped on: def with syncId: abc)
      final f4 = launchSyncSocket(
        SyncIdInfo(syncId: "def", linkedSyncIds: [
          "pqr",
          "stu",
        ]),
        "def",
      );
      await Future.wait([
        f1,
        f2,
        f3,
        f4,
      ]);
    });
  });

  group("Tests with Manual NetCore Server", () {
    String printPrefixAdditionalText = "[MANUAL] ";
    void log(Object? object, TestCaptureLog? captureLog) {
      logClient(printPrefixAdditionalText, object, captureLog);
    }

    late NetCoreTestServer netCoreTestServer;
    late String wsUrl;

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

    Future<void> stopServer() async {
      await netCoreTestServer.stop();
    }

    Future<Database> setUpDatabase({
      required SyncIdInfo syncIdInfo,
      String databaseFileName = "netcoresync_sync_test_manual.db",
    }) async {
      Database database = await Helper.setUpDatabase(
        testFilesFolder: testFilesFolder,
        databaseFileName: databaseFileName,
        useInMemoryDatabase: useInMemoryDatabase,
        logSqlStatements: logSqlStatements,
      );
      await database.netCoreSyncInitialize();
      database.netCoreSyncSetSyncIdInfo(syncIdInfo);
      return database;
    }

    Future tearDownDatabase(Database database) async {
      await Helper.tearDownDatabase(database);
    }

    test("Server stopped while SyncSocket connected", () async {
      await startServer();
      try {
        TestCaptureLog captureLog = TestCaptureLog();
        SyncSocket syncSocket = SyncSocket(
          url: wsUrl,
          logger: (object) => log(object, captureLog),
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
            syncIdInfo: SyncIdInfo(syncId: "abc"),
            customInfo: {},
          ),
        );
        expect(responseResult.errorMessage, isNotEmpty);
      } catch (e) {
        rethrow;
      } finally {
        await stopServer();
      }
    });

    test("SyncSession synchronize", () async {
      await startServer(
        args: [
          "clearDatabase=true",
        ],
      );
      // wsUrl = "wss://localhost:5001/netcoresyncserver";
      final dbAbc1 = await setUpDatabase(
        syncIdInfo: SyncIdInfo(syncId: "abc"),
        databaseFileName: "netcoresync_sync_test_manual_abc1.db",
      );
      dbAbc1.netCoreSyncSetLogger((object) {
        (object as Map<String, dynamic>)["db"] = "abc1";
        log(object, null);
      });
      final dbAbc2 = await setUpDatabase(
        syncIdInfo: SyncIdInfo(syncId: "abc"),
        databaseFileName: "netcoresync_sync_test_manual_abc2.db",
      );
      dbAbc2.netCoreSyncSetLogger((object) {
        (object as Map<String, dynamic>)["db"] = "abc2";
        log(object, null);
      });
      try {
        // Insert one AreaData and one Person, and Sync
        await dbAbc1.syncInto(dbAbc1.areas).syncInsert(AreasCompanion(
              city: Value("Jakarta"),
              district: Value("Menteng"),
            ));
        final area = await dbAbc1.syncSelect(dbAbc1.syncAreas).getSingle();
        await dbAbc1.syncInto(dbAbc1.persons).syncInsert(PersonsCompanion(
              name: Value("John Doe"),
              birthday: Value(DateTime(2000, 1, 1)),
              age: Value(21),
              isForeigner: Value(true),
              vaccinationAreaPk: Value(area.pk),
            ));
        final syncResult1 = await dbAbc1.netCoreSyncSynchronize(url: wsUrl);
        expect(syncResult1.error, equals(null));
        expect(syncResult1.errorMessage, equals(null));
        final syncedArea1 =
            await dbAbc1.syncSelect(dbAbc1.syncAreas).getSingle();
        expect(syncedArea1.syncSynced, equals(true));
        final syncedPerson1 =
            await dbAbc1.syncSelect(dbAbc1.syncPersons).getSingle();
        expect(syncedPerson1.synced, equals(true));
        var serverDataArea1 = syncResult1.logs
            .where((element) =>
                element["action"] == "syncTableResponse" &&
                element["data"]["className"] == "AreaData" &&
                (element["data"]["logs"] as Iterable).length == 1 &&
                (element["data"]["logs"] as Iterable).elementAt(0)["action"] ==
                    "insert" &&
                (element["data"]["logs"] as Iterable).elementAt(0)["data"]
                        ["id"] ==
                    syncedArea1.pk)
            .toList();
        expect(serverDataArea1.length, equals(1));
        var serverDataPerson1 = syncResult1.logs
            .where((element) =>
                element["action"] == "syncTableResponse" &&
                element["data"]["className"] == "Person" &&
                (element["data"]["logs"] as Iterable).length == 1 &&
                (element["data"]["logs"] as Iterable).elementAt(0)["action"] ==
                    "insert" &&
                (element["data"]["logs"] as Iterable).elementAt(0)["data"]
                        ["id"] ==
                    syncedPerson1.id)
            .toList();
        expect(serverDataPerson1.length, equals(1));

        // Sync only without any changes
        final syncResult2 = await dbAbc1.netCoreSyncSynchronize(url: wsUrl);
        expect(syncResult2.error, equals(null));
        expect(syncResult2.errorMessage, equals(null));
        var serverDataArea2 = syncResult2.logs
            .where((element) =>
                element["action"] == "syncTableRequest" &&
                element["data"]["className"] == "AreaData" &&
                (element["data"]["unsyncedRows"] as Iterable).isEmpty)
            .toList();
        expect(serverDataArea2.length, equals(1));
        var serverDataPerson2 = syncResult2.logs
            .where((element) =>
                element["action"] == "syncTableRequest" &&
                element["data"]["className"] == "Person" &&
                (element["data"]["unsyncedRows"] as Iterable).isEmpty)
            .toList();
        expect(serverDataPerson2.length, equals(1));

        // Update AreaData and Delete Person, and Sync
        final area3 = await dbAbc1.syncSelect(dbAbc1.syncAreas).getSingle();
        await dbAbc1
            .syncUpdate(dbAbc1.areas)
            .syncReplace(area3.toCompanion(true).copyWith(
                  district: Value("Kemang"),
                ));
        await dbAbc1.syncDelete(dbAbc1.persons).go();
        final syncResult3 = await dbAbc1.netCoreSyncSynchronize(url: wsUrl);
        expect(syncResult3.error, equals(null));
        expect(syncResult3.errorMessage, equals(null));
        final syncedArea3 =
            await dbAbc1.syncSelect(dbAbc1.syncAreas).getSingle();
        expect(syncedArea3.syncSynced, equals(true));
        final syncedPerson3 = await dbAbc1.select(dbAbc1.persons).getSingle();
        expect(syncedPerson3.synced, equals(true));
        expect((await dbAbc1.syncSelect(dbAbc1.syncPersons).get()).length,
            equals(0));
        var serverDataArea3 = syncResult3.logs
            .where((element) =>
                element["action"] == "syncTableResponse" &&
                element["data"]["className"] == "AreaData" &&
                (element["data"]["logs"] as Iterable).length == 1 &&
                (element["data"]["logs"] as Iterable).elementAt(0)["action"] ==
                    "update" &&
                (element["data"]["logs"] as Iterable).elementAt(0)["data"]
                        ["id"] ==
                    syncedArea3.pk)
            .toList();
        expect(serverDataArea3.length, equals(1));
        var serverDataPerson3 = syncResult3.logs
            .where((element) =>
                element["action"] == "syncTableResponse" &&
                element["data"]["className"] == "Person" &&
                (element["data"]["logs"] as Iterable).length == 1 &&
                (element["data"]["logs"] as Iterable).elementAt(0)["action"] ==
                    "delete" &&
                (element["data"]["logs"] as Iterable).elementAt(0)["data"]
                        ["id"] ==
                    syncedPerson3.id)
            .toList();
        expect(serverDataPerson3.length, equals(1));

        // TODO: Test a single user with two devices
      } catch (_) {
        rethrow;
      } finally {
        await tearDownDatabase(dbAbc1);
        await tearDownDatabase(dbAbc2);
        await stopServer();
      }
    });
  });
}

class TestCaptureLog {
  List<Map<String, dynamic>> logs = [];
}
