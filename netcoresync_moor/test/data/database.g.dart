// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class AreaData extends DataClass implements Insertable<AreaData> {
  final String pk;
  final String city;
  final String district;
  final int syncTimeStamp;
  final bool syncDeleted;
  final String? syncKnowledgeId;
  AreaData(
      {required this.pk,
      required this.city,
      required this.district,
      required this.syncTimeStamp,
      required this.syncDeleted,
      this.syncKnowledgeId});
  factory AreaData.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return AreaData(
      pk: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}pk'])!,
      city: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}city'])!,
      district: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}district'])!,
      syncTimeStamp: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}sync_time_stamp'])!,
      syncDeleted: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}sync_deleted'])!,
      syncKnowledgeId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}sync_knowledge_id']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pk'] = Variable<String>(pk);
    map['city'] = Variable<String>(city);
    map['district'] = Variable<String>(district);
    map['sync_time_stamp'] = Variable<int>(syncTimeStamp);
    map['sync_deleted'] = Variable<bool>(syncDeleted);
    if (!nullToAbsent || syncKnowledgeId != null) {
      map['sync_knowledge_id'] = Variable<String?>(syncKnowledgeId);
    }
    return map;
  }

  AreasCompanion toCompanion(bool nullToAbsent) {
    return AreasCompanion(
      pk: Value(pk),
      city: Value(city),
      district: Value(district),
      syncTimeStamp: Value(syncTimeStamp),
      syncDeleted: Value(syncDeleted),
      syncKnowledgeId: syncKnowledgeId == null && nullToAbsent
          ? const Value.absent()
          : Value(syncKnowledgeId),
    );
  }

  factory AreaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return AreaData(
      pk: serializer.fromJson<String>(json['pk']),
      city: serializer.fromJson<String>(json['city']),
      district: serializer.fromJson<String>(json['district']),
      syncTimeStamp: serializer.fromJson<int>(json['syncTimeStamp']),
      syncDeleted: serializer.fromJson<bool>(json['syncDeleted']),
      syncKnowledgeId: serializer.fromJson<String?>(json['syncKnowledgeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pk': serializer.toJson<String>(pk),
      'city': serializer.toJson<String>(city),
      'district': serializer.toJson<String>(district),
      'syncTimeStamp': serializer.toJson<int>(syncTimeStamp),
      'syncDeleted': serializer.toJson<bool>(syncDeleted),
      'syncKnowledgeId': serializer.toJson<String?>(syncKnowledgeId),
    };
  }

  AreaData copyWith(
          {String? pk,
          String? city,
          String? district,
          int? syncTimeStamp,
          bool? syncDeleted,
          String? syncKnowledgeId}) =>
      AreaData(
        pk: pk ?? this.pk,
        city: city ?? this.city,
        district: district ?? this.district,
        syncTimeStamp: syncTimeStamp ?? this.syncTimeStamp,
        syncDeleted: syncDeleted ?? this.syncDeleted,
        syncKnowledgeId: syncKnowledgeId ?? this.syncKnowledgeId,
      );
  @override
  String toString() {
    return (StringBuffer('AreaData(')
          ..write('pk: $pk, ')
          ..write('city: $city, ')
          ..write('district: $district, ')
          ..write('syncTimeStamp: $syncTimeStamp, ')
          ..write('syncDeleted: $syncDeleted, ')
          ..write('syncKnowledgeId: $syncKnowledgeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      pk.hashCode,
      $mrjc(
          city.hashCode,
          $mrjc(
              district.hashCode,
              $mrjc(syncTimeStamp.hashCode,
                  $mrjc(syncDeleted.hashCode, syncKnowledgeId.hashCode))))));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AreaData &&
          other.pk == this.pk &&
          other.city == this.city &&
          other.district == this.district &&
          other.syncTimeStamp == this.syncTimeStamp &&
          other.syncDeleted == this.syncDeleted &&
          other.syncKnowledgeId == this.syncKnowledgeId);
}

class AreasCompanion extends UpdateCompanion<AreaData> {
  final Value<String> pk;
  final Value<String> city;
  final Value<String> district;
  final Value<int> syncTimeStamp;
  final Value<bool> syncDeleted;
  final Value<String?> syncKnowledgeId;
  const AreasCompanion({
    this.pk = const Value.absent(),
    this.city = const Value.absent(),
    this.district = const Value.absent(),
    this.syncTimeStamp = const Value.absent(),
    this.syncDeleted = const Value.absent(),
    this.syncKnowledgeId = const Value.absent(),
  });
  AreasCompanion.insert({
    this.pk = const Value.absent(),
    this.city = const Value.absent(),
    this.district = const Value.absent(),
    this.syncTimeStamp = const Value.absent(),
    this.syncDeleted = const Value.absent(),
    this.syncKnowledgeId = const Value.absent(),
  });
  static Insertable<AreaData> custom({
    Expression<String>? pk,
    Expression<String>? city,
    Expression<String>? district,
    Expression<int>? syncTimeStamp,
    Expression<bool>? syncDeleted,
    Expression<String?>? syncKnowledgeId,
  }) {
    return RawValuesInsertable({
      if (pk != null) 'pk': pk,
      if (city != null) 'city': city,
      if (district != null) 'district': district,
      if (syncTimeStamp != null) 'sync_time_stamp': syncTimeStamp,
      if (syncDeleted != null) 'sync_deleted': syncDeleted,
      if (syncKnowledgeId != null) 'sync_knowledge_id': syncKnowledgeId,
    });
  }

