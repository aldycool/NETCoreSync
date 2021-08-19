import 'package:flutter/material.dart';
import '../data/database.dart';
import '../global.dart';
import '../utils.dart';
import 'person_entry_page.dart';
import 'list_row_widget.dart';

class PersonListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PersonListPageState();
}

class _PersonListPageState extends State<PersonListPage> {
  bool _isLoading = true;
  bool _viewDeletedOnly = false;
  late Stream<List<PersonJoined>> datas;

  @override
  void initState() {
    super.initState();
    _updateState();
  }

  Future<void> _updateState() async {
    var _datas = await Global.instance.database
        .getAllPersons(viewDeletedOnly: _viewDeletedOnly);
    setState(() {
      datas = _datas;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Person List"),
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
                MaterialPageRoute(builder: (context) => PersonEntryPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        child: _isLoading
            ? CircularProgressIndicator()
            : StreamBuilder<List<PersonJoined>>(
                stream: datas,
                initialData: [],
                builder: (buildContext, snapshot) {
                  return ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (buildContext, index) {
                      return ListRowWidget(
                        fields: {
                          "Name": snapshot.data![index].person.name,
                          "Vaccination Area": snapshot.data![index].area == null
                              ? "[None]"
                              : "${snapshot.data![index].area?.city} - ${snapshot.data![index].area?.district}",
                        },
                        idValue: snapshot.data![index].person.id,
                        syncIdValue: snapshot.data![index].person.syncId,
                        knowledgeIdValue:
                            snapshot.data![index].person.knowledgeId,
                        syncedValue: snapshot.data![index].person.synced,
                        deletedValue: snapshot.data![index].person.deleted,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PersonEntryPage(
                                  dataId: snapshot.data?[index].person.id),
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
