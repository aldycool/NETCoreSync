import 'package:flutter/material.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import '../global.dart';
import '../utils.dart';
import '../data/database.dart';
import "home_page.dart";

class SigninPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  bool _isLoading = true;

  final TextEditingController controllerUserName = TextEditingController();
  final TextEditingController controllerLinkedUserNames =
      TextEditingController();
  final TextEditingController controllerSyncUrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initAsync().whenComplete(() => setState(() => _isLoading = false));
  }

  Future<void> _initAsync() async {
    controllerSyncUrl.text = await Global.instance.database.getSyncUrl();
  }

  Future<void> _signin(
    BuildContext context,
    String userName,
    String linkedUserNames,
  ) async {
    if (userName.isEmpty) {
      await Utils.alert(
        buildContext: context,
        title: "Warning",
        message: "UserName cannot be empty",
      );
      return;
    }
    var parsedLinkedUserNames =
        linkedUserNames.split(",").map((e) => e.trim()).toList();
    for (var element in parsedLinkedUserNames) {
      if (element.contains(" ")) {
        await Utils.alert(
          buildContext: context,
          title: "Warning",
          message: "Linked UserName: $element cannot contain spaces",
        );
        return;
      }
      if (element == userName) {
        await Utils.alert(
          buildContext: context,
          title: "Warning",
          message: "Linked UserName: $element cannot be the same as UserName: "
              "$userName",
        );
        return;
      }
    }
    if (parsedLinkedUserNames.length == 1 && parsedLinkedUserNames[0].isEmpty) {
      parsedLinkedUserNames.clear();
    }
    if (await Utils.confirm(
        buildContext: context,
        title: "Signin",
        message: "Signin with UserName: $userName, and Linked UserNames: "
            "${(parsedLinkedUserNames.isEmpty) ? "[NONE]" : parsedLinkedUserNames}. "
            "Continue?")) {
      Global.instance.database.netCoreSyncSetSyncIdInfo(SyncIdInfo(
        syncId: userName,
        linkedSyncIds: parsedLinkedUserNames,
      ));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  Future<void> _setSyncUrl(BuildContext context, String value) async {
    if (value.isEmpty) {
      await Utils.alert(
        buildContext: context,
        title: "Warning",
        message: "Sync Url cannot be empty",
      );
      return;
    }
    await Global.instance.database.setSyncUrl(value);
    await Utils.alert(
        buildContext: context, title: "Info", message: "Sync Url is saved");
  }

  Future<void> _resetSyncUrl(BuildContext context) async {
    await Global.instance.database
        .setSyncUrl(Database.defaultConfigurationValueSyncUrl);
    await _initAsync();
    await Utils.alert(
        buildContext: context, title: "Info", message: "Sync Url is reset");
  }

  Future<void> _resetDatabase(BuildContext context) async {
    if (await Utils.confirm(
        buildContext: context,
        title: "Warning",
        message: "Reset database, continue?")) {
      await Global.instance.database.resetDatabase(includeConfiguration: true);
      await Utils.alert(
          buildContext: context,
          title: "Info",
          message: "Reset Database is finished");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Signin"),
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controllerUserName,
                decoration: InputDecoration(
                  labelText: "UserName",
                ),
              ),
              TextField(
                controller: controllerLinkedUserNames,
                decoration: InputDecoration(
                  labelText: "Linked UserNames (if any)",
                  helperText: "Separate the linked UserNames with comma",
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  child: Text("Signin"),
                  onPressed: () async {
                    await _signin(context, controllerUserName.text,
                        controllerLinkedUserNames.text);
                  },
                ),
              ),
              _isLoading
                  ? CircularProgressIndicator()
                  : TextField(
                      controller: controllerSyncUrl,
                      decoration: InputDecoration(
                        labelText: "Sync Url",
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: ElevatedButton(
                  child: Text("Set Sync Url"),
                  onPressed: () async {
                    await _setSyncUrl(context, controllerSyncUrl.text);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                child: ElevatedButton(
                  child: Text("Reset Sync Url"),
                  onPressed: () async {
                    await _resetSyncUrl(context);
                  },
                ),
              ),
              SizedBox(
                height: 12,
              ),
              ElevatedButton(
                child: Text("Reset Database"),
                onPressed: () async {
                  await _resetDatabase(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
