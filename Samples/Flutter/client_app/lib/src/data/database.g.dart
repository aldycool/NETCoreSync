// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class Employee extends DataClass implements Insertable<Employee> {
  final String id;
  final String? name;
  final DateTime birthday;
  final int numberOfComputers;
  final int savingAmount;
  final bool isActive;
  final String? departmentId;
  final String syncId;
  final String knowledgeId;
  final bool synced;
  final bool deleted;
  Employee(
      {required this.id,
      this.name,
      required this.birthday,
      required this.numberOfComputers,
      required this.savingAmount,
      required this.isActive,
      this.departmentId,
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
          .mapFromDatabaseResponse(data['${effectivePrefix}name']),
      birthday: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}birthday'])!,
      numberOfComputers: const IntType().mapFromDatabaseResponse(
          data['${effectivePrefix}number_of_computers'])!,
      savingAmount: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}saving_amount'])!,
      isActive: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}is_active'])!,
      departmentId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}department_id']),
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
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String?>(name);
    }
    map['birthday'] = Variable<DateTime>(birthday);
    map['number_of_computers'] = Variable<int>(numberOfComputers);
    map['saving_amount'] = Variable<int>(savingAmount);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || departmentId != null) {
      map['department_id'] = Variable<String?>(departmentId);
    }
    map['sync_id'] = Variable<String>(syncId);
    map['knowledge_id'] = Variable<String>(knowledgeId);
    map['synced'] = Variable<bool>(synced);
    map['deleted'] = Variable<bool>(deleted);
    return map;
  }

  EmployeesCompanion toCompanion(bool nullToAbsent) {
    return EmployeesCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      birthday: Value(birthday),
      numberOfComputers: Value(numberOfComputers),
      savingAmount: Value(savingAmount),
      isActive: Value(isActive),
      departmentId: departmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(departmentId),
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
      name: serializer.fromJson<String?>(json['name']),
      birthday: serializer.fromJson<DateTime>(json['birthday']),
      numberOfComputers: serializer.fromJson<int>(json['numberOfComputers']),
      savingAmount: serializer.fromJson<int>(json['savingAmount']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      departmentId: serializer.fromJson<String?>(json['departmentId']),
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
      'name': serializer.toJson<String?>(name),
      'birthday': serializer.toJson<DateTime>(birthday),
      'numberOfComputers': serializer.toJson<int>(numberOfComputers),
      'savingAmount': serializer.toJson<int>(savingAmount),
      'isActive': serializer.toJson<bool>(isActive),
      'departmentId': serializer.toJson<String?>(departmentId),
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
          int? numberOfComputers,
          int? savingAmount,
          bool? isActive,
          String? departmentId,
          String? syncId,
          String? knowledgeId,
          bool? synced,
          bool? deleted}) =>
      Employee(
        id: id ?? this.id,
        name: name ?? this.name,
        birthday: birthday ?? this.birthday,
        numberOfComputers: numberOfComputers ?? this.numberOfComputers,
        savingAmount: savingAmount ?? this.savingAmount,
        isActive: isActive ?? this.isActive,
        departmentId: departmentId ?? this.departmentId,
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
          ..write('numberOfComputers: $numberOfComputers, ')
          ..write('savingAmount: $savingAmount, ')
          ..write('isActive: $isActive, ')
          ..write('departmentId: $departmentId, ')
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
                  numberOfComputers.hashCode,
                  $mrjc(
                      savingAmount.hashCode,
                      $mrjc(
                          isActive.hashCode,
                          $mrjc(
                              departmentId.hashCode,
                              $mrjc(
                                  syncId.hashCode,
                                  $mrjc(
                                      knowledgeId.hashCode,
                                      $mrjc(synced.hashCode,
                                          deleted.hashCode)))))))))));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Employee &&
          other.id == this.id &&
          other.name == this.name &&
          other.birthday == this.birthday &&
          other.numberOfComputers == this.numberOfComputers &&
          other.savingAmount == this.savingAmount &&
          other.isActive == this.isActive &&
          other.departmentId == this.departmentId &&
          other.syncId == this.syncId &&
          other.knowledgeId == this.knowledgeId &&
          other.synced == this.synced &&
          other.deleted == this.deleted);
}

