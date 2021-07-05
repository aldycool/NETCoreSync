import 'package:flutter/material.dart';
import '../global.dart';
import '../utils.dart';

class SetupPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final TextEditingController textEditingControllerSynchronizationId =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _onReady().whenComplete(() => setState(() {}));
  }

  Future<void> _onReady() async {
    textEditingControllerSynchronizationId.text =
        await Global.instance.database.getSynchronizationId() ?? "";
  }

  void save(BuildContext buildContext) async {
    try {
      String? existing = await Global.instance.database.getSynchronizationId();
      if (existing != null) {
        bool isOK = await Utils.confirm(
          buildContext: buildContext,
          title: "Confirm",
          message:
              "Changing Synchronization ID require database reset, continue?",
        );
        if (!isOK) return;
      }
      await Global.instance.database.resetDatabase();
      await Global.instance.database
          .setSynchronizationId(textEditingControllerSynchronizationId.text);
      await Utils.alert(
        buildContext: buildContext,
        title: "Info",
        message: "Synchronization ID is saved",
      );
    } catch (e) {
      await Utils.alert(
        buildContext: buildContext,
        title: "Error",
        message: e.toString(),
      );
    }
  }

  void resetDatabase(BuildContext buildContext) async {
    try {
      bool isOK = await Utils.confirm(
        buildContext: buildContext,
        title: "Confirm",
        message: "Reset database, continue?",
      );
      if (!isOK) return;
      await Global.instance.database.resetDatabase(includeConfiguration: true);
      textEditingControllerSynchronizationId.text = "";
      setState(() {});
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
        title: Text("Setup"),
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: textEditingControllerSynchronizationId,
                decoration: InputDecoration(
                  labelText: "Synchronization ID",
                  border: UnderlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              ElevatedButton(
                child: Text("Save"),
                onPressed: () {
                  save(context);
                },
              ),
              SizedBox(
                height: 12,
              ),
              ElevatedButton(
                child: Text("Reset Database"),
                onPressed: () {
                  resetDatabase(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
