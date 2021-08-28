import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'data_access.dart';

// To follow general guideline about formatting DateTime to a json element:
// https://stackoverflow.com/questions/10286204/what-is-the-right-json-date-format
// this is a custom ValueSerializer to convert json DateTime to/from ISO 8601.
// Use it with: moorRuntimeOptions.defaultSerializer = CustomJsonValueSerializer();
// NOTE: At the moment, this class is not used.
// Coverage Notes: unreachable (unused) and remarked.
// class CustomJsonValueSerializer extends ValueSerializer {
//   static const defaults = ValueSerializer.defaults();

//   @override
//   dynamic toJson<T>(T value) {
//     if (value is DateTime) {
//       return value.toIso8601String();
//     }
//     return defaults.toJson<T>(value);
//   }

//   @override
//   T fromJson<T>(dynamic json) {
//     if (T == DateTime) {
//       return DateTime.parse(json as String) as T;
//     }
//     return defaults.fromJson(json);
//   }
// }

/// A class to hold the active [syncId] (unique user id) information.
///
///
/// The [linkedSyncIds] can contain other user's `syncId`s, that indicates the
/// primary user id (specified in [syncId]) is allowed to access
/// (and manipulate) data for those specified in the [linkedSyncIds].
/// Please read the [Client Side Initialization](https://github.com/aldycool/NETCoreSync/tree/master/netcoresync_moor#client-side-initialization)
/// in the `netcoresync_moor` documentation for more details.
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

  List<String> getAllSyncIds({
    String enclosure = "'",
  }) {
    List<String> syncIds = [];
    syncIds.add("$enclosure$syncId$enclosure");
    for (var i = 0; i < linkedSyncIds.length; i++) {
      syncIds.add("$enclosure${linkedSyncIds[i]}$enclosure");
    }
    return syncIds;
  }
}

/// The class for monitoring synchronization progress.
///
/// This class instance can be passed into the
/// [NetCoreSyncClient.netCoreSyncSynchronize()] call to monitor the
/// synchronization progress. The `progressEvent` function is a callback that
/// will be invoked by the framework for every progress. The `message` will
/// have an information of the stage, the `indeterminate` indicates whether the
/// current progress is deterministic (has a progress value) or not, and the
/// `value` will have a ranged value between `0.0` and `1.0` for deterministic
/// progress. For non-deterministic, the `value` will always be zero.
///
/// Please read the [Synchronization Progress Event](https://github.com/aldycool/NETCoreSync/tree/master/netcoresync_moor#synchronization-progress-event)
/// in the `netcoresync_moor` documentation for more details.
class SyncEvent {
  void Function(String message, bool indeterminate, double value)?
      progressEvent;

  SyncEvent({this.progressEvent});
}

/// The resulted class for synchronization process invoked by the
/// [NetCoreSyncClient.netCoreSyncSynchronize()] method call.
///
/// The class have errors information in the `errorMessages` and `error`
/// properties (if any) and a detailed log data list in the `logs` property.
/// Please read the [Synchronization Result Explanation](https://github.com/aldycool/NETCoreSync/tree/master/netcoresync_moor#synchronization-result-explanation)
/// in the `netcoresync_moor` documentation for more details.
class SyncResult {
  String? errorMessage;
  Object? error;
  List<Map<String, dynamic>> logs = [];
}

/// The verbosity level for the resulted logs in a synchronization process.
///
/// This value can be specified in the
/// [NetCoreSyncClient.netCoreSyncSynchronize()] method call's argument to
/// specify the verbosity level of the resulted [SyncResult.logs].
/// In the [Synchronization Logs](https://github.com/aldycool/NETCoreSync/tree/master/netcoresync_moor#synchronization-logs)
/// of the `netcoresync_moor` documentation, especially in the
/// `syncTableRequest` action, it shows how each enumeration value affect the
/// resulted logs.
enum SyncResultLogLevel {
  countsOnly,
  syncFieldsOnly,
  fullData,
}

/// A helper abstract class to generate the _synchronized version_ of tables
/// that is used in the code generation.
///
/// *(This class is used internally, no need to use it directly)*
abstract class SyncBaseTable<T extends HasResultSet, D> {
  Type get type;
}

/// A base abstract class for [SyncDoUpdate] and [SyncUpsertMultiple] classes.
///
/// *(This class is used internally, no need to use it directly)*
@sealed
abstract class SyncUpsertClause<T extends Table, D> {
  Future<UpsertClause<T, D>> resolve(DataAccess dataAccess);
}

/// The replacement class for Moor's [DoUpdate]. Use this method to ensure
/// compatibility with the synchronization process.
///
/// Please read the [Client Side Moor Code Adaptation](https://github.com/aldycool/NETCoreSync/tree/master/netcoresync_moor#client-side-moor-code-adaptation)
/// in the `netcoresync_moor` documentation for more details.
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

/// The replacement class for Moor's [UpsertMultiple]. Use this method to ensure
/// compatibility with the synchronization process.
///
/// Please read the [Client Side Moor Code Adaptation](https://github.com/aldycool/NETCoreSync/tree/master/netcoresync_moor#client-side-moor-code-adaptation)
/// in the `netcoresync_moor` documentation for more details.
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
