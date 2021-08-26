import 'package:moor/moor.dart';
import 'netcoresync_classes.dart';
import 'sync_socket.dart';
import 'data_access.dart';
import 'sync_messages.dart';

class SyncSession {
  final DataAccess dataAccess;
  final SyncEvent? syncEvent;
  final SyncResultLogLevel syncResultLogLevel;
  final Map<String, dynamic> customInfo;
  late SyncSocket _syncSocket;
  String? connectionId;

  SyncSession({
    required this.dataAccess,
    required String url,
    this.syncEvent,
    this.syncResultLogLevel = SyncResultLogLevel.fullData,
    this.customInfo = const {},
  }) {
    _syncSocket = SyncSocket(
      url: url,
      logger: dataAccess.logger,
    );
  }

  void _log(Map<String, dynamic> object) {
    if (dataAccess.logger != null) {
      dataAccess.logger!(object);
    }
  }

  void _logAction(
    SyncResult syncResult, {
    BasePayload? payload,
    String? action,
    Map<String, dynamic>? data,
  }) {
    Map<String, dynamic> log = {};
    log["action"] = payload?.action ?? action;
    log["data"] = payload?.toJson() ?? data;
    log = _stripLog(log);
    syncResult.logs.add(log);
    _log(log);
  }

  Map<String, dynamic> _stripLog(Map<String, dynamic> log) {
    if (syncResultLogLevel == SyncResultLogLevel.fullData) {
      return log;
    }

    dynamic _processStrip(dynamic listData, bool useServerAnnotations) {
      final list = listData as List<dynamic>;
      if (syncResultLogLevel == SyncResultLogLevel.countsOnly) {
        return list.length;
      } else if (syncResultLogLevel == SyncResultLogLevel.syncFieldsOnly) {
        final replaceList = [];
        final syncFieldNames = [];
        if (!useServerAnnotations) {
          final className = log["data"]["className"];
          final classType = dataAccess.engine.tables.keys
              .where((type) => type.toString() == className)
              .first;
          final clientAnnotation =
              dataAccess.engine.tables[classType]!.tableAnnotation;
          syncFieldNames.add(clientAnnotation.idFieldName);
          syncFieldNames.add(clientAnnotation.syncIdFieldName);
          syncFieldNames.add(clientAnnotation.knowledgeIdFieldName);
          syncFieldNames.add(clientAnnotation.syncedFieldName);
          syncFieldNames.add(clientAnnotation.deletedFieldName);
        } else {
          syncFieldNames.addAll(
              (log["data"]["annotations"] as Map<String, dynamic>).values);
        }

        for (var i = 0; i < list.length; i++) {
          var map = list[i];
          if (map is! Map<String, dynamic>) {
            map = dataAccess.engine.toJson(map);
          }
          var entry = {};
          for (var syncFieldName in syncFieldNames) {
            entry[syncFieldName] = map[syncFieldName];
          }
          replaceList.add(entry);
        }
        return replaceList;
      }
    }

    if (log.containsKey("action") &&
        (log["action"] == "syncTableRequest" ||
            log["action"] == "syncTableResponse") &&
        (log["data"] as Map<String, dynamic>).containsKey("unsyncedRows")) {
      log["data"]["unsyncedRows"] =
          _processStrip(log["data"]["unsyncedRows"], false);
    }
    if (log.containsKey("action") &&
        (log["action"] == "syncTableResponse" ||
            log["action"] == "responseApplyRows") &&
        (log["data"] as Map<String, dynamic>).containsKey("logs")) {
      bool useServerAnnotations = log["action"] == "syncTableResponse";
      log["data"]["logs"]["inserts"] =
          _processStrip(log["data"]["logs"]["inserts"], useServerAnnotations);
      log["data"]["logs"]["updates"] =
          _processStrip(log["data"]["logs"]["updates"], useServerAnnotations);
      log["data"]["logs"]["deletes"] =
          _processStrip(log["data"]["logs"]["deletes"], useServerAnnotations);
      log["data"]["logs"]["ignores"] =
          _processStrip(log["data"]["logs"]["ignores"], useServerAnnotations);
    }

    return log;
  }

