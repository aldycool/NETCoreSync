import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'netcoresync_exceptions.dart';
import 'netcoresync_classes.dart';
import 'data_access.dart';

@internal
class SyncInsertStatement<T extends Table, D> extends InsertStatement<T, D> {
  final DataAccess dataAccess;

  SyncInsertStatement(
    this.dataAccess,
    TableInfo<T, D> table,
  ) : super(dataAccess.resolvedEngine, table) {
    if (!dataAccess.engine.tables.containsKey(D)) {
      throw NetCoreSyncTypeNotRegisteredException(D);
    }
  }

  Future<int> syncInsert(
    Insertable<D> entity, {
    InsertMode? mode,
    SyncUpsertClause<T, D>? onConflict,
  }) async {
    return _syncActionInsert(
      entity,
      false, // We can confidently ensure that this operation will only be inserts, therefore we set the deleted to false. The mode parameter is also already checked for not doing other than inserts. The onConflict parameter is handled on different class (during resolve), which will not set the deleted value (on updates deleted will be ignored and not changed at all).
      mode: mode,
      onConflict: onConflict,
      implementation: (
        syncEntity,
        _mode,
        _onConflict,
      ) =>
          insert(
        syncEntity,
        mode: _mode,
        onConflict: _onConflict,
      ),
    );
  }

  Future<int> syncInsertOnConflictUpdate(Insertable<D> entity) async {
    return _syncActionInsert(
      entity,
      null, // In here, we cannot actually detect whether the operation will perform insert or update, therefore, we just rely on the entity's deleted value. In most likely situations (new object or queried existing) this will be false and not null, so proceed wisely, the worst case is we have a risk of undeleting a previously deleted data, but from user's interface this should not be possible (deleted rows will not be shown to be edited).
      implementation: (
        syncEntity,
        _,
        __,
      ) =>
          insertOnConflictUpdate(
        syncEntity,
      ),
    );
  }

  Future<D> syncInsertReturning(Insertable<D> entity,
      {InsertMode? mode, SyncUpsertClause<T, D>? onConflict}) async {
    return _syncActionInsert(
      entity,
      false, // The same explanation as the standard syncInsert above.
      mode: mode,
      onConflict: onConflict,
      implementation: (
        syncEntity,
        _mode,
        _onConflict,
      ) =>
          insertReturning(
        syncEntity,
        mode: _mode,
        onConflict: _onConflict,
      ),
    );
  }

  Future<V> _syncActionInsert<V>(
    Insertable<D> entity,
    bool? deleted, {
    InsertMode? mode,
    SyncUpsertClause<T, D>? onConflict,
    required Future<V> Function(
      Insertable<D> syncEntity,
      InsertMode? mode,
      UpsertClause<T, D>? onConflict,
    )
        implementation,
  }) async {
    if (mode != null &&
        (mode == InsertMode.replace || mode == InsertMode.insertOrReplace)) {
      throw NetCoreSyncException(
          "Unsupported mode: $mode. This mode is disabled because it may physically delete an existing already-synchronized row.");
    }

    return dataAccess.syncAction(
      entity,
      deleted,
      (syncEntity, obtainedKnowledgeId) => implementation(
        syncEntity,
        mode,
        onConflict?.resolve(dataAccess, obtainedKnowledgeId),
      ),
    );
  }
}
