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
  final String syncSyncId;
  final String syncKnowledgeId;
  final bool syncSynced;
  final bool syncDeleted;
  AreaData(
      {required this.pk,
      required this.city,
      required this.district,
      required this.syncSyncId,
      required this.syncKnowledgeId,
      required this.syncSynced,
      required this.syncDeleted});
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
      syncSyncId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}sync_sync_id'])!,
      syncKnowledgeId: const StringType().mapFromDatabaseResponse(
          data['${effectivePrefix}sync_knowledge_id'])!,
      syncSynced: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}sync_synced'])!,
      syncDeleted: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}sync_deleted'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pk'] = Variable<String>(pk);
    map['city'] = Variable<String>(city);
    map['district'] = Variable<String>(district);
    map['sync_sync_id'] = Variable<String>(syncSyncId);
    map['sync_knowledge_id'] = Variable<String>(syncKnowledgeId);
    map['sync_synced'] = Variable<bool>(syncSynced);
    map['sync_deleted'] = Variable<bool>(syncDeleted);
    return map;
  }

  AreasCompanion toCompanion(bool nullToAbsent) {
    return AreasCompanion(
      pk: Value(pk),
      city: Value(city),
      district: Value(district),
      syncSyncId: Value(syncSyncId),
      syncKnowledgeId: Value(syncKnowledgeId),
      syncSynced: Value(syncSynced),
      syncDeleted: Value(syncDeleted),
    );
  }

  factory AreaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return AreaData(
      pk: serializer.fromJson<String>(json['pk']),
      city: serializer.fromJson<String>(json['city']),
      district: serializer.fromJson<String>(json['district']),
      syncSyncId: serializer.fromJson<String>(json['syncSyncId']),
      syncKnowledgeId: serializer.fromJson<String>(json['syncKnowledgeId']),
      syncSynced: serializer.fromJson<bool>(json['syncSynced']),
      syncDeleted: serializer.fromJson<bool>(json['syncDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pk': serializer.toJson<String>(pk),
      'city': serializer.toJson<String>(city),
      'district': serializer.toJson<String>(district),
      'syncSyncId': serializer.toJson<String>(syncSyncId),
      'syncKnowledgeId': serializer.toJson<String>(syncKnowledgeId),
      'syncSynced': serializer.toJson<bool>(syncSynced),
      'syncDeleted': serializer.toJson<bool>(syncDeleted),
    };
  }

  AreaData copyWith(
          {String? pk,
          String? city,
          String? district,
          String? syncSyncId,
          String? syncKnowledgeId,
          bool? syncSynced,
          bool? syncDeleted}) =>
      AreaData(
        pk: pk ?? this.pk,
        city: city ?? this.city,
        district: district ?? this.district,
        syncSyncId: syncSyncId ?? this.syncSyncId,
        syncKnowledgeId: syncKnowledgeId ?? this.syncKnowledgeId,
        syncSynced: syncSynced ?? this.syncSynced,
        syncDeleted: syncDeleted ?? this.syncDeleted,
      );
  @override
  String toString() {
    return (StringBuffer('AreaData(')
          ..write('pk: $pk, ')
          ..write('city: $city, ')
          ..write('district: $district, ')
          ..write('syncSyncId: $syncSyncId, ')
          ..write('syncKnowledgeId: $syncKnowledgeId, ')
          ..write('syncSynced: $syncSynced, ')
          ..write('syncDeleted: $syncDeleted')
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
              $mrjc(
                  syncSyncId.hashCode,
                  $mrjc(syncKnowledgeId.hashCode,
                      $mrjc(syncSynced.hashCode, syncDeleted.hashCode)))))));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AreaData &&
          other.pk == this.pk &&
          other.city == this.city &&
          other.district == this.district &&
          other.syncSyncId == this.syncSyncId &&
          other.syncKnowledgeId == this.syncKnowledgeId &&
          other.syncSynced == this.syncSynced &&
          other.syncDeleted == this.syncDeleted);
}

