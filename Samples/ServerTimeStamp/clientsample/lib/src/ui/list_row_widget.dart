import 'package:flutter/material.dart';

class ListRowWidget extends StatelessWidget {
  final Map<String, String> fields;
  final bool showSyncFields;
  final String idValue;
  final String syncIdValue;
  final String knowledgeIdValue;
  final bool syncedValue;
  final bool deletedValue;
  final void Function()? onTap;

  ListRowWidget({
    required this.fields,
    this.showSyncFields = true,
    required this.idValue,
    required this.syncIdValue,
    required this.knowledgeIdValue,
    required this.syncedValue,
    required this.deletedValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final syncFieldTitleStyle = TextStyle(
      fontSize: 14,
      color: Colors.grey,
      fontStyle: FontStyle.italic,
    );
    final syncFieldStyle = TextStyle(
      color: Colors.grey,
      fontStyle: FontStyle.italic,
    );
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              deletedValue
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        "(DELETED)",
                        style: syncFieldStyle,
                      ),
                    )
                  : SizedBox(),
              for (var item in fields.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Text("${item.key}: "),
                      Text("${item.value}"),
                    ],
                  ),
                ),
              SizedBox(
                height: 12.0,
              ),
              !showSyncFields
                  ? Container()
                  : ExpansionTile(
                      title: Text(
                        "Sync Fields: ",
                        style: syncFieldTitleStyle,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Text(
                                "id: ",
                                style: syncFieldStyle,
                              ),
                              Text(
                                idValue,
                                style: syncFieldStyle,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Text(
                                "syncId: ",
                                style: syncFieldStyle,
                              ),
                              Text(
                                syncIdValue,
                                style: syncFieldStyle,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Text(
                                "knowledgeId: ",
                                style: syncFieldStyle,
                              ),
                              Text(
                                knowledgeIdValue,
                                style: syncFieldStyle,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Text(
                                "synced: ",
                                style: syncFieldStyle,
                              ),
                              Text(
                                syncedValue.toString(),
                                style: syncFieldStyle,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Text(
                                "deleted: ",
                                style: syncFieldStyle,
                              ),
                              Text(
                                deletedValue.toString(),
                                style: syncFieldStyle,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
