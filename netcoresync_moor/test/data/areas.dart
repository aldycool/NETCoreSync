import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';

@NetCoreSyncTable(
  mapToClassName: "SyncArea",
  idFieldName: "pk",
  timeStampFieldName: "syncTimeStamp",
  deletedFieldName: "syncDeleted",
  knowledgeIdFieldName: "syncKnowledgeId",
  order: 1,
)
@DataClassName("AreaData")
class Areas extends Table {
  TextColumn get pk =>
      text().withLength(max: 36).clientDefault(() => Uuid().v4())();
  TextColumn get city =>
      text().withLength(max: 255).withDefault(Constant(""))();
  TextColumn get district =>
      text().withLength(max: 255).withDefault(Constant(""))();

  IntColumn get syncTimeStamp => integer().withDefault(const Constant(0))();
  BoolColumn get syncDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get syncKnowledgeId => text().withLength(max: 255).nullable()();

  @override
  Set<Column> get primaryKey => {pk};

  @override
  List<String> get customConstraints => [
        "UNIQUE(city, district)",
      ];

  @override
  String? get tableName => "area";
}
