// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class Employee extends DataClass implements Insertable<Employee> {
  final String id;
  final String name;
  final DateTime birthday;
  final String syncId;
  final String knowledgeId;
  final bool synced;
  final bool deleted;
  Employee(
      {required this.id,
      required this.name,
      required this.birthday,
      required this.syncId,
      required this.knowledgeId,
      required this.synced,
      required this.deleted});
  factory Employee.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Employee(
      id: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      birthday: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}birthday'])!,
      syncId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}sync_id'])!,
      knowledgeId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}knowledge_id'])!,
      synced: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}synced'])!,
      deleted: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}deleted'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['birthday'] = Variable<DateTime>(birthday);
    map['sync_id'] = Variable<String>(syncId);
    map['knowledge_id'] = Variable<String>(knowledgeId);
    map['synced'] = Variable<bool>(synced);
    map['deleted'] = Variable<bool>(deleted);
    return map;
  }

  EmployeesCompanion toCompanion(bool nullToAbsent) {
    return EmployeesCompanion(
      id: Value(id),
      name: Value(name),
      birthday: Value(birthday),
      syncId: Value(syncId),
      knowledgeId: Value(knowledgeId),
      synced: Value(synced),
      deleted: Value(deleted),
    );
  }

  factory Employee.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Employee(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      birthday: serializer.fromJson<DateTime>(json['birthday']),
      syncId: serializer.fromJson<String>(json['syncId']),
      knowledgeId: serializer.fromJson<String>(json['knowledgeId']),
      synced: serializer.fromJson<bool>(json['synced']),
      deleted: serializer.fromJson<bool>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'birthday': serializer.toJson<DateTime>(birthday),
      'syncId': serializer.toJson<String>(syncId),
      'knowledgeId': serializer.toJson<String>(knowledgeId),
      'synced': serializer.toJson<bool>(synced),
      'deleted': serializer.toJson<bool>(deleted),
    };
  }

  Employee copyWith(
          {String? id,
          String? name,
          DateTime? birthday,
          String? syncId,
          String? knowledgeId,
          bool? synced,
          bool? deleted}) =>
      Employee(
        id: id ?? this.id,
        name: name ?? this.name,
        birthday: birthday ?? this.birthday,
        syncId: syncId ?? this.syncId,
        knowledgeId: knowledgeId ?? this.knowledgeId,
        synced: synced ?? this.synced,
        deleted: deleted ?? this.deleted,
      );
  @override
  String toString() {
    return (StringBuffer('Employee(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthday: $birthday, ')
          ..write('syncId: $syncId, ')
          ..write('knowledgeId: $knowledgeId, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          name.hashCode,
          $mrjc(
              birthday.hashCode,
              $mrjc(
                  syncId.hashCode,
                  $mrjc(knowledgeId.hashCode,
                      $mrjc(synced.hashCode, deleted.hashCode)))))));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Employee &&
          other.id == this.id &&
          other.name == this.name &&
          other.birthday == this.birthday &&
          other.syncId == this.syncId &&
          other.knowledgeId == this.knowledgeId &&
          other.synced == this.synced &&
          other.deleted == this.deleted);
}

