import 'package:moor/moor.dart';

abstract class NetCoreSyncEngine {
  Insertable<D> updateSyncColumns<D>(
    Insertable<D> entity, {
    required int timeStamp,
    bool? deleted,
  });
}
