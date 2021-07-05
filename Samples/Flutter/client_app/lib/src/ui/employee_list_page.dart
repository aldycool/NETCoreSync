import 'package:client_app/src/data/database.dart';
import 'package:flutter/material.dart';
import '../global.dart';
import 'employee_entry_page.dart';

class EmployeeListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  late Stream<List<EmployeeJoined>> datas;

  @override
  void initState() {
    super.initState();
    datas = Global.instance.database.getAllEmployees();
    _onReady().whenComplete(() => setState(() {}));
  }

  Future<void> _onReady() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employee List"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmployeeEntryPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        child: StreamBuilder<List<EmployeeJoined>>(
            stream: datas,
            initialData: [],
            builder: (buildContext, snapshot) {
              return ListView.builder(
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (buildContext, index) {
                  return ListTile(
                    title: Text(snapshot.data?[index].employee.name ?? ""),
                    subtitle: Text(
                        snapshot.data?[index].department?.name ?? "[None]"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EmployeeEntryPage(
                                dataId: snapshot.data?[index].employee.id)),
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
