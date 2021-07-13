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
