import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'netcoresync_exceptions.dart';
import 'data_access.dart';

@internal
class SyncResultSetImplementation<T extends HasResultSet, R>
    implements ResultSetImplementation<T, R> {
  final DataAccess dataAccess;
  final ResultSetImplementation<T, R> table;

  SyncResultSetImplementation(
    this.dataAccess,
    this.table,
  ) {
    if (!dataAccess.engine.tables.containsKey(R))
      throw NetCoreSyncTypeNotRegisteredException(R);
  }

  @override
  List<GeneratedColumn> get $columns => table.$columns;

  @override
  String get aliasedName => table.aliasedName;

  @override
  T get asDslTable => table.asDslTable;

  @override
  ResultSetImplementation<T, R> createAlias(String alias) {
    return table.createAlias(alias);
  }

  @override
  String get entityName =>
      "(SELECT * FROM ${table.entityName} WHERE ${dataAccess.engine.tables[R]!.deletedEscapedName} = 0)";

  @override
  R map(Map<String, dynamic> data, {String? tablePrefix}) {
    return table.map(data, tablePrefix: tablePrefix);
  }
}
