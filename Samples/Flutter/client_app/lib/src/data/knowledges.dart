import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';

@DataClassName("Knowledge")
class Knowledges extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();

  TextColumn get databaseInstanceId => text().withLength(max: 255).nullable()();

  BoolColumn get isLocal => boolean().withDefault(const Constant(false))();

  IntColumn get maxTimeStamp => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => "knowledge";
}
