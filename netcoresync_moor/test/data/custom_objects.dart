import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'database.dart';

@NetCoreSyncTable()
@UseRowClass(CustomObject, constructor: "fromDb")
class CustomObjects extends Table {
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

  TextColumn get syncId =>
      text().withLength(max: 36).withDefault(Constant(""))();
  TextColumn get knowledgeId =>
      text().withLength(max: 36).withDefault(Constant(""))();
  BoolColumn get synced => boolean()();
  BoolColumn get deleted => boolean()();

  @override
  Set<Column> get primaryKey => {
        id,
      };
}

class CustomObject implements Insertable<CustomObject> {
  String id = Uuid().v4();
  String fieldString = "";
  String? fieldStringNullable;
  int fieldInt = 0;
  int? fieldIntNullable;
  bool fieldBoolean = false;
  bool? fieldBooleanNullable;
  DateTime fieldDateTime = DateTime(0);
  DateTime? fieldDateTimeNullable;

  String syncId = "";
  String knowledgeId = "";
  bool synced = false;
  bool deleted = false;

  CustomObject();

  CustomObject.fromDb({
    required this.id,
    required this.fieldString,
    required this.fieldStringNullable,
    required this.fieldInt,
    required this.fieldIntNullable,
    required this.fieldBoolean,
    required this.fieldBooleanNullable,
    required this.fieldDateTime,
    required this.fieldDateTimeNullable,
    required this.syncId,
    required this.knowledgeId,
    required this.synced,
    required this.deleted,
  });

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return toCompanion(nullToAbsent).toColumns(nullToAbsent);
  }

  factory CustomObject.fromJson(Map<String, dynamic> json) {
    final serializer = moorRuntimeOptions.defaultSerializer;
    CustomObject customObject = CustomObject();
    customObject.id = serializer.fromJson<String>(json['id']);
    customObject.fieldString = serializer.fromJson<String>(json['fieldString']);
    customObject.fieldStringNullable =
        serializer.fromJson<String?>(json['fieldStringNullable']);
    customObject.fieldInt = serializer.fromJson<int>(json['fieldInt']);
    customObject.fieldIntNullable =
        serializer.fromJson<int?>(json['fieldIntNullable']);
    customObject.fieldBoolean = serializer.fromJson<bool>(json['fieldBoolean']);
    customObject.fieldBooleanNullable =
        serializer.fromJson<bool?>(json['fieldBooleanNullable']);
    customObject.fieldDateTime =
        serializer.fromJson<DateTime>(json['fieldDateTime']);
    customObject.fieldDateTimeNullable =
        serializer.fromJson<DateTime?>(json['fieldDateTimeNullable']);
    customObject.syncId = serializer.fromJson<String>(json['syncId']);
    customObject.knowledgeId = serializer.fromJson<String>(json['knowledgeId']);
    customObject.synced = serializer.fromJson<bool>(json['synced']);
    customObject.deleted = serializer.fromJson<bool>(json['deleted']);
    return customObject;
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
      'syncId': serializer.toJson<String>(syncId),
      'knowledgeId': serializer.toJson<String>(knowledgeId),
      'synced': serializer.toJson<bool>(synced),
      'deleted': serializer.toJson<bool>(deleted),
    };
  }

  CustomObjectsCompanion toCompanion(bool nullToAbsent) {
    return CustomObjectsCompanion(
      id: Value(id),
      fieldString: Value(fieldString),
      fieldStringNullable: nullToAbsent && fieldStringNullable == null
          ? Value.absent()
          : Value(fieldStringNullable),
      fieldInt: Value(fieldInt),
      fieldIntNullable: nullToAbsent && fieldIntNullable == null
          ? Value.absent()
          : Value(fieldIntNullable),
      fieldBoolean: Value(fieldBoolean),
      fieldBooleanNullable: nullToAbsent && fieldBooleanNullable == null
          ? Value.absent()
          : Value(fieldBooleanNullable),
      fieldDateTime: Value(fieldDateTime),
      fieldDateTimeNullable: nullToAbsent && fieldDateTimeNullable == null
          ? Value.absent()
          : Value(fieldDateTimeNullable),
      syncId: Value(syncId),
      knowledgeId: Value(knowledgeId),
      synced: Value(synced),
      deleted: Value(deleted),
    );
  }
}
