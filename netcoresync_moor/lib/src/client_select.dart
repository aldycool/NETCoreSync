import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'netcoresync_exceptions.dart';
import 'netcoresync_classes.dart';
import 'data_access.dart';

// Need to confirm with the moor's author @simolus3: why is the abstract class BaseSelectStatement is sealed? is there something I should worry about?
// ignore: subtype_of_sealed_class
@internal
class SyncSimpleSelectStatement<T extends HasResultSet, D>
    extends SimpleSelectStatement<T, D> {
  final DataAccess dataAccess;

  SyncSimpleSelectStatement(
    this.dataAccess,
    ResultSetImplementation<T, D> table, {
    bool distinct = false,
  }) : super(
          dataAccess.resolvedEngine,
          table,
          distinct: distinct,
        ) {
    if (!dataAccess.engine.tables.containsKey(D))
      throw NetCoreSyncTypeNotRegisteredException(D);
  }

  SyncJoinedSelectStatement syncJoin(List<Join> joins) {
    // DEV-WARNING: The implementation code is copied from original library, ensure future changes are updated in here!
    // This is needed because we need to handle the `writeStartPart()` of the original `JoinedSelectStatement` class.
    final statement =
        SyncJoinedSelectStatement(dataAccess, table, joins, distinct);

    if (whereExpr != null) {
      statement.where(whereExpr!.predicate);
    }
    if (orderByExpr != null) {
      statement.orderBy(orderByExpr!.terms);
    }
    if (limitExpr != null) {
      statement.limitExpr = limitExpr;
    }

    return statement;
  }

  @override
  void writeStartPart(GenerationContext ctx) {
    super.writeStartPart(ctx);
    // The ctx.watchedTables needs to be reverted back to original tables to ensure the `watch()` function works properly!
    // I don't know how the watchedTables is being used in other code, so I'm taking the safest approach here
    int idx = 0;
    while (idx < ctx.watchedTables.length) {
      if (ctx.watchedTables[idx] is SyncBaseTable) {
        final originalTable = dataAccess.engine
            .tables[(ctx.watchedTables[idx] as SyncBaseTable).type]!.tableInfo;
        ctx.watchedTables.removeAt(idx);
        ctx.watchedTables.insert(idx, originalTable);
      }
      idx++;
    }
  }
}

// ignore: subtype_of_sealed_class
@internal
class SyncJoinedSelectStatement<T extends HasResultSet, D>
    extends JoinedSelectStatement<T, D> {
  final DataAccess dataAccess;

  SyncJoinedSelectStatement(
    this.dataAccess,
    ResultSetImplementation<T, D> table,
    List<Join> joins, [
    bool distinct = false,
    bool includeMainTableInResult = true,
  ]) : super(
          dataAccess.resolvedEngine,
          table,
          joins,
          distinct,
          includeMainTableInResult,
        ) {
    if (!dataAccess.engine.tables.containsKey(D))
      throw NetCoreSyncTypeNotRegisteredException(D);
  }

  @override
  void writeStartPart(GenerationContext ctx) {
    super.writeStartPart(ctx);
    // The ctx.watchedTables needs to be reverted back to original tables to ensure the `watch()` function works properly!
    // I don't know how the watchedTables is being used in other code, so I'm taking the safest approach here
    int idx = 0;
    while (idx < ctx.watchedTables.length) {
      if (ctx.watchedTables[idx] is SyncBaseTable) {
        final originalTable = dataAccess.engine
            .tables[(ctx.watchedTables[idx] as SyncBaseTable).type]!.tableInfo;
        ctx.watchedTables.removeAt(idx);
        ctx.watchedTables.insert(idx, originalTable);
      }
      idx++;
    }
  }
}
