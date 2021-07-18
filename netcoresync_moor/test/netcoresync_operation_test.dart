import 'package:moor/moor.dart';
import 'package:test/test.dart';
import 'package:version/version.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'data/database.dart';
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
          await database.select(database.syncTable(database.persons)).get();
        },
        throwsA(isA<NetCoreSyncNotInitializedException>()),
      );

      database.netCoreSync_initialize();

      // should throw Exception if insert / update / delete operations is not wrapped inside Transaction
      await expectLater(
        () async {
          await database
              .syncInto(database.persons)
              .syncInsert(PersonsCompanion());
        },
        throwsA(isA<NetCoreSyncMustInsideTransactionException>()),
      );
      // should throw Exception if the table is not registered (not marked with @NetCoreSyncTable)
      await expectLater(
        () async {
          await database.transaction(() async {
            await database
                .select(database.syncTable(database.netCoreSyncKnowledges))
                .get();
          });
        },
        throwsA(isA<NetCoreSyncTypeNotRegisteredException>()),
      );
    });
  });

  group("Main Tests", () {
    late Database database;

    setUp(() async {
      database = await Helper.setUpDatabase(
        testFilesFolder: testFilesFolder,
        databaseFileName: databaseFileName,
        useInMemoryDatabase: useInMemoryDatabase,
        logSqlStatements: logSqlStatements,
      );
      database.netCoreSync_initialize();
    });

    tearDown(() async {
      await Helper.tearDownDatabase(database);
    });

    test(
      "Sync Insert",
      () async {
        await database.transaction(() async {
          await database.syncInto(database.persons).syncInsert(
                PersonsCompanion(name: Value("A")),
              );
          await database.syncInto(database.persons).syncInsert(
                PersonsCompanion(name: Value("B")),
              );
          final personA = await (database.select(database.persons)
                ..where((tbl) => tbl.name.equals("A")))
              .getSingle();
          expect(personA.timeStamp, equals(1));
          final personB = await (database.select(database.persons)
                ..where((tbl) => tbl.name.equals("B")))
              .getSingle();
          expect(personB.timeStamp, equals(2));
          final queryRow = await database
              .customSelect(
                  "SELECT ${database.netCoreSyncKnowledges.maxTimeStamp.escapedName} AS ts FROM ${database.netCoreSyncKnowledges.actualTableName} WHERE ${database.netCoreSyncKnowledges.local.escapedName} = 1")
              .getSingle();
          expect(queryRow.data["ts"], equals(2));
        });
      },
    );

    test(
      "Sync Insert with invalid mode",
      () async {
        await expectLater(
          () async {
            await database.transaction(() async {
              await database.syncInto(database.persons).syncInsert(
                    PersonsCompanion(),
                    mode: InsertMode.replace,
                  );
            });
          },
          throwsA(isA<NetCoreSyncException>()),
        );
        await expectLater(
          () async {
            await database.transaction(() async {
              await database.syncInto(database.persons).syncInsert(
                    PersonsCompanion(),
                    mode: InsertMode.insertOrReplace,
                  );
            });
          },
          throwsA(isA<NetCoreSyncException>()),
        );
      },
    );

    test(
      "Sync InsertOnConflictUpdate",
      () async {
        await database.transaction(() async {
          await database.syncInto(database.persons).syncInsert(
                PersonsCompanion(
                  name: Value("John Doe"),
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
          expect(persons[0].timeStamp, equals(2));
        });
      },
    );

    test(
      "Sync Insert with SyncDoUpdate",
      () async {
        await database.transaction(() async {
          await database.syncInto(database.persons).syncInsert(
                PersonsCompanion(
                  name: Value("John Doe"),
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
                  database.persons.name,
                ],
              ));
          final persons = await database.select(database.persons).get();
          expect(persons.length, equals(1));
          expect(persons[0].name, equals("John Doe 2"));
          expect(persons[0].timeStamp, equals(2));
        });
      },
    );

    test(
      "Sync Insert with invalid SyncDoUpdate",
      () async {
        await database.transaction(() async {
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
        });
      },
    );

    test(
      "Sync Insert with SyncUpsertMultiple",
      () async {
        await database.transaction(() async {
          await database.syncInto(database.persons).syncInsert(
                PersonsCompanion(
                  name: Value("John Doe"),
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
                    database.persons.name,
                  ],
                ),
              ]));
          final persons2 = await database.select(database.persons).get();
          expect(persons2.length, equals(1));
          expect(persons2[0].name, equals("John Doe 2"));
          expect(persons2[0].timeStamp, equals(2));
        });
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
        await database.transaction(() async {
          final person =
              await database.syncInto(database.persons).syncInsertReturning(
                    PersonsCompanion(name: Value("John Doe")),
                  );
          expect(person.name, equals("John Doe"));
          expect(person.timeStamp, equals(1));
        });
      },
      skip: Helper.shouldSkip(
        currentVersion,
        Version.parse("3.35.0"),
        moreInfo:
            "New sqlite feature: RETURNING. Read more at: https://sqlite.org/releaselog/3_35_0.html",
      ),
    );

    test(
      "Sync Selects",
      () async {
        // TODO: This should be later when Insert + Update + Delete finished, Update and Delete are ready, do them first!
        await database.transaction(() async {
          // print("TEST");
          // final dat1 = await database
          //     .syncInto(database.persons)
          //     .syncInsertReturning(PersonsCompanion(name: Value("A")));
          // print("TEST");
          // final numOfRowsDeleted = await (database.syncDelete(database.persons)
          //       ..where((tbl) => tbl.name.equals("A")))
          //     .go();
          // final rawPersons = await database.select(database.persons).get();
          // final persons =
          //     await database.select(database.syncTable(database.persons)).get();
          // print(persons);
          // print("TEST");
          // final joined =
          //     await database.select(database.syncTable(database.persons)).join([
          //   leftOuterJoin(database.syncTable(database.areas),
          //       database.areas.pk.equalsExp(database.persons.vaccinationAreaPk))
          // ]).get();
          // print(joined);
          // print("TEST");

          // await database.into(database.persons).insert(
          //       PersonsCompanion(name: Value("A")),
          //     );
          // await database.into(database.persons).insert(
          //       PersonsCompanion(name: Value("B")),
          //     );
          // await database.into(database.persons).insert(
          //       PersonsCompanion(name: Value("C")),
          //     );
          // final col1 = await database.select(database.persons).get();
          // expect(col1.length, equals(3));
          // final col2 = await (database.select(database.persons)
          //       ..where((tbl) => tbl.name.equals("A") | tbl.name.equals("B")))
          //     .get();
          // expect(col2.length, equals(2));
          // final ret1 = await (database.select(database.persons)
          //       ..where((tbl) => tbl.name.equals("A")))
          //     .getSingle();
          // expect(ret1.name, equals("A"));
          // final ret2 = await (database.select(database.persons)
          //       ..where((tbl) => tbl.name.equals("X")))
          //     .getSingleOrNull();
          // expect(ret2, equals(null));
        });
      },
    );
  });
}
