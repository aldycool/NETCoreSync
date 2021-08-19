import 'package:flutter/material.dart';
import '../data/custom_objects.dart';
import '../global.dart';
import '../utils.dart';
import 'custom_object_entry_page.dart';
import 'list_row_widget.dart';

class CustomObjectListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CustomObjectListPageState();
}

class _CustomObjectListPageState extends State<CustomObjectListPage> {
  bool _isLoading = true;
  bool _viewDeletedOnly = false;
  late Stream<List<CustomObject>> datas;

  @override
  void initState() {
    super.initState();
    _updateState();
  }

  Future<void> _updateState() async {
    var _datas = await Global.instance.database
        .getAllCustomObjects(viewDeletedOnly: _viewDeletedOnly);
    setState(() {
      datas = _datas;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CustomObject List"),
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
                MaterialPageRoute(
                    builder: (context) => CustomObjectEntryPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        child: _isLoading
            ? CircularProgressIndicator()
            : StreamBuilder<List<CustomObject>>(
                stream: datas,
                initialData: [],
                builder: (buildContext, snapshot) {
                  return ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (buildContext, index) {
                      return ListRowWidget(
                        fields: {
                          "FieldString": snapshot.data![index].fieldString,
                        },
                        idValue: snapshot.data![index].id,
                        syncIdValue: snapshot.data![index].syncId,
                        knowledgeIdValue: snapshot.data![index].knowledgeId,
                        syncedValue: snapshot.data![index].synced,
                        deletedValue: snapshot.data![index].deleted,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomObjectEntryPage(
                                  dataId: snapshot.data?[index].id),
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
