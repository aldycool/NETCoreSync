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
    Insertable<D> entity, {
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
      (syncEntity, obtainedTimeStamp) => implementation(
        syncEntity,
        mode,
        onConflict?.resolve(obtainedTimeStamp, dataAccess),
      ),
    );
  }
}
