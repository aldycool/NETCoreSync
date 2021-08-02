import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'data_access.dart';

class SyncIdInfo {
  String syncId;
  List<String> linkedSyncIds;

  SyncIdInfo({required this.syncId, this.linkedSyncIds = const []});

  SyncIdInfo.fromJson(Map<String, dynamic> json)
      : syncId = json["syncId"],
        linkedSyncIds = List.from(json["linkedSyncIds"]);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "syncId": syncId,
      "linkedSyncIds": linkedSyncIds,
    };
  }

  String get allSyncIds {
    StringBuffer buffer = StringBuffer();
    buffer.write("'$syncId'");
    for (var i = 0; i < linkedSyncIds.length; i++) {
      buffer.write(", '${linkedSyncIds[i]}'");
    }
    return buffer.toString();
  }
}

class SyncEvent {
  void Function(String message, double current, double min, double max)?
      progressEvent;

  SyncEvent({this.progressEvent});
}

class SyncResult {
  String? errorMessage;

  SyncResult({
    this.errorMessage,
  });
}

abstract class SyncBaseTable<T extends HasResultSet, D> {
  Type get type;
}

@sealed
abstract class SyncUpsertClause<T extends Table, D> {
  Future<UpsertClause<T, D>> resolve(DataAccess dataAccess);
}

class SyncDoUpdate<T extends Table, D> extends SyncUpsertClause<T, D> {
  final Insertable<D> Function(T old) _creator;
  final List<Column>? target;

  SyncDoUpdate(Insertable<D> Function(T old) update, {this.target})
      : _creator = update;

  @internal
  @override
  Future<DoUpdate<T, D>> resolve(DataAccess dataAccess) async {
    String knowledgeId = await dataAccess.getLocalKnowledgeId();
    return DoUpdate(
      (T old) {
        Insertable<D> result = _creator(old);
        // Because of DoUpdate is always called from Insert, and the INSERT INTO
        // + DO UPDATE behavior is always insert new row, then we should perform
        // syncActionInsert here rather than syncActionUpdate to ensure the sync
        // fields are always valid.
        Insertable<D> syncResult = dataAccess.syncActionInsert(
          result,
          knowledgeId,
        );
        return syncResult;
      },
      target: target,
    );
  }
}

class SyncUpsertMultiple<T extends Table, D> extends SyncUpsertClause<T, D> {
  final List<SyncDoUpdate<T, D>> clauses;

  SyncUpsertMultiple(this.clauses);

  @internal
  @override
  Future<UpsertMultiple<T, D>> resolve(DataAccess dataAccess) async {
    List<DoUpdate<T, D>> syncClauses = [];
    for (var element in clauses) {
      syncClauses.add(await element.resolve(dataAccess));
    }
    return UpsertMultiple(syncClauses);
  }
}
