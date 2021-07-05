import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';
import 'package:netcoresync_client_flutter/netcoresync_client_flutter.dart';

@SyncSchema(mapToClassName: "SyncDepartment")
@DataClassName("Department")
class Departments extends Table {
  @SyncProperty(propertyIndicator: PropertyIndicatorEnum.id)
  TextColumn get id => text().clientDefault(() => Uuid().v4())();

  @SyncFriendlyId()
  TextColumn get name => text().withLength(max: 255).nullable()();

  @SyncProperty(propertyIndicator: PropertyIndicatorEnum.lastUpdated)
  IntColumn get lastUpdated => integer().withDefault(const Constant(0))();

  @SyncProperty(propertyIndicator: PropertyIndicatorEnum.deleted)
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @SyncProperty(propertyIndicator: PropertyIndicatorEnum.databaseInstanceId)
  TextColumn get databaseInstanceId => text().withLength(max: 255).nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => "department";
}
