import 'dart:async';
import 'package:moor/moor.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
import 'package:version/version.dart';
import 'package:netcoresync_moor/src/netcoresync_exceptions.dart';
import 'package:netcoresync_moor/src/netcoresync_classes.dart';
import 'package:netcoresync_moor/src/netcoresync_knowledges.dart';
import 'data/database.dart';
import 'data/custom_objects.dart';
import 'utils/helper.dart';

void main() async {
  String testFilesFolder = ".test_files";
  bool useInMemoryDatabase = true;
  bool logSqlStatements = false;

  // Obtain the running sqlite3 library version first to determine which tests
  // to skip
  Version currentVersion = await Helper.getLibraryVersion(
    testFilesFolder: testFilesFolder,
    databaseFileName: "netcoresync_operation_test_root.db",
    useInMemoryDatabase: useInMemoryDatabase,
    logSqlStatements: logSqlStatements,
  );

  group("Uninitialized Tests", () {
    late Database database;

    setUp(() async {
      database = await Helper.setUpDatabase(
        testFilesFolder: testFilesFolder,
        databaseFileName: "netcoresync_operation_test_uninitialized.db",
        useInMemoryDatabase: useInMemoryDatabase,
        logSqlStatements: logSqlStatements,
      );
    });

    tearDown(() async {
      await Helper.tearDownDatabase(database);
    });

    test("Basic Validations", () async {
      // should throw Exception if not initialized yet on syncSelect
      await expectLater(
        () async {
          await database.syncSelect(database.syncPersons).get();
        },
        throwsA(isA<NetCoreSyncNotInitializedException>()),
      );
      // should throw Exception if not initialized yet on syncInto (expected
      // also on updates and deletes)
      await expectLater(
        () async {
          await database
              .syncInto(database.persons)
              .syncInsert(PersonsCompanion());
        },
        throwsA(isA<NetCoreSyncNotInitializedException>()),
      );
      // should throw Exception if not initialized yet on
      // netCoreSyncSetSyncIdInfo
      expect(
        () => database.netCoreSyncSetSyncIdInfo(SyncIdInfo(
          syncId: "someRandomId",
        )),
        throwsA(isA<NetCoreSyncNotInitializedException>()),
      );
      // should throw Exception if not initialized yet on
      // netCoreSyncSetActiveSyncId
      expect(
        () => database.netCoreSyncSetActiveSyncId("someRandomId"),
        throwsA(isA<NetCoreSyncNotInitializedException>()),
      );

      await database.netCoreSyncInitialize();

      // should throw Exception if SyncIdInfo is not set yet on syncSelect
      await expectLater(
        () async {
          await database.syncSelect(database.syncPersons).get();
        },
        throwsA(isA<NetCoreSyncSyncIdInfoNotSetException>()),
      );
      // should throw Exception if SyncIdInfo is not set yet on syncInto
      // (expected also on updates and deletes)
      await expectLater(
        () async {
          await database
              .syncInto(database.persons)
              .syncInsert(PersonsCompanion());
        },
        throwsA(isA<NetCoreSyncSyncIdInfoNotSetException>()),
      );
      // should throw if setSyncIdInfo syncId is empty
      expect(
        () => database.netCoreSyncSetSyncIdInfo(SyncIdInfo(
          syncId: "",
        )),
        throwsA(isA<NetCoreSyncException>()),
      );
      // should throw if setSyncIdInfo linkedSyncIds contains empty string
      expect(
        () => database.netCoreSyncSetSyncIdInfo(SyncIdInfo(
          syncId: "abc",
          linkedSyncIds: [
            "",
          ],
        )),
        throwsA(isA<NetCoreSyncException>()),
      );
      // should throw if setSyncIdInfo linkedSyncIds contains the same syncId
      expect(
        () => database.netCoreSyncSetSyncIdInfo(SyncIdInfo(
          syncId: "abc",
          linkedSyncIds: [
            "abc",
          ],
        )),
        throwsA(isA<NetCoreSyncException>()),
      );

      database.netCoreSyncSetSyncIdInfo(SyncIdInfo(
        syncId: "abc",
        linkedSyncIds: [
          "def",
        ],
      ));

      // should throw if setActiveSyncId is empty
      expect(
        () => database.netCoreSyncSetActiveSyncId(""),
        throwsA(isA<NetCoreSyncException>()),
      );
      // should throw if setActiveSyncId is not exist in syncIdInfo
      expect(
        () => database.netCoreSyncSetActiveSyncId("ghi"),
        throwsA(isA<NetCoreSyncException>()),
      );
      // should throw Exception if the table is not registered (not marked with
      // @NetCoreSyncTable) when using syncInto (expected also on updates and
      // deletes)
      await expectLater(
        () async {
          await database
              .syncInto(database.netCoreSyncKnowledges)
              .syncInsert(NetCoreSyncKnowledge());
        },
        throwsA(isA<NetCoreSyncTypeNotRegisteredException>()),
      );
      // should throw Exception if doing a syncJoin with a table that is not
      // its SyncTable's version
      await expectLater(
        () async {
          await database.syncSelect(database.syncPersons).syncJoin([
            leftOuterJoin(
              database.areas,
              database.areas.pk.equalsExp(database.persons.vaccinationAreaPk),
            ),
          ]).get();
        },
        throwsA(isA<NetCoreSyncException>()),
      );
      // should throw Exception if using the insert version inside syncInto
      await expectLater(
        () async {
          await database.syncInto(database.persons).insert(PersonsCompanion());
        },
        throwsA(isA<NetCoreSyncException>()),
      );
      // should throw Exception if using the insertOnConflictUpdate version
      // inside syncInto
      await expectLater(
        () async {
          await database
              .syncInto(database.persons)
              .insertOnConflictUpdate(PersonsCompanion());
        },
        throwsA(isA<NetCoreSyncException>()),
      );

      // NOTE: The insertReturning is not tested because at the time of
      // writing, insertReturning is still a new feature and pose a risk of not
      // supported in the current database

      // should throw Exception if using the write version inside syncUpdate
      await expectLater(
        () async {
          await database.syncUpdate(database.persons).write(PersonsCompanion());
        },
        throwsA(isA<NetCoreSyncException>()),
      );
      // should throw Exception if using the replace version inside syncUpdate
      await expectLater(
        () async {
          await database
              .syncUpdate(database.persons)
              .replace(PersonsCompanion());
        },
        throwsA(isA<NetCoreSyncException>()),
      );
      // should be ok if using the sync table version when doing syncInto
      // (because it will be 'normalized' into its original table)
      expect(
        database.syncInto(database.syncPersons).syncInsert(PersonsCompanion()),
        completes,
      );
      // should be ok if using the sync table version when doing syncUpdate
      // (because it will be 'normalized' into its original table)
      expect(
        database
            .syncUpdate(database.syncPersons)
            .syncReplace(PersonsCompanion().copyWith(id: Value(Uuid().v4()))),
        completes,
      );
      // should be ok if using the sync table version when doing syncDelete
      // (because it will be 'normalized' into its original table)
      expect(
        (database.syncDelete(database.syncPersons)
              ..where((tbl) => tbl.id.equals(Uuid().v4())))
            .go(),
        completes,
      );
    });
  });

  group("Single User Tests", () {
    late Database database;
    late String syncId;

    setUp(() async {
      database = await Helper.setUpDatabase(
        testFilesFolder: testFilesFolder,
        databaseFileName: "netcoresync_operation_test_single.db",
        useInMemoryDatabase: useInMemoryDatabase,
        logSqlStatements: logSqlStatements,
      );
      await database.netCoreSyncInitialize();
      syncId = "abc";
      database.netCoreSyncSetSyncIdInfo(SyncIdInfo(
        syncId: syncId,
      ));
    });

    tearDown(() async {
      await Helper.tearDownDatabase(database);
    });

    Future<String?> getLocalKnowledgeId() async {
      final queryRow = await database
          .customSelect(
              "SELECT ${database.netCoreSyncKnowledges.id.escapedName} AS id "
              "FROM ${database.netCoreSyncKnowledges.actualTableName} WHERE "
              "${database.netCoreSyncKnowledges.syncId.escapedName} = "
              "'${database.netCoreSyncGetActiveSyncId()}' AND "
              "${database.netCoreSyncKnowledges.local.escapedName} = 1")
          .getSingleOrNull();
      return queryRow?.data['id'];
    }

    // test("Test Concepts", () async {
    //   await database.transaction(() async {
    //     await database
    //         .into(database.persons)
    //         .insert(PersonsCompanion(name: Value("A")));
    //   });
    //   await database.netCoreSyncSynchronize(
    //     synchronizationId: "abc",
    //     url: "https://localhost:5001/custompath",
    //   );
    // });

    test(
      "Sync Insert",
      () async {
        String? localKnowledgeId = await getLocalKnowledgeId();
        expect(localKnowledgeId, equals(null));
        await database.syncInto(database.persons).syncInsert(
              PersonsCompanion(name: Value("A")),
            );
        localKnowledgeId = await getLocalKnowledgeId();
        expect(
          localKnowledgeId,
          allOf(
            isNot(equals(null)),
            isNot(equals("")),
          ),
        );
        await database.syncInto(database.persons).syncInsert(
              PersonsCompanion(name: Value("B")),
            );
        final personA = await (database.select(database.persons)
              ..where((tbl) => tbl.name.equals("A")))
            .getSingle();
        final personB = await (database.select(database.persons)
              ..where((tbl) => tbl.name.equals("B")))
            .getSingle();

        expect(personA.syncId, equals(syncId));
        expect(personA.knowledgeId, equals(localKnowledgeId));
        expect(personA.synced, equals(false));
        expect(personA.deleted, equals(false));
        expect(personB.syncId, equals(syncId));
        expect(personB.knowledgeId, equals(localKnowledgeId));
        expect(personB.synced, equals(false));
        expect(personB.deleted, equals(false));
      },
    );

    test(
      "Sync Insert with invalid mode",
      () async {
        await expectLater(
          () async {
            await database.syncInto(database.persons).syncInsert(
                  PersonsCompanion(),
                  mode: InsertMode.replace,
                );
          },
          throwsA(isA<NetCoreSyncException>()),
        );
        await expectLater(
          () async {
            await database.syncInto(database.persons).syncInsert(
                  PersonsCompanion(),
                  mode: InsertMode.insertOrReplace,
                );
          },
          throwsA(isA<NetCoreSyncException>()),
        );
      },
    );

    test(
      "Sync InsertOnConflictUpdate",
      () async {
        String? localKnowledgeId = await getLocalKnowledgeId();
        expect(localKnowledgeId, equals(null));
        await database.syncInto(database.persons).syncInsert(
              PersonsCompanion(
                name: Value("John Doe"),
              ),
            );
        localKnowledgeId = await getLocalKnowledgeId();
        expect(
          localKnowledgeId,
          allOf(
            isNot(equals(null)),
            isNot(equals("")),
          ),
        );
        final person = (await database.select(database.persons).get())[0];
        await database
            .syncInto(database.persons)
            .syncInsertOnConflictUpdate(person.toCompanion(true).copyWith(
                  name: Value("Jane Doe"),
                ));
        final persons = await database.select(database.persons).get();
        expect(persons.length, equals(1));
        expect(persons[0].name, equals("Jane Doe"));
        expect(persons[0].syncId, equals(syncId));
        expect(persons[0].knowledgeId, equals(localKnowledgeId));
        expect(persons[0].synced, equals(false));
        expect(persons[0].deleted, equals(false));
      },
    );

    test(
      "Sync Insert with SyncDoUpdate",
      () async {
        String? localKnowledgeId = await getLocalKnowledgeId();
        expect(localKnowledgeId, equals(null));
        await database.syncInto(database.persons).syncInsert(
              PersonsCompanion(
                name: Value("John Doe"),
              ),
            );
        localKnowledgeId = await getLocalKnowledgeId();
        expect(
          localKnowledgeId,
          allOf(
            isNot(equals(null)),
            isNot(equals("")),
          ),
        );
        await database.syncInto(database.persons).syncInsert(
            PersonsCompanion(
              name: Value("John Doe"),
            ),
            onConflict: SyncDoUpdate(
              (old) => PersonsCompanion.custom(
                name: old.name + Constant(" 2"),
              ),
              target: [
                database.persons.syncId,
                database.persons.name,
              ],
            ));
        final persons = await database.select(database.persons).get();
        expect(persons.length, equals(1));
        expect(persons[0].name, equals("John Doe 2"));
        expect(persons[0].syncId, equals(syncId));
        expect(persons[0].knowledgeId, equals(localKnowledgeId));
        expect(persons[0].synced, equals(false));
        expect(persons[0].deleted, equals(false));
      },
    );

    test(
      "Sync Insert with invalid SyncDoUpdate",
      () async {
        await database.syncInto(database.persons).syncInsert(
              PersonsCompanion(
                name: Value("John Doe"),
              ),
            );
        await database.syncInto(database.persons).syncInsert(
            PersonsCompanion(
              //id stays the same like previous, so the onConflict will kick in
              // (onConflict is defaulted to unique id constraint because we
              // do not specify list of targets there)
              // name needs to be changed because there is a name + syncId
              // constraint on the table
              name: Value("Jane Doe"),
              // syncId needs to be changed because there is a name + syncId
              // constraint on the table
              syncId: Value("Whatever"),
            ),
            onConflict: SyncDoUpdate(
              (old) => PersonsCompanion.custom(
                id: Constant(
                    "this will never be changed, because DoUpdate always "
                    "inserts new row with correct guid"),
                knowledgeId: Constant("RandomText"),
              ),
            ));
        final col1 = await database.select(database.persons).get();
        expect(col1.length, equals(2));
        expect(col1.where((element) => element.name == "Jane Doe").first.id,
            isNot(startsWith("this will never")));
        expect(col1.where((element) => element.name == "Jane Doe").first.syncId,
            isNot("Whatever"));
        expect(
            col1
                .where((element) => element.name == "Jane Doe")
                .first
                .knowledgeId,
            isNot("RandomText"));
        expect(col1.where((element) => element.name == "Jane Doe").first.synced,
            equals(false));
        expect(
            col1.where((element) => element.name == "Jane Doe").first.deleted,
            equals(false));
      },
    );

    test(
      "Sync Insert with SyncUpsertMultiple",
      () async {
        String? localKnowledgeId = await getLocalKnowledgeId();
        expect(localKnowledgeId, equals(null));
        await database.syncInto(database.persons).syncInsert(
              PersonsCompanion(
                name: Value("John Doe"),
              ),
            );
        localKnowledgeId = await getLocalKnowledgeId();
        expect(
          localKnowledgeId,
          allOf(
            isNot(equals(null)),
            isNot(equals("")),
          ),
        );
        await database.syncInto(database.persons).syncInsert(
            PersonsCompanion(
              name: Value("John Doe"),
            ),
            onConflict: SyncUpsertMultiple([
              SyncDoUpdate(
                (old) => PersonsCompanion.custom(
                  name: Constant(
                      "should never reached here because target is id and the "
                      "inserted object is a new object which has a new "
                      "guid id"),
                ),
                target: [
                  database.persons.id,
                ],
              ),
              SyncDoUpdate(
                (old) => PersonsCompanion.custom(
                  name: Constant("John Doe 2"),
                ),
                target: [
                  database.persons.syncId,
                  database.persons.name,
                ],
              ),
            ]));
        final persons = await database.select(database.persons).get();
        expect(persons.length, equals(1));
        expect(persons[0].name, equals("John Doe 2"));
        expect(persons[0].syncId, equals(syncId));
        expect(persons[0].knowledgeId, equals(localKnowledgeId));
        expect(persons[0].synced, equals(false));
        expect(persons[0].deleted, equals(false));
      },
      skip: Helper.shouldSkip(
        currentVersion,
        Version.parse("3.35.0"),
        moreInfo: "New sqlite feature: multiple ON CONFLICT. Read more at: "
            "https://sqlite.org/releaselog/3_35_0.html",
      ),
    );

    test(
      "Sync insertReturning",
      () async {
        String? localKnowledgeId = await getLocalKnowledgeId();
        expect(localKnowledgeId, equals(null));
        final person =
            await database.syncInto(database.persons).syncInsertReturning(
                  PersonsCompanion(name: Value("John Doe")),
                );
        localKnowledgeId = await getLocalKnowledgeId();
        expect(
          localKnowledgeId,
          allOf(
            isNot(equals(null)),
            isNot(equals("")),
          ),
        );
        expect(person.name, equals("John Doe"));
        expect(person.syncId, equals(syncId));
        expect(person.knowledgeId, equals(localKnowledgeId));
        expect(person.synced, equals(false));
        expect(person.deleted, equals(false));
      },
      skip: Helper.shouldSkip(
        currentVersion,
        Version.parse("3.35.0"),
        moreInfo: "New sqlite feature: RETURNING. Read more at: "
            "https://sqlite.org/releaselog/3_35_0.html",
      ),
    );

    test(
      "Sync Updates",
      () async {
        String? localKnowledgeId = await getLocalKnowledgeId();
        expect(localKnowledgeId, equals(null));
        await database.syncInto(database.persons).syncInsert(
              PersonsCompanion(name: Value("A")),
            );
        localKnowledgeId = await getLocalKnowledgeId();
        expect(
          localKnowledgeId,
          allOf(
            isNot(equals(null)),
            isNot(equals("")),
          ),
        );
        final ret1 = await (database.select(database.persons)
              ..where((tbl) => tbl.name.equals("A")))
            .getSingle();
        final affected1 = await database
            .syncUpdate(database.persons)
            .syncReplace(ret1.copyWith(name: "B"));
        expect(affected1, equals(true));
        final ret2 = await (database.select(database.persons)
              ..where((tbl) => tbl.name.equals("B")))
            .getSingle();
        expect(ret2.name, equals("B"));
        expect(ret2.syncId, equals(syncId));
        expect(ret2.knowledgeId, equals(localKnowledgeId));
        expect(ret2.synced, equals(false));
        expect(ret2.deleted, equals(false));
        await (database.syncUpdate(database.persons)
              ..where((tbl) => tbl.id.equals(ret2.id)))
            .syncWrite(ret2.toCompanion(true).copyWith(
                  name: Value("C"),
                  age: Value(10),
                ));
        final ret3 = await (database.select(database.persons)
              ..where((tbl) => tbl.name.equals("C") & tbl.age.equals(10)))
            .getSingle();
        expect(ret3.name, equals("C"));
        expect(ret3.age, equals(10));
        expect(ret3.syncId, equals(syncId));
        expect(ret3.knowledgeId, equals(localKnowledgeId));
        expect(ret3.synced, equals(false));
        expect(ret3.deleted, equals(false));
      },
    );

    test(
      "Sync Updates Try Messing Sync Fields",
      () async {
        String? localKnowledgeId = await getLocalKnowledgeId();
        expect(localKnowledgeId, equals(null));
        await database.syncInto(database.persons).syncInsert(
              PersonsCompanion(name: Value("A")),
            );
        localKnowledgeId = await getLocalKnowledgeId();
        expect(
          localKnowledgeId,
          allOf(
            isNot(equals(null)),
            isNot(equals("")),
          ),
        );
        final ret1 = await (database.select(database.persons)
              ..where((tbl) => tbl.name.equals("A")))
            .getSingle();
        // We try to deliberately mess with the sync fields values using
        // syncReplace (id is omitted because if we use different id, the row
        // will not be updated. This is the nature of Moor's replace.)
        final affected1 = await database
            .syncUpdate(database.persons)
            .syncReplace(ret1.copyWith(
              name: "B",
              syncId: "Whatever1",
              knowledgeId: "Whatever2",
              synced: true,
              deleted: true,
            ));
        expect(affected1, equals(true));
        final ret2 = await (database.select(database.persons)
              ..where((tbl) => tbl.name.equals("B")))
            .getSingle();
        expect(ret2.name, equals("B"));
        expect(ret2.syncId, equals(syncId));
        expect(ret2.knowledgeId, equals(localKnowledgeId));
        expect(ret2.synced, equals(false));
        expect(ret2.deleted, equals(false));
        // We try to deliberately mess with the sync fields values using
        // syncWrite
        await (database.syncUpdate(database.persons)
              ..where((tbl) => tbl.id.equals(ret2.id)))
            .syncWrite(ret2.toCompanion(true).copyWith(
                  name: Value("C"),
                  age: Value(10),
                  id: Value("XXX"),
                  syncId: Value("Whatever1"),
                  knowledgeId: Value("Whatever2"),
                  synced: Value(true),
                  deleted: Value(true),
                ));
        final ret3 = await (database.select(database.persons)
              ..where((tbl) => tbl.name.equals("C") & tbl.age.equals(10)))
            .getSingle();
        expect(ret3.name, equals("C"));
        expect(ret3.age, equals(10));
        expect(ret3.syncId, equals(syncId));
        expect(ret3.knowledgeId, equals(localKnowledgeId));
        expect(ret3.synced, equals(false));
        expect(ret3.deleted, equals(false));
      },
    );

    test(
      "Sync Deletes",
      () async {
        String? localKnowledgeId = await getLocalKnowledgeId();
        expect(localKnowledgeId, equals(null));
        await database.syncInto(database.persons).syncInsert(
              PersonsCompanion(name: Value("A")),
            );
        localKnowledgeId = await getLocalKnowledgeId();
        expect(
          localKnowledgeId,
          allOf(
            isNot(equals(null)),
            isNot(equals("")),
          ),
        );
        await database.syncInto(database.persons).syncInsert(
              PersonsCompanion(name: Value("B")),
            );
        await database.syncInto(database.persons).syncInsert(
              PersonsCompanion(name: Value("C")),
            );
        final deletedRowCount1 = await (database.syncDelete(database.persons)
              ..where((tbl) => tbl.name.equals("A")))
            .go();
        expect(deletedRowCount1, equals(1));
        final physical1 = await (database.select(database.persons)
              ..where((tbl) => tbl.name.equals("A")))
            .getSingle();
        expect(physical1.syncId, equals(syncId));
        expect(physical1.knowledgeId, equals(localKnowledgeId));
        expect(physical1.synced, equals(false));
        expect(physical1.deleted, equals(true));
        final deletedRowCount2 = await (database.syncDelete(database.persons)
              ..where((tbl) => tbl.name.equals("B") | tbl.name.equals("C")))
            .go();
        expect(deletedRowCount2, equals(2));
        final col2 = await (database.select(database.persons)
              ..where((tbl) => tbl.name.equals("B") | tbl.name.equals("C")))
            .get();
        expect(col2.length, equals(2));
        expect(col2[0].syncId, equals(syncId));
        expect(col2[0].knowledgeId, equals(localKnowledgeId));
        expect(col2[0].synced, equals(false));
        expect(col2[0].deleted, equals(true));
        expect(col2[1].syncId, equals(syncId));
        expect(col2[1].knowledgeId, equals(localKnowledgeId));
        expect(col2[1].synced, equals(false));
        expect(col2[1].deleted, equals(true));
      },
    );

    test(
      "Transactions",
      () async {
        await database.transaction(() async {
          String? localKnowledgeId = await getLocalKnowledgeId();
          expect(localKnowledgeId, equals(null));
          await database.syncInto(database.persons).syncInsert(
                PersonsCompanion(name: Value("A")),
              );
          localKnowledgeId = await getLocalKnowledgeId();
          expect(
            localKnowledgeId,
            allOf(
              isNot(equals(null)),
              isNot(equals("")),
            ),
          );
          await database.syncInto(database.persons).syncInsert(
                PersonsCompanion(name: Value("B")),
              );
          final personA = await (database.syncSelect(database.syncPersons)
                ..where((tbl) => tbl.name.equals("A")))
              .getSingle();
          await database
              .syncUpdate(database.persons)
              .syncReplace(personA.copyWith(age: 10));
          await (database.syncDelete(database.persons)
                ..where((tbl) => tbl.name.equals("B")))
              .go();
        });
        final col1 = await database.syncSelect(database.syncPersons).get();
        expect(col1.length, equals(1));
        final person1 = await (database.syncSelect(database.syncPersons)
              ..where((tbl) => tbl.name.equals("A")))
            .getSingle();
        expect(person1.age, equals(10));

        try {
          await database.transaction(() async {
            await database.syncDelete(database.persons).go();
            throw Exception("deliberate error to cancel transaction");
          });
        } catch (e) {
          assert(e is Exception);
        }

        final col2 = await database.syncSelect(database.syncPersons).get();
        expect(col2.length, equals(1));
        final person2 = await (database.syncSelect(database.syncPersons)
              ..where((tbl) => tbl.name.equals("A")))
            .getSingle();
        expect(person2.age, equals(10));
      },
    );

    test(
      "Sync Selects",
      () async {
        String? localKnowledgeId = await getLocalKnowledgeId();
        expect(localKnowledgeId, equals(null));
        await database.syncInto(database.persons).syncInsert(
              PersonsCompanion(
                name: Value("A"),
                age: Value(10),
              ),
            );
        localKnowledgeId = await getLocalKnowledgeId();
        expect(
          localKnowledgeId,
          allOf(
            isNot(equals(null)),
            isNot(equals("")),
          ),
        );
        await database.syncInto(database.persons).syncInsert(
              PersonsCompanion(
                name: Value("B"),
                age: Value(20),
              ),
            );
        await database.syncInto(database.persons).syncInsert(
              PersonsCompanion(
                name: Value("C"),
                age: Value(30),
              ),
            );

        await (database.syncDelete(database.persons)
              ..where((tbl) => tbl.name.equals("B")))
            .go();
        final colRemaining1 =
            await database.syncSelect(database.syncPersons).get();
        expect(colRemaining1.length, equals(2));

        final colRemaining2 =
            await (database.syncSelectOnly(database.syncPersons)
                  ..addColumns([
                    database.persons.name,
                    database.persons.age,
                  ])
                  ..orderBy([OrderingTerm(expression: database.persons.name)]))
                .get();
        expect(colRemaining2.length, equals(2));
        expect(colRemaining2[0].read(database.persons.name), equals("A"));
        expect(colRemaining2[1].read(database.persons.name), equals("C"));
      },
    );

    test(
      "Sync Watches",
      () async {
        final stream = database.syncSelect(database.syncPersons).watch();

        int numberOfCall = 0;
        String? action;

        stream.listen((persons) {
          numberOfCall++;

          if (numberOfCall == 1) {
            expect(action, equals(null));
          } else if (numberOfCall == 2) {
            expect(action, equals("InsertCall"));
            expect(persons.length, equals(1));
            expect(persons[0].name, equals("A"));
          } else if (numberOfCall == 3) {
            expect(action, equals("UpdateCall"));
            expect(persons.length, equals(1));
            expect(persons[0].name, equals("B"));
          } else if (numberOfCall == 4) {
            expect(action, equals("DeleteCall"));
            expect(persons.length, equals(0));
          }
        });
        // pump now, because the listen handler will be automatically invoked
        // during the first attach
        await pumpEventQueue(times: 1);

        action = "InsertCall";
        database.syncInto(database.persons).syncInsert(
              PersonsCompanion(
                name: Value("A"),
              ),
            );
        await pumpEventQueue(times: 1);

        action = "UpdateCall";
        final person =
            await database.syncSelect(database.syncPersons).getSingle();
        database.syncUpdate(database.persons).syncReplace(
              person.copyWith(
                name: "B",
              ),
            );
        await pumpEventQueue(times: 1);

        action = "DeleteCall";
        (database.syncDelete(database.persons)
              ..where((tbl) => tbl.name.equals("B")))
            .go();
        await pumpEventQueue(times: 1);
      },
    );

    test(
      "Sync Joins",
      () async {
        await database.syncInto(database.areas).syncInsert(
              AreasCompanion(
                city: Value("Jakarta"),
                district: Value("Menteng"),
              ),
            );
        final area = await database.select(database.areas).getSingle();
        await database.syncInto(database.persons).syncInsert(
              PersonsCompanion(
                name: Value("A"),
                vaccinationAreaPk: Value(area.pk),
              ),
            );

        // Standard join should work first
        final joined1 = (await database.select(database.persons).join([
          leftOuterJoin(
            database.areas,
            database.areas.pk.equalsExp(database.persons.vaccinationAreaPk),
          )
        ]).get())
            .map((row) {
          return _PersonJoined(
            person: row.readTable(database.persons),
            areaData: row.readTableOrNull(database.areas),
          );
        }).toList();
        expect(joined1.length, equals(1));
        expect(joined1[0].person.name, equals("A"));
        expect(joined1[0].areaData, isNot(equals(null)));
        expect(joined1[0].areaData!.city, equals("Jakarta"));

        // Now we SyncDelete the reference, it should not throw error because
        // it's doing soft-delete.
        // The join should work by returning null on the reference
        await expectLater(
          database.syncDelete(database.areas).go(),
          completion(equals(1)),
        );
        final deletedArea = await database.select(database.areas).getSingle();
        expect(deletedArea.syncDeleted, equals(true));
        final joined2 =
            (await database.syncSelect(database.syncPersons).syncJoin([
          leftOuterJoin(
            database.syncAreas,
            database.areas.pk.equalsExp(database.persons.vaccinationAreaPk),
          )
        ]).get())
                .map((row) {
          return _PersonJoined(
            person: row.readTable(database.syncPersons),
            areaData: row.readTableOrNull(database.syncAreas),
          );
        }).toList();
        expect(joined2.length, equals(1));
        expect(joined2[0].person.name, equals("A"));
        expect(joined2[0].areaData, equals(null));

        // Now we SyncDelete the main table, join should return empty row.
        await expectLater(
          database.syncDelete(database.persons).go(),
          completion(equals(1)),
        );
        final deletedPerson =
            await database.select(database.persons).getSingle();
        expect(deletedPerson.deleted, equals(true));
        final joined3 =
            (await database.syncSelect(database.syncPersons).syncJoin([
          leftOuterJoin(
            database.syncAreas,
            database.areas.pk.equalsExp(database.persons.vaccinationAreaPk),
          )
        ]).get())
                .map((row) {
          return _PersonJoined(
            person: row.readTable(database.syncPersons),
            areaData: row.readTableOrNull(database.syncAreas),
          );
        }).toList();
        expect(joined3.length, equals(0));
      },
    );

    test(
      "Sync @UseRowClass Tests",
      () async {
        String? localKnowledgeId = await getLocalKnowledgeId();
        expect(localKnowledgeId, equals(null));
        CustomObject data = CustomObject();
        data.fieldString = "A";
        await database.syncInto(database.customObjects).syncInsert(data);
        localKnowledgeId = await getLocalKnowledgeId();
        expect(
          localKnowledgeId,
          allOf(
            isNot(equals(null)),
            isNot(equals("")),
          ),
        );
        final ret1 = await (database.select(database.customObjects)
              ..where((tbl) => tbl.fieldString.equals("A")))
            .getSingle();
        expect(ret1.fieldString, equals("A"));
        expect(ret1.syncId, equals(syncId));
        expect(ret1.knowledgeId, equals(localKnowledgeId));
        expect(ret1.synced, equals(false));
        expect(ret1.deleted, equals(false));

        ret1.fieldString = "B";
        await database.syncUpdate(database.customObjects).syncReplace(ret1);
        final ret2 = await (database.select(database.customObjects)
              ..where((tbl) => tbl.fieldString.equals("B")))
            .getSingle();
        expect(ret2.fieldString, equals("B"));
        expect(ret2.syncId, equals(syncId));
        expect(ret2.knowledgeId, equals(localKnowledgeId));
        expect(ret2.synced, equals(false));
        expect(ret2.deleted, equals(false));
        await (database.syncDelete(database.customObjects)
              ..where((tbl) => tbl.fieldString.equals("B")))
            .go();
        final col1 = await database.select(database.customObjects).get();
        expect(col1.length, equals(1));
        expect(col1[0].syncId, equals(syncId));
        expect(col1[0].knowledgeId, equals(localKnowledgeId));
        expect(col1[0].synced, equals(false));
        expect(col1[0].deleted, equals(true));
        final col2 =
            await database.syncSelect(database.syncCustomObjects).get();
        expect(col2.length, equals(0));
      },
    );
  });

  group("Multi User Tests", () {
    late Database database;

    setUp(() async {
      database = await Helper.setUpDatabase(
        testFilesFolder: testFilesFolder,
        databaseFileName: "netcoresync_operation_test_multi.db",
        useInMemoryDatabase: useInMemoryDatabase,
        logSqlStatements: logSqlStatements,
      );
      await database.netCoreSyncInitialize();
    });

    tearDown(() async {
      await Helper.tearDownDatabase(database);
    });

    Future<String?> getLocalKnowledgeId(String syncId) async {
      final queryRow = await database
          .customSelect(
              "SELECT ${database.netCoreSyncKnowledges.id.escapedName} AS id "
              "FROM ${database.netCoreSyncKnowledges.actualTableName} WHERE "
              "${database.netCoreSyncKnowledges.syncId.escapedName} = '$syncId'"
              " AND ${database.netCoreSyncKnowledges.local.escapedName} = 1")
          .getSingleOrNull();
      return queryRow?.data['id'];
    }

    test("Insert on behalf of Linked User", () async {
      database.netCoreSyncSetSyncIdInfo(SyncIdInfo(
        syncId: "abc",
        linkedSyncIds: [
          "def",
        ],
      ));

      await database
          .syncInto(database.persons)
          .syncInsert(PersonsCompanion(name: Value("A")));

      database.netCoreSyncSetActiveSyncId("def");

      await database
          .syncInto(database.persons)
          .syncInsert(PersonsCompanion(name: Value("B")));

      final col1 = await (database.syncSelect(database.syncPersons)
            ..orderBy([
              (t) => OrderingTerm(expression: t.name),
            ]))
          .get();

      String? knowledgeId = await getLocalKnowledgeId("abc");
      expect(knowledgeId, isNot(equals(null)));
      expect(col1.length, equals(2));
      expect(col1[0].name, equals("A"));
      expect(col1[0].syncId, equals("abc"));
      expect(col1[0].knowledgeId, equals(knowledgeId));
      expect(col1[0].synced, equals(false));
      expect(col1[0].deleted, equals(false));
      expect(col1[1].name, equals("B"));
      expect(col1[1].syncId, equals("def"));
      expect(col1[1].knowledgeId, equals(knowledgeId));
      expect(col1[1].synced, equals(false));
      expect(col1[1].deleted, equals(false));
    });

    test("Update Sync'ed Linked User data", () async {
      // Simulate existing synchronized "def" user data
      NetCoreSyncKnowledge defKnowledge = NetCoreSyncKnowledge();
      defKnowledge.id = Uuid().v4();
      defKnowledge.syncId = "def";
      defKnowledge.local = false;
      await database.into(database.netCoreSyncKnowledges).insert(defKnowledge);
      await database.into(database.persons).insert(PersonsCompanion(
            name: Value("B"),
            syncId: Value(defKnowledge.syncId),
            knowledgeId: Value(defKnowledge.id),
            synced: Value(true),
            deleted: Value(false),
          ));

      database.netCoreSyncSetSyncIdInfo(SyncIdInfo(
        syncId: "abc",
        linkedSyncIds: [
          "def",
        ],
      ));

      var defData = await database.syncSelect(database.syncPersons).getSingle();
      await database
          .syncUpdate(database.persons)
          .syncReplace(defData.toCompanion(true).copyWith(
                name: Value("C"),
              ));

      final col1 = await database.syncSelect(database.syncPersons).get();
      expect(col1.length, equals(1));
      expect(col1[0].name, equals("C"));
      expect(col1[0].syncId, equals(defKnowledge.syncId));
      expect(col1[0].knowledgeId, equals(defKnowledge.id));
      expect(col1[0].synced, equals(false));
      expect(col1[0].deleted, equals(false));
    });

    test("Delete Sync'ed Linked User data", () async {
      // Simulate existing synchronized "def" user data
      NetCoreSyncKnowledge defKnowledge = NetCoreSyncKnowledge();
      defKnowledge.id = Uuid().v4();
      defKnowledge.syncId = "def";
      defKnowledge.local = false;
      await database.into(database.netCoreSyncKnowledges).insert(defKnowledge);
      await database.into(database.persons).insert(PersonsCompanion(
            name: Value("B"),
            syncId: Value(defKnowledge.syncId),
            knowledgeId: Value(defKnowledge.id),
            synced: Value(true),
            deleted: Value(false),
          ));

      database.netCoreSyncSetSyncIdInfo(SyncIdInfo(
        syncId: "abc",
        linkedSyncIds: [
          "def",
        ],
      ));

      var defData = await database.syncSelect(database.syncPersons).getSingle();
      await (database.syncDelete(database.persons)
            ..where((tbl) => tbl.id.equals(defData.id)))
          .go();

      final col1 = await database.select(database.persons).get();
      expect(col1.length, equals(1));
      expect(col1[0].syncId, equals(defKnowledge.syncId));
      expect(col1[0].knowledgeId, equals(defKnowledge.id));
      expect(col1[0].synced, equals(false));
      expect(col1[0].deleted, equals(true));
    });

    test("Each User Inserts and Selects", () async {
      database.netCoreSyncSetSyncIdInfo(SyncIdInfo(
        syncId: "abc",
      ));

      await database
          .syncInto(database.persons)
          .syncInsert(PersonsCompanion(name: Value("A")));

      database.netCoreSyncSetSyncIdInfo(SyncIdInfo(
        syncId: "def",
      ));

      await database
          .syncInto(database.persons)
          .syncInsert(PersonsCompanion(name: Value("B")));

      final col1 = await (database.select(database.persons)
            ..orderBy([
              (t) => OrderingTerm(expression: t.name),
            ]))
          .get();

      expect(col1.length, equals(2));
      String? abcKnowledgeId = await getLocalKnowledgeId("abc");
      expect(abcKnowledgeId, isNot(equals(null)));
      expect(col1[0].name, equals("A"));
      expect(col1[0].syncId, equals("abc"));
      expect(col1[0].knowledgeId, equals(abcKnowledgeId));
      expect(col1[0].synced, equals(false));
      expect(col1[0].deleted, equals(false));
      String? defKnowledgeId = await getLocalKnowledgeId("def");
      expect(defKnowledgeId, isNot(equals(null)));
      expect(col1[1].name, equals("B"));
      expect(col1[1].syncId, equals("def"));
      expect(col1[1].knowledgeId, equals(defKnowledgeId));
      expect(col1[1].synced, equals(false));
      expect(col1[1].deleted, equals(false));

      database.netCoreSyncSetSyncIdInfo(SyncIdInfo(
        syncId: "abc",
        linkedSyncIds: [
          "def",
        ],
      ));

      final col2 = await (database.syncSelect(database.syncPersons)
            ..orderBy([(o) => OrderingTerm(expression: o.name)]))
          .get();
      expect(col2.length, equals(2));
      expect(col2[0].name, equals("A"));
      expect(col2[1].name, equals("B"));

      database.netCoreSyncSetSyncIdInfo(SyncIdInfo(
        syncId: "def",
      ));

      final col3 = await database.syncSelect(database.syncPersons).get();
      expect(col3.length, equals(1));
      expect(col3[0].name, equals("B"));
    });
  });
}

class _PersonJoined {
  final Person person;
  final AreaData? areaData;
  const _PersonJoined({required this.person, this.areaData});
}
