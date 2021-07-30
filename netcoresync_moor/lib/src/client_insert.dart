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

  @override
  Future<int> insert(
    Insertable<D> entity, {
    InsertMode? mode,
    UpsertClause<T, D>? onConflict,
  }) async {
    throw NetCoreSyncException("Use the syncInsert version instead");
  }

  Future<int> syncInsert(
    Insertable<D> entity, {
    InsertMode? mode,
    SyncUpsertClause<T, D>? onConflict,
  }) async {
    return await _commonAction(
      entity,
      mode: mode,
      onConflict: onConflict,
      implementation: (syncEntity, syncMode, syncOnConflict) => super.insert(
        syncEntity,
        mode: syncMode,
        onConflict: syncOnConflict,
      ),
    );
  }

  @override
  Future<int> insertOnConflictUpdate(Insertable<D> entity) {
    throw NetCoreSyncException(
        "Use the syncInsertOnConflictUpdate version instead");
  }

  Future<int> syncInsertOnConflictUpdate(Insertable<D> entity) async {
    // COPIED-IMPLEMENTATION: The implementation code is copied from original
    // library, ensure future changes are updated in here!
    // This is needed because the original implementation of
    // `super.insertOnConflictUpdate()` is calling `insert()` directly, which we
    // already override above to throw Exception
    return syncInsert(entity, onConflict: SyncDoUpdate((_) => entity));
  }

  @override
  Future<D> insertReturning(Insertable<D> entity,
      {InsertMode? mode, UpsertClause<T, D>? onConflict}) async {
    throw NetCoreSyncException("Use the syncInsertReturning version instead");
  }

  Future<D> syncInsertReturning(Insertable<D> entity,
      {InsertMode? mode, SyncUpsertClause<T, D>? onConflict}) async {
    return await _commonAction(
      entity,
      mode: mode,
      onConflict: onConflict,
      implementation: (syncEntity, syncMode, syncOnConflict) =>
          super.insertReturning(
        syncEntity,
        mode: syncMode,
        onConflict: syncOnConflict,
      ),
    );
  }

  Future<V> _commonAction<V>(
    Insertable<D> entity, {
    InsertMode? mode,
    SyncUpsertClause<T, D>? onConflict,
    required Future<V> Function(
      Insertable<D> syncEntity,
      InsertMode? syncMode,
      UpsertClause<T, D>? syncOnConflict,
    )
        implementation,
  }) async {
    if (mode != null &&
        (mode == InsertMode.replace || mode == InsertMode.insertOrReplace)) {
      throw NetCoreSyncException(
          "Unsupported mode: $mode. This mode is disabled because it may "
          "physically delete an existing already-synchronized row.");
    }
    String knowledgeId = await dataAccess.getLocalKnowledgeId();
    Insertable<D> syncEntity = dataAccess.syncActionInsert(entity, knowledgeId);
    return await implementation(
      syncEntity,
      mode,
      await onConflict?.resolve(dataAccess),
    );
  }
}
