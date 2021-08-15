import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'netcoresync_exceptions.dart';
import 'netcoresync_engine.dart';
import 'netcoresync_classes.dart';
import 'data_access.dart';
import 'client_select.dart';
import 'client_insert.dart';
import 'client_update.dart';
import 'client_delete.dart';
import 'sync_session.dart';

mixin NetCoreSyncClient on GeneratedDatabase {
  DataAccess? _dataAccess;

  bool get netCoreSyncInitialized => _dataAccess != null;

  @internal
  DataAccess get dataAccess {
    if (!netCoreSyncInitialized) throw NetCoreSyncNotInitializedException();
    return _dataAccess!;
  }

  Future<void> netCoreSyncInitializeClient(
    NetCoreSyncEngine engine,
  ) async {
    _dataAccess = DataAccess(
      this,
      engine,
    );
  }

  dynamic get netCoreSyncResolvedEngine => dataAccess.resolvedEngine;

  void netCoreSyncSetLogger(void Function(Object? object) logger) {
    dataAccess.logger = logger;
  }

  SyncIdInfo? netCoreSyncGetSyncIdInfo() => dataAccess.syncIdInfo;

  void netCoreSyncSetSyncIdInfo(SyncIdInfo value) {
    if (!netCoreSyncInitialized) throw NetCoreSyncNotInitializedException();
    if (value.syncId.isEmpty) {
      throw NetCoreSyncException("SyncIdInfo.syncId cannot be empty");
    }
    if (value.linkedSyncIds.isNotEmpty && value.linkedSyncIds.contains("")) {
      throw NetCoreSyncException(
          "SyncIdInfo.linkedSyncIds should not contain empty string");
    }
    if (value.linkedSyncIds.isNotEmpty &&
        value.linkedSyncIds.contains(value.syncId)) {
      throw NetCoreSyncException(
          "SyncIdInfo.linkedSyncIds cannot contain the syncId itself");
    }
    dataAccess.syncIdInfo = value;
    dataAccess.activeSyncId = dataAccess.syncIdInfo!.syncId;
  }

  String? netCoreSyncGetActiveSyncId() => dataAccess.activeSyncId;

  void netCoreSyncSetActiveSyncId(String value) {
    if (!netCoreSyncInitialized) throw NetCoreSyncNotInitializedException();
    if (dataAccess.syncIdInfo == null) {
      throw NetCoreSyncSyncIdInfoNotSetException();
    }
    if (value.isEmpty) {
      throw NetCoreSyncException("The active syncId cannot be empty");
    }
    if (dataAccess.syncIdInfo!.syncId != value &&
        !dataAccess.syncIdInfo!.linkedSyncIds.contains(value)) {
      throw NetCoreSyncException(
          "The active syncId is different than the SyncIdInfo.syncId and also "
          "cannot be found in the SyncIdInfo.linkedSyncIds");
    }
    dataAccess.activeSyncId = value;
  }

  String netCoreSyncAllSyncIds() {
    if (dataAccess.syncIdInfo == null) {
      return "";
    }
    List<String> allSyncIds = dataAccess.syncIdInfo!.getAllSyncIds();
    return allSyncIds.join(", ");
  }

  Future<SyncResult> netCoreSyncSynchronize({
    required String url,
    SyncEvent? syncEvent,
    Map<String, dynamic> customInfo = const {},
  }) async {
    if (!netCoreSyncInitialized) throw NetCoreSyncNotInitializedException();
    if (dataAccess.syncIdInfo == null) {
      throw NetCoreSyncSyncIdInfoNotSetException();
    }
    if (dataAccess.inTransaction()) {
      throw NetCoreSyncMustNotInsideTransactionException();
    }

    SyncSession syncSession = SyncSession(
      dataAccess: dataAccess,
      url: url,
      syncEvent: syncEvent,
      customInfo: customInfo,
    );

    return syncSession.synchronize();
  }

  SyncSimpleSelectStatement<T, R> syncSelect<T extends HasResultSet, R>(
    SyncBaseTable<T, R> table, {
    bool distinct = false,
  }) {
    if (!netCoreSyncInitialized) throw NetCoreSyncNotInitializedException();
    return SyncSimpleSelectStatement(
      dataAccess,
      table as ResultSetImplementation<T, R>,
      distinct: distinct,
    );
  }

  SyncJoinedSelectStatement<T, R> syncSelectOnly<T extends HasResultSet, R>(
    SyncBaseTable<T, R> table, {
    bool distinct = false,
  }) {
    if (!netCoreSyncInitialized) throw NetCoreSyncNotInitializedException();
    return SyncJoinedSelectStatement<T, R>(
      dataAccess,
      table as ResultSetImplementation<T, R>,
      [],
      distinct,
      false,
    );
  }

  SyncInsertStatement<T, D> syncInto<T extends Table, D>(
    TableInfo<T, D> table,
  ) {
    if (!netCoreSyncInitialized) throw NetCoreSyncNotInitializedException();
    TableInfo<T, D> normalizedTable = table;
    if (table is SyncBaseTable<T, D>) {
      normalizedTable =
          dataAccess.engine.tables[D]!.tableInfo as TableInfo<T, D>;
    }
    return SyncInsertStatement<T, D>(
      dataAccess,
      normalizedTable,
    );
  }

  SyncUpdateStatement<T, D> syncUpdate<T extends Table, D>(
    TableInfo<T, D> table,
  ) {
    if (!netCoreSyncInitialized) throw NetCoreSyncNotInitializedException();
    TableInfo<T, D> normalizedTable = table;
    if (table is SyncBaseTable<T, D>) {
      normalizedTable =
          dataAccess.engine.tables[D]!.tableInfo as TableInfo<T, D>;
    }
    return SyncUpdateStatement<T, D>(
      dataAccess,
      normalizedTable,
    );
  }

  SyncDeleteStatement<T, D> syncDelete<T extends Table, D>(
    TableInfo<T, D> table,
  ) {
    if (!netCoreSyncInitialized) throw NetCoreSyncNotInitializedException();
    TableInfo<T, D> normalizedTable = table;
    if (table is SyncBaseTable<T, D>) {
      normalizedTable =
          dataAccess.engine.tables[D]!.tableInfo as TableInfo<T, D>;
    }
    return SyncDeleteStatement<T, D>(
      dataAccess,
      normalizedTable,
    );
  }
}
