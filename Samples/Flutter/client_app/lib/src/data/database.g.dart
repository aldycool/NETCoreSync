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

class Knowledge extends DataClass implements Insertable<Knowledge> {
  final String id;
  final String? databaseInstanceId;
  final bool isLocal;
  final int maxTimeStamp;
  Knowledge(
      {required this.id,
      this.databaseInstanceId,
      required this.isLocal,
      required this.maxTimeStamp});
  factory Knowledge.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Knowledge(
      id: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      databaseInstanceId: const StringType().mapFromDatabaseResponse(
          data['${effectivePrefix}database_instance_id']),
      isLocal: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}is_local'])!,
      maxTimeStamp: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}max_time_stamp'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || databaseInstanceId != null) {
      map['database_instance_id'] = Variable<String?>(databaseInstanceId);
    }
    map['is_local'] = Variable<bool>(isLocal);
    map['max_time_stamp'] = Variable<int>(maxTimeStamp);
    return map;
  }

  KnowledgesCompanion toCompanion(bool nullToAbsent) {
    return KnowledgesCompanion(
      id: Value(id),
      databaseInstanceId: databaseInstanceId == null && nullToAbsent
          ? const Value.absent()
          : Value(databaseInstanceId),
      isLocal: Value(isLocal),
      maxTimeStamp: Value(maxTimeStamp),
    );
  }

  factory Knowledge.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Knowledge(
      id: serializer.fromJson<String>(json['id']),
      databaseInstanceId:
          serializer.fromJson<String?>(json['databaseInstanceId']),
      isLocal: serializer.fromJson<bool>(json['isLocal']),
      maxTimeStamp: serializer.fromJson<int>(json['maxTimeStamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'databaseInstanceId': serializer.toJson<String?>(databaseInstanceId),
      'isLocal': serializer.toJson<bool>(isLocal),
      'maxTimeStamp': serializer.toJson<int>(maxTimeStamp),
    };
  }

  Knowledge copyWith(
          {String? id,
          String? databaseInstanceId,
          bool? isLocal,
          int? maxTimeStamp}) =>
      Knowledge(
        id: id ?? this.id,
        databaseInstanceId: databaseInstanceId ?? this.databaseInstanceId,
        isLocal: isLocal ?? this.isLocal,
        maxTimeStamp: maxTimeStamp ?? this.maxTimeStamp,
      );
  @override
  String toString() {
    return (StringBuffer('Knowledge(')
          ..write('id: $id, ')
          ..write('databaseInstanceId: $databaseInstanceId, ')
          ..write('isLocal: $isLocal, ')
          ..write('maxTimeStamp: $maxTimeStamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(databaseInstanceId.hashCode,
          $mrjc(isLocal.hashCode, maxTimeStamp.hashCode))));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Knowledge &&
          other.id == this.id &&
          other.databaseInstanceId == this.databaseInstanceId &&
          other.isLocal == this.isLocal &&
          other.maxTimeStamp == this.maxTimeStamp);
}

