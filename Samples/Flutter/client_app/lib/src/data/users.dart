import 'package:client_app/src/data/database.dart';
import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';

// NOTE: replace @DataClassName with below to use standard class
@UseRowClass(User, constructor: "fromDb")
// @DataClassName("User")
class Users extends Table {
  TextColumn get id => text().withLength(max: 36)();

  TextColumn get fieldString => text().withLength(max: 255)();

  TextColumn get fieldStringNullable =>
      text().withLength(max: 255).nullable()();

  IntColumn get fieldInt => integer()();

  IntColumn get fieldIntNullable => integer().nullable()();

  BoolColumn get fieldBoolean => boolean()();

  BoolColumn get fieldBooleanNullable => boolean().nullable()();

  DateTimeColumn get fieldDateTime => dateTime()();

  DateTimeColumn get fieldDateTimeNullable => dateTime().nullable()();

  IntColumn get lastUpdated => integer()();

  BoolColumn get deleted => boolean()();

  TextColumn get databaseInstanceId => text().withLength(max: 36).nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => "user";
}

class User implements Insertable<User> {
  String id = Uuid().v4();

  String fieldString = "";

  String? fieldStringNullable;
  int fieldInt = 0;
  int? fieldIntNullable;
  bool fieldBoolean = false;
  bool? fieldBooleanNullable;
  DateTime fieldDateTime = DateTime(0);
  DateTime? fieldDateTimeNullable;

  int lastUpdated = 0;
  bool deleted = false;
  String? databaseInstanceId;

  User();

  User.fromDb({
    required this.id,
    required this.fieldString,
    required this.fieldStringNullable,
    required this.fieldInt,
    required this.fieldIntNullable,
    required this.fieldBoolean,
    required this.fieldBooleanNullable,
    required this.fieldDateTime,
    required this.fieldDateTimeNullable,
    required this.lastUpdated,
    required this.deleted,
    required this.databaseInstanceId,
  });

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return UsersCompanion(
      id: id == "" ? Value.absent() : Value(id),
      fieldString: Value(fieldString),
      fieldStringNullable: Value(fieldStringNullable),
      fieldInt: Value(fieldInt),
      fieldIntNullable: Value(fieldIntNullable),
      fieldBoolean: Value(fieldBoolean),
      fieldBooleanNullable: Value(fieldBooleanNullable),
      fieldDateTime: Value(fieldDateTime),
      fieldDateTimeNullable: Value(fieldDateTimeNullable),
      lastUpdated: Value(lastUpdated),
      deleted: Value(deleted),
      databaseInstanceId: Value(databaseInstanceId),
    ).toColumns(nullToAbsent);
  }
}
