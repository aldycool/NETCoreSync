import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';

@DataClassName("Concept")
class Concepts extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();

  TextColumn get fieldString =>
      text().withLength(max: 255).withDefault(const Constant(""))();

  TextColumn get fieldStringNullable =>
      text().withLength(max: 255).nullable()();

  IntColumn get fieldInt => integer().withDefault(const Constant(0))();

  IntColumn get fieldIntNullable => integer().nullable()();

  BoolColumn get fieldBoolean => boolean().withDefault(const Constant(false))();

  BoolColumn get fieldBooleanNullable => boolean().nullable()();

  DateTimeColumn get fieldDateTime =>
      dateTime().withDefault(Constant(DateTime(0)))();

  DateTimeColumn get fieldDateTimeNullable => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => "concept";
}