class KnowledgesCompanion extends UpdateCompanion<Knowledge> {
  final Value<String> id;
  final Value<String?> databaseInstanceId;
  final Value<bool> isLocal;
  final Value<int> maxTimeStamp;
  const KnowledgesCompanion({
    this.id = const Value.absent(),
    this.databaseInstanceId = const Value.absent(),
    this.isLocal = const Value.absent(),
    this.maxTimeStamp = const Value.absent(),
  });
  KnowledgesCompanion.insert({
    this.id = const Value.absent(),
    this.databaseInstanceId = const Value.absent(),
    this.isLocal = const Value.absent(),
    this.maxTimeStamp = const Value.absent(),
  });
  static Insertable<Knowledge> custom({
    Expression<String>? id,
    Expression<String?>? databaseInstanceId,
    Expression<bool>? isLocal,
    Expression<int>? maxTimeStamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (databaseInstanceId != null)
        'database_instance_id': databaseInstanceId,
      if (isLocal != null) 'is_local': isLocal,
      if (maxTimeStamp != null) 'max_time_stamp': maxTimeStamp,
    });
  }

  KnowledgesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? databaseInstanceId,
      Value<bool>? isLocal,
      Value<int>? maxTimeStamp}) {
    return KnowledgesCompanion(
      id: id ?? this.id,
      databaseInstanceId: databaseInstanceId ?? this.databaseInstanceId,
      isLocal: isLocal ?? this.isLocal,
      maxTimeStamp: maxTimeStamp ?? this.maxTimeStamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (databaseInstanceId.present) {
      map['database_instance_id'] = Variable<String?>(databaseInstanceId.value);
    }
    if (isLocal.present) {
      map['is_local'] = Variable<bool>(isLocal.value);
    }
    if (maxTimeStamp.present) {
      map['max_time_stamp'] = Variable<int>(maxTimeStamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KnowledgesCompanion(')
          ..write('id: $id, ')
          ..write('databaseInstanceId: $databaseInstanceId, ')
          ..write('isLocal: $isLocal, ')
          ..write('maxTimeStamp: $maxTimeStamp')
          ..write(')'))
        .toString();
  }
}

class $KnowledgesTable extends Knowledges
    with TableInfo<$KnowledgesTable, Knowledge> {
  final GeneratedDatabase _db;
  final String? _alias;
  $KnowledgesTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String?> id = GeneratedColumn<String?>(
      'id', aliasedName, false,
      typeName: 'TEXT',
      requiredDuringInsert: false,
      clientDefault: () => Uuid().v4());
  final VerificationMeta _databaseInstanceIdMeta =
      const VerificationMeta('databaseInstanceId');
  late final GeneratedColumn<String?> databaseInstanceId =
      GeneratedColumn<String?>('database_instance_id', aliasedName, true,
          additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
          typeName: 'TEXT',
          requiredDuringInsert: false);
  final VerificationMeta _isLocalMeta = const VerificationMeta('isLocal');
  late final GeneratedColumn<bool?> isLocal = GeneratedColumn<bool?>(
      'is_local', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (is_local IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _maxTimeStampMeta =
      const VerificationMeta('maxTimeStamp');
  late final GeneratedColumn<int?> maxTimeStamp = GeneratedColumn<int?>(
      'max_time_stamp', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, databaseInstanceId, isLocal, maxTimeStamp];
  @override
  String get aliasedName => _alias ?? 'knowledge';
  @override
  String get actualTableName => 'knowledge';
  @override
  VerificationContext validateIntegrity(Insertable<Knowledge> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('database_instance_id')) {
      context.handle(
          _databaseInstanceIdMeta,
          databaseInstanceId.isAcceptableOrUnknown(
              data['database_instance_id']!, _databaseInstanceIdMeta));
    }
    if (data.containsKey('is_local')) {
      context.handle(_isLocalMeta,
          isLocal.isAcceptableOrUnknown(data['is_local']!, _isLocalMeta));
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
  $KnowledgesTable createAlias(String alias) {
    return $KnowledgesTable(_db, alias);
  }
}

class TimeStamp extends DataClass implements Insertable<TimeStamp> {
  final String id;
  final int counter;
  TimeStamp({required this.id, required this.counter});
  factory TimeStamp.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return TimeStamp(
      id: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      counter: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}counter'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['counter'] = Variable<int>(counter);
    return map;
  }

  TimeStampsCompanion toCompanion(bool nullToAbsent) {
    return TimeStampsCompanion(
      id: Value(id),
      counter: Value(counter),
    );
  }

  factory TimeStamp.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return TimeStamp(
      id: serializer.fromJson<String>(json['id']),
      counter: serializer.fromJson<int>(json['counter']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'counter': serializer.toJson<int>(counter),
    };
  }

  TimeStamp copyWith({String? id, int? counter}) => TimeStamp(
        id: id ?? this.id,
        counter: counter ?? this.counter,
      );
  @override
  String toString() {
    return (StringBuffer('TimeStamp(')
          ..write('id: $id, ')
          ..write('counter: $counter')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(id.hashCode, counter.hashCode));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimeStamp &&
          other.id == this.id &&
          other.counter == this.counter);
}

class TimeStampsCompanion extends UpdateCompanion<TimeStamp> {
  final Value<String> id;
  final Value<int> counter;
  const TimeStampsCompanion({
    this.id = const Value.absent(),
    this.counter = const Value.absent(),
  });
  TimeStampsCompanion.insert({
    this.id = const Value.absent(),
    this.counter = const Value.absent(),
  });
  static Insertable<TimeStamp> custom({
    Expression<String>? id,
    Expression<int>? counter,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (counter != null) 'counter': counter,
    });
  }

  TimeStampsCompanion copyWith({Value<String>? id, Value<int>? counter}) {
    return TimeStampsCompanion(
      id: id ?? this.id,
      counter: counter ?? this.counter,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (counter.present) {
      map['counter'] = Variable<int>(counter.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimeStampsCompanion(')
          ..write('id: $id, ')
          ..write('counter: $counter')
          ..write(')'))
        .toString();
  }
}

class $TimeStampsTable extends TimeStamps
    with TableInfo<$TimeStampsTable, TimeStamp> {
  final GeneratedDatabase _db;
  final String? _alias;
  $TimeStampsTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String?> id = GeneratedColumn<String?>(
      'id', aliasedName, false,
      typeName: 'TEXT',
      requiredDuringInsert: false,
      clientDefault: () => Uuid().v4());
  final VerificationMeta _counterMeta = const VerificationMeta('counter');
  late final GeneratedColumn<int?> counter = GeneratedColumn<int?>(
      'counter', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [id, counter];
  @override
  String get aliasedName => _alias ?? 'timestamp';
  @override
  String get actualTableName => 'timestamp';
  @override
  VerificationContext validateIntegrity(Insertable<TimeStamp> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('counter')) {
      context.handle(_counterMeta,
          counter.isAcceptableOrUnknown(data['counter']!, _counterMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimeStamp map(Map<String, dynamic> data, {String? tablePrefix}) {
    return TimeStamp.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $TimeStampsTable createAlias(String alias) {
    return $TimeStampsTable(_db, alias);
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

class Concept extends DataClass implements Insertable<Concept> {
  final String id;
  final String fieldString;
  final String? fieldStringNullable;
  final int fieldInt;
  final int? fieldIntNullable;
  final bool fieldBoolean;
  final bool? fieldBooleanNullable;
  final DateTime fieldDateTime;
  final DateTime? fieldDateTimeNullable;
  Concept(
      {required this.id,
      required this.fieldString,
      this.fieldStringNullable,
      required this.fieldInt,
      this.fieldIntNullable,
      required this.fieldBoolean,
      this.fieldBooleanNullable,
      required this.fieldDateTime,
      this.fieldDateTimeNullable});
  factory Concept.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Concept(
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
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['field_string'] = Variable<String>(fieldString);
    if (!nullToAbsent || fieldStringNullable != null) {
      map['field_string_nullable'] = Variable<String?>(fieldStringNullable);
    }
    map['field_int'] = Variable<int>(fieldInt);
    if (!nullToAbsent || fieldIntNullable != null) {
      map['field_int_nullable'] = Variable<int?>(fieldIntNullable);
    }
    map['field_boolean'] = Variable<bool>(fieldBoolean);
    if (!nullToAbsent || fieldBooleanNullable != null) {
      map['field_boolean_nullable'] = Variable<bool?>(fieldBooleanNullable);
    }
    map['field_date_time'] = Variable<DateTime>(fieldDateTime);
    if (!nullToAbsent || fieldDateTimeNullable != null) {
      map['field_date_time_nullable'] =
          Variable<DateTime?>(fieldDateTimeNullable);
    }
    return map;
  }

  ConceptsCompanion toCompanion(bool nullToAbsent) {
    return ConceptsCompanion(
      id: Value(id),
      fieldString: Value(fieldString),
      fieldStringNullable: fieldStringNullable == null && nullToAbsent
          ? const Value.absent()
          : Value(fieldStringNullable),
      fieldInt: Value(fieldInt),
      fieldIntNullable: fieldIntNullable == null && nullToAbsent
          ? const Value.absent()
          : Value(fieldIntNullable),
      fieldBoolean: Value(fieldBoolean),
      fieldBooleanNullable: fieldBooleanNullable == null && nullToAbsent
          ? const Value.absent()
          : Value(fieldBooleanNullable),
      fieldDateTime: Value(fieldDateTime),
      fieldDateTimeNullable: fieldDateTimeNullable == null && nullToAbsent
          ? const Value.absent()
          : Value(fieldDateTimeNullable),
    );
  }

  factory Concept.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Concept(
      id: serializer.fromJson<String>(json['id']),
      fieldString: serializer.fromJson<String>(json['fieldString']),
      fieldStringNullable:
          serializer.fromJson<String?>(json['fieldStringNullable']),
      fieldInt: serializer.fromJson<int>(json['fieldInt']),
      fieldIntNullable: serializer.fromJson<int?>(json['fieldIntNullable']),
      fieldBoolean: serializer.fromJson<bool>(json['fieldBoolean']),
      fieldBooleanNullable:
          serializer.fromJson<bool?>(json['fieldBooleanNullable']),
      fieldDateTime: serializer.fromJson<DateTime>(json['fieldDateTime']),
      fieldDateTimeNullable:
          serializer.fromJson<DateTime?>(json['fieldDateTimeNullable']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fieldString': serializer.toJson<String>(fieldString),
      'fieldStringNullable': serializer.toJson<String?>(fieldStringNullable),
      'fieldInt': serializer.toJson<int>(fieldInt),
      'fieldIntNullable': serializer.toJson<int?>(fieldIntNullable),
      'fieldBoolean': serializer.toJson<bool>(fieldBoolean),
      'fieldBooleanNullable': serializer.toJson<bool?>(fieldBooleanNullable),
      'fieldDateTime': serializer.toJson<DateTime>(fieldDateTime),
      'fieldDateTimeNullable':
          serializer.toJson<DateTime?>(fieldDateTimeNullable),
    };
  }

  Concept copyWith(
          {String? id,
          String? fieldString,
          String? fieldStringNullable,
          int? fieldInt,
          int? fieldIntNullable,
          bool? fieldBoolean,
          bool? fieldBooleanNullable,
          DateTime? fieldDateTime,
          DateTime? fieldDateTimeNullable}) =>
      Concept(
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
      );
  @override
  String toString() {
    return (StringBuffer('Concept(')
          ..write('id: $id, ')
          ..write('fieldString: $fieldString, ')
          ..write('fieldStringNullable: $fieldStringNullable, ')
          ..write('fieldInt: $fieldInt, ')
          ..write('fieldIntNullable: $fieldIntNullable, ')
          ..write('fieldBoolean: $fieldBoolean, ')
          ..write('fieldBooleanNullable: $fieldBooleanNullable, ')
          ..write('fieldDateTime: $fieldDateTime, ')
          ..write('fieldDateTimeNullable: $fieldDateTimeNullable')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          fieldString.hashCode,
          $mrjc(
              fieldStringNullable.hashCode,
              $mrjc(
                  fieldInt.hashCode,
                  $mrjc(
                      fieldIntNullable.hashCode,
                      $mrjc(
                          fieldBoolean.hashCode,
                          $mrjc(
                              fieldBooleanNullable.hashCode,
                              $mrjc(fieldDateTime.hashCode,
                                  fieldDateTimeNullable.hashCode)))))))));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Concept &&
          other.id == this.id &&
          other.fieldString == this.fieldString &&
          other.fieldStringNullable == this.fieldStringNullable &&
          other.fieldInt == this.fieldInt &&
          other.fieldIntNullable == this.fieldIntNullable &&
          other.fieldBoolean == this.fieldBoolean &&
          other.fieldBooleanNullable == this.fieldBooleanNullable &&
          other.fieldDateTime == this.fieldDateTime &&
          other.fieldDateTimeNullable == this.fieldDateTimeNullable);
}

class ConceptsCompanion extends UpdateCompanion<Concept> {
  final Value<String> id;
  final Value<String> fieldString;
  final Value<String?> fieldStringNullable;
  final Value<int> fieldInt;
  final Value<int?> fieldIntNullable;
  final Value<bool> fieldBoolean;
  final Value<bool?> fieldBooleanNullable;
  final Value<DateTime> fieldDateTime;
  final Value<DateTime?> fieldDateTimeNullable;
  const ConceptsCompanion({
    this.id = const Value.absent(),
    this.fieldString = const Value.absent(),
    this.fieldStringNullable = const Value.absent(),
    this.fieldInt = const Value.absent(),
    this.fieldIntNullable = const Value.absent(),
    this.fieldBoolean = const Value.absent(),
    this.fieldBooleanNullable = const Value.absent(),
    this.fieldDateTime = const Value.absent(),
    this.fieldDateTimeNullable = const Value.absent(),
  });
  ConceptsCompanion.insert({
    this.id = const Value.absent(),
    this.fieldString = const Value.absent(),
    this.fieldStringNullable = const Value.absent(),
    this.fieldInt = const Value.absent(),
    this.fieldIntNullable = const Value.absent(),
    this.fieldBoolean = const Value.absent(),
    this.fieldBooleanNullable = const Value.absent(),
    this.fieldDateTime = const Value.absent(),
    this.fieldDateTimeNullable = const Value.absent(),
  });
  static Insertable<Concept> custom({
    Expression<String>? id,
    Expression<String>? fieldString,
    Expression<String?>? fieldStringNullable,
    Expression<int>? fieldInt,
    Expression<int?>? fieldIntNullable,
    Expression<bool>? fieldBoolean,
    Expression<bool?>? fieldBooleanNullable,
    Expression<DateTime>? fieldDateTime,
    Expression<DateTime?>? fieldDateTimeNullable,
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
    });
  }

  ConceptsCompanion copyWith(
      {Value<String>? id,
      Value<String>? fieldString,
      Value<String?>? fieldStringNullable,
      Value<int>? fieldInt,
      Value<int?>? fieldIntNullable,
      Value<bool>? fieldBoolean,
      Value<bool?>? fieldBooleanNullable,
      Value<DateTime>? fieldDateTime,
      Value<DateTime?>? fieldDateTimeNullable}) {
    return ConceptsCompanion(
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConceptsCompanion(')
          ..write('id: $id, ')
          ..write('fieldString: $fieldString, ')
          ..write('fieldStringNullable: $fieldStringNullable, ')
          ..write('fieldInt: $fieldInt, ')
          ..write('fieldIntNullable: $fieldIntNullable, ')
          ..write('fieldBoolean: $fieldBoolean, ')
          ..write('fieldBooleanNullable: $fieldBooleanNullable, ')
          ..write('fieldDateTime: $fieldDateTime, ')
          ..write('fieldDateTimeNullable: $fieldDateTimeNullable')
          ..write(')'))
        .toString();
  }
}

class $ConceptsTable extends Concepts with TableInfo<$ConceptsTable, Concept> {
  final GeneratedDatabase _db;
  final String? _alias;
  $ConceptsTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String?> id = GeneratedColumn<String?>(
      'id', aliasedName, false,
      typeName: 'TEXT',
      requiredDuringInsert: false,
      clientDefault: () => Uuid().v4());
  final VerificationMeta _fieldStringMeta =
      const VerificationMeta('fieldString');
  late final GeneratedColumn<String?> fieldString = GeneratedColumn<String?>(
      'field_string', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
      typeName: 'TEXT',
      requiredDuringInsert: false,
      defaultValue: const Constant(""));
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
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
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
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (field_boolean IN (0, 1))',
      defaultValue: const Constant(false));
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
          typeName: 'INTEGER',
          requiredDuringInsert: false,
          defaultValue: Constant(DateTime(0)));
  final VerificationMeta _fieldDateTimeNullableMeta =
      const VerificationMeta('fieldDateTimeNullable');
  late final GeneratedColumn<DateTime?> fieldDateTimeNullable =
      GeneratedColumn<DateTime?>('field_date_time_nullable', aliasedName, true,
          typeName: 'INTEGER', requiredDuringInsert: false);
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
        fieldDateTimeNullable
      ];
  @override
  String get aliasedName => _alias ?? 'concept';
  @override
  String get actualTableName => 'concept';
  @override
  VerificationContext validateIntegrity(Insertable<Concept> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('field_string')) {
      context.handle(
          _fieldStringMeta,
          fieldString.isAcceptableOrUnknown(
              data['field_string']!, _fieldStringMeta));
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
    }
    if (data.containsKey('field_date_time_nullable')) {
      context.handle(
          _fieldDateTimeNullableMeta,
          fieldDateTimeNullable.isAcceptableOrUnknown(
              data['field_date_time_nullable']!, _fieldDateTimeNullableMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Concept map(Map<String, dynamic> data, {String? tablePrefix}) {
    return Concept.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $ConceptsTable createAlias(String alias) {
    return $ConceptsTable(_db, alias);
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $EmployeesTable employees = $EmployeesTable(this);
  late final $DepartmentsTable departments = $DepartmentsTable(this);
  late final $KnowledgesTable knowledges = $KnowledgesTable(this);
  late final $TimeStampsTable timeStamps = $TimeStampsTable(this);
  late final $ConfigurationsTable configurations = $ConfigurationsTable(this);
  late final $ConceptsTable concepts = $ConceptsTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        employees,
        departments,
        knowledges,
        timeStamps,
        configurations,
        concepts
      ];
}
