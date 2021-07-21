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
  final int timeStamp;
  final bool deleted;
  final String? knowledgeId;
  Employee(
      {required this.id,
      this.name,
      required this.birthday,
      required this.numberOfComputers,
      required this.savingAmount,
      required this.isActive,
      this.departmentId,
      required this.timeStamp,
      required this.deleted,
      this.knowledgeId});
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
      timeStamp: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}time_stamp'])!,
      deleted: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}deleted'])!,
      knowledgeId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}knowledge_id']),
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
    map['time_stamp'] = Variable<int>(timeStamp);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || knowledgeId != null) {
      map['knowledge_id'] = Variable<String?>(knowledgeId);
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
      timeStamp: Value(timeStamp),
      deleted: Value(deleted),
      knowledgeId: knowledgeId == null && nullToAbsent
          ? const Value.absent()
          : Value(knowledgeId),
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
      timeStamp: serializer.fromJson<int>(json['timeStamp']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      knowledgeId: serializer.fromJson<String?>(json['knowledgeId']),
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
      'timeStamp': serializer.toJson<int>(timeStamp),
      'deleted': serializer.toJson<bool>(deleted),
      'knowledgeId': serializer.toJson<String?>(knowledgeId),
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
          int? timeStamp,
          bool? deleted,
          String? knowledgeId}) =>
      Employee(
        id: id ?? this.id,
        name: name ?? this.name,
        birthday: birthday ?? this.birthday,
        numberOfComputers: numberOfComputers ?? this.numberOfComputers,
        savingAmount: savingAmount ?? this.savingAmount,
        isActive: isActive ?? this.isActive,
        departmentId: departmentId ?? this.departmentId,
        timeStamp: timeStamp ?? this.timeStamp,
        deleted: deleted ?? this.deleted,
        knowledgeId: knowledgeId ?? this.knowledgeId,
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
          ..write('timeStamp: $timeStamp, ')
          ..write('deleted: $deleted, ')
          ..write('knowledgeId: $knowledgeId')
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
                                  timeStamp.hashCode,
                                  $mrjc(deleted.hashCode,
                                      knowledgeId.hashCode))))))))));
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
          other.timeStamp == this.timeStamp &&
          other.deleted == this.deleted &&
          other.knowledgeId == this.knowledgeId);
}

