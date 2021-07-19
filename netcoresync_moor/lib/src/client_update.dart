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
  ) : super(dataAccess.resolvedEngine, table) {
    if (!dataAccess.engine.tables.containsKey(D))
      throw NetCoreSyncTypeNotRegisteredException(D);
  }

  Future<int> syncWrite(Insertable<D> entity,
      {bool dontExecute = false}) async {
    return _syncActionUpdate(
      entity,
      dontExecute: dontExecute,
      implementation: (
        syncEntity,
        _dontExecute,
      ) =>
          write(
        syncEntity,
        dontExecute: _dontExecute,
      ),
    );
  }

  Future<bool> syncReplace(Insertable<D> entity,
      {bool dontExecute = false}) async {
    return _syncActionUpdate(
      entity,
      dontExecute: dontExecute,
      implementation: (
        syncEntity,
        _dontExecute,
      ) =>
          replace(
        syncEntity,
        dontExecute: _dontExecute,
      ),
    );
  }

  Future<V> _syncActionUpdate<V>(
    Insertable<D> entity, {
    bool dontExecute = false,
    required Future<V> Function(
      Insertable<D> syncEntity,
      bool dontExecute,
    )
        implementation,
  }) async {
    return dataAccess.syncAction(
      entity,
      (syncEntity, obtainedTimeStamp) => implementation(
        syncEntity,
        dontExecute,
      ),
    );
  }
}