class EmployeesCompanion extends UpdateCompanion<Employee> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> birthday;
  final Value<String> syncId;
  final Value<String> knowledgeId;
  final Value<bool> synced;
  final Value<bool> deleted;
  const EmployeesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthday = const Value.absent(),
    this.syncId = const Value.absent(),
    this.knowledgeId = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
  });
  EmployeesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.birthday = const Value.absent(),
    this.syncId = const Value.absent(),
    this.knowledgeId = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Employee> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? birthday,
    Expression<String>? syncId,
    Expression<String>? knowledgeId,
    Expression<bool>? synced,
    Expression<bool>? deleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (birthday != null) 'birthday': birthday,
      if (syncId != null) 'sync_id': syncId,
      if (knowledgeId != null) 'knowledge_id': knowledgeId,
      if (synced != null) 'synced': synced,
      if (deleted != null) 'deleted': deleted,
    });
  }

  EmployeesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<DateTime>? birthday,
      Value<String>? syncId,
      Value<String>? knowledgeId,
      Value<bool>? synced,
      Value<bool>? deleted}) {
    return EmployeesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      syncId: syncId ?? this.syncId,
      knowledgeId: knowledgeId ?? this.knowledgeId,
      synced: synced ?? this.synced,
      deleted: deleted ?? this.deleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (birthday.present) {
      map['birthday'] = Variable<DateTime>(birthday.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (knowledgeId.present) {
      map['knowledge_id'] = Variable<String>(knowledgeId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmployeesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthday: $birthday, ')
          ..write('syncId: $syncId, ')
          ..write('knowledgeId: $knowledgeId, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }
}

class $EmployeesTable extends Employees
    with TableInfo<$EmployeesTable, Employee> {
  final GeneratedDatabase _db;
  final String? _alias;
  $EmployeesTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String?> id = GeneratedColumn<String?>(
      'id', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 36),
      typeName: 'TEXT',
      requiredDuringInsert: false,
      clientDefault: () => Uuid().v4());
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>(
      'name', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true);
  final VerificationMeta _birthdayMeta = const VerificationMeta('birthday');
  @override
  late final GeneratedColumn<DateTime?> birthday = GeneratedColumn<DateTime?>(
      'birthday', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  final VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String?> syncId = GeneratedColumn<String?>(
      'sync_id', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 36),
      typeName: 'TEXT',
      requiredDuringInsert: false,
      defaultValue: Constant(""));
  final VerificationMeta _knowledgeIdMeta =
      const VerificationMeta('knowledgeId');
  @override
  late final GeneratedColumn<String?> knowledgeId = GeneratedColumn<String?>(
      'knowledge_id', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 36),
      typeName: 'TEXT',
      requiredDuringInsert: false,
      defaultValue: Constant(""));
  final VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool?> synced = GeneratedColumn<bool?>(
      'synced', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (synced IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool?> deleted = GeneratedColumn<bool?>(
      'deleted', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (deleted IN (0, 1))',
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, birthday, syncId, knowledgeId, synced, deleted];
  @override
  String get aliasedName => _alias ?? 'employees';
  @override
  String get actualTableName => 'employees';
  @override
  VerificationContext validateIntegrity(Insertable<Employee> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('birthday')) {
      context.handle(_birthdayMeta,
          birthday.isAcceptableOrUnknown(data['birthday']!, _birthdayMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(_syncIdMeta,
          syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta));
    }
    if (data.containsKey('knowledge_id')) {
      context.handle(
          _knowledgeIdMeta,
          knowledgeId.isAcceptableOrUnknown(
              data['knowledge_id']!, _knowledgeIdMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Employee map(Map<String, dynamic> data, {String? tablePrefix}) {
    return Employee.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $EmployeesTable createAlias(String alias) {
    return $EmployeesTable(_db, alias);
  }
}

class NetCoreSyncKnowledgesCompanion
    extends UpdateCompanion<NetCoreSyncKnowledge> {
  final Value<String> id;
  final Value<String> syncId;
  final Value<bool> local;
  final Value<int> lastTimeStamp;
  final Value<String> meta;
  const NetCoreSyncKnowledgesCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.local = const Value.absent(),
    this.lastTimeStamp = const Value.absent(),
    this.meta = const Value.absent(),
  });
  NetCoreSyncKnowledgesCompanion.insert({
    required String id,
    required String syncId,
    required bool local,
    required int lastTimeStamp,
    required String meta,
  })  : id = Value(id),
        syncId = Value(syncId),
        local = Value(local),
        lastTimeStamp = Value(lastTimeStamp),
        meta = Value(meta);
  static Insertable<NetCoreSyncKnowledge> custom({
    Expression<String>? id,
    Expression<String>? syncId,
    Expression<bool>? local,
    Expression<int>? lastTimeStamp,
    Expression<String>? meta,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (local != null) 'local': local,
      if (lastTimeStamp != null) 'last_time_stamp': lastTimeStamp,
      if (meta != null) 'meta': meta,
    });
  }

  NetCoreSyncKnowledgesCompanion copyWith(
      {Value<String>? id,
      Value<String>? syncId,
      Value<bool>? local,
      Value<int>? lastTimeStamp,
      Value<String>? meta}) {
    return NetCoreSyncKnowledgesCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      local: local ?? this.local,
      lastTimeStamp: lastTimeStamp ?? this.lastTimeStamp,
      meta: meta ?? this.meta,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (local.present) {
      map['local'] = Variable<bool>(local.value);
    }
    if (lastTimeStamp.present) {
      map['last_time_stamp'] = Variable<int>(lastTimeStamp.value);
    }
    if (meta.present) {
      map['meta'] = Variable<String>(meta.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NetCoreSyncKnowledgesCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('local: $local, ')
          ..write('lastTimeStamp: $lastTimeStamp, ')
          ..write('meta: $meta')
          ..write(')'))
        .toString();
  }
}

class $NetCoreSyncKnowledgesTable extends NetCoreSyncKnowledges
    with TableInfo<$NetCoreSyncKnowledgesTable, NetCoreSyncKnowledge> {
  final GeneratedDatabase _db;
  final String? _alias;
  $NetCoreSyncKnowledgesTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String?> id = GeneratedColumn<String?>(
      'id', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 36),
      typeName: 'TEXT',
      requiredDuringInsert: true);
  final VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String?> syncId = GeneratedColumn<String?>(
      'sync_id', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 36),
      typeName: 'TEXT',
      requiredDuringInsert: true);
  final VerificationMeta _localMeta = const VerificationMeta('local');
  @override
  late final GeneratedColumn<bool?> local = GeneratedColumn<bool?>(
      'local', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: true,
      defaultConstraints: 'CHECK (local IN (0, 1))');
  final VerificationMeta _lastTimeStampMeta =
      const VerificationMeta('lastTimeStamp');
  @override
  late final GeneratedColumn<int?> lastTimeStamp = GeneratedColumn<int?>(
      'last_time_stamp', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: true);
  final VerificationMeta _metaMeta = const VerificationMeta('meta');
  @override
  late final GeneratedColumn<String?> meta = GeneratedColumn<String?>(
      'meta', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, syncId, local, lastTimeStamp, meta];
  @override
  String get aliasedName => _alias ?? 'netcoresync_knowledges';
  @override
  String get actualTableName => 'netcoresync_knowledges';
  @override
  VerificationContext validateIntegrity(
      Insertable<NetCoreSyncKnowledge> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sync_id')) {
      context.handle(_syncIdMeta,
          syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta));
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('local')) {
      context.handle(
          _localMeta, local.isAcceptableOrUnknown(data['local']!, _localMeta));
    } else if (isInserting) {
      context.missing(_localMeta);
    }
    if (data.containsKey('last_time_stamp')) {
      context.handle(
          _lastTimeStampMeta,
          lastTimeStamp.isAcceptableOrUnknown(
              data['last_time_stamp']!, _lastTimeStampMeta));
    } else if (isInserting) {
      context.missing(_lastTimeStampMeta);
    }
    if (data.containsKey('meta')) {
      context.handle(
          _metaMeta, meta.isAcceptableOrUnknown(data['meta']!, _metaMeta));
    } else if (isInserting) {
      context.missing(_metaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, syncId};
  @override
  NetCoreSyncKnowledge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NetCoreSyncKnowledge.fromDb(
      id: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      syncId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}sync_id'])!,
      local: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}local'])!,
      lastTimeStamp: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}last_time_stamp'])!,
      meta: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}meta'])!,
    );
  }

  @override
  $NetCoreSyncKnowledgesTable createAlias(String alias) {
    return $NetCoreSyncKnowledgesTable(_db, alias);
  }
}

abstract class _$MyDatabase extends GeneratedDatabase {
  _$MyDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $EmployeesTable employees = $EmployeesTable(this);
  late final $NetCoreSyncKnowledgesTable netCoreSyncKnowledges =
      $NetCoreSyncKnowledgesTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [employees, netCoreSyncKnowledges];
}

// **************************************************************************
// NetCoreSyncClientGenerator
// **************************************************************************

// NOTE: Obtained from @NetCoreSyncTable annotations:
// Employees: {"tableClassName":"Employees","dataClassName":"Employee","useRowClass":false,"netCoreSyncTable":{"idFieldName":"id","syncIdFieldName":"syncId","knowledgeIdFieldName":"knowledgeId","syncedFieldName":"synced","deletedFieldName":"deleted"},"columnFieldNames":["id","name","birthday","syncId","knowledgeId","synced","deleted"]}

class _$NetCoreSyncEngineUser extends NetCoreSyncEngine {
  _$NetCoreSyncEngineUser(Map<Type, NetCoreSyncTableUser> tables)
      : super(tables);

  @override
  Map<String, dynamic> toJson(dynamic object) {
    if (object is Employee) {
      return object.toJson();
    }
    throw NetCoreSyncException("Unexpected object: $object");
  }

  @override
  dynamic fromJson(Type type, Map<String, dynamic> json) {
    if (type == Employee) {
      return Employee.fromJson(json);
    }
    throw NetCoreSyncException("Unexpected type: $type");
  }

  @override
  UpdateCompanion<D> toSafeCompanion<D>(Insertable<D> entity) {
    if (D == Employee) {
      EmployeesCompanion safeEntity;
      if (entity is EmployeesCompanion) {
        safeEntity = entity as EmployeesCompanion;
      } else {
        safeEntity = (entity as Employee).toCompanion(false);
      }
      safeEntity = safeEntity.copyWith(
        id: Value.absent(),
        syncId: Value.absent(),
        knowledgeId: Value.absent(),
        synced: Value.absent(),
        deleted: Value.absent(),
      );
      return safeEntity as UpdateCompanion<D>;
    }
    throw NetCoreSyncException("Unexpected entity Type: $entity");
  }

  @override
  Object? getSyncColumnValue<D>(Insertable<D> entity, String fieldName) {
    if (entity is Employee) {
      switch (fieldName) {
        case "id":
          return (entity as Employee).id;
        case "deleted":
          return (entity as Employee).deleted;
      }
    }
    throw NetCoreSyncException(
        "Unexpected entity Type: $entity, fieldName: $fieldName");
  }

  @override
  Insertable<D> updateSyncColumns<D>(
    Insertable<D> entity, {
    required bool synced,
    String? syncId,
    String? knowledgeId,
    bool? deleted,
  }) {
    if (entity is RawValuesInsertable<D>) {
      entity.data[tables[D]!.syncedEscapedName] = Constant(synced);
      if (syncId != null) {
        entity.data[tables[D]!.syncIdEscapedName] = Constant(syncId);
      }
      if (knowledgeId != null) {
        entity.data[tables[D]!.knowledgeIdEscapedName] = Constant(knowledgeId);
      }
      if (deleted != null) {
        entity.data[tables[D]!.deletedEscapedName] = Constant(deleted);
      }
      return entity;
    } else if (entity is UpdateCompanion<D>) {
      if (D == Employee) {
        return (entity as EmployeesCompanion).copyWith(
          synced: Value(synced),
          syncId: syncId != null ? Value(syncId) : Value.absent(),
          knowledgeId:
              knowledgeId != null ? Value(knowledgeId) : Value.absent(),
          deleted: deleted != null ? Value(deleted) : Value.absent(),
        ) as Insertable<D>;
      }
    } else if (entity is DataClass) {
      if (entity is Employee) {
        return (entity as Employee).copyWith(
          synced: synced,
          syncId: syncId,
          knowledgeId: knowledgeId,
          deleted: deleted,
        ) as Insertable<D>;
      }
    } else {}
    throw NetCoreSyncException("Unexpected entity Type: $entity");
  }
}

extension $NetCoreSyncClientExtension on MyDatabase {
  Future<void> netCoreSyncInitialize() async {
    await netCoreSyncInitializeClient(
      _$NetCoreSyncEngineUser(
        {
          Employee: NetCoreSyncTableUser(
            employees,
            NetCoreSyncTable.fromJson({
              "idFieldName": "id",
              "syncIdFieldName": "syncId",
              "knowledgeIdFieldName": "knowledgeId",
              "syncedFieldName": "synced",
              "deletedFieldName": "deleted"
            }),
            employees.id.escapedName,
            employees.syncId.escapedName,
            employees.knowledgeId.escapedName,
            employees.synced.escapedName,
            employees.deleted.escapedName,
            [
              "id",
              "name",
              "birthday",
              "syncId",
              "knowledgeId",
              "synced",
              "deleted"
            ],
          ),
        },
      ),
    );
    netCoreSyncInitializeUser();
  }
}

class $SyncEmployeesTable extends $EmployeesTable
    implements SyncBaseTable<$EmployeesTable, Employee> {
  final String Function() _allSyncIds;
  $SyncEmployeesTable(_$MyDatabase db, this._allSyncIds) : super(db);
  @override
  Type get type => Employee;
  @override
  String get entityName =>
      "(SELECT * FROM ${super.entityName} WHERE ${super.deleted.escapedName} = 0 AND ${super.syncId.escapedName} IN (${_allSyncIds()}))";
}

mixin NetCoreSyncClientUser on NetCoreSyncClient {
  late $SyncEmployeesTable _syncEmployees;

  void netCoreSyncInitializeUser() {
    _syncEmployees =
        $SyncEmployeesTable(netCoreSyncResolvedEngine, netCoreSyncAllSyncIds);
  }

  $SyncEmployeesTable get syncEmployees {
    if (!netCoreSyncInitialized) throw NetCoreSyncNotInitializedException();
    return _syncEmployees;
  }
}
