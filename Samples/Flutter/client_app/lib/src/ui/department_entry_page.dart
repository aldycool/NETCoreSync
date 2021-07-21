import 'package:client_app/src/data/database.dart';
import 'package:flutter/material.dart';
import 'package:moor/moor.dart' as moor;
import '../global.dart';
import '../utils.dart';

class DepartmentEntryPage extends StatefulWidget {
  late final String? dataId;

  DepartmentEntryPage({this.dataId}) : super();

  @override
  State<StatefulWidget> createState() => _DepartmentEntryPageState();
}

class _DepartmentEntryPageState extends State<DepartmentEntryPage> {
  DepartmentsCompanion data = DepartmentsCompanion();
  final TextEditingController textEditingControllerName =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _onReady().whenComplete(() => setState(() {}));
  }

  Future<void> _onReady() async {
    if (widget.dataId != null) {
      data = (await Global.instance.database.getDepartmentById(widget.dataId!))!
          .toCompanion(true);
    }
    textEditingControllerName.text =
        data.name == moor.Value.absent() ? "" : data.name.value!;
  }

  Future<void> save(BuildContext buildContext) async {
    try {
      final saveData = data.copyWith(
        name: moor.Value(textEditingControllerName.text),
      );
      if (widget.dataId == null) {
        await Global.instance.database.insertDepartment(saveData);
      } else {
        await Global.instance.database.updateDepartment(saveData);
      }
    } catch (e) {
      await Utils.alert(
        buildContext: buildContext,
        title: "Error",
        message: e.toString(),
      );
    }
  }

  Future<void> delete(BuildContext buildContext) async {
    try {
      if (widget.dataId == null) {
        throw Exception("dataId is null");
      }
      if (await Global.instance.database
          .isDepartmentHasEmployees(widget.dataId!)) {
        throw Exception("Department is already have Employees");
      }
      await Global.instance.database.deleteDepartment(widget.dataId!);
    } catch (e) {
      await Utils.alert(
        buildContext: buildContext,
        title: "Error",
        message: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.dataId == null ? "Add" : "Edit"} Department"),
        actions: [
          widget.dataId != null
              ? IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    bool isOK = await Utils.confirm(
                      buildContext: context,
                      title: "Confirm",
                      message: "Delete data, continue?",
                    );
                    if (!isOK) return;
                    await delete(context);
                    Navigator.pop(context);
                  },
                )
              : Container(),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              await save(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: textEditingControllerName,
                decoration: InputDecoration(
                  labelText: "Name",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
