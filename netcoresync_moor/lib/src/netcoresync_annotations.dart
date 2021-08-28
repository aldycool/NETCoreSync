/// The annotation class that needs to be assigned to table classes.
///
/// For all table classes that wants to be synchronized with the server-side,
/// they need to be annotated with this class. If the default synchronization
/// field names conflicted with an existing field name, it can be overriden by
/// specifying different field name in the constructor arguments.
///
/// Please read the [Client Side Data Annotation](https://github.com/aldycool/NETCoreSync/tree/master/netcoresync_moor#client-side-data-annotation)
/// in the `netcoresync_moor` documentation for more details.
class NetCoreSyncTable {
  /// The `id` synchronization field name, defaults to: "id".
  final String idFieldName;

  /// The `syncId` synchronization field name, defaults to: "syncId".
  final String syncIdFieldName;

  /// The `knowledgeId` synchronization field name, defaults to: "knowledgeId".
  final String knowledgeIdFieldName;

  /// The `synced` synchronization field name, defaults to: "synced".
  final String syncedFieldName;

  /// The `deleted` synchronization field name, defaults to: "deleted".
  final String deletedFieldName;

  const NetCoreSyncTable({
    this.idFieldName = "id",
    this.syncIdFieldName = "syncId",
    this.knowledgeIdFieldName = "knowledgeId",
    this.syncedFieldName = "synced",
    this.deletedFieldName = "deleted",
  });

  factory NetCoreSyncTable.fromJson(Map<String, dynamic> json) {
    return NetCoreSyncTable(
      idFieldName: json["idFieldName"],
      syncIdFieldName: json["syncIdFieldName"],
      knowledgeIdFieldName: json["knowledgeIdFieldName"],
      syncedFieldName: json["syncedFieldName"],
      deletedFieldName: json["deletedFieldName"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "idFieldName": idFieldName,
      "syncIdFieldName": syncIdFieldName,
      "knowledgeIdFieldName": knowledgeIdFieldName,
      "syncedFieldName": syncedFieldName,
      "deletedFieldName": deletedFieldName,
    };
  }
}
