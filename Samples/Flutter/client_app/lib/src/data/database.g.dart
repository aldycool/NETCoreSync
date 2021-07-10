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
  final int lastUpdated;
  final bool deleted;
  final String? databaseInstanceId;
  Employee(
      {required this.id,
      this.name,
      required this.birthday,
      required this.numberOfComputers,
      required this.savingAmount,
      required this.isActive,
      this.departmentId,
      required this.lastUpdated,
      required this.deleted,
      this.databaseInstanceId});
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
      lastUpdated: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}last_updated'])!,
      deleted: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}deleted'])!,
      databaseInstanceId: const StringType().mapFromDatabaseResponse(
          data['${effectivePrefix}database_instance_id']),
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
    map['last_updated'] = Variable<int>(lastUpdated);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || databaseInstanceId != null) {
      map['database_instance_id'] = Variable<String?>(databaseInstanceId);
    }
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
      lastUpdated: Value(lastUpdated),
      deleted: Value(deleted),
      databaseInstanceId: databaseInstanceId == null && nullToAbsent
          ? const Value.absent()
          : Value(databaseInstanceId),
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
      lastUpdated: serializer.fromJson<int>(json['lastUpdated']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      databaseInstanceId:
          serializer.fromJson<String?>(json['databaseInstanceId']),
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
      'lastUpdated': serializer.toJson<int>(lastUpdated),
      'deleted': serializer.toJson<bool>(deleted),
      'databaseInstanceId': serializer.toJson<String?>(databaseInstanceId),
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
          int? lastUpdated,
          bool? deleted,
          String? databaseInstanceId}) =>
      Employee(
        id: id ?? this.id,
        name: name ?? this.name,
        birthday: birthday ?? this.birthday,
        numberOfComputers: numberOfComputers ?? this.numberOfComputers,
        savingAmount: savingAmount ?? this.savingAmount,
        isActive: isActive ?? this.isActive,
        departmentId: departmentId ?? this.departmentId,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        deleted: deleted ?? this.deleted,
        databaseInstanceId: databaseInstanceId ?? this.databaseInstanceId,
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
          ..write('lastUpdated: $lastUpdated, ')
          ..write('deleted: $deleted, ')
          ..write('databaseInstanceId: $databaseInstanceId')
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
                                  lastUpdated.hashCode,
                                  $mrjc(deleted.hashCode,
                                      databaseInstanceId.hashCode))))))))));
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
          other.lastUpdated == this.lastUpdated &&
          other.deleted == this.deleted &&
          other.databaseInstanceId == this.databaseInstanceId);
}