  static const String defaultConnectingMessage = "Connecting...";
  static const String defaultHandshakeRequestMessage = "Acquiring access...";
  static const String defaultSyncTableRequestMessage = "Synchronizing...";
  static const String defaultDisconnectingMessage = "Disconnecting...";

  Future<SyncResult> synchronize() async {
    final syncResult = SyncResult();

    Future closeFunc() async {
      _progress(defaultDisconnectingMessage);
      _logAction(
        syncResult,
        action: "closeRequest",
        data: {},
      );
      await _syncSocket.close();
      _logAction(
        syncResult,
        action: "closeResponse",
        data: {},
      );
    }

    _progress(defaultConnectingMessage);
    _logAction(
      syncResult,
      action: "connectRequest",
      data: {
        "url": _syncSocket.url,
      },
    );
    final connectResult = await _syncSocket.connect();
    if (connectResult.errorMessage != null || connectResult.error != null) {
      syncResult.errorMessage = connectResult.errorMessage;
      syncResult.error = connectResult.error;
      await _syncSocket.close();
      return syncResult;
    }
    connectionId = connectResult.connectionId;
    _logAction(
      syncResult,
      action: "connectResponse",
      data: {
        "connectionId": connectionId,
      },
    );

    late ResponseResult responseResult;

    _progress(defaultHandshakeRequestMessage);
    final handshakeRequest = HandshakeRequestPayload(
      schemaVersion: dataAccess.database.schemaVersion,
      syncIdInfo: dataAccess.syncIdInfo!,
      customInfo: customInfo,
    );
    _logAction(
      syncResult,
      payload: handshakeRequest,
    );
    responseResult = await _syncSocket.request(
      payload: handshakeRequest,
    );
    if (await _shouldTerminate(
      responseResult: responseResult,
      syncResult: syncResult,
    )) {
      return syncResult;
    }
    final handshakeResponse =
        responseResult.payload! as HandshakeResponsePayload;
    _logAction(
      syncResult,
      payload: handshakeResponse,
    );

    try {
      for (var i = 0; i < handshakeResponse.orderedClassNames.length; i++) {
        final className = handshakeResponse.orderedClassNames[i];
        _progress(
          defaultSyncTableRequestMessage,
          indeterminate: false,
          value: i,
          min: 0,
          max: handshakeResponse.orderedClassNames.length,
        );
        final classType = dataAccess.engine.tables.keys.firstWhere(
            (element) => element.toString() == className,
            orElse: () => Null);
        if (classType == Null) {
          _logAction(
            syncResult,
            action: "syncTableSkip",
            data: {
              "className": className,
            },
          );
          continue;
        }
        final tableUser = dataAccess.engine.tables[classType]!;
        final unsyncedRows = await (dataAccess.select(tableUser.tableInfo)
              ..where((tbl) => CustomExpression(
                  "${tableUser.syncIdEscapedName} IN "
                  "(${dataAccess.syncIdInfo!.getAllSyncIds().join(", ")}) AND "
                  "${tableUser.syncedEscapedName} = 0")))
            .get();
        final knowledges = await dataAccess.select(dataAccess.knowledges).get();
        Map<String, dynamic> annotations = tableUser.tableAnnotation.toJson();
        annotations["columnFieldNames"] = tableUser.columnFieldNames;
        final syncTableRequest = SyncTableRequestPayload(
          className: className,
          annotations: annotations,
          unsyncedRows: unsyncedRows,
          knowledges: knowledges,
          customInfo: customInfo,
        );
        _logAction(
          syncResult,
          payload: syncTableRequest,
        );
        responseResult = await _syncSocket.request(
          payload: syncTableRequest,
        );
        // Even though there might be errors from server here, try to capture the
        // incoming logs from server first (if there's any payload from server).
        if (responseResult.payload != null) {
          _logAction(syncResult, payload: responseResult.payload);
        }
        if (await _shouldTerminate(
          responseResult: responseResult,
          syncResult: syncResult,
        )) {
          return syncResult;
        }
        final syncTableResponse =
            responseResult.payload! as SyncTableResponsePayload;
        for (var j = 0; j < unsyncedRows.length; j++) {
          var unsyncedRow = unsyncedRows[j];
          unsyncedRow =
              dataAccess.engine.updateSyncColumns(unsyncedRow, synced: true);
          await dataAccess.update(tableUser.tableInfo).replace(unsyncedRow);
        }
        Map<String, dynamic> responseApplyRows = {
          "inserts": [],
          "updates": [],
          "deletes": [],
          "ignores": [],
          "deletedIds": [],
        };
        for (var j = 0; j < syncTableResponse.unsyncedRows.length; j++) {
          var serverRow = syncTableResponse.unsyncedRows[j];
          final serverData = dataAccess.engine.fromJson(classType, serverRow);
          final rowId =
              dataAccess.engine.getSyncColumnValue(serverData, "id") as String;
          final rowDeleted = dataAccess.engine
              .getSyncColumnValue(serverData, "deleted") as bool;
          final clientRows = await (dataAccess.select(tableUser.tableInfo)
                ..where((tbl) =>
                    CustomExpression("${tableUser.idEscapedName} = '$rowId'")))
              .get();
          if (clientRows.isEmpty) {
            if (!rowDeleted) {
              await dataAccess.into(tableUser.tableInfo).insert(serverData);
              responseApplyRows["inserts"]!.add(serverRow);
            } else {
              responseApplyRows["ignores"]!.add(serverRow);
            }
          } else {
            await dataAccess.update(tableUser.tableInfo).replace(serverData);
            if (!rowDeleted) {
              responseApplyRows["updates"]!.add(serverRow);
            } else {
              responseApplyRows["deletes"]!.add(serverRow);
            }
          }
        }
        for (var j = 0; j < syncTableResponse.deletedIds.length; j++) {
          var deletedId = syncTableResponse.deletedIds[j];
          final clientRows = await (dataAccess.select(tableUser.tableInfo)
                ..where((tbl) => CustomExpression(
                    "${tableUser.idEscapedName} = '$deletedId'")))
              .get();
          if (clientRows.isNotEmpty) {
            var clientRow = clientRows.elementAt(0);
            clientRow = dataAccess.engine.updateSyncColumns(
              clientRow,
              synced: true,
              deleted: true,
            );
            await dataAccess.update(tableUser.tableInfo).replace(clientRow);
            responseApplyRows["deletedIds"]!.add(deletedId);
          }
        }
        _logAction(syncResult,
            action: "responseApplyRows",
            data: {"className": className, "logs": responseApplyRows});
        Map<String, List<dynamic>> applyKnowledges = {
          "inserts": [],
          "updates": [],
        };
        for (var j = 0; j < syncTableResponse.knowledges.length; j++) {
          var knowledge = syncTableResponse.knowledges[j];
          var existing = await (dataAccess.select(dataAccess.knowledges)
                ..where((tbl) =>
                    tbl.id.equals(knowledge.id) &
                    tbl.syncId.equals(knowledge.syncId)))
              .getSingleOrNull();
          if (existing == null) {
            await dataAccess.into(dataAccess.knowledges).insert(knowledge);
            applyKnowledges["inserts"]!.add(knowledge.toJson());
          } else {
            existing.lastTimeStamp = knowledge.lastTimeStamp;
            await dataAccess.update(dataAccess.knowledges).replace(existing);
            applyKnowledges["updates"]!.add(existing.toJson());
          }
        }
        _logAction(syncResult,
            action: "applyKnowledges",
            data: {"className": className, "logs": applyKnowledges});
      }
    } catch (_) {
      try {
        await closeFunc();
      } catch (_) {}
      rethrow;
    }

    await closeFunc();

    return syncResult;
  }

  void _progress(
    String message, {
    bool indeterminate = true,
    int value = 0,
    int min = 0,
    int max = 0,
  }) {
    assert(value >= min && value <= max);
    syncEvent?.progressEvent?.call(
      message,
      indeterminate,
      (max - min) == 0 ? 0 : (value - min) / (max - min),
    );
  }

  Future<bool> _shouldTerminate({
    required ResponseResult responseResult,
    required SyncResult syncResult,
  }) async {
    if (responseResult.errorMessage != null || responseResult.error != null) {
      syncResult.errorMessage = responseResult.errorMessage;
      syncResult.error = responseResult.error;
      await _syncSocket.close();
      return true;
    } else if (responseResult.payload == null) {
      syncResult.errorMessage = ResponseResult.payloadNullErrorMessage;
      await _syncSocket.close();
      return true;
    }
    return false;
  }
}
