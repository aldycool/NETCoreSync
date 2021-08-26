import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'netcoresync_exceptions.dart';
import 'data_access.dart';

@internal
class SyncUpdateStatement<T extends Table, D> extends UpdateStatement<T, D> {
  final DataAccess dataAccess;

  SyncUpdateStatement(
    this.dataAccess,
    TableInfo<T, D> table,
  ) : super(dataAccess.databaseResolvedEngine, table) {
    if (!dataAccess.engine.tables.containsKey(D)) {
      throw NetCoreSyncTypeNotRegisteredException(D);
    }
  }

  @override
  Future<int> write(Insertable<D> entity, {bool dontExecute = false}) async {
    throw NetCoreSyncException("Use the syncWrite version instead");
  }

  Future<int> syncWrite(Insertable<D> entity,
      {bool dontExecute = false}) async {
    return await _commonAction(
      entity,
      dontExecute: dontExecute,
      implementation: (syncEntity, syncDontExecute) => super.write(
        syncEntity,
        dontExecute: syncDontExecute,
      ),
    );
  }

  @override
  Future<bool> replace(Insertable<D> entity, {bool dontExecute = false}) async {
    throw NetCoreSyncException("Use the syncReplace version instead");
  }

  Future<bool> syncReplace(Insertable<D> entity,
      {bool dontExecute = false}) async {
    // The super.replace() original behavior where if one of entity value is
    // absent, then it will be replaced with its default value, is conflicted
    // with the intention of protecting the sync fields (by setting them to
    // absent). So, the super.replace() implementation is overriden here using
    // whereSamePrimaryKey() + super.write(). Essentially this is the same as
    // the super.replace() implementation, but with more control (able to
    // protect the sync fields).
    whereSamePrimaryKey(entity);
    return await _commonAction(
          entity,
          dontExecute: dontExecute,
          implementation: (syncEntity, syncDontExecute) => super.write(
            syncEntity,
            dontExecute: syncDontExecute,
          ),
        ) >
        0;
  }

  Future<V> _commonAction<V>(
    Insertable<D> entity, {
    bool dontExecute = false,
    required Future<V> Function(
      Insertable<D> syncEntity,
      bool syncDontExecute,
    )
        implementation,
  }) async {
    Insertable<D> syncEntity = dataAccess.syncActionUpdate(
      entity,
    );
    return await implementation(
      syncEntity,
      dontExecute,
    );
  }
}
