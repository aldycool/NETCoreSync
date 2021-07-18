import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'netcoresync_exceptions.dart';
import 'data_access.dart';

@internal
class SyncDeleteStatement<T extends Table, D> extends DeleteStatement<T, D> {
  final DataAccess dataAccess;
  int? _timeStamp;

  SyncDeleteStatement(
    this.dataAccess,
    TableInfo<T, D> table,
  ) : super(dataAccess.resolvedEngine, table) {
    if (!dataAccess.engine.tables.containsKey(D))
      throw NetCoreSyncTypeNotRegisteredException(D);
  }

  @override
  void writeStartPart(GenerationContext ctx) async {
    assert(_timeStamp != null,
        "_timeStamp should've not be null because it should be generated on the go()");
    ctx.buffer.write(
        "UPDATE ${table.tableWithAlias} SET ${dataAccess.engine.tables[D]!.deletedEscapedName} = 1, ${dataAccess.engine.tables[D]!.timeStampEscapedName} = ${_timeStamp!} ");
    _timeStamp = null;
  }

  @override
  Future<int> go() async {
    _timeStamp = await dataAccess.getNextTimeStamp();
    return super.go();
  }
}
