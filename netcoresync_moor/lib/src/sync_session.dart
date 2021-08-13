import 'package:moor/moor.dart';
import 'netcoresync_classes.dart';
import 'sync_socket.dart';
import 'data_access.dart';
import 'sync_messages.dart';

class SyncSession {
  final DataAccess dataAccess;
  final SyncEvent? syncEvent;
  final Map<String, dynamic> customInfo;
  late SyncSocket _syncSocket;
  String? connectionId;

  SyncSession({
    required this.dataAccess,
    required String url,
    this.syncEvent,
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
    syncResult.logs.add(log);
    _log(log);
  }

  Future<SyncResult> synchronize() async {
    final syncResult = SyncResult();

    _progress("Connecting...");
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

    _progress("Acquiring access...");
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
    for (var i = 0; i < handshakeResponse.orderedClassNames.length; i++) {
      final className = handshakeResponse.orderedClassNames[i];
      _progress(
        "Synchronizing...",
        min: 0,
        max: handshakeResponse.orderedClassNames.length,
        current: i,
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
      final syncTableRequest = SyncTableRequestPayload(
        className: className,
        annotations: tableUser.tableAnnotation.toJson(),
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
      final syncTableResponse =
          responseResult.payload! as SyncTableResponsePayload;
      _logAction(syncResult, payload: syncTableResponse);
      if (await _shouldTerminate(
        responseResult: responseResult,
        syncResult: syncResult,
      )) {
        return syncResult;
      }
      for (var j = 0; j < unsyncedRows.length; j++) {
        var unsyncedRow = unsyncedRows[j];
        unsyncedRow =
            dataAccess.engine.updateSyncColumns(unsyncedRow, synced: true);
        await dataAccess.update(tableUser.tableInfo).replace(unsyncedRow);
      }
      for (var j = 0; j < syncTableResponse.knowledges.length; j++) {
        var knowledge = syncTableResponse.knowledges[j];
        var existing = await (dataAccess.select(dataAccess.knowledges)
              ..where((tbl) =>
                  tbl.id.equals(knowledge.id) &
                  tbl.syncId.equals(knowledge.syncId)))
            .getSingleOrNull();
        if (existing == null) {
          await dataAccess.into(dataAccess.knowledges).insert(knowledge);
        } else {
          existing.lastTimeStamp = knowledge.lastTimeStamp;
          await dataAccess.update(dataAccess.knowledges).replace(existing);
        }
      }

      // TODO: Handle unsynced rows from server response
      // TODO: handle deletedIds from server response
    }

    _progress("Disconnecting...");
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

    return syncResult;
  }

  void _progress(
    String message, {
    int current = 0,
    int min = 0,
    int max = 0,
  }) {
    assert(current >= min && current <= max);
    syncEvent?.progressEvent?.call(
      message,
      (current - min) / (max - min),
      0.0,
      1.0,
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
    }
    return false;
  }
}
