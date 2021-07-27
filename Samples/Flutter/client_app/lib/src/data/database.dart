import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';
import 'employees.dart';
import 'departments.dart';
import 'configurations.dart';

export 'database_shared.dart';

part 'database.g.dart';

@UseMoor(
  tables: [
    Employees,
    Departments,
    Configurations,
    NetCoreSyncKnowledges,
  ],
)
class Database extends _$Database
    with NetCoreSyncClient, NetCoreSyncClientUser {
  Database(QueryExecutor queryExecutor) : super(queryExecutor);

  static String get fileName => "client_app_data";

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (openingDetails) async {
          await this.customStatement("PRAGMA foreign_keys = ON");
        },
        onCreate: (Migrator m) {
          return m.createAll();
        },
      );

  static const String _configuration_key_synchronizationId =
      "SYNCHRONIZATIONID";

  Future<void> resetDatabase({bool includeConfiguration = false}) async {
    await delete(employees).go();
    await delete(departments).go();
    await delete(netCoreSyncKnowledges).go();
    if (includeConfiguration) {
      await delete(configurations).go();
    }
  }

  Future<String?> getSynchronizationId() async {
    Configuration? configuration = await (select(configurations)
          ..where((w) => w.key.equals(_configuration_key_synchronizationId)))
        .getSingleOrNull();
    return configuration?.value;
  }

  Future<void> setSynchronizationId(String synchronizationId) async {
    if (synchronizationId.isEmpty)
      throw Exception("synchronizationId cannot be empty");
    Configuration? configuration = await (select(configurations)
          ..where((w) => w.key.equals(_configuration_key_synchronizationId)))
        .getSingleOrNull();
    if (configuration == null) {
      into(configurations).insert(ConfigurationsCompanion.insert(
        key: Value(_configuration_key_synchronizationId),
        value: Value(synchronizationId),
      ));
    } else {
      update(configurations).replace(configuration.copyWith(
        value: synchronizationId,
      ));
    }
  }

  Stream<List<Department>> getAllDepartments() {
    return (syncSelect(syncDepartments)
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Future<List<Department>> getAllDepartmentsForPicker() async {
    List<Department> result = await (syncSelect(syncDepartments)
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
    result.insert(0, getEmptyDepartment());
    return result;
  }

  Department getEmptyDepartment() {
    return departments.mapFromCompanion(DepartmentsCompanion(
      id: Value<String>(Uuid.NAMESPACE_NIL),
      name: Value<String>("[None]"),
      syncId: Value<String>(""),
      knowledgeId: Value<String>(""),
      synced: Value<bool>(false),
      deleted: Value<bool>(false),
    ));
  }

  Future<Department?> getDepartmentById(String id) {
    return (syncSelect(syncDepartments)..where((w) => w.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertDepartment(Insertable<Department> data) {
    return transaction(() async {
      final ret = await syncInto(departments).syncInsert(data);
      return ret;
    });
  }

  Future<bool> updateDepartment(Insertable<Department> data) {
    return transaction(() async {
      final ret = await syncUpdate(departments).syncReplace(data);
      return ret;
    });
  }

  Future<int> deleteDepartment(String id) {
    return transaction(() async {
      final ret = await (syncDelete(departments)
            ..where((tbl) => tbl.id.equals(id)))
          .go();
      return ret;
    });
  }

  Stream<List<EmployeeJoined>> getAllEmployees() {
    final query = (syncSelect(syncEmployees).syncJoin([
      leftOuterJoin(
          syncDepartments, departments.id.equalsExp(employees.departmentId)),
    ])
      ..orderBy([OrderingTerm(expression: employees.name)]));

    return query.watch().map((rows) {
      return rows.map((row) {
        return EmployeeJoined(
          employee: row.readTable(syncEmployees),
          department: row.readTableOrNull((syncDepartments)),
        );
      }).toList();
    });
  }

  Future<Employee?> getEmployeeById(String id) {
    return (syncSelect(syncEmployees)..where((w) => w.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertEmployee(Insertable<Employee> data) {
    return transaction(() async {
      final ret = await syncInto(employees).syncInsert(data);
      return ret;
    });
  }

  Future<bool> updateEmployee(Insertable<Employee> data) {
    return transaction(() async {
      final ret = await syncUpdate(employees).syncReplace(data);
      return ret;
    });
  }

  Future<int> deleteEmployee(String id) {
    return transaction(() async {
      final ret =
          await (syncDelete(employees)..where((tbl) => tbl.id.equals(id))).go();
      return ret;
    });
  }

  Future<bool> isDepartmentHasEmployees(String id) async {
    return (await (syncSelect(syncEmployees)
                  ..where((w) => w.departmentId.equals(id)))
                .get())
            .length >
        0;
  }
}

class EmployeeJoined {
  final Employee employee;
  final Department? department;
  const EmployeeJoined({required this.employee, this.department});
}
