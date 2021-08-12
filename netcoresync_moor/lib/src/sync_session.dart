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

  Future<SyncResult> synchronize() async {
    final syncResult = SyncResult();

    _progress("Connecting...");
    final connectResult = await _syncSocket.connect();
    if (connectResult.errorMessage != null || connectResult.error != null) {
      syncResult.errorMessage = connectResult.errorMessage;
      syncResult.error = connectResult.error;
      await _syncSocket.close();
      return syncResult;
    }
    connectionId = connectResult.connectionId;

    late ResponseResult responseResult;

    _progress("Acquiring access...");
    responseResult = await _syncSocket.request(
      payload: HandshakeRequestPayload(
        schemaVersion: dataAccess.database.schemaVersion,
        syncIdInfo: dataAccess.syncIdInfo!,
      ),
    );
    if (await _shouldTerminate(
      responseResult: responseResult,
      syncResult: syncResult,
    )) {
      return syncResult;
    }
    final handshake =
        HandshakeResponsePayload.fromJson(responseResult.payload!.toJson());
    for (var i = 0; i < handshake.orderedClassNames.length; i++) {
      final className = handshake.orderedClassNames[i];
      final classType = dataAccess.engine.tables.keys.firstWhere(
          (element) => element.toString() == className,
          orElse: () => Null);
      if (classType == Null) {
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
      final syncTableResponse = _syncSocket.request(
          payload: SyncTableRequestPayload(
        className: className,
        annotations: tableUser.tableAnnotation.toJson(),
        unsyncedRows: unsyncedRows,
        knowledges: knowledges,
      ));
      print("");
    }

    // TODO: continue main synchronize logic when ready

    return syncResult;
  }

  void _progress(
    String message, {
    double current = 0,
    double min = 0,
    double max = 0,
  }) {
    syncEvent?.progressEvent?.call(
      message,
      current,
      min,
      max,
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
