import 'package:moor/moor.dart';
import 'package:test/test.dart';
import 'package:version/version.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'data/database.dart';
import 'data/custom_objects.dart';
import 'utils/helper.dart';

void main() async {
  String testFilesFolder = ".test_files";
  String databaseFileName = "netcoresync_moor_test.db";
  bool useInMemoryDatabase = true;
  bool logSqlStatements = false;

  // Obtain the running sqlite3 library version first to determine which tests to skip
  Version currentVersion = await Helper.getLibraryVersion(
    testFilesFolder: testFilesFolder,
    databaseFileName: databaseFileName,
    useInMemoryDatabase: useInMemoryDatabase,
    logSqlStatements: logSqlStatements,
  );

  group("Uninitialized Tests", () {
    late Database database;

    setUp(() async {
      database = await Helper.setUpDatabase(
        testFilesFolder: testFilesFolder,
        databaseFileName: databaseFileName,
        useInMemoryDatabase: useInMemoryDatabase,
        logSqlStatements: logSqlStatements,
      );
    });

    tearDown(() async {
      await Helper.tearDownDatabase(database);
    });

    test("Basic Validations", () async {
      // should throw Exception if not initialized yet
      await expectLater(
        () async {
          await database.syncSelect(database.persons).get();
        },
        throwsA(isA<NetCoreSyncNotInitializedException>()),
      );

      await database.netCoreSyncInitialize();

      // should throw Exception on selects if SyncIdInfo is not set yet
      await expectLater(
        () async {
          await database.syncSelect(database.syncPersons).get();
        },
        throwsA(isA<NetCoreSyncSyncIdInfoNotSetException>()),
      );
      // should throw Exception on inserts/updates/deletes if SyncIdInfo is not set yet
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
      // should throw Exception if the table is not registered (not marked with @NetCoreSyncTable)
      await expectLater(
        () async {
          await database.transaction(() async {
            await database.syncSelect(database.netCoreSyncKnowledges).get();
          });
        },
        throwsA(isA<NetCoreSyncTypeNotRegisteredException>()),
      );
    });
  });

  group("Single User Tests", () {
    late Database database;
    late String syncId;

    setUp(() async {
      database = await Helper.setUpDatabase(
        testFilesFolder: testFilesFolder,
        databaseFileName: databaseFileName,
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
              "SELECT ${database.netCoreSyncKnowledges.id.escapedName} AS id FROM ${database.netCoreSyncKnowledges.actualTableName} WHERE ${database.netCoreSyncKnowledges.syncId.escapedName} = '${database.netCoreSyncGetActiveSyncId()}' AND ${database.netCoreSyncKnowledges.local.escapedName} = 1")
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
        await expectLater(
          () async {
            await database.syncInto(database.persons).syncInsert(
                PersonsCompanion(
                  name: Value("John Doe"),
                ),
                onConflict: SyncDoUpdate(
                  (old) => PersonsCompanion.custom(
                    id: Constant("change id should not be allowed"),
                  ),
                ));
          },
          throwsA(isA<NetCoreSyncException>()),
        );
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
                      "should never reached here because target is id"),
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
        moreInfo:
            "New sqlite feature: multiple ON CONFLICT. Read more at: https://sqlite.org/releaselog/3_35_0.html",
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
        moreInfo:
            "New sqlite feature: RETURNING. Read more at: https://sqlite.org/releaselog/3_35_0.html",
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

    // test(
    //   "Sync Joins",
    //   () async {
    //     await database.transaction(() async {
    //       await database.syncInto(database.areas).syncInsert(
    //             AreasCompanion(
    //               city: Value("Jakarta"),
    //               district: Value("Menteng"),
    //             ),
    //           );
    //       final area = await database.select(database.areas).getSingle();
    //       await database.syncInto(database.persons).syncInsert(
    //             PersonsCompanion(
    //               name: Value("A"),
    //               vaccinationAreaPk: Value(area.pk),
    //             ),
    //           );

    //       // Standard join should work first
    //       final joined1 = (await database.select(database.persons).join([
    //         leftOuterJoin(
    //           database.areas,
    //           database.areas.pk.equalsExp(database.persons.vaccinationAreaPk),
    //         )
    //       ]).get())
    //           .map((row) {
    //         return _PersonJoined(
    //           person: row.readTable(database.persons),
    //           areaData: row.readTableOrNull(database.areas),
    //         );
    //       }).toList();
    //       expect(joined1.length, equals(1));
    //       expect(joined1[0].person.name, equals("A"));
    //       expect(joined1[0].areaData, isNot(equals(null)));
    //       expect(joined1[0].areaData!.city, equals("Jakarta"));

    //       // Now we SyncDelete the reference, it should not throw error because it's doing soft-delete.
    //       // The join should work by returning null on the reference
    //       await expectLater(
    //         database.syncDelete(database.areas).go(),
    //         completion(equals(1)),
    //       );
    //       final deletedArea = await database.select(database.areas).getSingle();
    //       expect(deletedArea.syncDeleted, equals(true));
    //       final joined2 =
    //           (await database.syncSelect(database.syncPersons).syncJoin([
    //         leftOuterJoin(
    //           database.syncAreas,
    //           database.areas.pk.equalsExp(database.persons.vaccinationAreaPk),
    //         )
    //       ]).get())
    //               .map((row) {
    //         return _PersonJoined(
    //           person: row.readTable(database.syncPersons),
    //           areaData: row.readTableOrNull(database.syncAreas),
    //         );
    //       }).toList();
    //       expect(joined2.length, equals(1));
    //       expect(joined2[0].person.name, equals("A"));
    //       expect(joined2[0].areaData, equals(null));

    //       // Now we SyncDelete the main table, join should return empty row.
    //       await expectLater(
    //         database.syncDelete(database.persons).go(),
    //         completion(equals(1)),
    //       );
    //       final deletedPerson =
    //           await database.select(database.persons).getSingle();
    //       expect(deletedPerson.deleted, equals(true));
    //       final joined3 =
    //           (await database.syncSelect(database.syncPersons).syncJoin([
    //         leftOuterJoin(
    //           database.syncAreas,
    //           database.areas.pk.equalsExp(database.persons.vaccinationAreaPk),
    //         )
    //       ]).get())
    //               .map((row) {
    //         return _PersonJoined(
    //           person: row.readTable(database.syncPersons),
    //           areaData: row.readTableOrNull(database.syncAreas),
    //         );
    //       }).toList();
    //       expect(joined3.length, equals(0));
    //     });
    //   },
    // );

    // test(
    //   "Sync @UseRowClass Tests",
    //   () async {
    //     await database.transaction(() async {
    //       CustomObject data = CustomObject();
    //       data.fieldString = "A";
    //       await database.syncInto(database.customObjects).syncInsert(data);
    //       final ret1 = await (database.select(database.customObjects)
    //             ..where((tbl) => tbl.fieldString.equals("A")))
    //           .getSingle();
    //       expect(ret1.fieldString, equals("A"));
    //       expect(ret1.timeStamp, equals(1));
    //       ret1.fieldString = "B";
    //       await database.syncUpdate(database.customObjects).syncReplace(ret1);
    //       final ret2 = await (database.select(database.customObjects)
    //             ..where((tbl) => tbl.fieldString.equals("B")))
    //           .getSingle();
    //       expect(ret2.fieldString, equals("B"));
    //       expect(ret2.timeStamp, equals(2));
    //       await (database.syncDelete(database.customObjects)
    //             ..where((tbl) => tbl.fieldString.equals("B")))
    //           .go();
    //       final col1 = await database.select(database.customObjects).get();
    //       expect(col1.length, equals(1));
    //       expect(col1[0].timeStamp, equals(3));
    //       expect(col1[0].deleted, equals(true));
    //       final col2 =
    //           await database.syncSelect(database.syncCustomObjects).get();
    //       expect(col2.length, equals(0));
    //     });
    //   },
    // );
  });
}

class _PersonJoined {
  final Person person;
  final AreaData? areaData;
  const _PersonJoined({required this.person, this.areaData});
}
