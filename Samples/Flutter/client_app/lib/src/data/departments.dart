import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';

@NetCoreSyncTable()
// @DataClassName("Department") // This is remarked to test the netcoresync_moor_generator
class Departments extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();

  TextColumn get name => text().withLength(max: 255).nullable()();

  TextColumn get syncId =>
      text().withLength(max: 36).withDefault(Constant(""))();

  TextColumn get knowledgeId =>
      text().withLength(max: 36).withDefault(Constant(""))();

  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {
        id,
      };

  @override
  String? get tableName => "department";
}
