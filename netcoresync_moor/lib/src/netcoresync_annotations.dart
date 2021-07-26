class NetCoreSyncTable {
  final String mapToClassName;
  final String idFieldName;
  final String syncIdFieldName;
  final String timeStampFieldName;
  final String deletedFieldName;
  final String knowledgeIdFieldName;
  final int order;

  const NetCoreSyncTable({
    this.mapToClassName = "",
    this.idFieldName = "id",
    this.syncIdFieldName = "syncId",
    this.timeStampFieldName = "timeStamp",
    this.deletedFieldName = "deleted",
    this.knowledgeIdFieldName = "knowledgeId",
    this.order = 0,
  });

  factory NetCoreSyncTable.fromJson(Map<String, dynamic> json) {
    return NetCoreSyncTable(
      mapToClassName: json["mapToClassName"],
      idFieldName: json["idFieldName"],
      syncIdFieldName: json["syncIdFieldName"],
      timeStampFieldName: json["timeStampFieldName"],
      deletedFieldName: json["deletedFieldName"],
      knowledgeIdFieldName: json["knowledgeIdFieldName"],
      order: json["order"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "mapToClassName": mapToClassName,
      "idFieldName": idFieldName,
      "syncIdFieldName": syncIdFieldName,
      "timeStampFieldName": timeStampFieldName,
      "deletedFieldName": deletedFieldName,
      "knowledgeIdFieldName": knowledgeIdFieldName,
      "order": order,
    };
  }
}
