import 'package:flutter/material.dart';
import 'package:moor/moor.dart' as moor;
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import '../data/database.dart';
import '../global.dart';
import '../utils.dart';

class PersonEntryPage extends StatefulWidget {
  late final String? dataId;

  PersonEntryPage({this.dataId}) : super();

  @override
  State<StatefulWidget> createState() => _PersonEntryPageState();
}

class _PersonEntryPageState extends State<PersonEntryPage> {
  bool _isLoading = true;

  PersonsCompanion data = PersonsCompanion();
  final TextEditingController controllerName = TextEditingController();
  late DateTime selectedBirthday;
  final TextEditingController controllerAge = TextEditingController();
  late bool selectedIsForeigner;
  late bool? selectedIsVaccinated;
  final TextEditingController controllerVaccineName = TextEditingController();
  late DateTime? selectedVaccinationDate;
  final TextEditingController controllerVaccinePhase = TextEditingController();
  late List<AreaData> areaDatas;
  AreaData selectedArea = Global.instance.database.getEmptyArea();

  @override
  void initState() {
    super.initState();
    _onReady().whenComplete(() => setState(() => _isLoading = false));
  }

  Future<void> _onReady() async {
    areaDatas = await Global.instance.database.getAllAreasForPicker();
    if (widget.dataId != null) {
      data = (await Global.instance.database.getPersonById(widget.dataId!))!
          .toCompanion(true);
    }
    controllerName.text =
        data.name == moor.Value.absent() ? "" : data.name.value;
    selectedBirthday = data.birthday == moor.Value.absent()
        ? DateTime.now()
        : data.birthday.value;
    controllerAge.text = data.age == moor.Value.absent()
        ? 0.toString()
        : data.age.value.toString();
    selectedIsForeigner = data.isForeigner == moor.Value.absent()
        ? false
        : data.isForeigner.value;
    selectedIsVaccinated = data.isVaccinated.value;
    controllerVaccineName.text =
        data.vaccineName == moor.Value.absent() ? "" : data.vaccineName.value!;
    selectedVaccinationDate = data.vaccinationDate.value;
    controllerVaccinePhase.text = data.vaccinePhase == moor.Value.absent()
        ? ""
        : data.vaccinePhase.value!.toString();
    if (data.vaccinationAreaPk != moor.Value.absent()) {
      selectedArea = (await Global.instance.database
          .getAreaById(data.vaccinationAreaPk.value!))!;
    }
  }

  Future<void> save(BuildContext buildContext) async {
    try {
      final saveData = data.copyWith(
        name: moor.Value(controllerName.text),
        birthday: moor.Value(selectedBirthday),
        age: moor.Value(int.parse(controllerAge.text)),
        isForeigner: moor.Value(selectedIsForeigner),
        isVaccinated: moor.Value(selectedIsVaccinated),
        vaccineName: moor.Value(controllerVaccineName.text.isEmpty
            ? null
            : controllerVaccineName.text),
        vaccinationDate: moor.Value(selectedVaccinationDate),
        vaccinePhase: moor.Value(controllerVaccinePhase.text.isEmpty
            ? null
            : int.parse(controllerVaccinePhase.text)),
        vaccinationAreaPk: moor.Value(
            selectedArea.pk == Uuid.NAMESPACE_NIL ? null : selectedArea.pk),
      );
      if (widget.dataId == null) {
        await Global.instance.database.insertPerson(saveData);
      } else {
        await Global.instance.database.updatePerson(saveData);
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
      await Global.instance.database.deletePerson(widget.dataId!);
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
                "${deleted ? "View" : (widget.dataId == null ? "Add" : "Edit")} Person"),
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
                      controller: controllerName,
                      decoration: InputDecoration(
                        labelText: "Name",
                      ),
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
                    TextField(
                      controller: controllerAge,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Age",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Text("Is Foreigner"),
                          Checkbox(
                              value: selectedIsForeigner,
                              onChanged: (value) {
                                setState(() {
                                  selectedIsForeigner = value!;
                                });
                              }),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Text("Is Vaccinated"),
                          Checkbox(
                              value: selectedIsVaccinated,
                              tristate: true,
                              onChanged: (value) {
                                setState(() {
                                  selectedIsVaccinated = value;
                                });
                              }),
                        ],
                      ),
                    ),
                    TextField(
                      controller: controllerVaccineName,
                      decoration: InputDecoration(
                        labelText: "Vaccine Name",
                      ),
                    ),
                    DateTimeField(
                      format: DateFormat("dd-MMM-yyyy"),
                      decoration: InputDecoration(
                        labelText: "Vaccination Date",
                      ),
                      initialValue: selectedVaccinationDate,
                      onShowPicker: (buildContext, currentValue) {
                        return showDatePicker(
                            context: buildContext,
                            firstDate: DateTime(1900),
                            initialDate: currentValue ?? DateTime.now(),
                            lastDate: DateTime(2100));
                      },
                      onChanged: (currentValue) {
                        selectedVaccinationDate = currentValue;
                      },
                    ),
                    TextField(
                      controller: controllerVaccinePhase,
                      decoration: InputDecoration(
                        labelText: "Vaccine Phase",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Text(
                              "Vaccination Area: ${selectedArea.city} - ${selectedArea.district}"),
                          SizedBox(width: 8.0),
                          PopupMenuButton<AreaData>(
                            icon: Icon(Icons.search),
                            initialValue: selectedArea,
                            onSelected: (value) => setState(() {
                              selectedArea = value;
                            }),
                            itemBuilder: (buildContext) {
                              return areaDatas
                                  .map<PopupMenuItem<AreaData>>((e) =>
                                      PopupMenuItem<AreaData>(
                                        value: e,
                                        child:
                                            Text("${e.city} - ${e.district}"),
                                      ))
                                  .toList();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
