import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as socket_channel_status;
import 'netcoresync_exceptions.dart';
import 'data_access.dart';

class SyncHandler {
  final DataAccess dataAccess;

  SyncHandler(this.dataAccess);

  Future<void> synchronize({
    required String url,
    Map<String, dynamic> customInfo = const {},
  }) async {
    if (dataAccess.inTransaction()) {
      throw NetCoreSyncMustNotInsideTransactionException();
    }

    var channel = IOWebSocketChannel.connect(Uri.parse(url));
    bool finished = false;
    int counter = 1;
    channel.sink.add('$counter = hello from client!');
    channel.stream.listen((message) async {
      print(message);

      await Future.delayed(Duration(seconds: 1), () {});

      counter++;
      if (counter <= 3) {
        channel.sink.add('$counter = hello from client!');
      } else {
        channel.sink.close(socket_channel_status.goingAway);
        finished = true;
      }
    });
    int waitFinish = 0;
    while (!finished) {
      await Future.delayed(Duration(seconds: 1), () {});
      waitFinish++;
      print("Waiting finished $waitFinish...");
    }
  }
}
