import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'netcoresync_exceptions.dart';
import 'data_access.dart';

@internal
class SyncDeleteStatement<T extends Table, D> extends DeleteStatement<T, D> {
  final DataAccess dataAccess;

  SyncDeleteStatement(
    this.dataAccess,
    TableInfo<T, D> table,
  ) : super(dataAccess.databaseResolvedEngine, table) {
    if (!dataAccess.engine.tables.containsKey(D)) {
      throw NetCoreSyncTypeNotRegisteredException(D);
    }
  }

  @override
  void writeStartPart(GenerationContext ctx) async {
    ctx.buffer.write("UPDATE ${table.tableWithAlias} "
        "SET ${dataAccess.engine.tables[D]!.deletedEscapedName} = 1, "
        "${dataAccess.engine.tables[D]!.syncedEscapedName} = 0 ");
  }
}
