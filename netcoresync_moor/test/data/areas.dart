import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';

@NetCoreSyncTable(
  idFieldName: "pk",
  syncIdFieldName: "syncSyncId",
  knowledgeIdFieldName: "syncKnowledgeId",
  syncedFieldName: "syncSynced",
  deletedFieldName: "syncDeleted",
)
@DataClassName("AreaData")
class Areas extends Table {
  TextColumn get pk =>
      text().withLength(max: 36).clientDefault(() => Uuid().v4())();
  TextColumn get city =>
      text().withLength(max: 255).withDefault(Constant(""))();
  TextColumn get district =>
      text().withLength(max: 255).withDefault(Constant(""))();

  TextColumn get syncSyncId =>
      text().withLength(max: 36).withDefault(Constant(""))();
  TextColumn get syncKnowledgeId =>
      text().withLength(max: 36).withDefault(Constant(""))();
  BoolColumn get syncSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get syncDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {
        pk,
        syncSyncId,
      };

  @override
  List<String> get customConstraints => [
        "UNIQUE(sync_sync_id, city, district)",
      ];

  @override
  String? get tableName => "area";
}
