import 'package:moor/moor.dart';

abstract class NetCoreSyncEngine {
  Insertable<D> updateSyncColumns<D>(
    Insertable<D> entity, {
    required int timeStamp,
    bool? deleted,
  });
}

class NetCoreSyncTableUser<T extends Table, D> {
  TableInfo<T, D> tableInfo;
  String idEscapedName;
  String timeStampEscapedName;
  String deletedEscapedName;
  String knowledgeIdEscapedName;
  NetCoreSyncTableUser(
    this.tableInfo,
    this.idEscapedName,
    this.timeStampEscapedName,
    this.deletedEscapedName,
    this.knowledgeIdEscapedName,
  );
}
