import 'dart:async';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as socket_channel_status;
import 'package:uuid/uuid.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'netcoresync_exceptions.dart';
import 'data_access.dart';
import 'sync_messages.dart';

class SyncHandler {
  final DataAccess dataAccess;

  SyncHandler(this.dataAccess);

  Future synchronize({
    required String url,
    Map<String, dynamic> customInfo = const {},
  }) async {
    if (dataAccess.syncIdInfo == null) {
      throw NetCoreSyncSyncIdInfoNotSetException();
    }
    if (dataAccess.inTransaction()) {
      throw NetCoreSyncMustNotInsideTransactionException();
    }

    var channel = WebSocketChannel.connect(Uri.parse(url));

    String echoMessage = Uuid().v4();
    final request = RequestMessage(
      schemaVersion: dataAccess.database.schemaVersion,
      syncIdInfo: dataAccess.syncIdInfo!,
      basePayload: EchoRequestPayload(message: echoMessage),
    );
    channel.sink.add(SyncMessages.compress(request));

    StreamSubscription sub = channel.stream.listen((message) async {
      ResponseMessage response = SyncMessages.decompress(message);

      if (EnumToString.fromString(PayloadActions.values, response.action) ==
          PayloadActions.echoResponse) {
        EchoResponsePayload payload =
            EchoResponsePayload.fromJson(response.payload);
        if (payload.message != echoMessage) {
          throw NetCoreSyncException(
              "Response echoMessage: ${payload.message} is "
              "different than Request echoMessage: $echoMessage");
        }

        final request = RequestMessage(
          schemaVersion: dataAccess.database.schemaVersion,
          syncIdInfo: dataAccess.syncIdInfo!,
          basePayload: HandshakeRequestPayload(),
        );
        channel.sink.add(SyncMessages.compress(request));
      }

      if (EnumToString.fromString(PayloadActions.values, response.action) ==
          PayloadActions.handshakeResponse) {
        HandshakeResponsePayload payload =
            HandshakeResponsePayload.fromJson(response.payload);
        print(payload.orderedClassNames);
        channel.sink.close(socket_channel_status.goingAway);
      }
    });

    await Future.wait([
      sub.asFuture(),
    ]);
  }
}
