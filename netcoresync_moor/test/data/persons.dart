import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';

@NetCoreSyncTable()
class Persons extends Table {
  TextColumn get id =>
      text().withLength(max: 36).clientDefault(() => Uuid().v4())();
  TextColumn get name =>
      text().withLength(max: 255).withDefault(Constant("")).customConstraint(
          "NOT NULL DEFAULT ''")(); // If using customConstraints, we have to repeat all attached constraints in SQL language
  DateTimeColumn get birthday =>
      dateTime().clientDefault(() => DateTime.now())();
  IntColumn get age => integer().withDefault(const Constant(0))();
  BoolColumn get isForeigner => boolean().withDefault(const Constant(false))();

  BoolColumn get isVaccinated => boolean().nullable()();
  TextColumn get vaccineName => text().withLength(max: 255).nullable()();
  DateTimeColumn get vaccinationDate => dateTime().nullable()();
  IntColumn get vaccinePhase => integer().nullable()();
  TextColumn get vaccinationAreaPk => text().nullable().customConstraint(
      "NULLABLE REFERENCES area(pk)")(); // If using customConstraints, we have to repeat all attached constraints in SQL language

  TextColumn get syncId =>
      text().withLength(max: 36).withDefault(Constant(""))();
  TextColumn get knowledgeId =>
      text().withLength(max: 36).withDefault(Constant(""))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {
        id,
        syncId,
      };

  @override
  List<String> get customConstraints => [
        "UNIQUE(sync_id, name)",
      ];

  @override
  String? get tableName => "person";
}