  AreasCompanion copyWith(
      {Value<String>? pk,
      Value<String>? city,
      Value<String>? district,
      Value<int>? syncTimeStamp,
      Value<bool>? syncDeleted,
      Value<String?>? syncKnowledgeId}) {
    return AreasCompanion(
      pk: pk ?? this.pk,
      city: city ?? this.city,
      district: district ?? this.district,
      syncTimeStamp: syncTimeStamp ?? this.syncTimeStamp,
      syncDeleted: syncDeleted ?? this.syncDeleted,
      syncKnowledgeId: syncKnowledgeId ?? this.syncKnowledgeId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pk.present) {
      map['pk'] = Variable<String>(pk.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (syncTimeStamp.present) {
      map['sync_time_stamp'] = Variable<int>(syncTimeStamp.value);
    }
    if (syncDeleted.present) {
      map['sync_deleted'] = Variable<bool>(syncDeleted.value);
    }
    if (syncKnowledgeId.present) {
      map['sync_knowledge_id'] = Variable<String?>(syncKnowledgeId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AreasCompanion(')
          ..write('pk: $pk, ')
          ..write('city: $city, ')
          ..write('district: $district, ')
          ..write('syncTimeStamp: $syncTimeStamp, ')
          ..write('syncDeleted: $syncDeleted, ')
          ..write('syncKnowledgeId: $syncKnowledgeId')
          ..write(')'))
        .toString();
  }
}

class $AreasTable extends Areas with TableInfo<$AreasTable, AreaData> {
  final GeneratedDatabase _db;
  final String? _alias;
  $AreasTable(this._db, [this._alias]);
  final VerificationMeta _pkMeta = const VerificationMeta('pk');
  late final GeneratedColumn<String?> pk = GeneratedColumn<String?>(
      'pk', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 36),
      typeName: 'TEXT',
      requiredDuringInsert: false,
      clientDefault: () => Uuid().v4());
  final VerificationMeta _cityMeta = const VerificationMeta('city');
  late final GeneratedColumn<String?> city = GeneratedColumn<String?>(
      'city', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
      typeName: 'TEXT',
      requiredDuringInsert: false,
      defaultValue: Constant(""));
  final VerificationMeta _districtMeta = const VerificationMeta('district');
  late final GeneratedColumn<String?> district = GeneratedColumn<String?>(
      'district', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
      typeName: 'TEXT',
      requiredDuringInsert: false,
      defaultValue: Constant(""));
  final VerificationMeta _syncTimeStampMeta =
      const VerificationMeta('syncTimeStamp');
  late final GeneratedColumn<int?> syncTimeStamp = GeneratedColumn<int?>(
      'sync_time_stamp', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  final VerificationMeta _syncDeletedMeta =
      const VerificationMeta('syncDeleted');
  late final GeneratedColumn<bool?> syncDeleted = GeneratedColumn<bool?>(
      'sync_deleted', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (sync_deleted IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _syncKnowledgeIdMeta =
      const VerificationMeta('syncKnowledgeId');
  late final GeneratedColumn<String?> syncKnowledgeId =
      GeneratedColumn<String?>('sync_knowledge_id', aliasedName, true,
          additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
          typeName: 'TEXT',
          requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [pk, city, district, syncTimeStamp, syncDeleted, syncKnowledgeId];
  @override
  String get aliasedName => _alias ?? 'area';
  @override
  String get actualTableName => 'area';
  @override
  VerificationContext validateIntegrity(Insertable<AreaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pk')) {
      context.handle(_pkMeta, pk.isAcceptableOrUnknown(data['pk']!, _pkMeta));
    }
    if (data.containsKey('city')) {
      context.handle(
          _cityMeta, city.isAcceptableOrUnknown(data['city']!, _cityMeta));
    }
    if (data.containsKey('district')) {
      context.handle(_districtMeta,
          district.isAcceptableOrUnknown(data['district']!, _districtMeta));
    }
    if (data.containsKey('sync_time_stamp')) {
      context.handle(
          _syncTimeStampMeta,
          syncTimeStamp.isAcceptableOrUnknown(
              data['sync_time_stamp']!, _syncTimeStampMeta));
    }
    if (data.containsKey('sync_deleted')) {
      context.handle(
          _syncDeletedMeta,
          syncDeleted.isAcceptableOrUnknown(
              data['sync_deleted']!, _syncDeletedMeta));
    }
    if (data.containsKey('sync_knowledge_id')) {
      context.handle(
          _syncKnowledgeIdMeta,
          syncKnowledgeId.isAcceptableOrUnknown(
              data['sync_knowledge_id']!, _syncKnowledgeIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pk};
  @override
  AreaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    return AreaData.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $AreasTable createAlias(String alias) {
    return $AreasTable(_db, alias);
  }
}

class Person extends DataClass implements Insertable<Person> {
  final String id;
  final String name;
  final DateTime birthday;
  final int age;
  final bool isForeigner;
  final bool? isVaccinated;
  final String? vaccineName;
  final DateTime? vaccinationDate;
  final int? vaccinePhase;
  final String? vaccinationAreaPk;
  final int timeStamp;
  final bool deleted;
  final String? knowledgeId;
  Person(
      {required this.id,
      required this.name,
      required this.birthday,
      required this.age,
      required this.isForeigner,
      this.isVaccinated,
      this.vaccineName,
      this.vaccinationDate,
      this.vaccinePhase,
      this.vaccinationAreaPk,
      required this.timeStamp,
      required this.deleted,
      this.knowledgeId});
  factory Person.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Person(
      id: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      birthday: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}birthday'])!,
      age: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}age'])!,
      isForeigner: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}is_foreigner'])!,
      isVaccinated: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}is_vaccinated']),
      vaccineName: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}vaccine_name']),
      vaccinationDate: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}vaccination_date']),
      vaccinePhase: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}vaccine_phase']),
      vaccinationAreaPk: const StringType().mapFromDatabaseResponse(
          data['${effectivePrefix}vaccination_area_pk']),
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
    map['name'] = Variable<String>(name);
    map['birthday'] = Variable<DateTime>(birthday);
    map['age'] = Variable<int>(age);
    map['is_foreigner'] = Variable<bool>(isForeigner);
    if (!nullToAbsent || isVaccinated != null) {
      map['is_vaccinated'] = Variable<bool?>(isVaccinated);
    }
    if (!nullToAbsent || vaccineName != null) {
      map['vaccine_name'] = Variable<String?>(vaccineName);
    }
    if (!nullToAbsent || vaccinationDate != null) {
      map['vaccination_date'] = Variable<DateTime?>(vaccinationDate);
    }
    if (!nullToAbsent || vaccinePhase != null) {
      map['vaccine_phase'] = Variable<int?>(vaccinePhase);
    }
    if (!nullToAbsent || vaccinationAreaPk != null) {
      map['vaccination_area_pk'] = Variable<String?>(vaccinationAreaPk);
    }
    map['time_stamp'] = Variable<int>(timeStamp);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || knowledgeId != null) {
      map['knowledge_id'] = Variable<String?>(knowledgeId);
    }
    return map;
  }

  PersonsCompanion toCompanion(bool nullToAbsent) {
    return PersonsCompanion(
      id: Value(id),
      name: Value(name),
      birthday: Value(birthday),
      age: Value(age),
      isForeigner: Value(isForeigner),
      isVaccinated: isVaccinated == null && nullToAbsent
          ? const Value.absent()
          : Value(isVaccinated),
      vaccineName: vaccineName == null && nullToAbsent
          ? const Value.absent()
          : Value(vaccineName),
      vaccinationDate: vaccinationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(vaccinationDate),
      vaccinePhase: vaccinePhase == null && nullToAbsent
          ? const Value.absent()
          : Value(vaccinePhase),
      vaccinationAreaPk: vaccinationAreaPk == null && nullToAbsent
          ? const Value.absent()
          : Value(vaccinationAreaPk),
      timeStamp: Value(timeStamp),
      deleted: Value(deleted),
      knowledgeId: knowledgeId == null && nullToAbsent
          ? const Value.absent()
          : Value(knowledgeId),
    );
  }

  factory Person.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Person(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      birthday: serializer.fromJson<DateTime>(json['birthday']),
      age: serializer.fromJson<int>(json['age']),
      isForeigner: serializer.fromJson<bool>(json['isForeigner']),
      isVaccinated: serializer.fromJson<bool?>(json['isVaccinated']),
      vaccineName: serializer.fromJson<String?>(json['vaccineName']),
      vaccinationDate: serializer.fromJson<DateTime?>(json['vaccinationDate']),
      vaccinePhase: serializer.fromJson<int?>(json['vaccinePhase']),
      vaccinationAreaPk:
          serializer.fromJson<String?>(json['vaccinationAreaPk']),
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
      'name': serializer.toJson<String>(name),
      'birthday': serializer.toJson<DateTime>(birthday),
      'age': serializer.toJson<int>(age),
      'isForeigner': serializer.toJson<bool>(isForeigner),
      'isVaccinated': serializer.toJson<bool?>(isVaccinated),
      'vaccineName': serializer.toJson<String?>(vaccineName),
      'vaccinationDate': serializer.toJson<DateTime?>(vaccinationDate),
      'vaccinePhase': serializer.toJson<int?>(vaccinePhase),
      'vaccinationAreaPk': serializer.toJson<String?>(vaccinationAreaPk),
      'timeStamp': serializer.toJson<int>(timeStamp),
      'deleted': serializer.toJson<bool>(deleted),
      'knowledgeId': serializer.toJson<String?>(knowledgeId),
    };
  }

