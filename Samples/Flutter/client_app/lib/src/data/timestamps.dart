import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';

@DataClassName("TimeStamp")
class TimeStamps extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();

  IntColumn get counter => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => "timestamp";
}
