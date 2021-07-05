import 'package:client_app/src/data/database.dart';
import 'package:flutter/material.dart';
import '../global.dart';
import 'department_entry_page.dart';

class DepartmentListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DepartmentListPageState();
}

class _DepartmentListPageState extends State<DepartmentListPage> {
  late Stream<List<Department>> datas;

  @override
  void initState() {
    super.initState();
    datas = Global.instance.database.getAllDepartments();
    _onReady().whenComplete(() => setState(() {}));
  }

  Future<void> _onReady() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Department List"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DepartmentEntryPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        child: StreamBuilder<List<Department>>(
            stream: datas,
            initialData: [],
            builder: (buildContext, snapshot) {
              return ListView.builder(
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (buildContext, index) {
                  return ListTile(
                    title: Text(snapshot.data?[index].name ?? ""),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DepartmentEntryPage(
                                dataId: snapshot.data?[index].id)),
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
