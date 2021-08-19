import 'package:flutter/material.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import '../global.dart';
import 'list_row_widget.dart';

class KnowledgeViewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _KnowledgeViewPageState();
}

class _KnowledgeViewPageState extends State<KnowledgeViewPage> {
  bool _isLoading = true;
  late Stream<List<NetCoreSyncKnowledge>> datas;

  @override
  void initState() {
    super.initState();
    _updateState();
  }

  Future<void> _updateState() async {
    var _datas = await Global.instance.database.getAllKnowledges();
    setState(() {
      datas = _datas;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Knowledge View"),
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        child: _isLoading
            ? CircularProgressIndicator()
            : StreamBuilder<List<NetCoreSyncKnowledge>>(
                stream: datas,
                initialData: [],
                builder: (buildContext, snapshot) {
                  return ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (buildContext, index) {
                      return ListRowWidget(
                        fields: {
                          "syncId": snapshot.data![index].syncId,
                          "local": snapshot.data![index].local.toString(),
                          "id (or known as knowledgeId)":
                              snapshot.data![index].id,
                          "lastTimeStamp":
                              snapshot.data![index].lastTimeStamp.toString(),
                        },
                        showSyncFields: false,
                        idValue: "",
                        syncIdValue: "",
                        knowledgeIdValue: "",
                        syncedValue: false,
                        deletedValue: false,
                        onTap: null,
                      );
                    },
                  );
                }),
      ),
    );
  }
}
