class NetCoreSyncTable {
  final String idFieldName;
  final String syncIdFieldName;
  final String knowledgeIdFieldName;
  final String syncedFieldName;
  final String deletedFieldName;
  final List<String> columnFieldNames;

  const NetCoreSyncTable({
    this.idFieldName = "id",
    this.syncIdFieldName = "syncId",
    this.knowledgeIdFieldName = "knowledgeId",
    this.syncedFieldName = "synced",
    this.deletedFieldName = "deleted",
    this.columnFieldNames = const [],
  });

  factory NetCoreSyncTable.fromJson(Map<String, dynamic> json) {
    return NetCoreSyncTable(
      idFieldName: json["idFieldName"],
      syncIdFieldName: json["syncIdFieldName"],
      knowledgeIdFieldName: json["knowledgeIdFieldName"],
      syncedFieldName: json["syncedFieldName"],
      deletedFieldName: json["deletedFieldName"],
      columnFieldNames: List.from(json["columnFieldNames"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "idFieldName": idFieldName,
      "syncIdFieldName": syncIdFieldName,
      "knowledgeIdFieldName": knowledgeIdFieldName,
      "syncedFieldName": syncedFieldName,
      "deletedFieldName": deletedFieldName,
      "columnFieldNames": columnFieldNames,
    };
  }
}
