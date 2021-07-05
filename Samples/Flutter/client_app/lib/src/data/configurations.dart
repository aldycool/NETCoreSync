import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';

@DataClassName("Configuration")
class Configurations extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();

  TextColumn get key =>
      text().withLength(max: 255).withDefault(const Constant(""))();

  TextColumn get value => text().withLength(max: 255).nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => "configuration";
}
