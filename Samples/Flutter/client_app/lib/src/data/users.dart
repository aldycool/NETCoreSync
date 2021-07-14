import 'package:client_app/src/data/database.dart';
import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';

@NetCoreSyncTable(mapToClassName: "SyncUser")
// NOTE: replace @DataClassName with below to generate the standard class
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

  IntColumn get timeStamp => integer()();

  BoolColumn get deleted => boolean()();

  TextColumn get knowledgeId => text().withLength(max: 36).nullable()();

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

  int timeStamp = 0;
  bool deleted = false;
  String? knowledgeId;

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
    required this.timeStamp,
    required this.deleted,
    required this.knowledgeId,
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
      timeStamp: Value(timeStamp),
      deleted: Value(deleted),
      knowledgeId: Value(knowledgeId),
    ).toColumns(nullToAbsent);
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final serializer = moorRuntimeOptions.defaultSerializer;
    User user = User();
    user.id = serializer.fromJson<String>(json['id']);
    user.fieldString = serializer.fromJson<String>(json['fieldString']);
    user.fieldStringNullable =
        serializer.fromJson<String?>(json['fieldStringNullable']);
    user.fieldInt = serializer.fromJson<int>(json['fieldInt']);
    user.fieldIntNullable = serializer.fromJson<int?>(json['fieldIntNullable']);
    user.fieldBoolean = serializer.fromJson<bool>(json['fieldBoolean']);
    user.fieldBooleanNullable =
        serializer.fromJson<bool?>(json['fieldBooleanNullable']);
    user.fieldDateTime = serializer.fromJson<DateTime>(json['fieldDateTime']);
    user.fieldDateTimeNullable =
        serializer.fromJson<DateTime?>(json['fieldDateTimeNullable']);
    user.timeStamp = serializer.fromJson<int>(json['timeStamp']);
    user.deleted = serializer.fromJson<bool>(json['deleted']);
    user.knowledgeId = serializer.fromJson<String?>(json['knowledgeId']);
    return user;
  }

  Map<String, dynamic> toJson() {
    final serializer = moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fieldString': serializer.toJson<String>(fieldString),
      'fieldStringNullable': serializer.toJson<String?>(fieldStringNullable),
      'fieldInt': serializer.toJson<int>(fieldInt),
      'fieldIntNullable': serializer.toJson<int?>(fieldIntNullable),
      'fieldBoolean': serializer.toJson<bool>(fieldBoolean),
      'fieldBooleanNullable': serializer.toJson<bool?>(fieldBooleanNullable),
      'fieldDateTime': serializer.toJson<DateTime>(fieldDateTime),
      'fieldDateTimeNullable':
          serializer.toJson<DateTime?>(fieldDateTimeNullable),
      'timeStamp': serializer.toJson<int>(timeStamp),
      'deleted': serializer.toJson<bool>(deleted),
      'knowledgeId': serializer.toJson<String?>(knowledgeId),
    };
  }
}
