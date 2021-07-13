import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';

@UseRowClass(NetCoreSyncKnowledge, constructor: "fromDb")
class NetCoreSyncKnowledges extends Table {
  TextColumn get id => text().withLength(max: 36)();
  BoolColumn get local => boolean()();
  IntColumn get maxTimeStamp => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => "netcoresync_knowledges";
}

class NetCoreSyncKnowledge implements Insertable<NetCoreSyncKnowledge> {
  String id = Uuid().v4();
  bool local = false;
  int maxTimeStamp = 0;

  NetCoreSyncKnowledge();

  NetCoreSyncKnowledge.fromDb({
    required this.id,
    required this.local,
    required this.maxTimeStamp,
  });

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['local'] = Variable<bool>(local);
    map['max_time_stamp'] = Variable<int>(maxTimeStamp);
    return map;
  }
}