class EmployeesCompanion extends UpdateCompanion<Employee> {
  final Value<String> id;
  final Value<String?> name;
  final Value<DateTime> birthday;
  final Value<int> numberOfComputers;
  final Value<int> savingAmount;
  final Value<bool> isActive;
  final Value<String?> departmentId;
  final Value<int> lastUpdated;
  final Value<bool> deleted;
  final Value<String?> databaseInstanceId;
  const EmployeesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthday = const Value.absent(),
    this.numberOfComputers = const Value.absent(),
    this.savingAmount = const Value.absent(),
    this.isActive = const Value.absent(),
    this.departmentId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.deleted = const Value.absent(),
    this.databaseInstanceId = const Value.absent(),
  });
  EmployeesCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthday = const Value.absent(),
    this.numberOfComputers = const Value.absent(),
    this.savingAmount = const Value.absent(),
    this.isActive = const Value.absent(),
    this.departmentId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.deleted = const Value.absent(),
    this.databaseInstanceId = const Value.absent(),
  });
  static Insertable<Employee> custom({
    Expression<String>? id,
    Expression<String?>? name,
    Expression<DateTime>? birthday,
    Expression<int>? numberOfComputers,
    Expression<int>? savingAmount,
    Expression<bool>? isActive,
    Expression<String?>? departmentId,
    Expression<int>? lastUpdated,
    Expression<bool>? deleted,
    Expression<String?>? databaseInstanceId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (birthday != null) 'birthday': birthday,
      if (numberOfComputers != null) 'number_of_computers': numberOfComputers,
      if (savingAmount != null) 'saving_amount': savingAmount,
      if (isActive != null) 'is_active': isActive,
      if (departmentId != null) 'department_id': departmentId,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (deleted != null) 'deleted': deleted,
      if (databaseInstanceId != null)
        'database_instance_id': databaseInstanceId,
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
      Value<int>? lastUpdated,
      Value<bool>? deleted,
      Value<String?>? databaseInstanceId}) {
    return EmployeesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      numberOfComputers: numberOfComputers ?? this.numberOfComputers,
      savingAmount: savingAmount ?? this.savingAmount,
      isActive: isActive ?? this.isActive,
      departmentId: departmentId ?? this.departmentId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      deleted: deleted ?? this.deleted,
      databaseInstanceId: databaseInstanceId ?? this.databaseInstanceId,
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
    if (lastUpdated.present) {
      map['last_updated'] = Variable<int>(lastUpdated.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (databaseInstanceId.present) {
      map['database_instance_id'] = Variable<String?>(databaseInstanceId.value);
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
          ..write('lastUpdated: $lastUpdated, ')
          ..write('deleted: $deleted, ')
          ..write('databaseInstanceId: $databaseInstanceId')
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
  final VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  late final GeneratedColumn<int?> lastUpdated = GeneratedColumn<int?>(
      'last_updated', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  final VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  late final GeneratedColumn<bool?> deleted = GeneratedColumn<bool?>(
      'deleted', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (deleted IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _databaseInstanceIdMeta =
      const VerificationMeta('databaseInstanceId');
  late final GeneratedColumn<String?> databaseInstanceId =
      GeneratedColumn<String?>('database_instance_id', aliasedName, true,
          additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
          typeName: 'TEXT',
          requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        birthday,
        numberOfComputers,
        savingAmount,
        isActive,
        departmentId,
        lastUpdated,
        deleted,
        databaseInstanceId
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
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('database_instance_id')) {
      context.handle(
          _databaseInstanceIdMeta,
          databaseInstanceId.isAcceptableOrUnknown(
              data['database_instance_id']!, _databaseInstanceIdMeta));
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
  final int lastUpdated;
  final bool deleted;
  final String? databaseInstanceId;
  Department(
      {required this.id,
      this.name,
      required this.lastUpdated,
      required this.deleted,
      this.databaseInstanceId});
  factory Department.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Department(
      id: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name']),
      lastUpdated: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}last_updated'])!,
      deleted: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}deleted'])!,
      databaseInstanceId: const StringType().mapFromDatabaseResponse(
          data['${effectivePrefix}database_instance_id']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String?>(name);
    }
    map['last_updated'] = Variable<int>(lastUpdated);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || databaseInstanceId != null) {
      map['database_instance_id'] = Variable<String?>(databaseInstanceId);
    }
    return map;
  }

  DepartmentsCompanion toCompanion(bool nullToAbsent) {
    return DepartmentsCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      lastUpdated: Value(lastUpdated),
      deleted: Value(deleted),
      databaseInstanceId: databaseInstanceId == null && nullToAbsent
          ? const Value.absent()
          : Value(databaseInstanceId),
    );
  }

  factory Department.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Department(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      lastUpdated: serializer.fromJson<int>(json['lastUpdated']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      databaseInstanceId:
          serializer.fromJson<String?>(json['databaseInstanceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String?>(name),
      'lastUpdated': serializer.toJson<int>(lastUpdated),
      'deleted': serializer.toJson<bool>(deleted),
      'databaseInstanceId': serializer.toJson<String?>(databaseInstanceId),
    };
  }

  Department copyWith(
          {String? id,
          String? name,
          int? lastUpdated,
          bool? deleted,
          String? databaseInstanceId}) =>
      Department(
        id: id ?? this.id,
        name: name ?? this.name,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        deleted: deleted ?? this.deleted,
        databaseInstanceId: databaseInstanceId ?? this.databaseInstanceId,
      );
  @override
  String toString() {
    return (StringBuffer('Department(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('deleted: $deleted, ')
          ..write('databaseInstanceId: $databaseInstanceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          name.hashCode,
          $mrjc(lastUpdated.hashCode,
              $mrjc(deleted.hashCode, databaseInstanceId.hashCode)))));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Department &&
          other.id == this.id &&
          other.name == this.name &&
          other.lastUpdated == this.lastUpdated &&
          other.deleted == this.deleted &&
          other.databaseInstanceId == this.databaseInstanceId);
}

class DepartmentsCompanion extends UpdateCompanion<Department> {
  final Value<String> id;
  final Value<String?> name;
  final Value<int> lastUpdated;
  final Value<bool> deleted;
  final Value<String?> databaseInstanceId;
  const DepartmentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.deleted = const Value.absent(),
    this.databaseInstanceId = const Value.absent(),
  });
  DepartmentsCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.deleted = const Value.absent(),
    this.databaseInstanceId = const Value.absent(),
  });
  static Insertable<Department> custom({
    Expression<String>? id,
    Expression<String?>? name,
    Expression<int>? lastUpdated,
    Expression<bool>? deleted,
    Expression<String?>? databaseInstanceId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (deleted != null) 'deleted': deleted,
      if (databaseInstanceId != null)
        'database_instance_id': databaseInstanceId,
    });
  }

  DepartmentsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? name,
      Value<int>? lastUpdated,
      Value<bool>? deleted,
      Value<String?>? databaseInstanceId}) {
    return DepartmentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      deleted: deleted ?? this.deleted,
      databaseInstanceId: databaseInstanceId ?? this.databaseInstanceId,
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
    if (lastUpdated.present) {
      map['last_updated'] = Variable<int>(lastUpdated.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (databaseInstanceId.present) {
      map['database_instance_id'] = Variable<String?>(databaseInstanceId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DepartmentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('deleted: $deleted, ')
          ..write('databaseInstanceId: $databaseInstanceId')
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
  final VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  late final GeneratedColumn<int?> lastUpdated = GeneratedColumn<int?>(
      'last_updated', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  final VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  late final GeneratedColumn<bool?> deleted = GeneratedColumn<bool?>(
      'deleted', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (deleted IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _databaseInstanceIdMeta =
      const VerificationMeta('databaseInstanceId');
  late final GeneratedColumn<String?> databaseInstanceId =
      GeneratedColumn<String?>('database_instance_id', aliasedName, true,
          additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
          typeName: 'TEXT',
          requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, lastUpdated, deleted, databaseInstanceId];
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
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('database_instance_id')) {
      context.handle(
          _databaseInstanceIdMeta,
          databaseInstanceId.isAcceptableOrUnknown(
              data['database_instance_id']!, _databaseInstanceIdMeta));
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

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> fieldString;
  final Value<String?> fieldStringNullable;
  final Value<int> fieldInt;
  final Value<int?> fieldIntNullable;
  final Value<bool> fieldBoolean;
  final Value<bool?> fieldBooleanNullable;
  final Value<DateTime> fieldDateTime;
  final Value<DateTime?> fieldDateTimeNullable;
  final Value<int> lastUpdated;
  final Value<bool> deleted;
  final Value<String?> databaseInstanceId;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.fieldString = const Value.absent(),
    this.fieldStringNullable = const Value.absent(),
    this.fieldInt = const Value.absent(),
    this.fieldIntNullable = const Value.absent(),
    this.fieldBoolean = const Value.absent(),
    this.fieldBooleanNullable = const Value.absent(),
    this.fieldDateTime = const Value.absent(),
    this.fieldDateTimeNullable = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.deleted = const Value.absent(),
    this.databaseInstanceId = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String fieldString,
    this.fieldStringNullable = const Value.absent(),
    required int fieldInt,
    this.fieldIntNullable = const Value.absent(),
    required bool fieldBoolean,
    this.fieldBooleanNullable = const Value.absent(),
    required DateTime fieldDateTime,
    this.fieldDateTimeNullable = const Value.absent(),
    required int lastUpdated,
    required bool deleted,
    this.databaseInstanceId = const Value.absent(),
  })  : id = Value(id),
        fieldString = Value(fieldString),
        fieldInt = Value(fieldInt),
        fieldBoolean = Value(fieldBoolean),
        fieldDateTime = Value(fieldDateTime),
        lastUpdated = Value(lastUpdated),
        deleted = Value(deleted);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? fieldString,
    Expression<String?>? fieldStringNullable,
    Expression<int>? fieldInt,
    Expression<int?>? fieldIntNullable,
    Expression<bool>? fieldBoolean,
    Expression<bool?>? fieldBooleanNullable,
    Expression<DateTime>? fieldDateTime,
    Expression<DateTime?>? fieldDateTimeNullable,
    Expression<int>? lastUpdated,
    Expression<bool>? deleted,
    Expression<String?>? databaseInstanceId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fieldString != null) 'field_string': fieldString,
      if (fieldStringNullable != null)
        'field_string_nullable': fieldStringNullable,
      if (fieldInt != null) 'field_int': fieldInt,
      if (fieldIntNullable != null) 'field_int_nullable': fieldIntNullable,
      if (fieldBoolean != null) 'field_boolean': fieldBoolean,
      if (fieldBooleanNullable != null)
        'field_boolean_nullable': fieldBooleanNullable,
      if (fieldDateTime != null) 'field_date_time': fieldDateTime,
      if (fieldDateTimeNullable != null)
        'field_date_time_nullable': fieldDateTimeNullable,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (deleted != null) 'deleted': deleted,
      if (databaseInstanceId != null)
        'database_instance_id': databaseInstanceId,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? fieldString,
      Value<String?>? fieldStringNullable,
      Value<int>? fieldInt,
      Value<int?>? fieldIntNullable,
      Value<bool>? fieldBoolean,
      Value<bool?>? fieldBooleanNullable,
      Value<DateTime>? fieldDateTime,
      Value<DateTime?>? fieldDateTimeNullable,
      Value<int>? lastUpdated,
      Value<bool>? deleted,
      Value<String?>? databaseInstanceId}) {
    return UsersCompanion(
      id: id ?? this.id,
      fieldString: fieldString ?? this.fieldString,
      fieldStringNullable: fieldStringNullable ?? this.fieldStringNullable,
      fieldInt: fieldInt ?? this.fieldInt,
      fieldIntNullable: fieldIntNullable ?? this.fieldIntNullable,
      fieldBoolean: fieldBoolean ?? this.fieldBoolean,
      fieldBooleanNullable: fieldBooleanNullable ?? this.fieldBooleanNullable,
      fieldDateTime: fieldDateTime ?? this.fieldDateTime,
      fieldDateTimeNullable:
          fieldDateTimeNullable ?? this.fieldDateTimeNullable,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      deleted: deleted ?? this.deleted,
      databaseInstanceId: databaseInstanceId ?? this.databaseInstanceId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fieldString.present) {
      map['field_string'] = Variable<String>(fieldString.value);
    }
    if (fieldStringNullable.present) {
      map['field_string_nullable'] =
          Variable<String?>(fieldStringNullable.value);
    }
    if (fieldInt.present) {
      map['field_int'] = Variable<int>(fieldInt.value);
    }
    if (fieldIntNullable.present) {
      map['field_int_nullable'] = Variable<int?>(fieldIntNullable.value);
    }
    if (fieldBoolean.present) {
      map['field_boolean'] = Variable<bool>(fieldBoolean.value);
    }
    if (fieldBooleanNullable.present) {
      map['field_boolean_nullable'] =
          Variable<bool?>(fieldBooleanNullable.value);
    }
    if (fieldDateTime.present) {
      map['field_date_time'] = Variable<DateTime>(fieldDateTime.value);
    }
    if (fieldDateTimeNullable.present) {
      map['field_date_time_nullable'] =
          Variable<DateTime?>(fieldDateTimeNullable.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<int>(lastUpdated.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (databaseInstanceId.present) {
      map['database_instance_id'] = Variable<String?>(databaseInstanceId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('fieldString: $fieldString, ')
          ..write('fieldStringNullable: $fieldStringNullable, ')
          ..write('fieldInt: $fieldInt, ')
          ..write('fieldIntNullable: $fieldIntNullable, ')
          ..write('fieldBoolean: $fieldBoolean, ')
          ..write('fieldBooleanNullable: $fieldBooleanNullable, ')
          ..write('fieldDateTime: $fieldDateTime, ')
          ..write('fieldDateTimeNullable: $fieldDateTimeNullable, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('deleted: $deleted, ')
          ..write('databaseInstanceId: $databaseInstanceId')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  final GeneratedDatabase _db;
  final String? _alias;
  $UsersTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String?> id = GeneratedColumn<String?>(
      'id', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 36),
      typeName: 'TEXT',
      requiredDuringInsert: true);
  final VerificationMeta _fieldStringMeta =
      const VerificationMeta('fieldString');
  late final GeneratedColumn<String?> fieldString = GeneratedColumn<String?>(
      'field_string', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
      typeName: 'TEXT',
      requiredDuringInsert: true);
  final VerificationMeta _fieldStringNullableMeta =
      const VerificationMeta('fieldStringNullable');
  late final GeneratedColumn<String?> fieldStringNullable =
      GeneratedColumn<String?>('field_string_nullable', aliasedName, true,
          additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
          typeName: 'TEXT',
          requiredDuringInsert: false);
  final VerificationMeta _fieldIntMeta = const VerificationMeta('fieldInt');
  late final GeneratedColumn<int?> fieldInt = GeneratedColumn<int?>(
      'field_int', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: true);
  final VerificationMeta _fieldIntNullableMeta =
      const VerificationMeta('fieldIntNullable');
  late final GeneratedColumn<int?> fieldIntNullable = GeneratedColumn<int?>(
      'field_int_nullable', aliasedName, true,
      typeName: 'INTEGER', requiredDuringInsert: false);
  final VerificationMeta _fieldBooleanMeta =
      const VerificationMeta('fieldBoolean');
  late final GeneratedColumn<bool?> fieldBoolean = GeneratedColumn<bool?>(
      'field_boolean', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: true,
      defaultConstraints: 'CHECK (field_boolean IN (0, 1))');
  final VerificationMeta _fieldBooleanNullableMeta =
      const VerificationMeta('fieldBooleanNullable');
  late final GeneratedColumn<bool?> fieldBooleanNullable =
      GeneratedColumn<bool?>('field_boolean_nullable', aliasedName, true,
          typeName: 'INTEGER',
          requiredDuringInsert: false,
          defaultConstraints: 'CHECK (field_boolean_nullable IN (0, 1))');
  final VerificationMeta _fieldDateTimeMeta =
      const VerificationMeta('fieldDateTime');
  late final GeneratedColumn<DateTime?> fieldDateTime =
      GeneratedColumn<DateTime?>('field_date_time', aliasedName, false,
          typeName: 'INTEGER', requiredDuringInsert: true);
  final VerificationMeta _fieldDateTimeNullableMeta =
      const VerificationMeta('fieldDateTimeNullable');
  late final GeneratedColumn<DateTime?> fieldDateTimeNullable =
      GeneratedColumn<DateTime?>('field_date_time_nullable', aliasedName, true,
          typeName: 'INTEGER', requiredDuringInsert: false);
  final VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  late final GeneratedColumn<int?> lastUpdated = GeneratedColumn<int?>(
      'last_updated', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: true);
  final VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  late final GeneratedColumn<bool?> deleted = GeneratedColumn<bool?>(
      'deleted', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: true,
      defaultConstraints: 'CHECK (deleted IN (0, 1))');
  final VerificationMeta _databaseInstanceIdMeta =
      const VerificationMeta('databaseInstanceId');
  late final GeneratedColumn<String?> databaseInstanceId =
      GeneratedColumn<String?>('database_instance_id', aliasedName, true,
          additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 36),
          typeName: 'TEXT',
          requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        fieldString,
        fieldStringNullable,
        fieldInt,
        fieldIntNullable,
        fieldBoolean,
        fieldBooleanNullable,
        fieldDateTime,
        fieldDateTimeNullable,
        lastUpdated,
        deleted,
        databaseInstanceId
      ];
  @override
  String get aliasedName => _alias ?? 'user';
  @override
  String get actualTableName => 'user';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('field_string')) {
      context.handle(
          _fieldStringMeta,
          fieldString.isAcceptableOrUnknown(
              data['field_string']!, _fieldStringMeta));
    } else if (isInserting) {
      context.missing(_fieldStringMeta);
    }
    if (data.containsKey('field_string_nullable')) {
      context.handle(
          _fieldStringNullableMeta,
          fieldStringNullable.isAcceptableOrUnknown(
              data['field_string_nullable']!, _fieldStringNullableMeta));
    }
    if (data.containsKey('field_int')) {
      context.handle(_fieldIntMeta,
          fieldInt.isAcceptableOrUnknown(data['field_int']!, _fieldIntMeta));
    } else if (isInserting) {
      context.missing(_fieldIntMeta);
    }
    if (data.containsKey('field_int_nullable')) {
      context.handle(
          _fieldIntNullableMeta,
          fieldIntNullable.isAcceptableOrUnknown(
              data['field_int_nullable']!, _fieldIntNullableMeta));
    }
    if (data.containsKey('field_boolean')) {
      context.handle(
          _fieldBooleanMeta,
          fieldBoolean.isAcceptableOrUnknown(
              data['field_boolean']!, _fieldBooleanMeta));
    } else if (isInserting) {
      context.missing(_fieldBooleanMeta);
    }
    if (data.containsKey('field_boolean_nullable')) {
      context.handle(
          _fieldBooleanNullableMeta,
          fieldBooleanNullable.isAcceptableOrUnknown(
              data['field_boolean_nullable']!, _fieldBooleanNullableMeta));
    }
    if (data.containsKey('field_date_time')) {
      context.handle(
          _fieldDateTimeMeta,
          fieldDateTime.isAcceptableOrUnknown(
              data['field_date_time']!, _fieldDateTimeMeta));
    } else if (isInserting) {
      context.missing(_fieldDateTimeMeta);
    }
    if (data.containsKey('field_date_time_nullable')) {
      context.handle(
          _fieldDateTimeNullableMeta,
          fieldDateTimeNullable.isAcceptableOrUnknown(
              data['field_date_time_nullable']!, _fieldDateTimeNullableMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    } else if (isInserting) {
      context.missing(_deletedMeta);
    }
    if (data.containsKey('database_instance_id')) {
      context.handle(
          _databaseInstanceIdMeta,
          databaseInstanceId.isAcceptableOrUnknown(
              data['database_instance_id']!, _databaseInstanceIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User.fromDb(
      id: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      fieldString: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}field_string'])!,
      fieldStringNullable: const StringType().mapFromDatabaseResponse(
          data['${effectivePrefix}field_string_nullable']),
      fieldInt: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}field_int'])!,
      fieldIntNullable: const IntType().mapFromDatabaseResponse(
          data['${effectivePrefix}field_int_nullable']),
      fieldBoolean: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}field_boolean'])!,
      fieldBooleanNullable: const BoolType().mapFromDatabaseResponse(
          data['${effectivePrefix}field_boolean_nullable']),
      fieldDateTime: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}field_date_time'])!,
      fieldDateTimeNullable: const DateTimeType().mapFromDatabaseResponse(
          data['${effectivePrefix}field_date_time_nullable']),
      lastUpdated: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}last_updated'])!,
      deleted: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}deleted'])!,
      databaseInstanceId: const StringType().mapFromDatabaseResponse(
          data['${effectivePrefix}database_instance_id']),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(_db, alias);
  }
}

class Knowledge extends DataClass implements Insertable<Knowledge> {
  final String id;
  final bool local;
  final int maxTimeStamp;
  Knowledge(
      {required this.id, required this.local, required this.maxTimeStamp});
  factory Knowledge.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Knowledge(
      id: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      local: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}local'])!,
      maxTimeStamp: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}max_time_stamp'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['local'] = Variable<bool>(local);
    map['max_time_stamp'] = Variable<int>(maxTimeStamp);
    return map;
  }

  NetCoreSyncKnowledgesCompanion toCompanion(bool nullToAbsent) {
    return NetCoreSyncKnowledgesCompanion(
      id: Value(id),
      local: Value(local),
      maxTimeStamp: Value(maxTimeStamp),
    );
  }

  factory Knowledge.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Knowledge(
      id: serializer.fromJson<String>(json['id']),
      local: serializer.fromJson<bool>(json['local']),
      maxTimeStamp: serializer.fromJson<int>(json['maxTimeStamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'local': serializer.toJson<bool>(local),
      'maxTimeStamp': serializer.toJson<int>(maxTimeStamp),
    };
  }

  Knowledge copyWith({String? id, bool? local, int? maxTimeStamp}) => Knowledge(
        id: id ?? this.id,
        local: local ?? this.local,
        maxTimeStamp: maxTimeStamp ?? this.maxTimeStamp,
      );
  @override
  String toString() {
    return (StringBuffer('Knowledge(')
          ..write('id: $id, ')
          ..write('local: $local, ')
          ..write('maxTimeStamp: $maxTimeStamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      $mrjf($mrjc(id.hashCode, $mrjc(local.hashCode, maxTimeStamp.hashCode)));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Knowledge &&
          other.id == this.id &&
          other.local == this.local &&
          other.maxTimeStamp == this.maxTimeStamp);
}

class NetCoreSyncKnowledgesCompanion extends UpdateCompanion<Knowledge> {
  final Value<String> id;
  final Value<bool> local;
  final Value<int> maxTimeStamp;
  const NetCoreSyncKnowledgesCompanion({
    this.id = const Value.absent(),
    this.local = const Value.absent(),
    this.maxTimeStamp = const Value.absent(),
  });
  NetCoreSyncKnowledgesCompanion.insert({
    this.id = const Value.absent(),
    this.local = const Value.absent(),
    this.maxTimeStamp = const Value.absent(),
  });
  static Insertable<Knowledge> custom({
    Expression<String>? id,
    Expression<bool>? local,
    Expression<int>? maxTimeStamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (local != null) 'local': local,
      if (maxTimeStamp != null) 'max_time_stamp': maxTimeStamp,
    });
  }

  NetCoreSyncKnowledgesCompanion copyWith(
      {Value<String>? id, Value<bool>? local, Value<int>? maxTimeStamp}) {
    return NetCoreSyncKnowledgesCompanion(
      id: id ?? this.id,
      local: local ?? this.local,
      maxTimeStamp: maxTimeStamp ?? this.maxTimeStamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (local.present) {
      map['local'] = Variable<bool>(local.value);
    }
    if (maxTimeStamp.present) {
      map['max_time_stamp'] = Variable<int>(maxTimeStamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NetCoreSyncKnowledgesCompanion(')
          ..write('id: $id, ')
          ..write('local: $local, ')
          ..write('maxTimeStamp: $maxTimeStamp')
          ..write(')'))
        .toString();
  }
}

class $NetCoreSyncKnowledgesTable extends NetCoreSyncKnowledges
    with TableInfo<$NetCoreSyncKnowledgesTable, Knowledge> {
  final GeneratedDatabase _db;
  final String? _alias;
  $NetCoreSyncKnowledgesTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String?> id = GeneratedColumn<String?>(
      'id', aliasedName, false,
      typeName: 'TEXT',
      requiredDuringInsert: false,
      clientDefault: () => Uuid().v4());
  final VerificationMeta _localMeta = const VerificationMeta('local');
  late final GeneratedColumn<bool?> local = GeneratedColumn<bool?>(
      'local', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (local IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _maxTimeStampMeta =
      const VerificationMeta('maxTimeStamp');
  late final GeneratedColumn<int?> maxTimeStamp = GeneratedColumn<int?>(
      'max_time_stamp', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [id, local, maxTimeStamp];
  @override
  String get aliasedName => _alias ?? 'netcoresync_knowledges';
  @override
  String get actualTableName => 'netcoresync_knowledges';
  @override
  VerificationContext validateIntegrity(Insertable<Knowledge> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('local')) {
      context.handle(
          _localMeta, local.isAcceptableOrUnknown(data['local']!, _localMeta));
    }
    if (data.containsKey('max_time_stamp')) {
      context.handle(
          _maxTimeStampMeta,
          maxTimeStamp.isAcceptableOrUnknown(
              data['max_time_stamp']!, _maxTimeStampMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Knowledge map(Map<String, dynamic> data, {String? tablePrefix}) {
    return Knowledge.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
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
  late final $UsersTable users = $UsersTable(this);
  late final $NetCoreSyncKnowledgesTable netCoreSyncKnowledges =
      $NetCoreSyncKnowledgesTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [employees, departments, configurations, users, netCoreSyncKnowledges];
}
