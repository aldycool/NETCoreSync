import 'package:client_app/src/data/database.dart';
import 'package:flutter/material.dart';
import 'package:moor/moor.dart' as moor;
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../global.dart';
import '../utils.dart';

class EmployeeEntryPage extends StatefulWidget {
  late final String? dataId;

  EmployeeEntryPage({this.dataId}) : super();

  @override
  State<StatefulWidget> createState() => _EmployeeEntryPageState();
}

class _EmployeeEntryPageState extends State<EmployeeEntryPage> {
  bool isLoading = true;
  EmployeesCompanion data = EmployeesCompanion();
  final TextEditingController textEditingControllerName =
      TextEditingController();
  late DateTime selectedBirthday;
  final TextEditingController textEditingControllerNumberOfComputers =
      TextEditingController();
  final TextEditingController textEditingControllerSavingAmount =
      TextEditingController();
  late bool selectedIsActive;
  late List<Department> departmentDatas;
  Department selectedDepartment = Global.instance.database.getEmptyDepartment();

  @override
  void initState() {
    super.initState();
    _onReady().whenComplete(() => setState(() {
          isLoading = false;
        }));
  }

  Future<void> _onReady() async {
    departmentDatas =
        await Global.instance.database.getAllDepartmentsForPicker();
    if (widget.dataId != null) {
      data = (await Global.instance.database.getEmployeeById(widget.dataId!))!
          .toCompanion(true);
    }
    textEditingControllerName.text =
        data.name == moor.Value.absent() ? "" : data.name.value!;
    selectedBirthday = data.birthday == moor.Value.absent()
        ? DateTime.now()
        : data.birthday.value;
    textEditingControllerNumberOfComputers.text =
        data.numberOfComputers == moor.Value.absent()
            ? 0.toString()
            : data.numberOfComputers.value.toString();
    textEditingControllerSavingAmount.text =
        data.savingAmount == moor.Value.absent()
            ? 0.toString()
            : data.savingAmount.value.toString();
    selectedIsActive =
        data.isActive == moor.Value.absent() ? false : data.isActive.value;
    if (data.departmentId != moor.Value.absent()) {
      selectedDepartment = (await Global.instance.database
          .getDepartmentById(data.departmentId.value!))!;
    }
  }

  Future<void> save(BuildContext buildContext) async {
    try {
      final saveData = data.copyWith(
        name: moor.Value(textEditingControllerName.text),
        birthday: moor.Value(selectedBirthday),
        numberOfComputers:
            moor.Value(int.parse(textEditingControllerNumberOfComputers.text)),
        savingAmount:
            moor.Value(int.parse(textEditingControllerSavingAmount.text)),
        isActive: moor.Value(selectedIsActive),
        departmentId: moor.Value(selectedDepartment.id == Uuid.NAMESPACE_NIL
            ? null
            : selectedDepartment.id),
      );
      if (widget.dataId == null) {
        await Global.instance.database.insertEmployee(saveData);
      } else {
        await Global.instance.database.updateEmployee(saveData);
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
      await Global.instance.database.deleteEmployee(widget.dataId!);
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
        title: Text("${widget.dataId == null ? "Add" : "Edit"} Employee"),
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
            children: isLoading
                ? []
                : [
                    TextField(
                      controller: textEditingControllerName,
                      decoration: InputDecoration(
                        labelText: "Name",
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    DateTimeField(
                      format: DateFormat("dd-MMM-yyyy"),
                      decoration: InputDecoration(
                        labelText: "Birthday",
                      ),
                      initialValue: selectedBirthday,
                      onShowPicker: (buildContext, currentValue) {
                        return showDatePicker(
                            context: buildContext,
                            firstDate: DateTime(1900),
                            initialDate: currentValue ?? selectedBirthday,
                            lastDate: DateTime(2100));
                      },
                      onChanged: (currentValue) {
                        selectedBirthday = currentValue ?? DateTime.now();
                      },
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    TextField(
                      controller: textEditingControllerNumberOfComputers,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Number of Computers",
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    TextField(
                      controller: textEditingControllerSavingAmount,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Saving Amount",
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Checkbox(
                            value: selectedIsActive,
                            onChanged: (value) {
                              setState(() {
                                selectedIsActive = value!;
                              });
                            }),
                        Text("Is Active"),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    PopupMenuButton<Department>(
                      child: Text("Department: ${selectedDepartment.name!}"),
                      initialValue: selectedDepartment,
                      onSelected: (value) => setState(() {
                        selectedDepartment = value;
                      }),
                      itemBuilder: (buildContext) {
                        return departmentDatas
                            .map<PopupMenuItem<Department>>(
                                (e) => PopupMenuItem<Department>(
                                      value: e,
                                      child: Text(e.name!),
                                    ))
                            .toList();
                      },
                    )
                  ],
          ),
        ),
      ),
    );
  }
}
