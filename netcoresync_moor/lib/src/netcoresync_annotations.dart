class NetCoreSyncTable {
  final String mapToClassName;
  final String idFieldName;
  final String timeStampFieldName;
  final String deletedFieldName;
  final String knowledgeIdFieldName;

  const NetCoreSyncTable({
    this.mapToClassName = "",
    this.idFieldName = "id",
    this.timeStampFieldName = "timeStamp",
    this.deletedFieldName = "deleted",
    this.knowledgeIdFieldName = "knowledgeId",
  });

  factory NetCoreSyncTable.fromJson(Map<String, dynamic> json) {
    return NetCoreSyncTable(
      mapToClassName: json["mapToClassName"],
      idFieldName: json["idFieldName"],
      timeStampFieldName: json["timeStampFieldName"],
      deletedFieldName: json["deletedFieldName"],
      knowledgeIdFieldName: json["knowledgeIdFieldName"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "mapToClassName": mapToClassName,
      "idFieldName": idFieldName,
      "timeStampFieldName": timeStampFieldName,
      "deletedFieldName": deletedFieldName,
      "knowledgeIdFieldName": knowledgeIdFieldName,
    };
  }
}
