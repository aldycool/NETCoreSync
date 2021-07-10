import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'data/database.dart';

class Global {
  Global._();
  static final Global instance = Global._();

  late Database database;
  late NetCoreSyncClient netCoreSyncClient;

  void setDatabase(Database database) {
    this.database = database;
  }

  void setNetCoreSyncClient(NetCoreSyncClient netCoreSyncClient) {
    this.netCoreSyncClient = netCoreSyncClient;
  }
}
