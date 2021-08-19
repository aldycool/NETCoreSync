import 'package:flutter/material.dart';
import 'package:moor/moor.dart' as moor;
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:uuid/uuid.dart';
import '../data/database.dart';
import '../global.dart';
import '../utils.dart';

class CustomObjectEntryPage extends StatefulWidget {
  late final String? dataId;

  CustomObjectEntryPage({this.dataId}) : super();

  @override
  State<StatefulWidget> createState() => _CustomObjectEntryPageState();
}

class _CustomObjectEntryPageState extends State<CustomObjectEntryPage> {
  bool _isLoading = true;

  CustomObjectsCompanion data =
      CustomObjectsCompanion().copyWith(id: moor.Value(Uuid().v4()));
  final TextEditingController controllerFieldString = TextEditingController();
  final TextEditingController controllerFieldStringNullable =
      TextEditingController();
  final TextEditingController controllerFieldInt = TextEditingController();
  final TextEditingController controllerFieldIntNullable =
      TextEditingController();
  late bool selectedFieldBoolean;
  late bool? selectedFieldBooleanNullable;
  late DateTime selectedFieldDateTime;
  late DateTime? selectedFieldDateTimeNullable;

  @override
  void initState() {
    super.initState();
    _onReady().whenComplete(() => setState(() => _isLoading = false));
  }

  Future<void> _onReady() async {
    if (widget.dataId != null) {
      data =
          (await Global.instance.database.getCustomObjectById(widget.dataId!))!
              .toCompanion(true);
    }
    controllerFieldString.text =
        data.fieldString == moor.Value.absent() ? "" : data.fieldString.value;
    controllerFieldStringNullable.text =
        data.fieldStringNullable == moor.Value.absent()
            ? ""
            : data.fieldStringNullable.value!;
    controllerFieldInt.text = data.fieldInt == moor.Value.absent()
        ? 0.toString()
        : data.fieldInt.value.toString();
    controllerFieldIntNullable.text =
        data.fieldIntNullable == moor.Value.absent()
            ? ""
            : data.fieldIntNullable.value!.toString();
    selectedFieldBoolean = data.fieldBoolean == moor.Value.absent()
        ? false
        : data.fieldBoolean.value;
    selectedFieldBooleanNullable = data.fieldBooleanNullable.value;
    selectedFieldDateTime = data.fieldDateTime == moor.Value.absent()
        ? DateTime.now()
        : data.fieldDateTime.value;
    selectedFieldDateTimeNullable = data.fieldDateTimeNullable.value;
  }

  Future<void> save(BuildContext buildContext) async {
    try {
      final saveData = data.copyWith(
        fieldString: moor.Value(controllerFieldString.text),
        fieldStringNullable: moor.Value(
            controllerFieldStringNullable.text.isEmpty
                ? null
                : controllerFieldStringNullable.text),
        fieldInt: moor.Value(int.parse(controllerFieldInt.text)),
        fieldIntNullable: moor.Value(controllerFieldIntNullable.text.isEmpty
            ? null
            : int.parse(controllerFieldIntNullable.text)),
        fieldBoolean: moor.Value(selectedFieldBoolean),
        fieldBooleanNullable: moor.Value(selectedFieldBooleanNullable),
        fieldDateTime: moor.Value(selectedFieldDateTime),
        fieldDateTimeNullable: moor.Value(selectedFieldDateTimeNullable),
      );
      if (widget.dataId == null) {
        await Global.instance.database.insertCustomObject(saveData);
      } else {
        await Global.instance.database.updateCustomObject(saveData);
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
      await Global.instance.database.deleteCustomObject(widget.dataId!);
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
    bool deleted = _isLoading
        ? false
        : (data.deleted == moor.Value.absent() ? false : data.deleted.value);
    return Scaffold(
      appBar: AppBar(
        title: _isLoading
            ? Container()
            : Text(
                "${deleted ? "View" : (widget.dataId == null ? "Add" : "Edit")} CustomObject"),
        actions: _isLoading || deleted
            ? []
            : [
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
          child: _isLoading
              ? CircularProgressIndicator()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: controllerFieldString,
                      decoration: InputDecoration(
                        labelText: "FieldString",
                      ),
                    ),
                    TextField(
                      controller: controllerFieldStringNullable,
                      decoration: InputDecoration(
                        labelText: "FieldStringNullable",
                      ),
                    ),
                    TextField(
                      controller: controllerFieldInt,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "FieldInt",
                      ),
                    ),
                    TextField(
                      controller: controllerFieldIntNullable,
                      decoration: InputDecoration(
                        labelText: "FieldIntNullable",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Text("FieldBoolean"),
                          Checkbox(
                              value: selectedFieldBoolean,
                              onChanged: (value) {
                                setState(() {
                                  selectedFieldBoolean = value!;
                                });
                              }),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Text("FieldBooleanNullable"),
                          Checkbox(
                              value: selectedFieldBooleanNullable,
                              tristate: true,
                              onChanged: (value) {
                                setState(() {
                                  selectedFieldBooleanNullable = value;
                                });
                              }),
                        ],
                      ),
                    ),
                    DateTimeField(
                      format: DateFormat("dd-MMM-yyyy"),
                      decoration: InputDecoration(
                        labelText: "FieldDateTime",
                      ),
                      initialValue: selectedFieldDateTime,
                      onShowPicker: (buildContext, currentValue) {
                        return showDatePicker(
                            context: buildContext,
                            firstDate: DateTime(1900),
                            initialDate: currentValue ?? selectedFieldDateTime,
                            lastDate: DateTime(2100));
                      },
                      onChanged: (currentValue) {
                        selectedFieldDateTime = currentValue ?? DateTime.now();
                      },
                    ),
                    DateTimeField(
                      format: DateFormat("dd-MMM-yyyy"),
                      decoration: InputDecoration(
                        labelText: "FieldDateTimeNullable",
                      ),
                      initialValue: selectedFieldDateTimeNullable,
                      onShowPicker: (buildContext, currentValue) {
                        return showDatePicker(
                            context: buildContext,
                            firstDate: DateTime(1900),
                            initialDate: currentValue ?? DateTime.now(),
                            lastDate: DateTime(2100));
                      },
                      onChanged: (currentValue) {
                        selectedFieldDateTimeNullable = currentValue;
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