class AreasCompanion extends UpdateCompanion<AreaData> {
  final Value<String> pk;
  final Value<String> city;
  final Value<String> district;
  final Value<String> syncSyncId;
  final Value<String> syncKnowledgeId;
  final Value<bool> syncSynced;
  final Value<bool> syncDeleted;
  const AreasCompanion({
    this.pk = const Value.absent(),
    this.city = const Value.absent(),
    this.district = const Value.absent(),
    this.syncSyncId = const Value.absent(),
    this.syncKnowledgeId = const Value.absent(),
    this.syncSynced = const Value.absent(),
    this.syncDeleted = const Value.absent(),
  });
  AreasCompanion.insert({
    this.pk = const Value.absent(),
    this.city = const Value.absent(),
    this.district = const Value.absent(),
    this.syncSyncId = const Value.absent(),
    this.syncKnowledgeId = const Value.absent(),
    this.syncSynced = const Value.absent(),
    this.syncDeleted = const Value.absent(),
  });
  static Insertable<AreaData> custom({
    Expression<String>? pk,
    Expression<String>? city,
    Expression<String>? district,
    Expression<String>? syncSyncId,
    Expression<String>? syncKnowledgeId,
    Expression<bool>? syncSynced,
    Expression<bool>? syncDeleted,
  }) {
    return RawValuesInsertable({
      if (pk != null) 'pk': pk,
      if (city != null) 'city': city,
      if (district != null) 'district': district,
      if (syncSyncId != null) 'sync_sync_id': syncSyncId,
      if (syncKnowledgeId != null) 'sync_knowledge_id': syncKnowledgeId,
      if (syncSynced != null) 'sync_synced': syncSynced,
      if (syncDeleted != null) 'sync_deleted': syncDeleted,
    });
  }

