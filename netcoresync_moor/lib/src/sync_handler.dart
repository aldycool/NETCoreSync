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

    final echoRequest = RequestMessage(
      schemaVersion: dataAccess.database.schemaVersion,
      syncIdInfo: dataAccess.syncIdInfo!,
      basePayload: EchoRequestPayload(message: echoMessage),
    );
    channel.sink.add(SyncMessages.compress(echoRequest));

    StreamSubscription sub = channel.stream.listen((message) async {
      ResponseMessage responseMessage = SyncMessages.decompress(message);

      if (EnumToString.fromString(
              PayloadActions.values, responseMessage.action) ==
          PayloadActions.echoResponse) {
        EchoResponsePayload echoResponsePayload =
            EchoResponsePayload.fromJson(responseMessage.payload);
        if (echoResponsePayload.message != echoMessage) {
          throw NetCoreSyncException(
              "Response echoMessage: ${echoResponsePayload.message} is "
              "different than Request echoMessage: $echoMessage");
        }

        final handshakeRequest = RequestMessage(
          schemaVersion: dataAccess.database.schemaVersion,
          syncIdInfo: dataAccess.syncIdInfo!,
          basePayload: HandshakeRequestPayload(),
        );
        channel.sink.add(SyncMessages.compress(handshakeRequest));
      }

      if (EnumToString.fromString(
              PayloadActions.values, responseMessage.action) ==
          PayloadActions.handshakeResponse) {
        HandshakeResponsePayload handshakeResponsePayload =
            HandshakeResponsePayload.fromJson(responseMessage.payload);
        print(handshakeResponsePayload.orderedClassNames);
        channel.sink.close(socket_channel_status.goingAway);
      }
    });

    return Future.wait([
      sub.asFuture(),
    ]);
  }
}
