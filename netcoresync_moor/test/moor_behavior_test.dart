import 'package:moor/moor.dart';
import 'package:test/test.dart';
import 'package:version/version.dart';
import 'data/custom_objects.dart';
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

  test(
    "Default values on Insert",
    () async {
      await database.into(database.persons).insert(
            PersonsCompanion(),
          );
      final persons = await database.select(database.persons).get();
      expect(persons.length, equals(1));
      final person = persons[0];
      expect(person.id.length, equals(36));
      expect(person.name, equals(""));
      expect(person.birthday.millisecond,
          closeTo(DateTime.now().millisecond, 1000));
      expect(person.age, equals(0));
      expect(person.isForeigner, equals(false));
      expect(person.isVaccinated, equals(null));
      expect(person.vaccineName, equals(null));
      expect(person.vaccinationDate, equals(null));
      expect(person.vaccinePhase, equals(null));
      expect(person.vaccinationAreaPk, equals(null));
    },
  );

  test(
    "Primary Key Constraint",
    () async {
      await database.into(database.persons).insert(
            PersonsCompanion(),
          );
      final person = (await database.select(database.persons).get())[0];
      await expectLater(
        () async {
          await database.into(database.persons).insert(person);
        },
        throwsA(isA<Exception>()),
      );
    },
  );

  test(
    "Single Column Unique Constraint",
    () async {
      await database.into(database.persons).insert(
            PersonsCompanion(
              name: Value("John Doe"),
            ),
          );
      await expectLater(
        () async {
          await database.into(database.persons).insert(PersonsCompanion(
                name: Value("John Doe"),
              ));
        },
        throwsA(isA<Exception>()),
      );
    },
  );

  test(
    "Multiple Columns Unique Constraint",
    () async {
      await database.into(database.areas).insert(AreasCompanion(
            city: Value("Jakarta"),
            district: Value("Menteng"),
          ));
      await expectLater(
        () async {
          await database.into(database.areas).insert(AreasCompanion(
                city: Value("Jakarta"),
                district: Value("Menteng"),
              ));
        },
        throwsA(isA<Exception>()),
      );
    },
  );

  test(
    "Foreign Key Constraint",
    () async {
      await database.into(database.areas).insert(AreasCompanion());
      final area = (await database.select(database.areas).get())[0];
      await database.into(database.persons).insert(
            PersonsCompanion(
              vaccinationAreaPk: Value(area.pk),
            ),
          );
      await expectLater(
        () async {
          await (database.delete(database.areas)
                ..where((tbl) => tbl.pk.equals(area.pk)))
              .go();
        },
        throwsA(isA<Exception>()),
      );
    },
  );

  test(
    "Moor's insertOnConflictUpdate",
    () async {
      await database.into(database.persons).insert(
            PersonsCompanion(
              name: Value("John Doe"),
            ),
          );
      final person = (await database.select(database.persons).get())[0];
      await database
          .into(database.persons)
          .insertOnConflictUpdate(person.toCompanion(true).copyWith(
                name: Value("Jane Doe"),
              ));
      final persons = await database.select(database.persons).get();
      expect(persons.length, equals(1));
      expect(persons[0].name, equals("Jane Doe"));
    },
  );

  test(
    "Moor's insert with DoUpdate",
    () async {
      await database.into(database.persons).insert(
            PersonsCompanion(
              name: Value("John Doe"),
            ),
          );
      await database.into(database.persons).insert(
          PersonsCompanion(
            name: Value("John Doe"),
          ),
          onConflict: DoUpdate(
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
    },
  );

  test(
    "Moor's insert with UpsertMultiple",
    () async {
      await database.into(database.persons).insert(
            PersonsCompanion(
              name: Value("John Doe"),
            ),
          );
      await database.into(database.persons).insert(
          PersonsCompanion(
            name: Value("John Doe"),
          ),
          onConflict: UpsertMultiple([
            DoUpdate(
              (old) => PersonsCompanion.custom(
                name:
                    Constant("should never reached here because target is id"),
              ),
              target: [
                database.persons.id,
              ],
            ),
            DoUpdate(
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
    },
    skip: Helper.shouldSkip(
      currentVersion,
      Version.parse("3.35.0"),
      moreInfo:
          "New sqlite feature: multiple ON CONFLICT. Read more at: https://sqlite.org/releaselog/3_35_0.html",
    ),
  );

  test(
    "Moor's insertReturning",
    () async {
      final person = await database.into(database.persons).insertReturning(
            PersonsCompanion(name: Value("John Doe")),
          );
      expect(person.name, equals("John Doe"));
    },
    skip: Helper.shouldSkip(
      currentVersion,
      Version.parse("3.35.0"),
      moreInfo:
          "New sqlite feature: RETURNING. Read more at: https://sqlite.org/releaselog/3_35_0.html",
    ),
  );

  test(
    "Moor's selects",
    () async {
      await database.into(database.persons).insert(
            PersonsCompanion(name: Value("A")),
          );
      await database.into(database.persons).insert(
            PersonsCompanion(name: Value("B")),
          );
      await database.into(database.persons).insert(
            PersonsCompanion(name: Value("C")),
          );
      final col1 = await database.select(database.persons).get();
      expect(col1.length, equals(3));
      final col2 = await (database.select(database.persons)
            ..where((tbl) => tbl.name.equals("A") | tbl.name.equals("B")))
          .get();
      expect(col2.length, equals(2));
      final ret1 = await (database.select(database.persons)
            ..where((tbl) => tbl.name.equals("A")))
          .getSingle();
      expect(ret1.name, equals("A"));
      final ret2 = await (database.select(database.persons)
            ..where((tbl) => tbl.name.equals("X")))
          .getSingleOrNull();
      expect(ret2, equals(null));
    },
  );

  test(
    "Moor's updates",
    () async {
      await database.into(database.persons).insert(
            PersonsCompanion(name: Value("A")),
          );
      final ret1 = await (database.select(database.persons)
            ..where((tbl) => tbl.name.equals("A")))
          .getSingle();
      final affected1 = await database
          .update(database.persons)
          .replace(ret1.copyWith(name: "B"));
      expect(affected1, equals(true));
      final ret2 = await (database.select(database.persons)
            ..where((tbl) => tbl.name.equals("B")))
          .getSingle();
      expect(ret2.name, equals("B"));
      await (database.update(database.persons)
            ..where((tbl) => tbl.id.equals(ret2.id)))
          .write(ret2.toCompanion(true).copyWith(
                name: Value("C"),
                age: Value(10),
              ));
      final ret3 = await (database.select(database.persons)
            ..where((tbl) => tbl.name.equals("C") & tbl.age.equals(10)))
          .getSingle();
      expect(ret3.name, equals("C"));
      expect(ret3.age, equals(10));
    },
  );

  test(
    "Moor's deletes",
    () async {
      await database.into(database.persons).insert(
            PersonsCompanion(name: Value("A")),
          );
      await database.into(database.persons).insert(
            PersonsCompanion(name: Value("B")),
          );
      await database.into(database.persons).insert(
            PersonsCompanion(name: Value("C")),
          );
      await (database.delete(database.persons)
            ..where((tbl) => tbl.name.equals("A")))
          .go();
      final col1 = await database.select(database.persons).get();
      expect(col1.length, equals(2));
      await (database.delete(database.persons)
            ..where((tbl) => tbl.name.equals("B") | tbl.name.equals("C")))
          .go();
      final col2 = await database.select(database.persons).get();
      expect(col2.length, equals(0));
    },
  );

  test(
    "Moor's transactions",
    () async {
      await database.transaction(() async {
        await database.into(database.persons).insert(
              PersonsCompanion(name: Value("A")),
            );
        await database.into(database.persons).insert(
              PersonsCompanion(name: Value("B")),
            );
        final personA = await (database.select(database.persons)
              ..where((tbl) => tbl.name.equals("A")))
            .getSingle();
        await database
            .update(database.persons)
            .replace(personA.copyWith(age: 10));
        await (database.delete(database.persons)
              ..where((tbl) => tbl.name.equals("B")))
            .go();
      });
      final col1 = await database.select(database.persons).get();
      expect(col1.length, equals(1));
      final person1 = await (database.select(database.persons)
            ..where((tbl) => tbl.name.equals("A")))
          .getSingle();
      expect(person1.age, equals(10));

      try {
        await database.transaction(() async {
          await database.delete(database.persons).go();
          throw Exception("deliberate error to cancel transaction");
        });
      } catch (e) {
        assert(e is Exception);
      }

      final col2 = await database.select(database.persons).get();
      expect(col2.length, equals(1));
      final person2 = await (database.select(database.persons)
            ..where((tbl) => tbl.name.equals("A")))
          .getSingle();
      expect(person2.age, equals(10));
    },
  );

  test(
    "Moor's @UseRowClass tests",
    () async {
      CustomObject data = CustomObject();
      data.fieldString = "A";
      await database.into(database.customObjects).insert(data);
      final ret1 = await (database.select(database.customObjects)
            ..where((tbl) => tbl.fieldString.equals("A")))
          .getSingle();
      expect(ret1.fieldString, equals("A"));
      ret1.fieldString = "B";
      await database.update(database.customObjects).replace(ret1);
      final ret2 = await (database.select(database.customObjects)
            ..where((tbl) => tbl.fieldString.equals("B")))
          .getSingle();
      expect(ret2.fieldString, equals("B"));
      await (database.delete(database.customObjects)
            ..where((tbl) => tbl.fieldString.equals("B")))
          .go();
      final col1 = await database.select(database.customObjects).get();
      expect(col1.length, equals(0));
    },
  );
}
