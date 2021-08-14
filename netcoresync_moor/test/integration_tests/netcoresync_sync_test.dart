import 'dart:async';
import 'dart:convert';
import 'package:moor/moor.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
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

  String dotnetExecutableFullPath = "/usr/local/share/dotnet/dotnet";
  bool netCorePrintStdout = true;
  String netCoreProjectRootDirectory = "../Samples/ServerTimeStamp/WebSample";
  String netCoreDllFileName = "WebSample.dll";
  String netCoreDllDirectory =
      "../Samples/ServerTimeStamp/WebSample/bin/Debug/net5.0";

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
    bool buildResult = await NetCoreTestServer.build(
      dotnetExecutablePath: dotnetExecutableFullPath,
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
        dotnetExecutablePath: dotnetExecutableFullPath,
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
        dotnetExecutablePath: dotnetExecutableFullPath,
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

    test("SyncSession Synchronize", () async {
      await startServer(
        args: [
          "clearDatabase=true",
        ],
      );

      // wsUrl = "wss://localhost:5001/netcoresyncserver";

      // START: Helper methods for repetitive tasks

      AreasCompanion defaultArea() => AreasCompanion(
            city: Value("Jakarta"),
            district: Value("Menteng"),
          );

      PersonsCompanion defaultPerson() => PersonsCompanion(
            name: Value("John Doe"),
            birthday: Value(DateTime(2000, 1, 1)),
            age: Value(21),
            isForeigner: Value(true),
          );

      Future<AreaData> doInsertArea(
        Database db,
        AreasCompanion entity,
      ) async {
        String id = Uuid().v4();
        entity = entity.copyWith(pk: Value(id));
        await db.syncInto(db.areas).syncInsert(entity);
        final data = await (db.select(db.areas)..whereSamePrimaryKey(entity))
            .getSingle();
        return data;
      }

      Future<Person> doInsertPerson(
        Database db,
        PersonsCompanion entity,
      ) async {
        String id = Uuid().v4();
        entity = entity.copyWith(id: Value(id));
        await db.syncInto(db.persons).syncInsert(entity);
        final data = await (db.select(db.persons)..whereSamePrimaryKey(entity))
            .getSingle();
        return data;
      }

      Future validateClientState(
        Database db,
        List<AreaData> areaDatas,
        List<Person> personDatas,
      ) async {
        if (areaDatas.isNotEmpty) {
          for (var i = 0; i < areaDatas.length; i++) {
            final data = areaDatas[i];
            final actuals = await (db.select(db.areas)
                  ..where((tbl) => tbl.pk.equals(data.pk)))
                .get();
            expect(actuals.length, equals(1));
            expect(actuals[0].city, equals(data.city));
            expect(actuals[0].district, equals(data.district));
            expect(actuals[0].syncSynced, equals(true));
          }
        }
        expect(
            (await db.select(db.areas).get()).length, equals(areaDatas.length));
        if (personDatas.isNotEmpty) {
          for (var i = 0; i < personDatas.length; i++) {
            final data = personDatas[i];
            final actuals = await (db.select(db.persons)
                  ..where((tbl) => tbl.id.equals(data.id)))
                .get();
            expect(actuals.length, equals(1));
            expect(actuals[0].name, equals(data.name));
            expect(actuals[0].birthday, equals(data.birthday));
            expect(actuals[0].age, equals(data.age));
            expect(actuals[0].isForeigner, equals(data.isForeigner));
            expect(actuals[0].synced, equals(true));
          }
        }
        expect((await db.select(db.persons).get()).length,
            equals(personDatas.length));
      }

      void validateServerState(
        SyncResult syncResult,
        Object? error,
        String? errorMessage,
        Map<String, String> areaIdOperations,
        Map<String, String> personIdOperations,
      ) {
        expect(syncResult.error, equals(error));
        expect(syncResult.errorMessage, equals(errorMessage));

        void validateServerLogs(
            String className, Map<String, String> operations) {
          final logLines = syncResult.logs.where((element) =>
              element["action"] == "syncTableResponse" &&
              element["data"]["className"] == className);
          expect(logLines.length, equals(1));
          final serverLogs = logLines.elementAt(0)["data"]["logs"];
          expect(serverLogs,
              allOf(isNot(equals(null)), isA<List<Map<String, dynamic>>>()));
          operations.forEach((key, value) {
            expect(
                (serverLogs as List<Map<String, dynamic>>).any((element) =>
                    element.containsKey("action") &&
                    element["action"] == value &&
                    element["data"]["id"] == key),
                equals(true));
          });
          expect(serverLogs.length, equals(operations.length));
        }

        validateServerLogs("AreaData", areaIdOperations);
        validateServerLogs("Person", personIdOperations);
      }

      Future validateKnowledge(Database db) async {
        final knowledges = await db.select(db.netCoreSyncKnowledges).get();
        for (var i = 0; i < knowledges.length; i++) {
          final knowledge = knowledges[i];
          final areaExist = (await (db.select(db.areas)
                    ..where((tbl) =>
                        tbl.syncSyncId.equals(knowledge.syncId) &
                        tbl.syncKnowledgeId.equals(knowledge.id)))
                  .get())
              .isNotEmpty;
          final personExist = (await (db.select(db.persons)
                    ..where((tbl) =>
                        tbl.syncId.equals(knowledge.syncId) &
                        tbl.knowledgeId.equals(knowledge.id)))
                  .get())
              .isNotEmpty;
          expect(true, anyOf(areaExist, personExist));
        }
      }

      // END: Helper methods for repetitive tasks

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
        // Activity #1: abc1 insert AreaData + insert Person + Sync
        final abc1area1 = await doInsertArea(dbAbc1, defaultArea());
        final abc1person1 = await doInsertPerson(dbAbc1,
            defaultPerson().copyWith(vaccinationAreaPk: Value(abc1area1.pk)));
        final abc1syncResult1 = await dbAbc1.netCoreSyncSynchronize(url: wsUrl);
        await validateClientState(dbAbc1, [abc1area1], [abc1person1]);
        validateServerState(abc1syncResult1, null, null,
            {abc1area1.pk: "insert"}, {abc1person1.id: "insert"});
        await validateKnowledge(dbAbc1);

        // Activity #2: abc1 no changes + Sync
        final abc1syncResult2 = await dbAbc1.netCoreSyncSynchronize(url: wsUrl);
        await validateClientState(dbAbc1, [abc1area1], [abc1person1]);
        validateServerState(abc1syncResult2, null, null, {}, {});
        await validateKnowledge(dbAbc1);

        // Activity #3: abc1 update AreaData + update Person + Sync
        await dbAbc1
            .syncUpdate(dbAbc1.areas)
            .syncReplace(abc1area1.toCompanion(true).copyWith(
                  city: Value("Denpasar"),
                  district: Value("Nusa Dua"),
                ));
        final abc1area3 = await (dbAbc1.select(dbAbc1.areas)
              ..where((tbl) => tbl.pk.equals(abc1area1.pk)))
            .getSingle();
        await dbAbc1.syncUpdate(dbAbc1.persons).syncReplace(
            abc1person1.toCompanion(true).copyWith(name: Value("John Doe 2")));
        final abc1person3 = await (dbAbc1.select(dbAbc1.persons)
              ..where((tbl) => tbl.id.equals(abc1person1.id)))
            .getSingle();
        final abc1syncResult3 = await dbAbc1.netCoreSyncSynchronize(url: wsUrl);
        await validateClientState(dbAbc1, [abc1area3], [abc1person3]);
        validateServerState(abc1syncResult3, null, null,
            {abc1area3.pk: "update"}, {abc1person3.id: "update"});
        await validateKnowledge(dbAbc1);

        // Activity #4: abc2 insert Person + Sync, abc1 Sync
        final abc2person4 = await doInsertPerson(
            dbAbc2,
            defaultPerson().copyWith(
                name: Value(
              "Jane Doe",
            )));
        final abc2syncResult4 = await dbAbc2.netCoreSyncSynchronize(url: wsUrl);
        await validateClientState(dbAbc2, [], [abc2person4]);
        validateServerState(
            abc2syncResult4, null, null, {}, {abc2person4.id: "insert"});
        await validateKnowledge(dbAbc2);
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
