class NetCoreSyncTable {
  final String idFieldName;
  final String syncIdFieldName;
  final String knowledgeIdFieldName;
  final String syncedFieldName;
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
