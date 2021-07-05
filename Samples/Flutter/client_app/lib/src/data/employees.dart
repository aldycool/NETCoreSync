import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';
import 'package:netcoresync_client_flutter/netcoresync_client_flutter.dart';

@SyncSchema(mapToClassName: "SyncEmployee")
@DataClassName("Employee")
class Employees extends Table {
  @SyncProperty(propertyIndicator: PropertyIndicatorEnum.id)
  TextColumn get id => text().clientDefault(() => Uuid().v4())();

  @SyncFriendlyId()
  TextColumn get name => text().withLength(max: 255).nullable()();

  DateTimeColumn get birthday =>
      dateTime().withDefault(Constant(DateTime.now()))();

  IntColumn get numberOfComputers => integer().withDefault(const Constant(0))();

  IntColumn get savingAmount => integer().withDefault(const Constant(0))();

  BoolColumn get isActive => boolean().withDefault(const Constant(false))();

  TextColumn get departmentId => text()
      .nullable()
      .customConstraint("NULLABLE REFERENCES department(id)")();

  @SyncProperty(propertyIndicator: PropertyIndicatorEnum.lastUpdated)
  IntColumn get lastUpdated => integer().withDefault(const Constant(0))();

  @SyncProperty(propertyIndicator: PropertyIndicatorEnum.deleted)
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @SyncProperty(propertyIndicator: PropertyIndicatorEnum.databaseInstanceId)
  TextColumn get databaseInstanceId => text().withLength(max: 255).nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => "employee";
}