class EmployeesCompanion extends UpdateCompanion<Employee> {
  final Value<String> id;
  final Value<String?> name;
  final Value<DateTime> birthday;
  final Value<int> numberOfComputers;
  final Value<int> savingAmount;
  final Value<bool> isActive;
  final Value<String?> departmentId;
  final Value<int> timeStamp;
  final Value<bool> deleted;
  final Value<String?> knowledgeId;
  const EmployeesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthday = const Value.absent(),
    this.numberOfComputers = const Value.absent(),
    this.savingAmount = const Value.absent(),
    this.isActive = const Value.absent(),
    this.departmentId = const Value.absent(),
    this.timeStamp = const Value.absent(),
    this.deleted = const Value.absent(),
    this.knowledgeId = const Value.absent(),
  });
  EmployeesCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthday = const Value.absent(),
    this.numberOfComputers = const Value.absent(),
    this.savingAmount = const Value.absent(),
    this.isActive = const Value.absent(),
    this.departmentId = const Value.absent(),
    this.timeStamp = const Value.absent(),
    this.deleted = const Value.absent(),
    this.knowledgeId = const Value.absent(),
  });
  static Insertable<Employee> custom({
    Expression<String>? id,
    Expression<String?>? name,
    Expression<DateTime>? birthday,
    Expression<int>? numberOfComputers,
    Expression<int>? savingAmount,
    Expression<bool>? isActive,
    Expression<String?>? departmentId,
    Expression<int>? timeStamp,
    Expression<bool>? deleted,
    Expression<String?>? knowledgeId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (birthday != null) 'birthday': birthday,
      if (numberOfComputers != null) 'number_of_computers': numberOfComputers,
      if (savingAmount != null) 'saving_amount': savingAmount,
      if (isActive != null) 'is_active': isActive,
      if (departmentId != null) 'department_id': departmentId,
      if (timeStamp != null) 'time_stamp': timeStamp,
      if (deleted != null) 'deleted': deleted,
      if (knowledgeId != null) 'knowledge_id': knowledgeId,
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
      Value<int>? timeStamp,
      Value<bool>? deleted,
      Value<String?>? knowledgeId}) {
    return EmployeesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      numberOfComputers: numberOfComputers ?? this.numberOfComputers,
      savingAmount: savingAmount ?? this.savingAmount,
      isActive: isActive ?? this.isActive,
      departmentId: departmentId ?? this.departmentId,
      timeStamp: timeStamp ?? this.timeStamp,
      deleted: deleted ?? this.deleted,
      knowledgeId: knowledgeId ?? this.knowledgeId,
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
    if (timeStamp.present) {
      map['time_stamp'] = Variable<int>(timeStamp.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (knowledgeId.present) {
      map['knowledge_id'] = Variable<String?>(knowledgeId.value);
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
          ..write('timeStamp: $timeStamp, ')
          ..write('deleted: $deleted, ')
          ..write('knowledgeId: $knowledgeId')
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
  final VerificationMeta _timeStampMeta = const VerificationMeta('timeStamp');
  late final GeneratedColumn<int?> timeStamp = GeneratedColumn<int?>(
      'time_stamp', aliasedName, false,
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
  final VerificationMeta _knowledgeIdMeta =
      const VerificationMeta('knowledgeId');
  late final GeneratedColumn<String?> knowledgeId = GeneratedColumn<String?>(
      'knowledge_id', aliasedName, true,
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
        timeStamp,
        deleted,
        knowledgeId
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
    if (data.containsKey('time_stamp')) {
      context.handle(_timeStampMeta,
          timeStamp.isAcceptableOrUnknown(data['time_stamp']!, _timeStampMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('knowledge_id')) {
      context.handle(
          _knowledgeIdMeta,
          knowledgeId.isAcceptableOrUnknown(
              data['knowledge_id']!, _knowledgeIdMeta));
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
  final int timeStamp;
  final bool deleted;
  final String? knowledgeId;
  Department(
      {required this.id,
      this.name,
      required this.timeStamp,
      required this.deleted,
      this.knowledgeId});
  factory Department.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Department(
      id: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name']),
      timeStamp: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}time_stamp'])!,
      deleted: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}deleted'])!,
      knowledgeId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}knowledge_id']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String?>(name);
    }
    map['time_stamp'] = Variable<int>(timeStamp);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || knowledgeId != null) {
      map['knowledge_id'] = Variable<String?>(knowledgeId);
    }
    return map;
  }

  DepartmentsCompanion toCompanion(bool nullToAbsent) {
    return DepartmentsCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      timeStamp: Value(timeStamp),
      deleted: Value(deleted),
      knowledgeId: knowledgeId == null && nullToAbsent
          ? const Value.absent()
          : Value(knowledgeId),
    );
  }

  factory Department.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Department(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      timeStamp: serializer.fromJson<int>(json['timeStamp']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      knowledgeId: serializer.fromJson<String?>(json['knowledgeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String?>(name),
      'timeStamp': serializer.toJson<int>(timeStamp),
      'deleted': serializer.toJson<bool>(deleted),
      'knowledgeId': serializer.toJson<String?>(knowledgeId),
    };
  }

  Department copyWith(
          {String? id,
          String? name,
          int? timeStamp,
          bool? deleted,
          String? knowledgeId}) =>
      Department(
        id: id ?? this.id,
        name: name ?? this.name,
        timeStamp: timeStamp ?? this.timeStamp,
        deleted: deleted ?? this.deleted,
        knowledgeId: knowledgeId ?? this.knowledgeId,
      );
  @override
  String toString() {
    return (StringBuffer('Department(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('timeStamp: $timeStamp, ')
          ..write('deleted: $deleted, ')
          ..write('knowledgeId: $knowledgeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          name.hashCode,
          $mrjc(timeStamp.hashCode,
              $mrjc(deleted.hashCode, knowledgeId.hashCode)))));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Department &&
          other.id == this.id &&
          other.name == this.name &&
          other.timeStamp == this.timeStamp &&
          other.deleted == this.deleted &&
          other.knowledgeId == this.knowledgeId);
}

class DepartmentsCompanion extends UpdateCompanion<Department> {
  final Value<String> id;
  final Value<String?> name;
  final Value<int> timeStamp;
  final Value<bool> deleted;
  final Value<String?> knowledgeId;
  const DepartmentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.timeStamp = const Value.absent(),
    this.deleted = const Value.absent(),
    this.knowledgeId = const Value.absent(),
  });
  DepartmentsCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.timeStamp = const Value.absent(),
    this.deleted = const Value.absent(),
    this.knowledgeId = const Value.absent(),
  });
  static Insertable<Department> custom({
    Expression<String>? id,
    Expression<String?>? name,
    Expression<int>? timeStamp,
    Expression<bool>? deleted,
    Expression<String?>? knowledgeId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (timeStamp != null) 'time_stamp': timeStamp,
      if (deleted != null) 'deleted': deleted,
      if (knowledgeId != null) 'knowledge_id': knowledgeId,
    });
  }

  DepartmentsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? name,
      Value<int>? timeStamp,
      Value<bool>? deleted,
      Value<String?>? knowledgeId}) {
    return DepartmentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      timeStamp: timeStamp ?? this.timeStamp,
      deleted: deleted ?? this.deleted,
      knowledgeId: knowledgeId ?? this.knowledgeId,
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
    if (timeStamp.present) {
      map['time_stamp'] = Variable<int>(timeStamp.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (knowledgeId.present) {
      map['knowledge_id'] = Variable<String?>(knowledgeId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DepartmentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('timeStamp: $timeStamp, ')
          ..write('deleted: $deleted, ')
          ..write('knowledgeId: $knowledgeId')
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
  final VerificationMeta _timeStampMeta = const VerificationMeta('timeStamp');
  late final GeneratedColumn<int?> timeStamp = GeneratedColumn<int?>(
      'time_stamp', aliasedName, false,
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
  final VerificationMeta _knowledgeIdMeta =
      const VerificationMeta('knowledgeId');
  late final GeneratedColumn<String?> knowledgeId = GeneratedColumn<String?>(
      'knowledge_id', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
      typeName: 'TEXT',
      requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, timeStamp, deleted, knowledgeId];
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
    if (data.containsKey('time_stamp')) {
      context.handle(_timeStampMeta,
          timeStamp.isAcceptableOrUnknown(data['time_stamp']!, _timeStampMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('knowledge_id')) {
      context.handle(
          _knowledgeIdMeta,
          knowledgeId.isAcceptableOrUnknown(
              data['knowledge_id']!, _knowledgeIdMeta));
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
  final Value<bool> local;
  final Value<int> maxTimeStamp;
  const NetCoreSyncKnowledgesCompanion({
    this.id = const Value.absent(),
    this.local = const Value.absent(),
    this.maxTimeStamp = const Value.absent(),
  });
  NetCoreSyncKnowledgesCompanion.insert({
    required String id,
    required bool local,
    required int maxTimeStamp,
  })  : id = Value(id),
        local = Value(local),
        maxTimeStamp = Value(maxTimeStamp);
  static Insertable<NetCoreSyncKnowledge> custom({
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
  final VerificationMeta _localMeta = const VerificationMeta('local');
  late final GeneratedColumn<bool?> local = GeneratedColumn<bool?>(
      'local', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: true,
      defaultConstraints: 'CHECK (local IN (0, 1))');
  final VerificationMeta _maxTimeStampMeta =
      const VerificationMeta('maxTimeStamp');
  late final GeneratedColumn<int?> maxTimeStamp = GeneratedColumn<int?>(
      'max_time_stamp', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, local, maxTimeStamp];
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
    if (data.containsKey('local')) {
      context.handle(
          _localMeta, local.isAcceptableOrUnknown(data['local']!, _localMeta));
    } else if (isInserting) {
      context.missing(_localMeta);
    }
    if (data.containsKey('max_time_stamp')) {
      context.handle(
          _maxTimeStampMeta,
          maxTimeStamp.isAcceptableOrUnknown(
              data['max_time_stamp']!, _maxTimeStampMeta));
    } else if (isInserting) {
      context.missing(_maxTimeStampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NetCoreSyncKnowledge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NetCoreSyncKnowledge.fromDb(
      id: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      local: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}local'])!,
      maxTimeStamp: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}max_time_stamp'])!,
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
// Employees: {"tableClassName":"Employees","dataClassName":"Employee","useRowClass":false,"netCoreSyncTable":{"mapToClassName":"SyncEmployee","idFieldName":"id","timeStampFieldName":"timeStamp","deletedFieldName":"deleted","knowledgeIdFieldName":"knowledgeId"}}
// Departments: {"tableClassName":"Departments","dataClassName":"Department","useRowClass":false,"netCoreSyncTable":{"mapToClassName":"SyncDepartment","idFieldName":"id","timeStampFieldName":"timeStamp","deletedFieldName":"deleted","knowledgeIdFieldName":"knowledgeId"}}

class _$NetCoreSyncEngineUser extends NetCoreSyncEngine {
  _$NetCoreSyncEngineUser(Map<Type, NetCoreSyncTableUser> tables)
      : super(tables);

  @override
  Object? getSyncColumnValue<D>(Insertable<D> entity, String fieldName) {
    if (entity is UpdateCompanion<D>) {
      if (D == Employee) {
        switch (fieldName) {
          case "id":
            return (entity as EmployeesCompanion).id == Value.absent()
                ? null
                : (entity as EmployeesCompanion).id.value;
          case "timeStamp":
            return (entity as EmployeesCompanion).timeStamp == Value.absent()
                ? null
                : (entity as EmployeesCompanion).timeStamp.value;
          case "deleted":
            return (entity as EmployeesCompanion).deleted == Value.absent()
                ? null
                : (entity as EmployeesCompanion).deleted.value;
          case "knowledgeId":
            return (entity as EmployeesCompanion).knowledgeId == Value.absent()
                ? null
                : (entity as EmployeesCompanion).knowledgeId.value;
        }
      }
      if (D == Department) {
        switch (fieldName) {
          case "id":
            return (entity as DepartmentsCompanion).id == Value.absent()
                ? null
                : (entity as DepartmentsCompanion).id.value;
          case "timeStamp":
            return (entity as DepartmentsCompanion).timeStamp == Value.absent()
                ? null
                : (entity as DepartmentsCompanion).timeStamp.value;
          case "deleted":
            return (entity as DepartmentsCompanion).deleted == Value.absent()
                ? null
                : (entity as DepartmentsCompanion).deleted.value;
          case "knowledgeId":
            return (entity as DepartmentsCompanion).knowledgeId ==
                    Value.absent()
                ? null
                : (entity as DepartmentsCompanion).knowledgeId.value;
        }
      }
    } else {
      if (entity is Employee) {
        switch (fieldName) {
          case "id":
            return (entity as Employee).id;
          case "timeStamp":
            return (entity as Employee).timeStamp;
          case "deleted":
            return (entity as Employee).deleted;
          case "knowledgeId":
            return (entity as Employee).knowledgeId;
        }
      }
      if (entity is Department) {
        switch (fieldName) {
          case "id":
            return (entity as Department).id;
          case "timeStamp":
            return (entity as Department).timeStamp;
          case "deleted":
            return (entity as Department).deleted;
          case "knowledgeId":
            return (entity as Department).knowledgeId;
        }
      }
    }
    throw NetCoreSyncException(
        "Unexpected entity Type: $entity, fieldName: $fieldName");
  }

  @override
  Insertable<D> updateSyncColumns<D>(
    Insertable<D> entity, {
    required int timeStamp,
    bool? deleted,
  }) {
    if (entity is RawValuesInsertable<D>) {
      entity.data[tables[D]!.timeStampEscapedName] = Constant(timeStamp);
      entity.data[tables[D]!.knowledgeIdEscapedName] = Constant(null);
      if (deleted != null)
        entity.data[tables[D]!.deletedEscapedName] = Constant(deleted);
      return entity;
    } else if (entity is UpdateCompanion<D>) {
      if (D == Employee) {
        return (entity as EmployeesCompanion).copyWith(
          timeStamp: Value(timeStamp),
          knowledgeId: Value(null),
          deleted: deleted != null ? Value(deleted) : Value.absent(),
        ) as Insertable<D>;
      }
      if (D == Department) {
        return (entity as DepartmentsCompanion).copyWith(
          timeStamp: Value(timeStamp),
          knowledgeId: Value(null),
          deleted: deleted != null ? Value(deleted) : Value.absent(),
        ) as Insertable<D>;
      }
    } else if (entity is DataClass) {
      if (entity is Employee) {
        return (entity as Employee).copyWith(
          timeStamp: timeStamp,
          knowledgeId: null,
          deleted: deleted,
        ) as Insertable<D>;
      }
      if (entity is Department) {
        return (entity as Department).copyWith(
          timeStamp: timeStamp,
          knowledgeId: null,
          deleted: deleted,
        ) as Insertable<D>;
      }
    } else {}
    throw NetCoreSyncException("Unexpected entity Type: $entity");
  }
}

extension $NetCoreSyncClientExtension on Database {
  Future<void> netCoreSync_initialize() async {
    await netCoreSync_initializeClient(
      _$NetCoreSyncEngineUser(
        {
          Employee: NetCoreSyncTableUser(
            employees,
            NetCoreSyncTable.fromJson({
              "mapToClassName": "SyncEmployee",
              "idFieldName": "id",
              "timeStampFieldName": "timeStamp",
              "deletedFieldName": "deleted",
              "knowledgeIdFieldName": "knowledgeId"
            }),
            employees.id.escapedName,
            employees.timeStamp.escapedName,
            employees.deleted.escapedName,
            employees.knowledgeId.escapedName,
          ),
          Department: NetCoreSyncTableUser(
            departments,
            NetCoreSyncTable.fromJson({
              "mapToClassName": "SyncDepartment",
              "idFieldName": "id",
              "timeStampFieldName": "timeStamp",
              "deletedFieldName": "deleted",
              "knowledgeIdFieldName": "knowledgeId"
            }),
            departments.id.escapedName,
            departments.timeStamp.escapedName,
            departments.deleted.escapedName,
            departments.knowledgeId.escapedName,
          ),
        },
      ),
    );
    netCoreSync_initializeUser();
  }
}

class $SyncEmployeesTable extends $EmployeesTable implements SyncBaseTable {
  $SyncEmployeesTable(_$Database db) : super(db);
  @override
  Type get type => Employee;
  @override
  String get entityName =>
      "(SELECT * FROM ${super.entityName} WHERE ${super.deleted.escapedName} = 0)";
}

class $SyncDepartmentsTable extends $DepartmentsTable implements SyncBaseTable {
  $SyncDepartmentsTable(_$Database db) : super(db);
  @override
  Type get type => Department;
  @override
  String get entityName =>
      "(SELECT * FROM ${super.entityName} WHERE ${super.deleted.escapedName} = 0)";
}

mixin NetCoreSyncClientUser on NetCoreSyncClient {
  late $SyncEmployeesTable syncEmployees;
  late $SyncDepartmentsTable syncDepartments;

  void netCoreSync_initializeUser() {
    syncEmployees = $SyncEmployeesTable(resolvedEngine);
    syncDepartments = $SyncDepartmentsTable(resolvedEngine);
  }
}
