import 'package:moor/moor.dart';
import 'netcoresync_annotations.dart';

abstract class NetCoreSyncEngine {
  late List<Type> orderedTypes;
  late Map<Type, NetCoreSyncTableUser> tables;

  NetCoreSyncEngine(this.orderedTypes, this.tables);

  Object? getSyncColumnValue<D>(Insertable<D> entity, String fieldName);

  Insertable<D> updateSyncColumns<D>(
    Insertable<D> entity, {
    required int timeStamp,
    bool? deleted,
  });
}

class NetCoreSyncTableUser<T extends Table, D> {
  TableInfo<T, D> tableInfo;
  NetCoreSyncTable tableAnnotation;
  String idEscapedName;
  String syncIdEscapedName;
  String timeStampEscapedName;
  String deletedEscapedName;
  String knowledgeIdEscapedName;
  NetCoreSyncTableUser(
    this.tableInfo,
    this.tableAnnotation,
    this.idEscapedName,
    this.syncIdEscapedName,
    this.timeStampEscapedName,
    this.deletedEscapedName,
    this.knowledgeIdEscapedName,
  );
}
