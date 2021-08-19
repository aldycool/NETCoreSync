import 'package:flutter/material.dart';
import '../data/database.dart';
import '../global.dart';
import '../utils.dart';
import 'area_entry_page.dart';
import 'list_row_widget.dart';

class AreaListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AreaListPageState();
}

class _AreaListPageState extends State<AreaListPage> {
  bool _isLoading = true;
  bool _viewDeletedOnly = false;
  late Stream<List<AreaData>> datas;

  @override
  void initState() {
    super.initState();
    _updateState();
  }

  Future<void> _updateState() async {
    var _datas = await Global.instance.database
        .getAllAreas(viewDeletedOnly: _viewDeletedOnly);
    setState(() {
      datas = _datas;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Area List"),
        actions: [
          IconButton(
            icon: Icon(Icons.visibility),
            onPressed: () async {
              _viewDeletedOnly = !_viewDeletedOnly;
              await _updateState();
              Utils.showToast(
                  context,
                  _viewDeletedOnly
                      ? "The list now displays deleted data only"
                      : "The list now displays non-deleted data");
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AreaEntryPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        child: _isLoading
            ? CircularProgressIndicator()
            : StreamBuilder<List<AreaData>>(
                stream: datas,
                initialData: [],
                builder: (buildContext, snapshot) {
                  return ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (buildContext, index) {
                      return ListRowWidget(
                        fields: {
                          "City": snapshot.data![index].city,
                          "District": snapshot.data![index].district,
                        },
                        idValue: snapshot.data![index].pk,
                        syncIdValue: snapshot.data![index].syncSyncId,
                        knowledgeIdValue: snapshot.data![index].syncKnowledgeId,
                        syncedValue: snapshot.data![index].syncSynced,
                        deletedValue: snapshot.data![index].syncDeleted,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AreaEntryPage(
                                  dataId: snapshot.data?[index].pk),
                            ),
                          );
                        },
                      );
                    },
                  );
                }),
      ),
    );
  }
}