  Person copyWith(
          {String? id,
          String? name,
          DateTime? birthday,
          int? age,
          bool? isForeigner,
          bool? isVaccinated,
          String? vaccineName,
          DateTime? vaccinationDate,
          int? vaccinePhase,
          String? vaccinationAreaPk,
          int? timeStamp,
          bool? deleted,
          String? knowledgeId}) =>
      Person(
        id: id ?? this.id,
        name: name ?? this.name,
        birthday: birthday ?? this.birthday,
        age: age ?? this.age,
        isForeigner: isForeigner ?? this.isForeigner,
        isVaccinated: isVaccinated ?? this.isVaccinated,
        vaccineName: vaccineName ?? this.vaccineName,
        vaccinationDate: vaccinationDate ?? this.vaccinationDate,
        vaccinePhase: vaccinePhase ?? this.vaccinePhase,
        vaccinationAreaPk: vaccinationAreaPk ?? this.vaccinationAreaPk,
        timeStamp: timeStamp ?? this.timeStamp,
        deleted: deleted ?? this.deleted,
        knowledgeId: knowledgeId ?? this.knowledgeId,
      );
  @override
  String toString() {
    return (StringBuffer('Person(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthday: $birthday, ')
          ..write('age: $age, ')
          ..write('isForeigner: $isForeigner, ')
          ..write('isVaccinated: $isVaccinated, ')
          ..write('vaccineName: $vaccineName, ')
          ..write('vaccinationDate: $vaccinationDate, ')
          ..write('vaccinePhase: $vaccinePhase, ')
          ..write('vaccinationAreaPk: $vaccinationAreaPk, ')
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
                  age.hashCode,
                  $mrjc(
                      isForeigner.hashCode,
                      $mrjc(
                          isVaccinated.hashCode,
                          $mrjc(
                              vaccineName.hashCode,
                              $mrjc(
                                  vaccinationDate.hashCode,
                                  $mrjc(
                                      vaccinePhase.hashCode,
                                      $mrjc(
                                          vaccinationAreaPk.hashCode,
                                          $mrjc(
                                              timeStamp.hashCode,
                                              $mrjc(
                                                  deleted.hashCode,
                                                  knowledgeId
                                                      .hashCode)))))))))))));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Person &&
          other.id == this.id &&
          other.name == this.name &&
          other.birthday == this.birthday &&
          other.age == this.age &&
          other.isForeigner == this.isForeigner &&
          other.isVaccinated == this.isVaccinated &&
          other.vaccineName == this.vaccineName &&
          other.vaccinationDate == this.vaccinationDate &&
          other.vaccinePhase == this.vaccinePhase &&
          other.vaccinationAreaPk == this.vaccinationAreaPk &&
          other.timeStamp == this.timeStamp &&
          other.deleted == this.deleted &&
          other.knowledgeId == this.knowledgeId);
}

