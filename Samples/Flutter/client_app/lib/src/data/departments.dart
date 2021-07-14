import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';

@NetCoreSyncTable(mapToClassName: "SyncDepartment")
// @DataClassName("Department") // This is remarked to test the netcoresync_moor_generator
class Departments extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();

  TextColumn get name => text().withLength(max: 255).nullable()();

  IntColumn get timeStamp => integer().withDefault(const Constant(0))();

  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  TextColumn get knowledgeId => text().withLength(max: 255).nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => "department";
}
