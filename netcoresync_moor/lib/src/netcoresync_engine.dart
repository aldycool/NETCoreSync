import 'package:moor/moor.dart';
import 'netcoresync_annotations.dart';

/// The abstract class for performing required actions by the framework that is
/// specific to the project's database schema, where its implementation is
/// created during code generation.
///
/// *(This class is used internally, no need to use it directly)*
abstract class NetCoreSyncEngine {
  late Map<Type, NetCoreSyncTableUser> tables;

  NetCoreSyncEngine(this.tables);

  Map<String, dynamic> toJson(dynamic object);

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

/// A helper class for the [NetCoreSyncEngine] class that is used in the code
/// generation.
///
/// *(This class is used internally, no need to use it directly)*
class NetCoreSyncTableUser<T extends Table, D> {
  TableInfo<T, D> tableInfo;
  NetCoreSyncTable tableAnnotation;
  String idEscapedName;
  String syncIdEscapedName;
  String knowledgeIdEscapedName;
  String syncedEscapedName;
  String deletedEscapedName;
  List<String> columnFieldNames;

  NetCoreSyncTableUser(
    this.tableInfo,
    this.tableAnnotation,
    this.idEscapedName,
    this.syncIdEscapedName,
    this.knowledgeIdEscapedName,
    this.syncedEscapedName,
    this.deletedEscapedName,
    this.columnFieldNames,
  );
}
