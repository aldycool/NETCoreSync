import 'package:flutter/material.dart';
import 'package:moor/moor.dart' as moor;
import '../data/database.dart';
import '../global.dart';
import '../utils.dart';

class AreaEntryPage extends StatefulWidget {
  late final String? dataId;

  AreaEntryPage({this.dataId}) : super();

  @override
  State<StatefulWidget> createState() => _AreaEntryPageState();
}

class _AreaEntryPageState extends State<AreaEntryPage> {
  bool _isLoading = true;

  AreasCompanion data = AreasCompanion();
  final TextEditingController controllerCity = TextEditingController();
  final TextEditingController controllerDistrict = TextEditingController();

  @override
  void initState() {
    super.initState();
    _onReady().whenComplete(() => setState(() => _isLoading = false));
  }

  Future<void> _onReady() async {
    if (widget.dataId != null) {
      data = (await Global.instance.database.getAreaById(widget.dataId!))!
          .toCompanion(true);
    }
    controllerCity.text =
        data.city == moor.Value.absent() ? "" : data.city.value;
    controllerDistrict.text =
        data.district == moor.Value.absent() ? "" : data.district.value;
  }

  Future<void> save(BuildContext buildContext) async {
    try {
      final saveData = data.copyWith(
        city: moor.Value(controllerCity.text),
        district: moor.Value(controllerDistrict.text),
      );
      if (widget.dataId == null) {
        await Global.instance.database.insertArea(saveData);
      } else {
        await Global.instance.database.updateArea(saveData);
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
      if (await Global.instance.database.isAreaHasPersons(widget.dataId!)) {
        throw Exception("Area is already has Persons");
      }
      await Global.instance.database.deleteArea(widget.dataId!);
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
        : (data.syncDeleted == moor.Value.absent()
            ? false
            : data.syncDeleted.value);
    return Scaffold(
      appBar: AppBar(
        title: _isLoading
            ? Container()
            : Text(
                "${deleted ? "View" : (widget.dataId == null ? "Add" : "Edit")} Area"),
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
                      controller: controllerCity,
                      decoration: InputDecoration(
                        labelText: "City",
                      ),
                    ),
                    TextField(
                      controller: controllerDistrict,
                      decoration: InputDecoration(
                        labelText: "District",
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
