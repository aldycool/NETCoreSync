import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';

@NetCoreSyncTable()
@DataClassName("Employee")
class Employees extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();

  TextColumn get name => text().withLength(max: 255).nullable()();

  DateTimeColumn get birthday =>
      dateTime().withDefault(Constant(DateTime.now()))();

  IntColumn get numberOfComputers => integer().withDefault(const Constant(0))();

  IntColumn get savingAmount => integer().withDefault(const Constant(0))();

  BoolColumn get isActive => boolean().withDefault(const Constant(false))();

  TextColumn get departmentId => text()
      .nullable()
      .customConstraint("NULLABLE REFERENCES department(id)")();

  TextColumn get syncId =>
      text().withLength(max: 36).withDefault(Constant(""))();

  TextColumn get knowledgeId =>
      text().withLength(max: 36).withDefault(Constant(""))();

  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => "employee";
}