class EmployeesCompanion extends UpdateCompanion<Employee> {
  final Value<String> id;
  final Value<String?> name;
  final Value<DateTime> birthday;
  final Value<int> numberOfComputers;
  final Value<int> savingAmount;
  final Value<bool> isActive;
  final Value<String?> departmentId;
  final Value<String> syncId;
  final Value<String> knowledgeId;
  final Value<bool> synced;
  final Value<bool> deleted;
  const EmployeesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthday = const Value.absent(),
    this.numberOfComputers = const Value.absent(),
    this.savingAmount = const Value.absent(),
    this.isActive = const Value.absent(),
    this.departmentId = const Value.absent(),
    this.syncId = const Value.absent(),
    this.knowledgeId = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
  });
  EmployeesCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthday = const Value.absent(),
    this.numberOfComputers = const Value.absent(),
    this.savingAmount = const Value.absent(),
    this.isActive = const Value.absent(),
    this.departmentId = const Value.absent(),
    this.syncId = const Value.absent(),
    this.knowledgeId = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
  });
  static Insertable<Employee> custom({
    Expression<String>? id,
    Expression<String?>? name,
    Expression<DateTime>? birthday,
    Expression<int>? numberOfComputers,
    Expression<int>? savingAmount,
    Expression<bool>? isActive,
    Expression<String?>? departmentId,
    Expression<String>? syncId,
    Expression<String>? knowledgeId,
    Expression<bool>? synced,
    Expression<bool>? deleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (birthday != null) 'birthday': birthday,
      if (numberOfComputers != null) 'number_of_computers': numberOfComputers,
      if (savingAmount != null) 'saving_amount': savingAmount,
      if (isActive != null) 'is_active': isActive,
      if (departmentId != null) 'department_id': departmentId,
      if (syncId != null) 'sync_id': syncId,
      if (knowledgeId != null) 'knowledge_id': knowledgeId,
      if (synced != null) 'synced': synced,
      if (deleted != null) 'deleted': deleted,
    });
  }

  EmployeesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? name,
      Value<DateTime>? birthday,
      Value<int>? numberOfComputers,
      Value<int>? savingAmount,
      Value<bool>? isActive,
      Value<String?>? departmentId,
      Value<String>? syncId,
      Value<String>? knowledgeId,
      Value<bool>? synced,
      Value<bool>? deleted}) {
    return EmployeesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      numberOfComputers: numberOfComputers ?? this.numberOfComputers,
      savingAmount: savingAmount ?? this.savingAmount,
      isActive: isActive ?? this.isActive,
      departmentId: departmentId ?? this.departmentId,
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
      map['name'] = Variable<String?>(name.value);
    }
    if (birthday.present) {
      map['birthday'] = Variable<DateTime>(birthday.value);
    }
    if (numberOfComputers.present) {
      map['number_of_computers'] = Variable<int>(numberOfComputers.value);
    }
    if (savingAmount.present) {
      map['saving_amount'] = Variable<int>(savingAmount.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (departmentId.present) {
      map['department_id'] = Variable<String?>(departmentId.value);
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
          ..write('numberOfComputers: $numberOfComputers, ')
          ..write('savingAmount: $savingAmount, ')
          ..write('isActive: $isActive, ')
          ..write('departmentId: $departmentId, ')
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
  late final GeneratedColumn<String?> id = GeneratedColumn<String?>(
      'id', aliasedName, false,
      typeName: 'TEXT',
      requiredDuringInsert: false,
      clientDefault: () => Uuid().v4());
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>(
      'name', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
      typeName: 'TEXT',
      requiredDuringInsert: false);
  final VerificationMeta _birthdayMeta = const VerificationMeta('birthday');
  late final GeneratedColumn<DateTime?> birthday = GeneratedColumn<DateTime?>(
      'birthday', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultValue: Constant(DateTime.now()));
  final VerificationMeta _numberOfComputersMeta =
      const VerificationMeta('numberOfComputers');
  late final GeneratedColumn<int?> numberOfComputers = GeneratedColumn<int?>(
      'number_of_computers', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  final VerificationMeta _savingAmountMeta =
      const VerificationMeta('savingAmount');
  late final GeneratedColumn<int?> savingAmount = GeneratedColumn<int?>(
      'saving_amount', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  final VerificationMeta _isActiveMeta = const VerificationMeta('isActive');
  late final GeneratedColumn<bool?> isActive = GeneratedColumn<bool?>(
      'is_active', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (is_active IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _departmentIdMeta =
      const VerificationMeta('departmentId');
  late final GeneratedColumn<String?> departmentId = GeneratedColumn<String?>(
      'department_id', aliasedName, true,
      typeName: 'TEXT',
      requiredDuringInsert: false,
      $customConstraints: 'NULLABLE REFERENCES department(id)');
  final VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  late final GeneratedColumn<String?> syncId = GeneratedColumn<String?>(
      'sync_id', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 36),
      typeName: 'TEXT',
      requiredDuringInsert: false,
      defaultValue: Constant(""));
  final VerificationMeta _knowledgeIdMeta =
      const VerificationMeta('knowledgeId');
  late final GeneratedColumn<String?> knowledgeId = GeneratedColumn<String?>(
      'knowledge_id', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 36),
      typeName: 'TEXT',
      requiredDuringInsert: false,
      defaultValue: Constant(""));
  final VerificationMeta _syncedMeta = const VerificationMeta('synced');
  late final GeneratedColumn<bool?> synced = GeneratedColumn<bool?>(
      'synced', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (synced IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  late final GeneratedColumn<bool?> deleted = GeneratedColumn<bool?>(
      'deleted', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (deleted IN (0, 1))',
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        birthday,
        numberOfComputers,
        savingAmount,
        isActive,
        departmentId,
        syncId,
        knowledgeId,
        synced,
        deleted
      ];
  @override
  String get aliasedName => _alias ?? 'employee';
  @override
  String get actualTableName => 'employee';
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
    }
    if (data.containsKey('birthday')) {
      context.handle(_birthdayMeta,
          birthday.isAcceptableOrUnknown(data['birthday']!, _birthdayMeta));
    }
    if (data.containsKey('number_of_computers')) {
      context.handle(
          _numberOfComputersMeta,
          numberOfComputers.isAcceptableOrUnknown(
              data['number_of_computers']!, _numberOfComputersMeta));
    }
    if (data.containsKey('saving_amount')) {
      context.handle(
          _savingAmountMeta,
          savingAmount.isAcceptableOrUnknown(
              data['saving_amount']!, _savingAmountMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('department_id')) {
      context.handle(
          _departmentIdMeta,
          departmentId.isAcceptableOrUnknown(
              data['department_id']!, _departmentIdMeta));
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

class Department extends DataClass implements Insertable<Department> {
  final String id;
  final String? name;
  final String syncId;
  final String knowledgeId;
  final bool synced;
  final bool deleted;
  Department(
      {required this.id,
      this.name,
      required this.syncId,
      required this.knowledgeId,
      required this.synced,
      required this.deleted});
  factory Department.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Department(
      id: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name']),
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
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String?>(name);
    }
    map['sync_id'] = Variable<String>(syncId);
    map['knowledge_id'] = Variable<String>(knowledgeId);
    map['synced'] = Variable<bool>(synced);
    map['deleted'] = Variable<bool>(deleted);
    return map;
  }

  DepartmentsCompanion toCompanion(bool nullToAbsent) {
    return DepartmentsCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      syncId: Value(syncId),
      knowledgeId: Value(knowledgeId),
      synced: Value(synced),
      deleted: Value(deleted),
    );
  }

  factory Department.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Department(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
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
      'name': serializer.toJson<String?>(name),
      'syncId': serializer.toJson<String>(syncId),
      'knowledgeId': serializer.toJson<String>(knowledgeId),
      'synced': serializer.toJson<bool>(synced),
      'deleted': serializer.toJson<bool>(deleted),
    };
  }

  Department copyWith(
          {String? id,
          String? name,
          String? syncId,
          String? knowledgeId,
          bool? synced,
          bool? deleted}) =>
      Department(
        id: id ?? this.id,
        name: name ?? this.name,
        syncId: syncId ?? this.syncId,
        knowledgeId: knowledgeId ?? this.knowledgeId,
        synced: synced ?? this.synced,
        deleted: deleted ?? this.deleted,
      );
  @override
  String toString() {
    return (StringBuffer('Department(')
          ..write('id: $id, ')
          ..write('name: $name, ')
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
              syncId.hashCode,
              $mrjc(knowledgeId.hashCode,
                  $mrjc(synced.hashCode, deleted.hashCode))))));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Department &&
          other.id == this.id &&
          other.name == this.name &&
          other.syncId == this.syncId &&
          other.knowledgeId == this.knowledgeId &&
          other.synced == this.synced &&
          other.deleted == this.deleted);
}

class DepartmentsCompanion extends UpdateCompanion<Department> {
  final Value<String> id;
  final Value<String?> name;
  final Value<String> syncId;
  final Value<String> knowledgeId;
  final Value<bool> synced;
  final Value<bool> deleted;
  const DepartmentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.syncId = const Value.absent(),
    this.knowledgeId = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
  });
  DepartmentsCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.syncId = const Value.absent(),
    this.knowledgeId = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
  });
  static Insertable<Department> custom({
    Expression<String>? id,
    Expression<String?>? name,
    Expression<String>? syncId,
    Expression<String>? knowledgeId,
    Expression<bool>? synced,
    Expression<bool>? deleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (syncId != null) 'sync_id': syncId,
      if (knowledgeId != null) 'knowledge_id': knowledgeId,
      if (synced != null) 'synced': synced,
      if (deleted != null) 'deleted': deleted,
    });
  }

  DepartmentsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? name,
      Value<String>? syncId,
      Value<String>? knowledgeId,
      Value<bool>? synced,
      Value<bool>? deleted}) {
    return DepartmentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
      map['name'] = Variable<String?>(name.value);
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
    return (StringBuffer('DepartmentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('syncId: $syncId, ')
          ..write('knowledgeId: $knowledgeId, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }
}

class $DepartmentsTable extends Departments
    with TableInfo<$DepartmentsTable, Department> {
  final GeneratedDatabase _db;
  final String? _alias;
  $DepartmentsTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String?> id = GeneratedColumn<String?>(
      'id', aliasedName, false,
      typeName: 'TEXT',
      requiredDuringInsert: false,
      clientDefault: () => Uuid().v4());
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>(
      'name', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
      typeName: 'TEXT',
      requiredDuringInsert: false);
  final VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  late final GeneratedColumn<String?> syncId = GeneratedColumn<String?>(
      'sync_id', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 36),
      typeName: 'TEXT',
      requiredDuringInsert: false,
      defaultValue: Constant(""));
  final VerificationMeta _knowledgeIdMeta =
      const VerificationMeta('knowledgeId');
  late final GeneratedColumn<String?> knowledgeId = GeneratedColumn<String?>(
      'knowledge_id', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 36),
      typeName: 'TEXT',
      requiredDuringInsert: false,
      defaultValue: Constant(""));
  final VerificationMeta _syncedMeta = const VerificationMeta('synced');
  late final GeneratedColumn<bool?> synced = GeneratedColumn<bool?>(
      'synced', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (synced IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  late final GeneratedColumn<bool?> deleted = GeneratedColumn<bool?>(
      'deleted', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (deleted IN (0, 1))',
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, syncId, knowledgeId, synced, deleted];
  @override
  String get aliasedName => _alias ?? 'department';
  @override
  String get actualTableName => 'department';
  @override
  VerificationContext validateIntegrity(Insertable<Department> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
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
  Department map(Map<String, dynamic> data, {String? tablePrefix}) {
    return Department.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $DepartmentsTable createAlias(String alias) {
    return $DepartmentsTable(_db, alias);
  }
}

class Configuration extends DataClass implements Insertable<Configuration> {
  final String id;
  final String key;
  final String? value;
  Configuration({required this.id, required this.key, this.value});
  factory Configuration.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Configuration(
      id: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      key: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}key'])!,
      value: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}value']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String?>(value);
    }
    return map;
  }

  ConfigurationsCompanion toCompanion(bool nullToAbsent) {
    return ConfigurationsCompanion(
      id: Value(id),
      key: Value(key),
      value:
          value == null && nullToAbsent ? const Value.absent() : Value(value),
    );
  }

  factory Configuration.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Configuration(
      id: serializer.fromJson<String>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  Configuration copyWith({String? id, String? key, String? value}) =>
      Configuration(
        id: id ?? this.id,
        key: key ?? this.key,
        value: value ?? this.value,
      );
  @override
  String toString() {
    return (StringBuffer('Configuration(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      $mrjf($mrjc(id.hashCode, $mrjc(key.hashCode, value.hashCode)));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Configuration &&
          other.id == this.id &&
          other.key == this.key &&
          other.value == this.value);
}

class ConfigurationsCompanion extends UpdateCompanion<Configuration> {
  final Value<String> id;
  final Value<String> key;
  final Value<String?> value;
  const ConfigurationsCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
  });
  ConfigurationsCompanion.insert({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
  });
  static Insertable<Configuration> custom({
    Expression<String>? id,
    Expression<String>? key,
    Expression<String?>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
    });
  }

  ConfigurationsCompanion copyWith(
      {Value<String>? id, Value<String>? key, Value<String?>? value}) {
    return ConfigurationsCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String?>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfigurationsCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $ConfigurationsTable extends Configurations
    with TableInfo<$ConfigurationsTable, Configuration> {
  final GeneratedDatabase _db;
  final String? _alias;
  $ConfigurationsTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String?> id = GeneratedColumn<String?>(
      'id', aliasedName, false,
      typeName: 'TEXT',
      requiredDuringInsert: false,
      clientDefault: () => Uuid().v4());
  final VerificationMeta _keyMeta = const VerificationMeta('key');
  late final GeneratedColumn<String?> key = GeneratedColumn<String?>(
      'key', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
      typeName: 'TEXT',
      requiredDuringInsert: false,
      defaultValue: const Constant(""));
  final VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<String?> value = GeneratedColumn<String?>(
      'value', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
      typeName: 'TEXT',
      requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, key, value];
  @override
  String get aliasedName => _alias ?? 'configuration';
  @override
  String get actualTableName => 'configuration';
  @override
  VerificationContext validateIntegrity(Insertable<Configuration> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Configuration map(Map<String, dynamic> data, {String? tablePrefix}) {
    return Configuration.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $ConfigurationsTable createAlias(String alias) {
    return $ConfigurationsTable(_db, alias);
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
  late final GeneratedColumn<String?> id = GeneratedColumn<String?>(
      'id', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 36),
      typeName: 'TEXT',
      requiredDuringInsert: true);
  final VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  late final GeneratedColumn<String?> syncId = GeneratedColumn<String?>(
      'sync_id', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 36),
      typeName: 'TEXT',
      requiredDuringInsert: true);
  final VerificationMeta _localMeta = const VerificationMeta('local');
  late final GeneratedColumn<bool?> local = GeneratedColumn<bool?>(
      'local', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: true,
      defaultConstraints: 'CHECK (local IN (0, 1))');
  final VerificationMeta _lastTimeStampMeta =
      const VerificationMeta('lastTimeStamp');
  late final GeneratedColumn<int?> lastTimeStamp = GeneratedColumn<int?>(
      'last_time_stamp', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: true);
  final VerificationMeta _metaMeta = const VerificationMeta('meta');
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

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $EmployeesTable employees = $EmployeesTable(this);
  late final $DepartmentsTable departments = $DepartmentsTable(this);
  late final $ConfigurationsTable configurations = $ConfigurationsTable(this);
  late final $NetCoreSyncKnowledgesTable netCoreSyncKnowledges =
      $NetCoreSyncKnowledgesTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [employees, departments, configurations, netCoreSyncKnowledges];
}

// **************************************************************************
// NetCoreSyncClientGenerator
// **************************************************************************

// NOTE: Obtained from @NetCoreSyncTable annotations:
// Employees: {"tableClassName":"Employees","dataClassName":"Employee","useRowClass":false,"netCoreSyncTable":{"idFieldName":"id","syncIdFieldName":"syncId","knowledgeIdFieldName":"knowledgeId","syncedFieldName":"synced","deletedFieldName":"deleted","columnFieldNames":["id","name","birthday","numberOfComputers","savingAmount","isActive","departmentId","syncId","knowledgeId","synced","deleted"]}}
// Departments: {"tableClassName":"Departments","dataClassName":"Department","useRowClass":false,"netCoreSyncTable":{"idFieldName":"id","syncIdFieldName":"syncId","knowledgeIdFieldName":"knowledgeId","syncedFieldName":"synced","deletedFieldName":"deleted","columnFieldNames":["id","name","syncId","knowledgeId","synced","deleted"]}}

class _$NetCoreSyncEngineUser extends NetCoreSyncEngine {
  _$NetCoreSyncEngineUser(Map<Type, NetCoreSyncTableUser> tables)
      : super(tables);

  @override
  dynamic fromJson(Type type, Map<String, dynamic> json) {
    if (type == Employee) {
      return Employee.fromJson(json);
    }
    if (type == Department) {
      return Department.fromJson(json);
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
    if (D == Department) {
      DepartmentsCompanion safeEntity;
      if (entity is DepartmentsCompanion) {
        safeEntity = entity as DepartmentsCompanion;
      } else {
        safeEntity = (entity as Department).toCompanion(false);
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
    if (entity is Department) {
      switch (fieldName) {
        case "id":
          return (entity as Department).id;
        case "deleted":
          return (entity as Department).deleted;
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
      if (D == Department) {
        return (entity as DepartmentsCompanion).copyWith(
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
      if (entity is Department) {
        return (entity as Department).copyWith(
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

extension $NetCoreSyncClientExtension on Database {
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
              "deletedFieldName": "deleted",
              "columnFieldNames": [
                "id",
                "name",
                "birthday",
                "numberOfComputers",
                "savingAmount",
                "isActive",
                "departmentId",
                "syncId",
                "knowledgeId",
                "synced",
                "deleted"
              ]
            }),
            employees.id.escapedName,
            employees.syncId.escapedName,
            employees.knowledgeId.escapedName,
            employees.synced.escapedName,
            employees.deleted.escapedName,
          ),
          Department: NetCoreSyncTableUser(
            departments,
            NetCoreSyncTable.fromJson({
              "idFieldName": "id",
              "syncIdFieldName": "syncId",
              "knowledgeIdFieldName": "knowledgeId",
              "syncedFieldName": "synced",
              "deletedFieldName": "deleted",
              "columnFieldNames": [
                "id",
                "name",
                "syncId",
                "knowledgeId",
                "synced",
                "deleted"
              ]
            }),
            departments.id.escapedName,
            departments.syncId.escapedName,
            departments.knowledgeId.escapedName,
            departments.synced.escapedName,
            departments.deleted.escapedName,
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
  $SyncEmployeesTable(_$Database db, this._allSyncIds) : super(db);
  @override
  Type get type => Employee;
  @override
  String get entityName =>
      "(SELECT * FROM ${super.entityName} WHERE ${super.deleted.escapedName} = 0 AND ${super.syncId.escapedName} IN (${_allSyncIds()}))";
}

class $SyncDepartmentsTable extends $DepartmentsTable
    implements SyncBaseTable<$DepartmentsTable, Department> {
  final String Function() _allSyncIds;
  $SyncDepartmentsTable(_$Database db, this._allSyncIds) : super(db);
  @override
  Type get type => Department;
  @override
  String get entityName =>
      "(SELECT * FROM ${super.entityName} WHERE ${super.deleted.escapedName} = 0 AND ${super.syncId.escapedName} IN (${_allSyncIds()}))";
}

mixin NetCoreSyncClientUser on NetCoreSyncClient {
  late $SyncEmployeesTable _syncEmployees;
  late $SyncDepartmentsTable _syncDepartments;

  void netCoreSyncInitializeUser() {
    _syncEmployees =
        $SyncEmployeesTable(netCoreSyncResolvedEngine, netCoreSyncAllSyncIds);
    _syncDepartments =
        $SyncDepartmentsTable(netCoreSyncResolvedEngine, netCoreSyncAllSyncIds);
  }

  $SyncEmployeesTable get syncEmployees {
    if (!netCoreSyncInitialized) throw NetCoreSyncNotInitializedException();
    return _syncEmployees;
  }

  $SyncDepartmentsTable get syncDepartments {
    if (!netCoreSyncInitialized) throw NetCoreSyncNotInitializedException();
    return _syncDepartments;
  }
}
