import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';

@DataClassName("Knowledge")
class NetCoreSyncKnowledges extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  BoolColumn get local => boolean().withDefault(const Constant(false))();
  IntColumn get maxTimeStamp => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => "netcoresync_knowledge";
}