class PersonsCompanion extends UpdateCompanion<Person> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> birthday;
  final Value<int> age;
  final Value<bool> isForeigner;
  final Value<bool?> isVaccinated;
  final Value<String?> vaccineName;
  final Value<DateTime?> vaccinationDate;
  final Value<int?> vaccinePhase;
  final Value<String?> vaccinationAreaPk;
  final Value<int> timeStamp;
  final Value<bool> deleted;
  final Value<String?> knowledgeId;
  const PersonsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthday = const Value.absent(),
    this.age = const Value.absent(),
    this.isForeigner = const Value.absent(),
    this.isVaccinated = const Value.absent(),
    this.vaccineName = const Value.absent(),
    this.vaccinationDate = const Value.absent(),
    this.vaccinePhase = const Value.absent(),
    this.vaccinationAreaPk = const Value.absent(),
    this.timeStamp = const Value.absent(),
    this.deleted = const Value.absent(),
    this.knowledgeId = const Value.absent(),
  });
  PersonsCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthday = const Value.absent(),
    this.age = const Value.absent(),
    this.isForeigner = const Value.absent(),
    this.isVaccinated = const Value.absent(),
    this.vaccineName = const Value.absent(),
    this.vaccinationDate = const Value.absent(),
    this.vaccinePhase = const Value.absent(),
    this.vaccinationAreaPk = const Value.absent(),
    this.timeStamp = const Value.absent(),
    this.deleted = const Value.absent(),
    this.knowledgeId = const Value.absent(),
  });
  static Insertable<Person> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? birthday,
    Expression<int>? age,
    Expression<bool>? isForeigner,
    Expression<bool?>? isVaccinated,
    Expression<String?>? vaccineName,
    Expression<DateTime?>? vaccinationDate,
    Expression<int?>? vaccinePhase,
    Expression<String?>? vaccinationAreaPk,
    Expression<int>? timeStamp,
    Expression<bool>? deleted,
    Expression<String?>? knowledgeId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (birthday != null) 'birthday': birthday,
      if (age != null) 'age': age,
      if (isForeigner != null) 'is_foreigner': isForeigner,
      if (isVaccinated != null) 'is_vaccinated': isVaccinated,
      if (vaccineName != null) 'vaccine_name': vaccineName,
      if (vaccinationDate != null) 'vaccination_date': vaccinationDate,
      if (vaccinePhase != null) 'vaccine_phase': vaccinePhase,
      if (vaccinationAreaPk != null) 'vaccination_area_pk': vaccinationAreaPk,
      if (timeStamp != null) 'time_stamp': timeStamp,
      if (deleted != null) 'deleted': deleted,
      if (knowledgeId != null) 'knowledge_id': knowledgeId,
    });
  }

  PersonsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<DateTime>? birthday,
      Value<int>? age,
      Value<bool>? isForeigner,
      Value<bool?>? isVaccinated,
      Value<String?>? vaccineName,
      Value<DateTime?>? vaccinationDate,
      Value<int?>? vaccinePhase,
      Value<String?>? vaccinationAreaPk,
      Value<int>? timeStamp,
      Value<bool>? deleted,
      Value<String?>? knowledgeId}) {
    return PersonsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      age: age ?? this.age,
      isForeigner: isForeigner ?? this.isForeigner,
      isVaccinated: isVaccinated ?? this.isVaccinated,
      vaccineName: vaccineName ?? this.vaccineName,
      vaccinationDate: vaccinationDate ?? this.vaccinationDate,
      vaccinePhase: vaccinePhase ?? this.vaccinePhase,
      vaccinationAreaPk: vaccinationAreaPk ?? this.vaccinationAreaPk,
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
      map['name'] = Variable<String>(name.value);
    }
    if (birthday.present) {
      map['birthday'] = Variable<DateTime>(birthday.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (isForeigner.present) {
      map['is_foreigner'] = Variable<bool>(isForeigner.value);
    }
    if (isVaccinated.present) {
      map['is_vaccinated'] = Variable<bool?>(isVaccinated.value);
    }
    if (vaccineName.present) {
      map['vaccine_name'] = Variable<String?>(vaccineName.value);
    }
    if (vaccinationDate.present) {
      map['vaccination_date'] = Variable<DateTime?>(vaccinationDate.value);
    }
    if (vaccinePhase.present) {
      map['vaccine_phase'] = Variable<int?>(vaccinePhase.value);
    }
    if (vaccinationAreaPk.present) {
      map['vaccination_area_pk'] = Variable<String?>(vaccinationAreaPk.value);
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
    return (StringBuffer('PersonsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthday: $birthday, ')
          ..write('age: $age, ')
          ..write('isForeigner: $isForeigner, ')
          ..write('isVaccinated: $isVaccinated, ')
          ..write('vaccineName: $vaccineName, ')
          ..write('vaccinationDate: $vaccinationDate, ')
          ..write('vaccinePhase: $vaccinePhase, ')
          ..write('vaccinationAreaPk: $vaccinationAreaPk, ')
          ..write('timeStamp: $timeStamp, ')
          ..write('deleted: $deleted, ')
          ..write('knowledgeId: $knowledgeId')
          ..write(')'))
        .toString();
  }
}

class $PersonsTable extends Persons with TableInfo<$PersonsTable, Person> {
  final GeneratedDatabase _db;
  final String? _alias;
  $PersonsTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String?> id = GeneratedColumn<String?>(
      'id', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 36),
      typeName: 'TEXT',
      requiredDuringInsert: false,
      clientDefault: () => Uuid().v4());
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>(
      'name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
      typeName: 'TEXT',
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT \'\' UNIQUE',
      defaultValue: Constant(""));
  final VerificationMeta _birthdayMeta = const VerificationMeta('birthday');
  late final GeneratedColumn<DateTime?> birthday = GeneratedColumn<DateTime?>(
      'birthday', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  final VerificationMeta _ageMeta = const VerificationMeta('age');
  late final GeneratedColumn<int?> age = GeneratedColumn<int?>(
      'age', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  final VerificationMeta _isForeignerMeta =
      const VerificationMeta('isForeigner');
  late final GeneratedColumn<bool?> isForeigner = GeneratedColumn<bool?>(
      'is_foreigner', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (is_foreigner IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _isVaccinatedMeta =
      const VerificationMeta('isVaccinated');
  late final GeneratedColumn<bool?> isVaccinated = GeneratedColumn<bool?>(
      'is_vaccinated', aliasedName, true,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (is_vaccinated IN (0, 1))');
  final VerificationMeta _vaccineNameMeta =
      const VerificationMeta('vaccineName');
  late final GeneratedColumn<String?> vaccineName = GeneratedColumn<String?>(
      'vaccine_name', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
      typeName: 'TEXT',
      requiredDuringInsert: false);
  final VerificationMeta _vaccinationDateMeta =
      const VerificationMeta('vaccinationDate');
  late final GeneratedColumn<DateTime?> vaccinationDate =
      GeneratedColumn<DateTime?>('vaccination_date', aliasedName, true,
          typeName: 'INTEGER', requiredDuringInsert: false);
  final VerificationMeta _vaccinePhaseMeta =
      const VerificationMeta('vaccinePhase');
  late final GeneratedColumn<int?> vaccinePhase = GeneratedColumn<int?>(
      'vaccine_phase', aliasedName, true,
      typeName: 'INTEGER', requiredDuringInsert: false);
  final VerificationMeta _vaccinationAreaPkMeta =
      const VerificationMeta('vaccinationAreaPk');
  late final GeneratedColumn<String?> vaccinationAreaPk =
      GeneratedColumn<String?>('vaccination_area_pk', aliasedName, true,
          typeName: 'TEXT',
          requiredDuringInsert: false,
          $customConstraints: 'NULLABLE REFERENCES area(pk)');
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
        age,
        isForeigner,
        isVaccinated,
        vaccineName,
        vaccinationDate,
        vaccinePhase,
        vaccinationAreaPk,
        timeStamp,
        deleted,
        knowledgeId
      ];
  @override
  String get aliasedName => _alias ?? 'person';
  @override
  String get actualTableName => 'person';
  @override
  VerificationContext validateIntegrity(Insertable<Person> instance,
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
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    }
    if (data.containsKey('is_foreigner')) {
      context.handle(
          _isForeignerMeta,
          isForeigner.isAcceptableOrUnknown(
              data['is_foreigner']!, _isForeignerMeta));
    }
    if (data.containsKey('is_vaccinated')) {
      context.handle(
          _isVaccinatedMeta,
          isVaccinated.isAcceptableOrUnknown(
              data['is_vaccinated']!, _isVaccinatedMeta));
    }
    if (data.containsKey('vaccine_name')) {
      context.handle(
          _vaccineNameMeta,
          vaccineName.isAcceptableOrUnknown(
              data['vaccine_name']!, _vaccineNameMeta));
    }
    if (data.containsKey('vaccination_date')) {
      context.handle(
          _vaccinationDateMeta,
          vaccinationDate.isAcceptableOrUnknown(
              data['vaccination_date']!, _vaccinationDateMeta));
    }
    if (data.containsKey('vaccine_phase')) {
      context.handle(
          _vaccinePhaseMeta,
          vaccinePhase.isAcceptableOrUnknown(
              data['vaccine_phase']!, _vaccinePhaseMeta));
    }
    if (data.containsKey('vaccination_area_pk')) {
      context.handle(
          _vaccinationAreaPkMeta,
          vaccinationAreaPk.isAcceptableOrUnknown(
              data['vaccination_area_pk']!, _vaccinationAreaPkMeta));
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
  Person map(Map<String, dynamic> data, {String? tablePrefix}) {
    return Person.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $PersonsTable createAlias(String alias) {
    return $PersonsTable(_db, alias);
  }
}

class CustomObjectsCompanion extends UpdateCompanion<CustomObject> {
  final Value<String> id;
  final Value<String> fieldString;
  final Value<String?> fieldStringNullable;
  final Value<int> fieldInt;
  final Value<int?> fieldIntNullable;
  final Value<bool> fieldBoolean;
  final Value<bool?> fieldBooleanNullable;
  final Value<DateTime> fieldDateTime;
  final Value<DateTime?> fieldDateTimeNullable;
  final Value<int> timeStamp;
  final Value<bool> deleted;
  final Value<String?> knowledgeId;
  const CustomObjectsCompanion({
    this.id = const Value.absent(),
    this.fieldString = const Value.absent(),
    this.fieldStringNullable = const Value.absent(),
    this.fieldInt = const Value.absent(),
    this.fieldIntNullable = const Value.absent(),
    this.fieldBoolean = const Value.absent(),
    this.fieldBooleanNullable = const Value.absent(),
    this.fieldDateTime = const Value.absent(),
    this.fieldDateTimeNullable = const Value.absent(),
    this.timeStamp = const Value.absent(),
    this.deleted = const Value.absent(),
    this.knowledgeId = const Value.absent(),
  });
  CustomObjectsCompanion.insert({
    required String id,
    required String fieldString,
    this.fieldStringNullable = const Value.absent(),
    required int fieldInt,
    this.fieldIntNullable = const Value.absent(),
    required bool fieldBoolean,
    this.fieldBooleanNullable = const Value.absent(),
    required DateTime fieldDateTime,
    this.fieldDateTimeNullable = const Value.absent(),
    required int timeStamp,
    required bool deleted,
    this.knowledgeId = const Value.absent(),
  })  : id = Value(id),
        fieldString = Value(fieldString),
        fieldInt = Value(fieldInt),
        fieldBoolean = Value(fieldBoolean),
        fieldDateTime = Value(fieldDateTime),
        timeStamp = Value(timeStamp),
        deleted = Value(deleted);
  static Insertable<CustomObject> custom({
    Expression<String>? id,
    Expression<String>? fieldString,
    Expression<String?>? fieldStringNullable,
    Expression<int>? fieldInt,
    Expression<int?>? fieldIntNullable,
    Expression<bool>? fieldBoolean,
    Expression<bool?>? fieldBooleanNullable,
    Expression<DateTime>? fieldDateTime,
    Expression<DateTime?>? fieldDateTimeNullable,
    Expression<int>? timeStamp,
    Expression<bool>? deleted,
    Expression<String?>? knowledgeId,
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
      if (timeStamp != null) 'time_stamp': timeStamp,
      if (deleted != null) 'deleted': deleted,
      if (knowledgeId != null) 'knowledge_id': knowledgeId,
    });
  }

  CustomObjectsCompanion copyWith(
      {Value<String>? id,
      Value<String>? fieldString,
      Value<String?>? fieldStringNullable,
      Value<int>? fieldInt,
      Value<int?>? fieldIntNullable,
      Value<bool>? fieldBoolean,
      Value<bool?>? fieldBooleanNullable,
      Value<DateTime>? fieldDateTime,
      Value<DateTime?>? fieldDateTimeNullable,
      Value<int>? timeStamp,
      Value<bool>? deleted,
      Value<String?>? knowledgeId}) {
    return CustomObjectsCompanion(
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
    return (StringBuffer('CustomObjectsCompanion(')
          ..write('id: $id, ')
          ..write('fieldString: $fieldString, ')
          ..write('fieldStringNullable: $fieldStringNullable, ')
          ..write('fieldInt: $fieldInt, ')
          ..write('fieldIntNullable: $fieldIntNullable, ')
          ..write('fieldBoolean: $fieldBoolean, ')
          ..write('fieldBooleanNullable: $fieldBooleanNullable, ')
          ..write('fieldDateTime: $fieldDateTime, ')
          ..write('fieldDateTimeNullable: $fieldDateTimeNullable, ')
          ..write('timeStamp: $timeStamp, ')
          ..write('deleted: $deleted, ')
          ..write('knowledgeId: $knowledgeId')
          ..write(')'))
        .toString();
  }
}

class $CustomObjectsTable extends CustomObjects
    with TableInfo<$CustomObjectsTable, CustomObject> {
  final GeneratedDatabase _db;
  final String? _alias;
  $CustomObjectsTable(this._db, [this._alias]);
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
  final VerificationMeta _timeStampMeta = const VerificationMeta('timeStamp');
  late final GeneratedColumn<int?> timeStamp = GeneratedColumn<int?>(
      'time_stamp', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: true);
  final VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  late final GeneratedColumn<bool?> deleted = GeneratedColumn<bool?>(
      'deleted', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: true,
      defaultConstraints: 'CHECK (deleted IN (0, 1))');
  final VerificationMeta _knowledgeIdMeta =
      const VerificationMeta('knowledgeId');
  late final GeneratedColumn<String?> knowledgeId = GeneratedColumn<String?>(
      'knowledge_id', aliasedName, true,
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
        timeStamp,
        deleted,
        knowledgeId
      ];
  @override
  String get aliasedName => _alias ?? 'custom_objects';
  @override
  String get actualTableName => 'custom_objects';
  @override
  VerificationContext validateIntegrity(Insertable<CustomObject> instance,
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
    if (data.containsKey('time_stamp')) {
      context.handle(_timeStampMeta,
          timeStamp.isAcceptableOrUnknown(data['time_stamp']!, _timeStampMeta));
    } else if (isInserting) {
      context.missing(_timeStampMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    } else if (isInserting) {
      context.missing(_deletedMeta);
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
  CustomObject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomObject.fromDb(
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
      timeStamp: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}time_stamp'])!,
      deleted: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}deleted'])!,
      knowledgeId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}knowledge_id']),
    );
  }

  @override
  $CustomObjectsTable createAlias(String alias) {
    return $CustomObjectsTable(_db, alias);
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
  late final $AreasTable areas = $AreasTable(this);
  late final $PersonsTable persons = $PersonsTable(this);
  late final $CustomObjectsTable customObjects = $CustomObjectsTable(this);
  late final $NetCoreSyncKnowledgesTable netCoreSyncKnowledges =
      $NetCoreSyncKnowledgesTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [areas, persons, customObjects, netCoreSyncKnowledges];
}

// **************************************************************************
// NetCoreSyncClientGenerator
// **************************************************************************

// NOTE: Obtained from @NetCoreSyncTable annotations:
// Areas: {"tableClassName":"Areas","dataClassName":"AreaData","useRowClass":false,"netCoreSyncTable":{"mapToClassName":"SyncArea","idFieldName":"pk","timeStampFieldName":"syncTimeStamp","deletedFieldName":"syncDeleted","knowledgeIdFieldName":"syncKnowledgeId"}}
// CustomObjects: {"tableClassName":"CustomObjects","dataClassName":"CustomObject","useRowClass":true,"netCoreSyncTable":{"mapToClassName":"SyncCustomObject","idFieldName":"id","timeStampFieldName":"timeStamp","deletedFieldName":"deleted","knowledgeIdFieldName":"knowledgeId"}}
// Persons: {"tableClassName":"Persons","dataClassName":"Person","useRowClass":false,"netCoreSyncTable":{"mapToClassName":"SyncPerson","idFieldName":"id","timeStampFieldName":"timeStamp","deletedFieldName":"deleted","knowledgeIdFieldName":"knowledgeId"}}

class _$NetCoreSyncEngineUser extends NetCoreSyncEngine {
  _$NetCoreSyncEngineUser(Map<Type, NetCoreSyncTableUser> tables)
      : super(tables);

  @override
  Object? getSyncColumnValue<D>(Insertable<D> entity, String fieldName) {
    if (entity is UpdateCompanion<D>) {
      if (D == AreaData) {
        switch (fieldName) {
          case "id":
            return (entity as AreasCompanion).pk == Value.absent()
                ? null
                : (entity as AreasCompanion).pk.value;
          case "timeStamp":
            return (entity as AreasCompanion).syncTimeStamp == Value.absent()
                ? null
                : (entity as AreasCompanion).syncTimeStamp.value;
          case "deleted":
            return (entity as AreasCompanion).syncDeleted == Value.absent()
                ? null
                : (entity as AreasCompanion).syncDeleted.value;
          case "knowledgeId":
            return (entity as AreasCompanion).syncKnowledgeId == Value.absent()
                ? null
                : (entity as AreasCompanion).syncKnowledgeId.value;
        }
      }
      if (D == CustomObject) {
        switch (fieldName) {
          case "id":
            return (entity as CustomObjectsCompanion).id == Value.absent()
                ? null
                : (entity as CustomObjectsCompanion).id.value;
          case "timeStamp":
            return (entity as CustomObjectsCompanion).timeStamp ==
                    Value.absent()
                ? null
                : (entity as CustomObjectsCompanion).timeStamp.value;
          case "deleted":
            return (entity as CustomObjectsCompanion).deleted == Value.absent()
                ? null
                : (entity as CustomObjectsCompanion).deleted.value;
          case "knowledgeId":
            return (entity as CustomObjectsCompanion).knowledgeId ==
                    Value.absent()
                ? null
                : (entity as CustomObjectsCompanion).knowledgeId.value;
        }
      }
      if (D == Person) {
        switch (fieldName) {
          case "id":
            return (entity as PersonsCompanion).id == Value.absent()
                ? null
                : (entity as PersonsCompanion).id.value;
          case "timeStamp":
            return (entity as PersonsCompanion).timeStamp == Value.absent()
                ? null
                : (entity as PersonsCompanion).timeStamp.value;
          case "deleted":
            return (entity as PersonsCompanion).deleted == Value.absent()
                ? null
                : (entity as PersonsCompanion).deleted.value;
          case "knowledgeId":
            return (entity as PersonsCompanion).knowledgeId == Value.absent()
                ? null
                : (entity as PersonsCompanion).knowledgeId.value;
        }
      }
    } else {
      if (entity is AreaData) {
        switch (fieldName) {
          case "id":
            return (entity as AreaData).pk;
          case "timeStamp":
            return (entity as AreaData).syncTimeStamp;
          case "deleted":
            return (entity as AreaData).syncDeleted;
          case "knowledgeId":
            return (entity as AreaData).syncKnowledgeId;
        }
      }
      if (entity is CustomObject) {
        switch (fieldName) {
          case "id":
            return (entity as CustomObject).id;
          case "timeStamp":
            return (entity as CustomObject).timeStamp;
          case "deleted":
            return (entity as CustomObject).deleted;
          case "knowledgeId":
            return (entity as CustomObject).knowledgeId;
        }
      }
      if (entity is Person) {
        switch (fieldName) {
          case "id":
            return (entity as Person).id;
          case "timeStamp":
            return (entity as Person).timeStamp;
          case "deleted":
            return (entity as Person).deleted;
          case "knowledgeId":
            return (entity as Person).knowledgeId;
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
      if (D == AreaData) {
        return (entity as AreasCompanion).copyWith(
          syncTimeStamp: Value(timeStamp),
          syncKnowledgeId: Value(null),
          syncDeleted: deleted != null ? Value(deleted) : Value.absent(),
        ) as Insertable<D>;
      }
      if (D == CustomObject) {
        return (entity as CustomObjectsCompanion).copyWith(
          timeStamp: Value(timeStamp),
          knowledgeId: Value(null),
          deleted: deleted != null ? Value(deleted) : Value.absent(),
        ) as Insertable<D>;
      }
      if (D == Person) {
        return (entity as PersonsCompanion).copyWith(
          timeStamp: Value(timeStamp),
          knowledgeId: Value(null),
          deleted: deleted != null ? Value(deleted) : Value.absent(),
        ) as Insertable<D>;
      }
    } else if (entity is DataClass) {
      if (entity is AreaData) {
        return (entity as AreaData).copyWith(
          syncTimeStamp: timeStamp,
          syncKnowledgeId: null,
          syncDeleted: deleted,
        ) as Insertable<D>;
      }
      if (entity is Person) {
        return (entity as Person).copyWith(
          timeStamp: timeStamp,
          knowledgeId: null,
          deleted: deleted,
        ) as Insertable<D>;
      }
    } else {
      if (entity is CustomObject) {
        (entity as CustomObject).timeStamp = timeStamp;
        (entity as CustomObject).knowledgeId = null;
        if (deleted != null) (entity as CustomObject).deleted = deleted;
        return entity;
      }
    }
    throw NetCoreSyncException("Unexpected entity Type: $entity");
  }
}

extension $NetCoreSyncClientExtension on Database {
  Future<void> netCoreSync_initialize() async {
    await netCoreSync_initializeImpl(
      _$NetCoreSyncEngineUser(
        {
          AreaData: NetCoreSyncTableUser(
            areas,
            NetCoreSyncTable.fromJson({
              "mapToClassName": "SyncArea",
              "idFieldName": "pk",
              "timeStampFieldName": "syncTimeStamp",
              "deletedFieldName": "syncDeleted",
              "knowledgeIdFieldName": "syncKnowledgeId"
            }),
            areas.pk.escapedName,
            areas.syncTimeStamp.escapedName,
            areas.syncDeleted.escapedName,
            areas.syncKnowledgeId.escapedName,
          ),
          CustomObject: NetCoreSyncTableUser(
            customObjects,
            NetCoreSyncTable.fromJson({
              "mapToClassName": "SyncCustomObject",
              "idFieldName": "id",
              "timeStampFieldName": "timeStamp",
              "deletedFieldName": "deleted",
              "knowledgeIdFieldName": "knowledgeId"
            }),
            customObjects.id.escapedName,
            customObjects.timeStamp.escapedName,
            customObjects.deleted.escapedName,
            customObjects.knowledgeId.escapedName,
          ),
          Person: NetCoreSyncTableUser(
            persons,
            NetCoreSyncTable.fromJson({
              "mapToClassName": "SyncPerson",
              "idFieldName": "id",
              "timeStampFieldName": "timeStamp",
              "deletedFieldName": "deleted",
              "knowledgeIdFieldName": "knowledgeId"
            }),
            persons.id.escapedName,
            persons.timeStamp.escapedName,
            persons.deleted.escapedName,
            persons.knowledgeId.escapedName,
          ),
        },
      ),
    );
  }
}
