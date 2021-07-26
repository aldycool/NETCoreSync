import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';

@UseRowClass(NetCoreSyncKnowledge, constructor: "fromDb")
class NetCoreSyncKnowledges extends Table {
  TextColumn get id => text().withLength(max: 36)();
  BoolColumn get local => boolean()();
  IntColumn get maxTimeStamp => integer()();
  TextColumn get syncId => text().withLength(max: 255)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => "netcoresync_knowledges";
}

class NetCoreSyncKnowledge implements Insertable<NetCoreSyncKnowledge> {
  String id = Uuid().v4();
  bool local = false;
  int maxTimeStamp = 0;
  String syncId = "";

  NetCoreSyncKnowledge();

  NetCoreSyncKnowledge.fromDb({
    required this.id,
    required this.local,
    required this.maxTimeStamp,
    required this.syncId,
  });

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['local'] = Variable<bool>(local);
    map['max_time_stamp'] = Variable<int>(maxTimeStamp);
    map['sync_id'] = Variable<String>(syncId);
    return map;
  }

  factory NetCoreSyncKnowledge.fromJson(Map<String, dynamic> json) {
    final serializer = moorRuntimeOptions.defaultSerializer;
    NetCoreSyncKnowledge customObject = NetCoreSyncKnowledge();
    customObject.id = serializer.fromJson<String>(json['id']);
    customObject.local = serializer.fromJson<bool>(json['local']);
    customObject.maxTimeStamp = serializer.fromJson<int>(json['maxTimeStamp']);
    customObject.syncId = serializer.fromJson<String>(json['syncId']);
    return customObject;
  }

  Map<String, dynamic> toJson() {
    final serializer = moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'local': serializer.toJson<bool>(local),
      'maxTimeStamp': serializer.toJson<int>(maxTimeStamp),
      'syncId': serializer.toJson<String>(syncId),
    };
  }
}
