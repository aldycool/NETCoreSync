import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';

@DataClassName("Department")
class Departments extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();

  TextColumn get name => text().withLength(max: 255).nullable()();

  IntColumn get lastUpdated => integer().withDefault(const Constant(0))();

  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  TextColumn get databaseInstanceId => text().withLength(max: 255).nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => "department";
}
