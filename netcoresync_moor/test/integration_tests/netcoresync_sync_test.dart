import 'dart:async';
import 'dart:convert';
import 'package:moor/moor.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:netcoresync_moor/src/netcoresync_classes.dart';
import 'package:netcoresync_moor/src/netcoresync_exceptions.dart';
import 'package:netcoresync_moor/src/sync_messages.dart';
import 'package:netcoresync_moor/src/sync_socket.dart';
import 'package:netcoresync_moor/src/sync_session.dart';
import '../utils/net_core_test_server.dart';
import '../utils/helper.dart';
import '../data/database.dart';

// TODO: 210830: Consider adding a real Flutter integration test in
// `netcoresync_moor` tests, because this package is supposed to be used in a
// real Flutter application, so we need to ensure it always works properly. One
// case happened earlier where in Generator, to score more pub points, the
// `analyzer` package is upgraded from 1.7.0 to 2.0.0, which by transitive deps
// also silently upgrades `meta` to 1.7.0. This is fine in the libraries,
// because they only depends on Dart and have no dependencies to Flutter, but,
// in a Flutter application, it turns out that Flutter (at the time of writing)
// still depends on `meta` 1.3.0, thus breaks the code generation in the client
// project.

void main() async {
  bool testPrint = true;
  void logTest(Object? object) {
    if (testPrint) {
      print("\x1B[1;93mTest:\x1B[0m " + object.toString());
    }
  }

  Helper.bypassHttpCertificateVerifyFailed();

  String dotnetExecutableFullPath =
      await NetCoreTestServer.getDotNetExecutablePath();
  if (dotnetExecutableFullPath.isEmpty) {
    throw Exception("Unexpected dotnetExecutableFullPath is empty");
  }
  bool netCorePrintStdout = true;
  String netCoreProjectRootDirectory = "../Samples/ServerTimeStamp/WebSample";
  String netCoreDllFileName = "WebSample.dll";
  String netCoreDllDirectory =
      "../Samples/ServerTimeStamp/WebSample/bin/Debug/net5.0";

  String testFilesFolder = ".test_files";
  bool useInMemoryDatabase = true;
  bool logSqlStatements = false;

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

    test("SyncSession Basic Validation", () async {
      await startServer(
        args: [
          "clearDatabase=true",
        ],
      );
      final db = await setUpDatabase(
        syncIdInfo: SyncIdInfo(syncId: "abc"),
        databaseFileName: "netcoresync_sync_test_manual_basic.db",
      );
      try {
        // Basic Validation: synchronize must not execute inside transaction
        try {
          await db.transaction(
              () async => await db.netCoreSyncSynchronize(url: wsUrl));
        } catch (ex) {
          expect(ex, isA<NetCoreSyncMustNotInsideTransactionException>());
        }
        // Capture synchronize events
        await db.syncInto(db.areas).syncInsert(
            AreasCompanion(city: Value("Jakarta"), district: Value("Menteng")));
        List<String> syncEventMessages = [];
        SyncEvent syncEvent = SyncEvent(
            progressEvent: (message, _, __) => syncEventMessages.add(message));
        await db.netCoreSyncSynchronize(url: wsUrl, syncEvent: syncEvent);
        expect(syncEventMessages.contains(SyncSession.defaultConnectingMessage),
            equals(true));
        expect(
            syncEventMessages
                .contains(SyncSession.defaultHandshakeRequestMessage),
            equals(true));
        expect(
            syncEventMessages
                .contains(SyncSession.defaultSyncTableRequestMessage),
            equals(true));
        expect(
            syncEventMessages.contains(SyncSession.defaultDisconnectingMessage),
            equals(true));

        // Check the syncOnlyFields log level output
        await db.syncInto(db.areas).syncInsert(
            AreasCompanion(city: Value("Tokyo"), district: Value("Shibuya")));
        final syncResultSyncFieldsOnly = await db.netCoreSyncSynchronize(
          url: wsUrl,
          syncResultLogLevel: SyncResultLogLevel.syncFieldsOnly,
        );
        expect(
            syncResultSyncFieldsOnly.logs.any((element) =>
                element["action"] == "syncTableRequest" &&
                element["data"]["className"] == "AreaData" &&
                element["data"]["unsyncedRows"] is List<dynamic> &&
                element["data"]["unsyncedRows"].length == 1 &&
                !element["data"]["unsyncedRows"][0].containsKey("city") &&
                !element["data"]["unsyncedRows"][0].containsKey("district")),
            equals(true));

        // Check the countsOnly log level output
        await db.syncInto(db.areas).syncInsert(AreasCompanion(
            city: Value("Paris"), district: Value("Champs-Elysées")));
        final syncResultCountsOnly = await db.netCoreSyncSynchronize(
          url: wsUrl,
          syncResultLogLevel: SyncResultLogLevel.countsOnly,
        );
        expect(
            syncResultCountsOnly.logs.any((element) =>
                element["action"] == "syncTableRequest" &&
                element["data"]["className"] == "AreaData" &&
                element["data"]["unsyncedRows"] is int &&
                element["data"]["unsyncedRows"] == 1),
            equals(true));
      } catch (e) {
        rethrow;
      } finally {
        await tearDownDatabase(db);
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

      moorRuntimeOptions.dontWarnAboutMultipleDatabases = true;

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

      Future<AreaData> doUpdateArea(
        Database db,
        AreasCompanion entity,
      ) async {
        await db.syncUpdate(db.areas).syncReplace(entity);
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

      Future<Person> doUpdatePerson(
        Database db,
        PersonsCompanion entity,
      ) async {
        await db.syncUpdate(db.persons).syncReplace(entity);
        final data = await (db.select(db.persons)..whereSamePrimaryKey(entity))
            .getSingle();
        return data;
      }

      Future<Person> doDeletePerson(
        Database db,
        PersonsCompanion entity,
      ) async {
        await (db.syncDelete(db.persons)..whereSamePrimaryKey(entity)).go();
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
            expect(actuals[0].syncSyncId, equals(data.syncSyncId));
            expect(actuals[0].syncKnowledgeId, equals(data.syncKnowledgeId));
            expect(actuals[0].syncSynced, equals(true));
            expect(actuals[0].syncDeleted, equals(data.syncDeleted));
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
            expect(actuals[0].syncId, equals(data.syncId));
            expect(actuals[0].knowledgeId, equals(data.knowledgeId));
            expect(actuals[0].synced, equals(true));
            expect(actuals[0].deleted, equals(data.deleted));
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
              allOf(isNot(equals(null)), isA<Map<String, dynamic>>()));
          Set<String> processedActions = {};
          int logCount = 0;
          operations.forEach((key, value) {
            // Warning: for this test, it is expected that the server
            // counterpart table's primary key column name is always "id".
            expect(
                (serverLogs as Map<String, dynamic>).containsKey(value) &&
                    serverLogs[value] is List<dynamic> &&
                    (serverLogs[value] as List<dynamic>)
                        .any((element) => element["id"] == key),
                equals(true));
            if (!processedActions.contains(value)) {
              logCount += (serverLogs[value] as List<dynamic>).length;
              processedActions.add(value);
            }
          });

          expect(logCount, equals(operations.length));
        }

        validateServerLogs("AreaData", areaIdOperations);
        validateServerLogs("Person", personIdOperations);
      }

      Future validateClientKnowledge(Database db) async {
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
        final groupedAreas = await (db.selectOnly(db.areas)
              ..addColumns([db.areas.syncSyncId, db.areas.syncKnowledgeId])
              ..groupBy([db.areas.syncSyncId, db.areas.syncKnowledgeId]))
            .get();
        for (var item in groupedAreas) {
          final syncId = item.read(db.areas.syncSyncId);
          final knowledgeId = item.read(db.areas.syncKnowledgeId);
          expect(
              (await (db.select(db.netCoreSyncKnowledges)
                        ..where((tbl) =>
                            tbl.id.equals(knowledgeId) &
                            tbl.syncId.equals(syncId)))
                      .get())
                  .isNotEmpty,
              equals(true));
        }
        final groupedPersons = await (db.selectOnly(db.persons)
              ..addColumns([db.persons.syncId, db.persons.knowledgeId])
              ..groupBy([db.persons.syncId, db.persons.knowledgeId]))
            .get();
        for (var item in groupedPersons) {
          final syncId = item.read(db.persons.syncId);
          final knowledgeId = item.read(db.persons.knowledgeId);
          expect(
              (await (db.select(db.netCoreSyncKnowledges)
                        ..where((tbl) =>
                            tbl.id.equals(knowledgeId) &
                            tbl.syncId.equals(syncId)))
                      .get())
                  .isNotEmpty,
              equals(true));
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
      final dbDef3 = await setUpDatabase(
        syncIdInfo: SyncIdInfo(syncId: "def", linkedSyncIds: ["abc"]),
        databaseFileName: "netcoresync_sync_test_manual_def3.db",
      );
      dbDef3.netCoreSyncSetLogger((object) {
        (object as Map<String, dynamic>)["db"] = "def3";
        log(object, null);
      });

      try {
        // Activity #1: abc1 insert AreaData + insert Person + Sync
        log({"activity": "=== ACTIVITY #1 ==="}, null);
        final abc1area1 = await doInsertArea(dbAbc1, defaultArea());
        final abc1person1 = await doInsertPerson(dbAbc1,
            defaultPerson().copyWith(vaccinationAreaPk: Value(abc1area1.pk)));
        final abc1syncResult1 = await dbAbc1.netCoreSyncSynchronize(url: wsUrl);
        validateServerState(
          abc1syncResult1,
          null,
          null,
          {abc1area1.pk: "inserts"},
          {abc1person1.id: "inserts"},
        );
        await validateClientState(
          dbAbc1,
          [abc1area1],
          [abc1person1],
        );
        await validateClientKnowledge(dbAbc1);

        // Activity #2: abc1 no changes + Sync
        log({"activity": "=== ACTIVITY #2 ==="}, null);
        final abc1syncResult2 = await dbAbc1.netCoreSyncSynchronize(url: wsUrl);
        validateServerState(
          abc1syncResult2,
          null,
          null,
          {},
          {},
        );
        await validateClientState(
          dbAbc1,
          [abc1area1],
          [abc1person1],
        );
        await validateClientKnowledge(dbAbc1);

        // Activity #3: abc1 update AreaData + update Person + Sync
        log({"activity": "=== ACTIVITY #3 ==="}, null);
        final abc1area3 = await doUpdateArea(
            dbAbc1,
            abc1area1.toCompanion(true).copyWith(
                  city: Value("Denpasar"),
                  district: Value("Nusa Dua"),
                ));
        final abc1person3 = await doUpdatePerson(dbAbc1,
            abc1person1.toCompanion(true).copyWith(name: Value("John Doe 2")));
        final abc1syncResult3 = await dbAbc1.netCoreSyncSynchronize(url: wsUrl);
        validateServerState(
          abc1syncResult3,
          null,
          null,
          {abc1area3.pk: "updates"},
          {abc1person3.id: "updates"},
        );
        await validateClientState(
          dbAbc1,
          [abc1area3],
          [abc1person3],
        );
        await validateClientKnowledge(dbAbc1);

        // Activity #4: abc2 insert Person + Sync, abc1 Sync
        log({"activity": "=== ACTIVITY #4 ==="}, null);
        final abc2person4 = await doInsertPerson(
            dbAbc2,
            defaultPerson().copyWith(
                name: Value(
              "Jane Doe",
            )));
        final abc2syncResult4 = await dbAbc2.netCoreSyncSynchronize(url: wsUrl);
        validateServerState(
          abc2syncResult4,
          null,
          null,
          {},
          {abc2person4.id: "inserts"},
        );
        await validateClientState(
          dbAbc2,
          [abc1area3],
          [abc1person3, abc2person4],
        );
        await validateClientKnowledge(dbAbc2);
        final abc1syncResult4 = await dbAbc1.netCoreSyncSynchronize(url: wsUrl);
        validateServerState(
          abc1syncResult4,
          null,
          null,
          {},
          {},
        );
        await validateClientState(
          dbAbc1,
          [abc1area3],
          [abc1person3, abc2person4],
        );
        await validateClientKnowledge(dbAbc1);

        // Activity #5: abc1 insert Person + update abc2's Person, abc2 insert
        //              Person + update abc1's Person, abc1 Sync, abc2 Sync,
        //              abc1 Sync
        log({"activity": "=== ACTIVITY #5 ==="}, null);
        final abc1person5_1 = await doInsertPerson(
            dbAbc1,
            defaultPerson().copyWith(
                name: Value(
              "Alice",
            )));
        final abc1person5_2 = await doUpdatePerson(
            dbAbc1, abc2person4.toCompanion(true).copyWith(name: Value("Bob")));
        final abc2person5_1 = await doInsertPerson(
            dbAbc2,
            defaultPerson().copyWith(
                name: Value(
              "Chuck",
            )));
        final abc2person5_2 = await doUpdatePerson(
            dbAbc2, abc1person3.toCompanion(true).copyWith(name: Value("Dan")));
        final abc1syncResult5_1 =
            await dbAbc1.netCoreSyncSynchronize(url: wsUrl);
        validateServerState(
          abc1syncResult5_1,
          null,
          null,
          {},
          {abc1person5_1.id: "inserts", abc1person5_2.id: "updates"},
        );
        await validateClientState(
          dbAbc1,
          [abc1area3],
          [abc1person3, abc1person5_1, abc1person5_2],
        );
        await validateClientKnowledge(dbAbc1);
        final abc2syncResult5_1 =
            await dbAbc2.netCoreSyncSynchronize(url: wsUrl);
        validateServerState(
          abc2syncResult5_1,
          null,
          null,
          {},
          {abc2person5_1.id: "inserts", abc2person5_2.id: "updates"},
        );
        await validateClientState(
          dbAbc2,
          [abc1area3],
          [abc1person5_1, abc1person5_2, abc2person5_1, abc2person5_2],
        );
        await validateClientKnowledge(dbAbc2);
        final abc1syncResult5_2 =
            await dbAbc1.netCoreSyncSynchronize(url: wsUrl);
        validateServerState(
          abc1syncResult5_2,
          null,
          null,
          {},
          {},
        );
        await validateClientState(
          dbAbc1,
          [abc1area3],
          [abc1person5_1, abc1person5_2, abc2person5_1, abc2person5_2],
        );
        await validateClientKnowledge(dbAbc1);

        // Activity #6: abc1 delete its Person, abc2 update abc1's Person,
        //              abc1 Sync, abc2 Sync, abc1 Sync
        log({"activity": "=== ACTIVITY #6 ==="}, null);
        final abc1person6 =
            await doDeletePerson(dbAbc1, abc1person5_1.toCompanion(true));
        final abc2person6 = await doUpdatePerson(dbAbc2,
            abc1person5_1.toCompanion(true).copyWith(name: Value("Eve")));
        final abc1syncResult6_1 =
            await dbAbc1.netCoreSyncSynchronize(url: wsUrl);
        validateServerState(
          abc1syncResult6_1,
          null,
          null,
          {},
          {abc1person6.id: "deletes"},
        );
        await validateClientState(
          dbAbc1,
          [abc1area3],
          [abc1person6, abc1person5_2, abc2person5_1, abc2person5_2],
        );
        await validateClientKnowledge(dbAbc1);
        final abc2syncResult6_1 =
            await dbAbc2.netCoreSyncSynchronize(url: wsUrl);
        validateServerState(
          abc2syncResult6_1,
          null,
          null,
          {},
          {abc2person6.id: "ignores"},
        );
        await validateClientState(
          dbAbc2,
          [abc1area3],
          [
            abc2person6.copyWith(deleted: true),
            abc1person5_2,
            abc2person5_1,
            abc2person5_2
          ],
        );
        await validateClientKnowledge(dbAbc2);
        final abc1syncResult6_2 =
            await dbAbc1.netCoreSyncSynchronize(url: wsUrl);
        validateServerState(
          abc1syncResult6_2,
          null,
          null,
          {},
          {},
        );
        await validateClientState(
          dbAbc1,
          [abc1area3],
          [abc1person6, abc1person5_2, abc2person5_1, abc2person5_2],
        );
        await validateClientKnowledge(dbAbc1);

        // Activity #7: Introduce def (known as def3), which can access abc's
        // data (includes abc1 + abc2), def3 Sync
        log({"activity": "=== ACTIVITY #7 ==="}, null);
        final def3syncResult7 = await dbDef3.netCoreSyncSynchronize(url: wsUrl);
        validateServerState(
          def3syncResult7,
          null,
          null,
          {},
          {},
        );
        await validateClientState(
          dbDef3,
          [abc1area3],
          [abc1person5_2, abc2person5_1, abc2person5_2],
        );
        await validateClientKnowledge(dbDef3);

        // Activity #8: def3 insert Person + insert on behalf abc's Person
        // + update on behalf abc's Person + Sync
        log({"activity": "=== ACTIVITY #8 ==="}, null);
        final def3person8 = await doInsertPerson(
            dbDef3, defaultPerson().copyWith(name: Value("Frank")));
        dbDef3.netCoreSyncSetActiveSyncId("abc");
        final def3abcperson8_1 = await doInsertPerson(
            dbDef3, defaultPerson().copyWith(name: Value("Grace")));
        final def3abcperson8_2 = await doUpdatePerson(dbDef3,
            abc1person5_2.toCompanion(true).copyWith(name: Value("Heidi")));
        final def3syncResult8 = await dbDef3.netCoreSyncSynchronize(url: wsUrl);
        validateServerState(
          def3syncResult8,
          null,
          null,
          {},
          {
            def3person8.id: "inserts",
            def3abcperson8_1.id: "inserts",
            def3abcperson8_2.id: "updates"
          },
        );
        await validateClientState(
          dbDef3,
          [abc1area3],
          [
            def3person8,
            def3abcperson8_1,
            def3abcperson8_2,
            abc2person5_1,
            abc2person5_2
          ],
        );
        await validateClientKnowledge(dbDef3);

        // Activity #9: abc1 Sync
        log({"activity": "=== ACTIVITY #9 ==="}, null);
        final abc1syncResult9 = await dbAbc1.netCoreSyncSynchronize(url: wsUrl);
        validateServerState(
          abc1syncResult9,
          null,
          null,
          {},
          {},
        );
        await validateClientState(
          dbAbc1,
          [abc1area3],
          [
            abc1person6,
            def3abcperson8_2,
            abc2person5_1,
            abc2person5_2,
            def3abcperson8_1
          ],
        );
        await validateClientKnowledge(dbAbc1);
      } catch (_) {
        rethrow;
      } finally {
        await tearDownDatabase(dbAbc1);
        await tearDownDatabase(dbAbc2);
        await tearDownDatabase(dbDef3);
        await stopServer();
      }
    });
  });
}

class TestCaptureLog {
  List<Map<String, dynamic>> logs = [];
}
