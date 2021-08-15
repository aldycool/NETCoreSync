import 'package:moor/moor.dart';
import 'netcoresync_annotations.dart';

abstract class NetCoreSyncEngine {
  late Map<Type, NetCoreSyncTableUser> tables;

  NetCoreSyncEngine(this.tables);

  dynamic fromJson(Type type, Map<String, dynamic> json);

  UpdateCompanion<D> toSafeCompanion<D>(Insertable<D> entity);

  Object? getSyncColumnValue<D>(Insertable<D> entity, String fieldName);

  Insertable<D> updateSyncColumns<D>(
    Insertable<D> entity, {
    required bool synced,
    String? syncId,
    String? knowledgeId,
    bool? deleted,
  });
}

class NetCoreSyncTableUser<T extends Table, D> {
  TableInfo<T, D> tableInfo;
  NetCoreSyncTable tableAnnotation;
  String idEscapedName;
  String syncIdEscapedName;
  String knowledgeIdEscapedName;
  String syncedEscapedName;
  String deletedEscapedName;
  NetCoreSyncTableUser(
    this.tableInfo,
    this.tableAnnotation,
    this.idEscapedName,
    this.syncIdEscapedName,
    this.knowledgeIdEscapedName,
    this.syncedEscapedName,
    this.deletedEscapedName,
  );
}
