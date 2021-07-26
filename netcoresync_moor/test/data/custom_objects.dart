import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'database.dart';

@NetCoreSyncTable(
  mapToClassName: "SyncCustomObject",
  order: 3,
)
@UseRowClass(CustomObject, constructor: "fromDb")
class CustomObjects extends Table {
  TextColumn get id => text().withLength(max: 36)();
  TextColumn get syncId =>
      text().withLength(max: 255).withDefault(Constant(""))();
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
}

class CustomObject implements Insertable<CustomObject> {
  String id = Uuid().v4();
  String syncId = "";
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

  CustomObject();

  CustomObject.fromDb({
    required this.id,
    required this.syncId,
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
    return CustomObjectsCompanion(
      id: id == "" ? Value.absent() : Value(id),
      syncId: Value(syncId),
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

  factory CustomObject.fromJson(Map<String, dynamic> json) {
    final serializer = moorRuntimeOptions.defaultSerializer;
    CustomObject customObject = CustomObject();
    customObject.id = serializer.fromJson<String>(json['id']);
    customObject.syncId = serializer.fromJson<String>(json['syncId']);
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
    customObject.timeStamp = serializer.fromJson<int>(json['timeStamp']);
    customObject.deleted = serializer.fromJson<bool>(json['deleted']);
    customObject.knowledgeId =
        serializer.fromJson<String?>(json['knowledgeId']);
    return customObject;
  }

  Map<String, dynamic> toJson() {
    final serializer = moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncId': serializer.toJson<String>(syncId),
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
