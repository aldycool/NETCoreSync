import 'package:flutter/material.dart';
import '../global.dart';
import '../utils.dart';
import 'area_list_page.dart';
import 'person_list_page.dart';
import 'custom_object_list_page.dart';
import 'knowledge_view_page.dart';
import 'sync_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _loggedInSyncId;
  late List<String> _availableSyncIds;

  @override
  void initState() {
    super.initState();
    _updateLoggedInState();
  }

  void _updateLoggedInState() {
    setState(() {
      _loggedInSyncId = Global.instance.database.netCoreSyncGetActiveSyncId()!;
      _availableSyncIds = Global.instance.database
          .netCoreSyncGetSyncIdInfo()!
          .getAllSyncIds(enclosure: "")
            ..removeWhere((element) => element == _loggedInSyncId);
    });
  }

  Future<void> _changeSyncId(BuildContext context, int index) async {
    String changedToUserName = _availableSyncIds[index];
    Global.instance.database.netCoreSyncSetActiveSyncId(changedToUserName);
    _updateLoggedInState();
    await Utils.alert(
        buildContext: context,
        title: "Info",
        message: "UserName changed to: $changedToUserName");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "You are logged-in as: $_loggedInSyncId",
              ),
              SizedBox(
                height: 12,
              ),
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _availableSyncIds.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ElevatedButton(
                        child: Text(
                            "Change UserName to: ${_availableSyncIds[index]}"),
                        onPressed: () async =>
                            await _changeSyncId(context, index),
                      ),
                    );
                  }),
              SizedBox(
                height: 24,
              ),
              ElevatedButton(
                child: Text("Areas"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AreaListPage()),
                  );
                },
              ),
              SizedBox(
                height: 12,
              ),
              ElevatedButton(
                child: Text("Persons"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PersonListPage()),
                  );
                },
              ),
              SizedBox(
                height: 12,
              ),
              ElevatedButton(
                child: Text("CustomObjects"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CustomObjectListPage()),
                  );
                },
              ),
              SizedBox(
                height: 12,
              ),
              ElevatedButton(
                child: Text("View Knowledges"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => KnowledgeViewPage()),
                  );
                },
              ),
              SizedBox(
                height: 12,
              ),
              ElevatedButton(
                child: Text("Sync"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SyncPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
