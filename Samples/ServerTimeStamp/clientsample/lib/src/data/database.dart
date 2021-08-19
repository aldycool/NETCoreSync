import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'areas.dart';
import 'persons.dart';
import 'custom_objects.dart';
import 'configurations.dart';

export 'database_shared.dart';

part 'database.g.dart';

@UseMoor(
  tables: [
    Areas,
    Persons,
    CustomObjects,
    Configurations,
    NetCoreSyncKnowledges,
  ],
)
class Database extends _$Database
    with NetCoreSyncClient, NetCoreSyncClientUser {
  Database(QueryExecutor queryExecutor) : super(queryExecutor);

  static String get fileName => "clientsample_data";

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (openingDetails) async {
          await customStatement("PRAGMA foreign_keys = ON");
        },
        onCreate: (Migrator m) {
          return m.createAll();
        },
      );

  static const String defaultConfigurationKeySyncUrl = "SYNCURL";
  static String defaultConfigurationValueSyncUrl = UniversalPlatform.isAndroid
      ? "wss://10.0.2.2:5001/netcoresyncserver"
      : "wss://localhost:5001/netcoresyncserver";

  Future<void> resetDatabase({bool includeConfiguration = false}) async {
    await delete(persons).go();
    await delete(areas).go();
    await delete(customObjects).go();
    await delete(netCoreSyncKnowledges).go();
    if (includeConfiguration) {
      await delete(configurations).go();
    }
  }

  Future<Configuration> _initSyncUrl() async {
    var configuration = await (select(configurations)
          ..where((tbl) => tbl.key.equals(defaultConfigurationKeySyncUrl)))
        .getSingleOrNull();
    if (configuration == null) {
      await into(configurations).insert(ConfigurationsCompanion(
          key: Value(defaultConfigurationKeySyncUrl),
          value: Value(defaultConfigurationValueSyncUrl)));
      configuration = await (select(configurations)
            ..where((tbl) => tbl.key.equals(defaultConfigurationKeySyncUrl)))
          .getSingle();
    }
    return configuration;
  }

  Future<String> getSyncUrl() async {
    final configuration = await _initSyncUrl();
    return configuration.value!;
  }

  Future<void> setSyncUrl(String value) async {
    final configuration = await _initSyncUrl();
    await update(configurations).replace(configuration.copyWith(value: value));
  }

  Stream<List<AreaData>> getAllAreas({bool viewDeletedOnly = false}) {
    if (!viewDeletedOnly) {
      return (syncSelect(syncAreas)
            ..orderBy([(t) => OrderingTerm(expression: t.city)]))
          .watch();
    } else {
      return (select(areas)
            ..where((tbl) => tbl.syncDeleted)
            ..orderBy([(t) => OrderingTerm(expression: t.city)]))
          .watch();
    }
  }

  Future<AreaData?> getAreaById(String id) {
    return (select(areas)..where((w) => w.pk.equals(id))).getSingleOrNull();
  }

  Future<int> insertArea(Insertable<AreaData> data) {
    return syncInto(syncAreas).syncInsert(data);
  }

  Future<bool> updateArea(Insertable<AreaData> data) {
    return syncUpdate(syncAreas).syncReplace(data);
  }

  Future<int> deleteArea(String id) {
    return (syncDelete(syncAreas)..where((tbl) => tbl.pk.equals(id))).go();
  }

  Future<bool> isAreaHasPersons(String id) async {
    return (await (syncSelect(syncPersons)
                  ..where((w) => w.vaccinationAreaPk.equals(id)))
                .get())
            .length >
        0;
  }

  Stream<List<PersonJoined>> getAllPersons({bool viewDeletedOnly = false}) {
    if (!viewDeletedOnly) {
      final query = (syncSelect(syncPersons).syncJoin([
        leftOuterJoin(syncAreas, areas.pk.equalsExp(persons.vaccinationAreaPk)),
      ])
        ..orderBy([OrderingTerm(expression: persons.name)]));
      return query.watch().map(
            (rows) => rows
                .map(
                  (row) => PersonJoined(
                    person: row.readTable(syncPersons),
                    area: row.readTableOrNull(syncAreas),
                  ),
                )
                .toList(),
          );
    } else {
      final query = (select(persons).join([
        leftOuterJoin(areas, areas.pk.equalsExp(persons.vaccinationAreaPk)),
      ])
        ..where(persons.deleted)
        ..orderBy([OrderingTerm(expression: persons.name)]));
      return query.watch().map(
            (rows) => rows
                .map(
                  (row) => PersonJoined(
                    person: row.readTable(persons),
                    area: row.readTableOrNull(areas),
                  ),
                )
                .toList(),
          );
    }
  }

  AreaData getEmptyArea() {
    return areas.mapFromCompanion(AreasCompanion(
      pk: Value(Uuid.NAMESPACE_NIL),
      city: Value("[None]"),
      district: Value("[None]"),
      syncSyncId: Value(""),
      syncKnowledgeId: Value(""),
      syncSynced: Value(false),
      syncDeleted: Value(false),
    ));
  }

  Future<List<AreaData>> getAllAreasForPicker() async {
    List<AreaData> result = await (syncSelect(syncAreas)
          ..orderBy([(t) => OrderingTerm(expression: t.city)]))
        .get();
    result.insert(0, getEmptyArea());
    return result;
  }

  Future<Person?> getPersonById(String id) {
    return (select(persons)..where((w) => w.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertPerson(Insertable<Person> data) {
    return syncInto(syncPersons).syncInsert(data);
  }

  Future<bool> updatePerson(Insertable<Person> data) {
    return syncUpdate(syncPersons).syncReplace(data);
  }

  Future<int> deletePerson(String id) {
    return (syncDelete(syncPersons)..where((tbl) => tbl.id.equals(id))).go();
  }

  Stream<List<CustomObject>> getAllCustomObjects(
      {bool viewDeletedOnly = false}) {
    if (!viewDeletedOnly) {
      return (syncSelect(syncCustomObjects)
            ..orderBy([(t) => OrderingTerm(expression: t.fieldString)]))
          .watch();
    } else {
      return (select(customObjects)
            ..where((tbl) => tbl.deleted)
            ..orderBy([(t) => OrderingTerm(expression: t.fieldString)]))
          .watch();
    }
  }

  Future<CustomObject?> getCustomObjectById(String id) {
    return (select(customObjects)..where((w) => w.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertCustomObject(Insertable<CustomObject> data) {
    return syncInto(syncCustomObjects).syncInsert(data);
  }

  Future<bool> updateCustomObject(Insertable<CustomObject> data) {
    return syncUpdate(syncCustomObjects).syncReplace(data);
  }

  Future<int> deleteCustomObject(String id) {
    return (syncDelete(syncCustomObjects)..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  Stream<List<NetCoreSyncKnowledge>> getAllKnowledges() {
    return (select(netCoreSyncKnowledges)
          ..orderBy([
            (t) => OrderingTerm(expression: t.syncId),
            (t) => OrderingTerm(expression: t.local, mode: OrderingMode.desc),
          ]))
        .watch();
  }
}

class PersonJoined {
  final Person person;
  final AreaData? area;
  const PersonJoined({required this.person, this.area});
}
