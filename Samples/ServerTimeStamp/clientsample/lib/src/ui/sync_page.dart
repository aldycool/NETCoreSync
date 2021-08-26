import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import '../global.dart';
import '../utils.dart';

class SyncPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  bool _showLogsInTreeView = false;
  TreeController _treeController = TreeController(allNodesExpanded: false);
  bool _syncStarted = false;
  final List<Map<String, dynamic>> _logs = [];
  String _progressMessage = "";
  double _progressValue = 0;
  String? _errorMessage;
  Object? _error;
  SyncResultLogLevel? _logLevel = SyncResultLogLevel.fullData;

  void _toggleShowLogsInTreeView(bool value) {
    setState(() {
      _showLogsInTreeView = value;
    });
  }

  Future _synchronize(BuildContext context) async {
    try {
      setState(() {
        _syncStarted = true;
      });
      final syncUrl = await Global.instance.database.getSyncUrl();
      SyncEvent syncEvent =
          SyncEvent(progressEvent: (eventMessage, indeterminate, value) {
        setState(() {
          _progressMessage = eventMessage;
          _progressValue = value;
        });
      });
      setState(() {
        _errorMessage = null;
        _error = null;
        _logs.clear();
      });
      final syncResult = await Global.instance.database.netCoreSyncSynchronize(
        url: syncUrl,
        syncEvent: syncEvent,
        syncResultLogLevel: _logLevel ?? SyncResultLogLevel.fullData,
        customInfo: {
          "a": "abc",
          "b": 1000,
        },
      );
      setState(() {
        _errorMessage = syncResult.errorMessage;
        _error = syncResult.error;
        for (var i = 0; i < syncResult.logs.length; i++) {
          final log = syncResult.logs[i];
          _logs.add(log);
        }
      });
      if (syncResult.errorMessage != null) {
        await Utils.alert(
          buildContext: context,
          title: "ErrorMessage",
          message: syncResult.errorMessage!,
        );
      } else if (syncResult.error != null) {
        await Utils.alert(
            buildContext: context,
            title: "Error",
            message: syncResult.error.toString());
      } else {
        await Utils.alert(
            buildContext: context,
            title: "Info",
            message: "Synchronization is finished");
      }
    } catch (e) {
      await Utils.alert(
        buildContext: context,
        title: "Exception",
        message: e.toString(),
      );
    } finally {
      setState(() {
        _syncStarted = false;
        _progressMessage = "";
        _progressValue = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sync"),
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                child: Text(_syncStarted ? "Synchronizing..." : "Synchronize"),
                onPressed: _syncStarted
                    ? null
                    : () async {
                        await _synchronize(context);
                      },
              ),
              SizedBox(
                height: 12,
              ),
              Text(_progressMessage),
              SizedBox(
                height: 12,
              ),
              LinearProgressIndicator(value: _progressValue),
              SizedBox(
                height: 12,
              ),
              Text("Error Message: ${_errorMessage.toString()}"),
              SizedBox(
                height: 12,
              ),
              Text("Error: ${_error.toString()}"),
              SizedBox(
                height: 12,
              ),
              Text("Log Level:"),
              RadioListTile<SyncResultLogLevel?>(
                title: Text("Counts Only"),
                value: SyncResultLogLevel.countsOnly,
                groupValue: _logLevel,
                onChanged: (value) {
                  setState(() {
                    _logLevel = value;
                  });
                },
              ),
              RadioListTile<SyncResultLogLevel?>(
                title: Text("Sync Fields Only"),
                value: SyncResultLogLevel.syncFieldsOnly,
                groupValue: _logLevel,
                onChanged: (value) {
                  setState(() {
                    _logLevel = value;
                  });
                },
              ),
              RadioListTile<SyncResultLogLevel?>(
                title: Text("Full Data"),
                value: SyncResultLogLevel.fullData,
                groupValue: _logLevel,
                onChanged: (value) {
                  setState(() {
                    _logLevel = value;
                  });
                },
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Flexible(
                    child: Text("Show Logs in TreeView"),
                  ),
                  Flexible(
                    child: Switch(
                      value: _showLogsInTreeView,
                      onChanged: (value) => _toggleShowLogsInTreeView(value),
                    ),
                  ),
                  _showLogsInTreeView
                      ? Flexible(
                          child: ElevatedButton(
                            child: Text("Expand All"),
                            onPressed: () {
                              setState(() {
                                _treeController.expandAll();
                              });
                            },
                          ),
                        )
                      : Container(),
                  _showLogsInTreeView
                      ? SizedBox(
                          width: 12,
                        )
                      : Container(),
                  _showLogsInTreeView
                      ? Flexible(
                          child: ElevatedButton(
                            child: Text("Collapse All"),
                            onPressed: () {
                              setState(() {
                                _treeController.collapseAll();
                              });
                            },
                          ),
                        )
                      : Container(),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Divider(
                color: Colors.grey,
              ),
              ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _logs.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.grey),
                  itemBuilder: (context, index) {
                    if (!_showLogsInTreeView) {
                      return SelectableText(jsonEncode(_logs[index]));
                    } else {
                      return TreeView(
                          treeController: _treeController,
                          nodes: _toTreeNodes(_logs[index], true));
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }

  List<TreeNode> _toTreeNodes(dynamic parsedJson, bool isRoot) {
    if (isRoot) {
      final map = parsedJson as Map<String, dynamic>;
      String title = "action: ${map["action"]}";
      if (((map["data"] as Map<String, dynamic>).containsKey("className"))) {
        title = "$title, className: ${map["data"]["className"]}";
      }
      return [
        TreeNode(
            content: Flexible(
              child: SelectableText(title),
            ),
            children: _toTreeNodes(map["data"], false))
      ];
    } else {
      if (parsedJson is Map<String, dynamic>) {
        return parsedJson.keys.map((k) {
          String content = "$k:";
          List<TreeNode> children = [];
          if (parsedJson[k] is! Map<String, dynamic> &&
              parsedJson[k] is! List<dynamic>) {
            content = "$content ${parsedJson[k].toString()}";
          } else {
            if (parsedJson[k] is Map<String, dynamic> &&
                (parsedJson[k] as Map<String, dynamic>).isEmpty) {
              content = "$content {}";
            } else if (parsedJson[k] is List<dynamic> &&
                (parsedJson[k] as List<dynamic>).isEmpty) {
              content = "$content []";
            } else {
              children = _toTreeNodes(parsedJson[k], false);
            }
          }
          return TreeNode(
              content: Flexible(
                child: SelectableText(content),
              ),
              children: children);
        }).toList();
      }
      if (parsedJson is List<dynamic>) {
        return parsedJson
            .asMap()
            .map((i, element) {
              String content = "[$i]:";
              List<TreeNode> children = [];
              if (element is! Map<String, dynamic> &&
                  element is! List<dynamic>) {
                content = "$content ${element.toString()}";
              } else {
                if (element is Map<String, dynamic> && element.isEmpty) {
                  content = "$content {}";
                } else if (element is List<dynamic> && element.isEmpty) {
                  content = "$content []";
                } else {
                  children = _toTreeNodes(element, false);
                }
              }
              return MapEntry(
                  i,
                  TreeNode(
                      content: Flexible(
                        child: SelectableText(content),
                      ),
                      children: children));
            })
            .values
            .toList();
      }
      throw Exception("Unexpected parse");
      // return [TreeNode(content: Text(parsedJson.toString()))];
    }
  }
}