  AreasCompanion copyWith(
      {Value<String>? pk,
      Value<String>? city,
      Value<String>? district,
      Value<String>? syncSyncId,
      Value<String>? syncKnowledgeId,
      Value<bool>? syncSynced,
      Value<bool>? syncDeleted}) {
    return AreasCompanion(
      pk: pk ?? this.pk,
      city: city ?? this.city,
      district: district ?? this.district,
      syncSyncId: syncSyncId ?? this.syncSyncId,
      syncKnowledgeId: syncKnowledgeId ?? this.syncKnowledgeId,
      syncSynced: syncSynced ?? this.syncSynced,
      syncDeleted: syncDeleted ?? this.syncDeleted,
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
    if (syncSyncId.present) {
      map['sync_sync_id'] = Variable<String>(syncSyncId.value);
    }
    if (syncKnowledgeId.present) {
      map['sync_knowledge_id'] = Variable<String>(syncKnowledgeId.value);
    }
    if (syncSynced.present) {
      map['sync_synced'] = Variable<bool>(syncSynced.value);
    }
    if (syncDeleted.present) {
      map['sync_deleted'] = Variable<bool>(syncDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AreasCompanion(')
          ..write('pk: $pk, ')
          ..write('city: $city, ')
          ..write('district: $district, ')
          ..write('syncSyncId: $syncSyncId, ')
          ..write('syncKnowledgeId: $syncKnowledgeId, ')
          ..write('syncSynced: $syncSynced, ')
          ..write('syncDeleted: $syncDeleted')
          ..write(')'))
        .toString();
  }
}

class $AreasTable extends Areas with TableInfo<$AreasTable, AreaData> {
  final GeneratedDatabase _db;
  final String? _alias;
  $AreasTable(this._db, [this._alias]);
  final VerificationMeta _pkMeta = const VerificationMeta('pk');
  @override
  late final GeneratedColumn<String?> pk = GeneratedColumn<String?>(
      'pk', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 36),
      typeName: 'TEXT',
      requiredDuringInsert: false,
      clientDefault: () => Uuid().v4());
  final VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String?> city = GeneratedColumn<String?>(
      'city', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
      typeName: 'TEXT',
      requiredDuringInsert: false,
      defaultValue: Constant(""));
  final VerificationMeta _districtMeta = const VerificationMeta('district');
  @override
  late final GeneratedColumn<String?> district = GeneratedColumn<String?>(
      'district', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
      typeName: 'TEXT',
      requiredDuringInsert: false,
      defaultValue: Constant(""));
  final VerificationMeta _syncSyncIdMeta = const VerificationMeta('syncSyncId');
  @override
  late final GeneratedColumn<String?> syncSyncId = GeneratedColumn<String?>(
      'sync_sync_id', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 36),
      typeName: 'TEXT',
      requiredDuringInsert: false,
      defaultValue: Constant(""));
  final VerificationMeta _syncKnowledgeIdMeta =
      const VerificationMeta('syncKnowledgeId');
  @override
  late final GeneratedColumn<String?> syncKnowledgeId =
      GeneratedColumn<String?>('sync_knowledge_id', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 36),
          typeName: 'TEXT',
          requiredDuringInsert: false,
          defaultValue: Constant(""));
  final VerificationMeta _syncSyncedMeta = const VerificationMeta('syncSynced');
  @override
  late final GeneratedColumn<bool?> syncSynced = GeneratedColumn<bool?>(
      'sync_synced', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (sync_synced IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _syncDeletedMeta =
      const VerificationMeta('syncDeleted');
  @override
  late final GeneratedColumn<bool?> syncDeleted = GeneratedColumn<bool?>(
      'sync_deleted', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (sync_deleted IN (0, 1))',
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        pk,
        city,
        district,
        syncSyncId,
        syncKnowledgeId,
        syncSynced,
        syncDeleted
      ];
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
    if (data.containsKey('sync_sync_id')) {
      context.handle(
          _syncSyncIdMeta,
          syncSyncId.isAcceptableOrUnknown(
              data['sync_sync_id']!, _syncSyncIdMeta));
    }
    if (data.containsKey('sync_knowledge_id')) {
      context.handle(
          _syncKnowledgeIdMeta,
          syncKnowledgeId.isAcceptableOrUnknown(
              data['sync_knowledge_id']!, _syncKnowledgeIdMeta));
    }
    if (data.containsKey('sync_synced')) {
      context.handle(
          _syncSyncedMeta,
          syncSynced.isAcceptableOrUnknown(
              data['sync_synced']!, _syncSyncedMeta));
    }
    if (data.containsKey('sync_deleted')) {
      context.handle(
          _syncDeletedMeta,
          syncDeleted.isAcceptableOrUnknown(
              data['sync_deleted']!, _syncDeletedMeta));
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
  final String syncId;
  final String knowledgeId;
  final bool synced;
  final bool deleted;
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
      required this.syncId,
      required this.knowledgeId,
      required this.synced,
      required this.deleted});
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
    map['sync_id'] = Variable<String>(syncId);
    map['knowledge_id'] = Variable<String>(knowledgeId);
    map['synced'] = Variable<bool>(synced);
    map['deleted'] = Variable<bool>(deleted);
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
      syncId: Value(syncId),
      knowledgeId: Value(knowledgeId),
      synced: Value(synced),
      deleted: Value(deleted),
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
      'age': serializer.toJson<int>(age),
      'isForeigner': serializer.toJson<bool>(isForeigner),
      'isVaccinated': serializer.toJson<bool?>(isVaccinated),
      'vaccineName': serializer.toJson<String?>(vaccineName),
      'vaccinationDate': serializer.toJson<DateTime?>(vaccinationDate),
      'vaccinePhase': serializer.toJson<int?>(vaccinePhase),
      'vaccinationAreaPk': serializer.toJson<String?>(vaccinationAreaPk),
      'syncId': serializer.toJson<String>(syncId),
      'knowledgeId': serializer.toJson<String>(knowledgeId),
      'synced': serializer.toJson<bool>(synced),
      'deleted': serializer.toJson<bool>(deleted),
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
          String? syncId,
          String? knowledgeId,
          bool? synced,
          bool? deleted}) =>
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
        syncId: syncId ?? this.syncId,
        knowledgeId: knowledgeId ?? this.knowledgeId,
        synced: synced ?? this.synced,
        deleted: deleted ?? this.deleted,
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
                                              syncId.hashCode,
                                              $mrjc(
                                                  knowledgeId.hashCode,
                                                  $mrjc(
                                                      synced.hashCode,
                                                      deleted
                                                          .hashCode))))))))))))));
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
          other.syncId == this.syncId &&
          other.knowledgeId == this.knowledgeId &&
          other.synced == this.synced &&
          other.deleted == this.deleted);
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
  final Value<String> syncId;
  final Value<String> knowledgeId;
  final Value<bool> synced;
  final Value<bool> deleted;
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
    this.syncId = const Value.absent(),
    this.knowledgeId = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
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
    this.syncId = const Value.absent(),
    this.knowledgeId = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
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
    Expression<String>? syncId,
    Expression<String>? knowledgeId,
    Expression<bool>? synced,
    Expression<bool>? deleted,
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
      if (syncId != null) 'sync_id': syncId,
      if (knowledgeId != null) 'knowledge_id': knowledgeId,
      if (synced != null) 'synced': synced,
      if (deleted != null) 'deleted': deleted,
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
      Value<String>? syncId,
      Value<String>? knowledgeId,
      Value<bool>? synced,
      Value<bool>? deleted}) {
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
          ..write('syncId: $syncId, ')
          ..write('knowledgeId: $knowledgeId, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }
}

class $PersonsTable extends Persons with TableInfo<$PersonsTable, Person> {
  final GeneratedDatabase _db;
  final String? _alias;
  $PersonsTable(this._db, [this._alias]);
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
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
      typeName: 'TEXT',
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT \'\'',
      defaultValue: Constant(""));
  final VerificationMeta _birthdayMeta = const VerificationMeta('birthday');
  @override
  late final GeneratedColumn<DateTime?> birthday = GeneratedColumn<DateTime?>(
      'birthday', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  final VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int?> age = GeneratedColumn<int?>(
      'age', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  final VerificationMeta _isForeignerMeta =
      const VerificationMeta('isForeigner');
  @override
  late final GeneratedColumn<bool?> isForeigner = GeneratedColumn<bool?>(
      'is_foreigner', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (is_foreigner IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _isVaccinatedMeta =
      const VerificationMeta('isVaccinated');
  @override
  late final GeneratedColumn<bool?> isVaccinated = GeneratedColumn<bool?>(
      'is_vaccinated', aliasedName, true,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (is_vaccinated IN (0, 1))');
  final VerificationMeta _vaccineNameMeta =
      const VerificationMeta('vaccineName');
  @override
  late final GeneratedColumn<String?> vaccineName = GeneratedColumn<String?>(
      'vaccine_name', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
      typeName: 'TEXT',
      requiredDuringInsert: false);
  final VerificationMeta _vaccinationDateMeta =
      const VerificationMeta('vaccinationDate');
  @override
  late final GeneratedColumn<DateTime?> vaccinationDate =
      GeneratedColumn<DateTime?>('vaccination_date', aliasedName, true,
          typeName: 'INTEGER', requiredDuringInsert: false);
  final VerificationMeta _vaccinePhaseMeta =
      const VerificationMeta('vaccinePhase');
  @override
  late final GeneratedColumn<int?> vaccinePhase = GeneratedColumn<int?>(
      'vaccine_phase', aliasedName, true,
      typeName: 'INTEGER', requiredDuringInsert: false);
  final VerificationMeta _vaccinationAreaPkMeta =
      const VerificationMeta('vaccinationAreaPk');
  @override
  late final GeneratedColumn<String?> vaccinationAreaPk =
      GeneratedColumn<String?>('vaccination_area_pk', aliasedName, true,
          typeName: 'TEXT',
          requiredDuringInsert: false,
          $customConstraints: 'NULLABLE REFERENCES area(pk)');
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
        syncId,
        knowledgeId,
        synced,
        deleted
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
  final Value<String> syncId;
  final Value<String> knowledgeId;
  final Value<bool> synced;
  final Value<bool> deleted;
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
    this.syncId = const Value.absent(),
    this.knowledgeId = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
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
    this.syncId = const Value.absent(),
    this.knowledgeId = const Value.absent(),
    required bool synced,
    required bool deleted,
  })  : id = Value(id),
        fieldString = Value(fieldString),
        fieldInt = Value(fieldInt),
        fieldBoolean = Value(fieldBoolean),
        fieldDateTime = Value(fieldDateTime),
        synced = Value(synced),
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
    Expression<String>? syncId,
    Expression<String>? knowledgeId,
    Expression<bool>? synced,
    Expression<bool>? deleted,
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
      if (syncId != null) 'sync_id': syncId,
      if (knowledgeId != null) 'knowledge_id': knowledgeId,
      if (synced != null) 'synced': synced,
      if (deleted != null) 'deleted': deleted,
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
      Value<String>? syncId,
      Value<String>? knowledgeId,
      Value<bool>? synced,
      Value<bool>? deleted}) {
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
          ..write('syncId: $syncId, ')
          ..write('knowledgeId: $knowledgeId, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted')
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
  @override
  late final GeneratedColumn<String?> id = GeneratedColumn<String?>(
      'id', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 36),
      typeName: 'TEXT',
      requiredDuringInsert: true);
  final VerificationMeta _fieldStringMeta =
      const VerificationMeta('fieldString');
  @override
  late final GeneratedColumn<String?> fieldString = GeneratedColumn<String?>(
      'field_string', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
      typeName: 'TEXT',
      requiredDuringInsert: true);
  final VerificationMeta _fieldStringNullableMeta =
      const VerificationMeta('fieldStringNullable');
  @override
  late final GeneratedColumn<String?> fieldStringNullable =
      GeneratedColumn<String?>('field_string_nullable', aliasedName, true,
          additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
          typeName: 'TEXT',
          requiredDuringInsert: false);
  final VerificationMeta _fieldIntMeta = const VerificationMeta('fieldInt');
  @override
  late final GeneratedColumn<int?> fieldInt = GeneratedColumn<int?>(
      'field_int', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: true);
  final VerificationMeta _fieldIntNullableMeta =
      const VerificationMeta('fieldIntNullable');
  @override
  late final GeneratedColumn<int?> fieldIntNullable = GeneratedColumn<int?>(
      'field_int_nullable', aliasedName, true,
      typeName: 'INTEGER', requiredDuringInsert: false);
  final VerificationMeta _fieldBooleanMeta =
      const VerificationMeta('fieldBoolean');
  @override
  late final GeneratedColumn<bool?> fieldBoolean = GeneratedColumn<bool?>(
      'field_boolean', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: true,
      defaultConstraints: 'CHECK (field_boolean IN (0, 1))');
  final VerificationMeta _fieldBooleanNullableMeta =
      const VerificationMeta('fieldBooleanNullable');
  @override
  late final GeneratedColumn<bool?> fieldBooleanNullable =
      GeneratedColumn<bool?>('field_boolean_nullable', aliasedName, true,
          typeName: 'INTEGER',
          requiredDuringInsert: false,
          defaultConstraints: 'CHECK (field_boolean_nullable IN (0, 1))');
  final VerificationMeta _fieldDateTimeMeta =
      const VerificationMeta('fieldDateTime');
  @override
  late final GeneratedColumn<DateTime?> fieldDateTime =
      GeneratedColumn<DateTime?>('field_date_time', aliasedName, false,
          typeName: 'INTEGER', requiredDuringInsert: true);
  final VerificationMeta _fieldDateTimeNullableMeta =
      const VerificationMeta('fieldDateTimeNullable');
  @override
  late final GeneratedColumn<DateTime?> fieldDateTimeNullable =
      GeneratedColumn<DateTime?>('field_date_time_nullable', aliasedName, true,
          typeName: 'INTEGER', requiredDuringInsert: false);
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
      requiredDuringInsert: true,
      defaultConstraints: 'CHECK (synced IN (0, 1))');
  final VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool?> deleted = GeneratedColumn<bool?>(
      'deleted', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: true,
      defaultConstraints: 'CHECK (deleted IN (0, 1))');
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
        syncId,
        knowledgeId,
        synced,
        deleted
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
    } else if (isInserting) {
      context.missing(_syncedMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    } else if (isInserting) {
      context.missing(_deletedMeta);
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
  $CustomObjectsTable createAlias(String alias) {
    return $CustomObjectsTable(_db, alias);
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
// Areas: {"tableClassName":"Areas","dataClassName":"AreaData","useRowClass":false,"netCoreSyncTable":{"idFieldName":"pk","syncIdFieldName":"syncSyncId","knowledgeIdFieldName":"syncKnowledgeId","syncedFieldName":"syncSynced","deletedFieldName":"syncDeleted"}}
// CustomObjects: {"tableClassName":"CustomObjects","dataClassName":"CustomObject","useRowClass":true,"netCoreSyncTable":{"idFieldName":"id","syncIdFieldName":"syncId","knowledgeIdFieldName":"knowledgeId","syncedFieldName":"synced","deletedFieldName":"deleted"}}
// Persons: {"tableClassName":"Persons","dataClassName":"Person","useRowClass":false,"netCoreSyncTable":{"idFieldName":"id","syncIdFieldName":"syncId","knowledgeIdFieldName":"knowledgeId","syncedFieldName":"synced","deletedFieldName":"deleted"}}

class _$NetCoreSyncEngineUser extends NetCoreSyncEngine {
  _$NetCoreSyncEngineUser(Map<Type, NetCoreSyncTableUser> tables)
      : super(tables);

  @override
  UpdateCompanion<D> toSafeCompanion<D>(Insertable<D> entity) {
    if (D == AreaData) {
      AreasCompanion safeEntity;
      if (entity is AreasCompanion) {
        safeEntity = entity as AreasCompanion;
      } else {
        safeEntity = (entity as AreaData).toCompanion(false);
      }
      safeEntity = safeEntity.copyWith(
        pk: Value.absent(),
        syncSyncId: Value.absent(),
        syncKnowledgeId: Value.absent(),
        syncSynced: Value.absent(),
        syncDeleted: Value.absent(),
      );
      return safeEntity as UpdateCompanion<D>;
    }
    if (D == CustomObject) {
      CustomObjectsCompanion safeEntity;
      if (entity is CustomObjectsCompanion) {
        safeEntity = entity as CustomObjectsCompanion;
      } else {
        safeEntity = (entity as CustomObject).toCompanion(false);
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
    if (D == Person) {
      PersonsCompanion safeEntity;
      if (entity is PersonsCompanion) {
        safeEntity = entity as PersonsCompanion;
      } else {
        safeEntity = (entity as Person).toCompanion(false);
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
    if (entity is RawValuesInsertable<D>) {
      switch (fieldName) {
        case "id":
          return entity.data[tables[D]!.idEscapedName];
        case "syncId":
          return entity.data[tables[D]!.syncIdEscapedName];
        case "knowledgeId":
          return entity.data[tables[D]!.knowledgeIdEscapedName];
        case "synced":
          return entity.data[tables[D]!.syncedEscapedName];
        case "deleted":
          return entity.data[tables[D]!.deletedEscapedName];
      }
    } else if (entity is UpdateCompanion<D>) {
      if (D == AreaData) {
        switch (fieldName) {
          case "id":
            return (entity as AreasCompanion).pk == Value.absent()
                ? null
                : (entity as AreasCompanion).pk.value;
          case "syncId":
            return (entity as AreasCompanion).syncSyncId == Value.absent()
                ? null
                : (entity as AreasCompanion).syncSyncId.value;
          case "knowledgeId":
            return (entity as AreasCompanion).syncKnowledgeId == Value.absent()
                ? null
                : (entity as AreasCompanion).syncKnowledgeId.value;
          case "synced":
            return (entity as AreasCompanion).syncSynced == Value.absent()
                ? null
                : (entity as AreasCompanion).syncSynced.value;
          case "deleted":
            return (entity as AreasCompanion).syncDeleted == Value.absent()
                ? null
                : (entity as AreasCompanion).syncDeleted.value;
        }
      }
      if (D == CustomObject) {
        switch (fieldName) {
          case "id":
            return (entity as CustomObjectsCompanion).id == Value.absent()
                ? null
                : (entity as CustomObjectsCompanion).id.value;
          case "syncId":
            return (entity as CustomObjectsCompanion).syncId == Value.absent()
                ? null
                : (entity as CustomObjectsCompanion).syncId.value;
          case "knowledgeId":
            return (entity as CustomObjectsCompanion).knowledgeId ==
                    Value.absent()
                ? null
                : (entity as CustomObjectsCompanion).knowledgeId.value;
          case "synced":
            return (entity as CustomObjectsCompanion).synced == Value.absent()
                ? null
                : (entity as CustomObjectsCompanion).synced.value;
          case "deleted":
            return (entity as CustomObjectsCompanion).deleted == Value.absent()
                ? null
                : (entity as CustomObjectsCompanion).deleted.value;
        }
      }
      if (D == Person) {
        switch (fieldName) {
          case "id":
            return (entity as PersonsCompanion).id == Value.absent()
                ? null
                : (entity as PersonsCompanion).id.value;
          case "syncId":
            return (entity as PersonsCompanion).syncId == Value.absent()
                ? null
                : (entity as PersonsCompanion).syncId.value;
          case "knowledgeId":
            return (entity as PersonsCompanion).knowledgeId == Value.absent()
                ? null
                : (entity as PersonsCompanion).knowledgeId.value;
          case "synced":
            return (entity as PersonsCompanion).synced == Value.absent()
                ? null
                : (entity as PersonsCompanion).synced.value;
          case "deleted":
            return (entity as PersonsCompanion).deleted == Value.absent()
                ? null
                : (entity as PersonsCompanion).deleted.value;
        }
      }
    } else {
      if (entity is AreaData) {
        switch (fieldName) {
          case "id":
            return (entity as AreaData).pk;
          case "syncId":
            return (entity as AreaData).syncSyncId;
          case "knowledgeId":
            return (entity as AreaData).syncKnowledgeId;
          case "synced":
            return (entity as AreaData).syncSynced;
          case "deleted":
            return (entity as AreaData).syncDeleted;
        }
      }
      if (entity is CustomObject) {
        switch (fieldName) {
          case "id":
            return (entity as CustomObject).id;
          case "syncId":
            return (entity as CustomObject).syncId;
          case "knowledgeId":
            return (entity as CustomObject).knowledgeId;
          case "synced":
            return (entity as CustomObject).synced;
          case "deleted":
            return (entity as CustomObject).deleted;
        }
      }
      if (entity is Person) {
        switch (fieldName) {
          case "id":
            return (entity as Person).id;
          case "syncId":
            return (entity as Person).syncId;
          case "knowledgeId":
            return (entity as Person).knowledgeId;
          case "synced":
            return (entity as Person).synced;
          case "deleted":
            return (entity as Person).deleted;
        }
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
      if (D == AreaData) {
        return (entity as AreasCompanion).copyWith(
          syncSynced: Value(synced),
          syncSyncId: syncId != null ? Value(syncId) : Value.absent(),
          syncKnowledgeId:
              knowledgeId != null ? Value(knowledgeId) : Value.absent(),
          syncDeleted: deleted != null ? Value(deleted) : Value.absent(),
        ) as Insertable<D>;
      }
      if (D == CustomObject) {
        return (entity as CustomObjectsCompanion).copyWith(
          synced: Value(synced),
          syncId: syncId != null ? Value(syncId) : Value.absent(),
          knowledgeId:
              knowledgeId != null ? Value(knowledgeId) : Value.absent(),
          deleted: deleted != null ? Value(deleted) : Value.absent(),
        ) as Insertable<D>;
      }
      if (D == Person) {
        return (entity as PersonsCompanion).copyWith(
          synced: Value(synced),
          syncId: syncId != null ? Value(syncId) : Value.absent(),
          knowledgeId:
              knowledgeId != null ? Value(knowledgeId) : Value.absent(),
          deleted: deleted != null ? Value(deleted) : Value.absent(),
        ) as Insertable<D>;
      }
    } else if (entity is DataClass) {
      if (entity is AreaData) {
        return (entity as AreaData).copyWith(
          syncSynced: synced,
          syncSyncId: syncId,
          syncKnowledgeId: knowledgeId,
          syncDeleted: deleted,
        ) as Insertable<D>;
      }
      if (entity is Person) {
        return (entity as Person).copyWith(
          synced: synced,
          syncId: syncId,
          knowledgeId: knowledgeId,
          deleted: deleted,
        ) as Insertable<D>;
      }
    } else {
      if (entity is CustomObject) {
        (entity as CustomObject).synced = synced;
        if (syncId != null) {
          (entity as CustomObject).syncId = syncId;
        }
        if (knowledgeId != null) {
          (entity as CustomObject).knowledgeId = knowledgeId;
        }
        if (deleted != null) {
          (entity as CustomObject).deleted = deleted;
        }
        return entity;
      }
    }
    throw NetCoreSyncException("Unexpected entity Type: $entity");
  }
}

extension $NetCoreSyncClientExtension on Database {
  Future<void> netCoreSyncInitialize() async {
    await netCoreSyncInitializeClient(
      _$NetCoreSyncEngineUser(
        {
          AreaData: NetCoreSyncTableUser(
            areas,
            NetCoreSyncTable.fromJson({
              "idFieldName": "pk",
              "syncIdFieldName": "syncSyncId",
              "knowledgeIdFieldName": "syncKnowledgeId",
              "syncedFieldName": "syncSynced",
              "deletedFieldName": "syncDeleted"
            }),
            areas.pk.escapedName,
            areas.syncSyncId.escapedName,
            areas.syncKnowledgeId.escapedName,
            areas.syncSynced.escapedName,
            areas.syncDeleted.escapedName,
          ),
          CustomObject: NetCoreSyncTableUser(
            customObjects,
            NetCoreSyncTable.fromJson({
              "idFieldName": "id",
              "syncIdFieldName": "syncId",
              "knowledgeIdFieldName": "knowledgeId",
              "syncedFieldName": "synced",
              "deletedFieldName": "deleted"
            }),
            customObjects.id.escapedName,
            customObjects.syncId.escapedName,
            customObjects.knowledgeId.escapedName,
            customObjects.synced.escapedName,
            customObjects.deleted.escapedName,
          ),
          Person: NetCoreSyncTableUser(
            persons,
            NetCoreSyncTable.fromJson({
              "idFieldName": "id",
              "syncIdFieldName": "syncId",
              "knowledgeIdFieldName": "knowledgeId",
              "syncedFieldName": "synced",
              "deletedFieldName": "deleted"
            }),
            persons.id.escapedName,
            persons.syncId.escapedName,
            persons.knowledgeId.escapedName,
            persons.synced.escapedName,
            persons.deleted.escapedName,
          ),
        },
      ),
    );
    netCoreSyncInitializeUser();
  }
}

class $SyncAreasTable extends $AreasTable
    implements SyncBaseTable<$AreasTable, AreaData> {
  final String Function() _allSyncIds;
  $SyncAreasTable(_$Database db, this._allSyncIds) : super(db);
  @override
  Type get type => AreaData;
  @override
  String get entityName =>
      "(SELECT * FROM ${super.entityName} WHERE ${super.syncDeleted.escapedName} = 0 AND ${super.syncSyncId.escapedName} IN (${_allSyncIds.call()}))";
}

class $SyncCustomObjectsTable extends $CustomObjectsTable
    implements SyncBaseTable<$CustomObjectsTable, CustomObject> {
  final String Function() _allSyncIds;
  $SyncCustomObjectsTable(_$Database db, this._allSyncIds) : super(db);
  @override
  Type get type => CustomObject;
  @override
  String get entityName =>
      "(SELECT * FROM ${super.entityName} WHERE ${super.deleted.escapedName} = 0 AND ${super.syncId.escapedName} IN (${_allSyncIds.call()}))";
}

class $SyncPersonsTable extends $PersonsTable
    implements SyncBaseTable<$PersonsTable, Person> {
  final String Function() _allSyncIds;
  $SyncPersonsTable(_$Database db, this._allSyncIds) : super(db);
  @override
  Type get type => Person;
  @override
  String get entityName =>
      "(SELECT * FROM ${super.entityName} WHERE ${super.deleted.escapedName} = 0 AND ${super.syncId.escapedName} IN (${_allSyncIds.call()}))";
}

mixin NetCoreSyncClientUser on NetCoreSyncClient {
  late $SyncAreasTable _syncAreas;
  late $SyncCustomObjectsTable _syncCustomObjects;
  late $SyncPersonsTable _syncPersons;

  void netCoreSyncInitializeUser() {
    _syncAreas =
        $SyncAreasTable(netCoreSyncResolvedEngine, netCoreSyncAllSyncIds);
    _syncCustomObjects = $SyncCustomObjectsTable(
        netCoreSyncResolvedEngine, netCoreSyncAllSyncIds);
    _syncPersons =
        $SyncPersonsTable(netCoreSyncResolvedEngine, netCoreSyncAllSyncIds);
  }

  $SyncAreasTable get syncAreas {
    if (!netCoreSyncInitialized) throw NetCoreSyncNotInitializedException();
    return _syncAreas;
  }

  $SyncCustomObjectsTable get syncCustomObjects {
    if (!netCoreSyncInitialized) throw NetCoreSyncNotInitializedException();
    return _syncCustomObjects;
  }

  $SyncPersonsTable get syncPersons {
    if (!netCoreSyncInitialized) throw NetCoreSyncNotInitializedException();
    return _syncPersons;
  }
}
