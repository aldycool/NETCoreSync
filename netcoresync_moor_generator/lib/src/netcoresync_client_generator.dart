import 'dart:convert';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:recase/recase.dart';
import 'package:moor/moor.dart';
import 'exceptions.dart';

class NetCoreSyncClientGenerator extends GeneratorForAnnotation<UseMoor> {
  static const String nameClassClient = "NetCoreSyncClient";
  static const String nameClassKnowledge = "NetCoreSyncKnowledges";

  @override
  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    // Pre-check some conditions
    if (element is! ClassElement) {
      throw NetCoreSyncMoorGeneratorException(
          "Element that is annotated with @UseMoor is expected to be a Class");
    }
    if (element.mixins
        .where(
            (w) => w.getDisplayString(withNullability: true) == nameClassClient)
        .isEmpty) {
      throw NetCoreSyncMoorGeneratorException(
          "The database class (${element.name}) is expected to be 'mixin' with "
          "$nameClassClient (for example: 'class Database extends _\$Database "
          "with $nameClassClient')");
    }
    if (annotation
        .read("tables")
        .listValue
        .where((w) =>
            w
                .toTypeValue()
                ?.getDisplayString(withNullability: true)
                .contains(nameClassKnowledge) ??
            false)
        .isEmpty) {
      throw NetCoreSyncMoorGeneratorException(
          "The $nameClassKnowledge table must be included in UseMoor's tables");
    }

    // Collect NetCoreSyncTable's parts
    List<String> validTables = [];
    annotation.read("tables").listValue.forEach((element) {
      validTables
          .add(element.toTypeValue()!.getDisplayString(withNullability: false));
    });
    final assetIds = await buildStep
        .findAssets(Glob("**.netcoresync_moor_table.part"))
        .toList();
    List<String> jsonParts =
        await Stream.fromIterable(assetIds).asyncMap((assetId) async {
      String content = (await buildStep.readAsString(assetId))
          .split("/* PART-MARKER */")
          .last;
      content = content.replaceAll("//", "").trim();
      return content;
    }).toList();
    // find included jsonParts for the current @UseMoor tables
    jsonParts.removeWhere((element) {
      Map<String, dynamic> part = jsonDecode(element);
      return !validTables.contains(part["tableClassName"]);
    });

    // Perform code generation
    StringBuffer buffer = StringBuffer();

    if (jsonParts.isEmpty) {
      buffer.writeln(
          "// NOTE: NetCoreSyncExtension does not generate any codes because "
          "classes annotated with @NetCoreSyncTable were not found");
      return buffer.toString();
    }

    buffer.writeln();
    buffer.writeln("// NOTE: Obtained from @NetCoreSyncTable annotations:");
    for (var jsonPart in jsonParts) {
      Map<String, dynamic> part = jsonDecode(jsonPart);
      buffer.writeln("// ${part["tableClassName"]}: $jsonPart");
    }

    // START CLASS: _$NetCoreSyncEngineUser
    buffer.writeln();
    buffer
        .writeln("class _\$NetCoreSyncEngineUser extends NetCoreSyncEngine {");
    buffer.writeln(
        "_\$NetCoreSyncEngineUser(Map<Type, NetCoreSyncTableUser> tables) : super(tables);");

    // START METHOD: toJson
    buffer.writeln();
    buffer.writeln("@override");
    buffer.writeln("Map<String, dynamic> toJson(dynamic object) {");
    for (var jsonPart in jsonParts) {
      Map<String, dynamic> part = jsonDecode(jsonPart);
      buffer.writeln("if (object is ${part["dataClassName"]}) {");
      buffer.writeln("return object.toJson();");
      buffer.writeln("}");
    }
    buffer.writeln(
        "throw NetCoreSyncException(\"Unexpected object: \$object\");");
    buffer.writeln("}");
    // END METHOD: toJson

    // START METHOD: fromJson
    buffer.writeln();
    buffer.writeln("@override");
    buffer.writeln("dynamic fromJson(Type type, Map<String, dynamic> json) {");
    for (var jsonPart in jsonParts) {
      Map<String, dynamic> part = jsonDecode(jsonPart);
      buffer.writeln("if (type == ${part["dataClassName"]}) {");
      buffer.writeln("return ${part["dataClassName"]}.fromJson(json);");
      buffer.writeln("}");
    }
    buffer.writeln("throw NetCoreSyncException(\"Unexpected type: \$type\");");
    buffer.writeln("}");
    // END METHOD: fromJson

    // START METHOD: toSafeCompanion
    buffer.writeln();
    buffer.writeln("@override");
    buffer.writeln(
        "UpdateCompanion<D> toSafeCompanion<D>(Insertable<D> entity) {");
    for (var jsonPart in jsonParts) {
      Map<String, dynamic> part = jsonDecode(jsonPart);
      // @UseRowClass is expected to already implements toCompanion() method (forced by generator)
      buffer.writeln("if (D == ${part["dataClassName"]}) {");
      buffer.writeln("${part["tableClassName"]}Companion safeEntity;");
      buffer.writeln(
          "if (entity is ${part["tableClassName"]}Companion) { safeEntity = entity as ${part["tableClassName"]}Companion; } else { safeEntity = (entity as ${part["dataClassName"]}).toCompanion(false); }");
      buffer.writeln('''
        safeEntity = safeEntity.copyWith(
          ${part["netCoreSyncTable"]["idFieldName"]}: Value.absent(),
          ${part["netCoreSyncTable"]["syncIdFieldName"]}: Value.absent(),
          ${part["netCoreSyncTable"]["knowledgeIdFieldName"]}: Value.absent(),
          ${part["netCoreSyncTable"]["syncedFieldName"]}: Value.absent(),
          ${part["netCoreSyncTable"]["deletedFieldName"]}: Value.absent(),
        );
        return safeEntity as UpdateCompanion<D>;
      ''');
      buffer.writeln("}");
    }
    buffer.writeln(
        "throw NetCoreSyncException(\"Unexpected entity Type: \$entity\");");
    buffer.writeln("}");
    // END METHOD: toSafeCompanion

    // START METHOD: getSyncColumnValue
    // Optimization Notes: fieldName used are only: id + deleted. The D type
    // are only: DataClass and custom row class. Unused code are remarked.
    buffer.writeln();
    buffer.writeln("@override");
    buffer.writeln(
        "Object? getSyncColumnValue<D>(Insertable<D> entity, String fieldName) {");
    // buffer.writeln("if (entity is RawValuesInsertable<D>) {");
    // buffer.writeln("switch (fieldName) {");
    // buffer.writeln("case\"id\":");
    // buffer.writeln("return entity.data[tables[D]!.idEscapedName];");
    // buffer.writeln("case\"syncId\":");
    // buffer.writeln("return entity.data[tables[D]!.syncIdEscapedName];");
    // buffer.writeln("case\"knowledgeId\":");
    // buffer.writeln("return entity.data[tables[D]!.knowledgeIdEscapedName];");
    // buffer.writeln("case\"synced\":");
    // buffer.writeln("return entity.data[tables[D]!.syncedEscapedName];");
    // buffer.writeln("case\"deleted\":");
    // buffer.writeln("return entity.data[tables[D]!.deletedEscapedName];");
    // buffer.writeln("}");
    // buffer.writeln("} else if (entity is UpdateCompanion<D>) {");
    // for (var jsonPart in jsonParts) {
    //   Map<String, dynamic> part = jsonDecode(jsonPart);
    //   buffer.writeln("if (D == ${part["dataClassName"]}) {");
    //   buffer.writeln("switch (fieldName) {");
    //   buffer.writeln("case\"id\":");
    //   buffer.writeln(
    //       "return (entity as ${part["tableClassName"]}Companion).${part["netCoreSyncTable"]["idFieldName"]} == Value.absent() ? null : (entity as ${part["tableClassName"]}Companion).${part["netCoreSyncTable"]["idFieldName"]}.value;");
    //   buffer.writeln("case\"syncId\":");
    //   buffer.writeln(
    //       "return (entity as ${part["tableClassName"]}Companion).${part["netCoreSyncTable"]["syncIdFieldName"]} == Value.absent() ? null : (entity as ${part["tableClassName"]}Companion).${part["netCoreSyncTable"]["syncIdFieldName"]}.value;");
    //   buffer.writeln("case\"knowledgeId\":");
    //   buffer.writeln(
    //       "return (entity as ${part["tableClassName"]}Companion).${part["netCoreSyncTable"]["knowledgeIdFieldName"]} == Value.absent() ? null : (entity as ${part["tableClassName"]}Companion).${part["netCoreSyncTable"]["knowledgeIdFieldName"]}.value;");
    //   buffer.writeln("case\"synced\":");
    //   buffer.writeln(
    //       "return (entity as ${part["tableClassName"]}Companion).${part["netCoreSyncTable"]["syncedFieldName"]} == Value.absent() ? null : (entity as ${part["tableClassName"]}Companion).${part["netCoreSyncTable"]["syncedFieldName"]}.value;");
    //   buffer.writeln("case\"deleted\":");
    //   buffer.writeln(
    //       "return (entity as ${part["tableClassName"]}Companion).${part["netCoreSyncTable"]["deletedFieldName"]} == Value.absent() ? null : (entity as ${part["tableClassName"]}Companion).${part["netCoreSyncTable"]["deletedFieldName"]}.value;");
    //   buffer.writeln("}");
    //   buffer.writeln("}");
    // }
    // buffer.writeln("} else {");
    for (var jsonPart in jsonParts) {
      Map<String, dynamic> part = jsonDecode(jsonPart);
      buffer.writeln("if (entity is ${part["dataClassName"]}) {");
      buffer.writeln("switch (fieldName) {");
      buffer.writeln("case\"id\":");
      buffer.writeln(
          "return (entity as ${part["dataClassName"]}).${part["netCoreSyncTable"]["idFieldName"]};");
      // buffer.writeln("case\"syncId\":");
      // buffer.writeln(
      //     "return (entity as ${part["dataClassName"]}).${part["netCoreSyncTable"]["syncIdFieldName"]};");
      // buffer.writeln("case\"knowledgeId\":");
      // buffer.writeln(
      //     "return (entity as ${part["dataClassName"]}).${part["netCoreSyncTable"]["knowledgeIdFieldName"]};");
      // buffer.writeln("case\"synced\":");
      // buffer.writeln(
      //     "return (entity as ${part["dataClassName"]}).${part["netCoreSyncTable"]["syncedFieldName"]};");
      buffer.writeln("case\"deleted\":");
      buffer.writeln(
          "return (entity as ${part["dataClassName"]}).${part["netCoreSyncTable"]["deletedFieldName"]};");
      buffer.writeln("}");
      buffer.writeln("}");
    }
    // buffer.writeln("}");
    buffer.writeln(
        "throw NetCoreSyncException(\"Unexpected entity Type: \$entity, fieldName: \$fieldName\");");
    buffer.writeln("}");
    // END METHOD: getSyncColumnValue

    // START METHOD: updateSyncColumns
    buffer.writeln();
    buffer.writeln("@override");
    buffer.writeln(
        "Insertable<D> updateSyncColumns<D>(Insertable<D> entity, {required bool synced, String? syncId, String? knowledgeId, bool? deleted,}) {");
    buffer.writeln("if (entity is RawValuesInsertable<D>) {");
    buffer.writeln(
        "entity.data[tables[D]!.syncedEscapedName] = Constant(synced);");
    buffer.writeln(
        "if (syncId != null) { entity.data[tables[D]!.syncIdEscapedName] = Constant(syncId); }");
    buffer.writeln(
        "if (knowledgeId != null) { entity.data[tables[D]!.knowledgeIdEscapedName] = Constant(knowledgeId); }");
    buffer.writeln(
        "if (deleted != null) { entity.data[tables[D]!.deletedEscapedName] = Constant(deleted); }");
    buffer.writeln("return entity;");
    buffer.writeln("} else if (entity is UpdateCompanion<D>) {");
    for (var jsonPart in jsonParts) {
      Map<String, dynamic> part = jsonDecode(jsonPart);
      buffer.writeln("if (D == ${part["dataClassName"]}) {");
      buffer.writeln(
          "return (entity as ${part["tableClassName"]}Companion).copyWith(");
      buffer.writeln(
          "${part["netCoreSyncTable"]["syncedFieldName"]}: Value(synced),");
      buffer.writeln(
          "${part["netCoreSyncTable"]["syncIdFieldName"]}: syncId != null ? Value(syncId) : Value.absent(),");
      buffer.writeln(
          "${part["netCoreSyncTable"]["knowledgeIdFieldName"]}: knowledgeId != null ? Value(knowledgeId) : Value.absent(),");
      buffer.writeln(
          "${part["netCoreSyncTable"]["deletedFieldName"]}: deleted != null ? Value(deleted) : Value.absent(),");
      buffer.writeln(") as Insertable<D>;");
      buffer.writeln("}");
    }
    buffer.writeln("} else if (entity is DataClass) {");
    for (var jsonPart in jsonParts) {
      Map<String, dynamic> part = jsonDecode(jsonPart);
      // @UseRowClass never generate data class that extends DataClass
      if (part["useRowClass"]) continue;
      buffer.writeln("if (entity is ${part["dataClassName"]}) {");
      buffer.writeln("return (entity as ${part["dataClassName"]}).copyWith(");
      buffer.writeln("${part["netCoreSyncTable"]["syncedFieldName"]}: synced,");
      buffer.writeln("${part["netCoreSyncTable"]["syncIdFieldName"]}: syncId,");
      buffer.writeln(
          "${part["netCoreSyncTable"]["knowledgeIdFieldName"]}: knowledgeId,");
      buffer
          .writeln("${part["netCoreSyncTable"]["deletedFieldName"]}: deleted,");
      buffer.writeln(") as Insertable<D>;");
      buffer.writeln("}");
    }
    buffer.writeln("} else {");
    for (var jsonPart in jsonParts) {
      Map<String, dynamic> part = jsonDecode(jsonPart);
      // @UseRowClass is processed here and expected to be mutable
      if (!part["useRowClass"]) continue;
      buffer.writeln("if (entity is ${part["dataClassName"]}) {");
      buffer.writeln(
          "(entity as ${part["dataClassName"]}).${part["netCoreSyncTable"]["syncedFieldName"]} = synced;");
      buffer.writeln(
          "if (syncId != null) { (entity as ${part["dataClassName"]}).${part["netCoreSyncTable"]["syncIdFieldName"]} = syncId; }");
      buffer.writeln(
          "if (knowledgeId != null) { (entity as ${part["dataClassName"]}).${part["netCoreSyncTable"]["knowledgeIdFieldName"]} = knowledgeId; }");
      buffer.writeln(
          "if (deleted != null) { (entity as ${part["dataClassName"]}).${part["netCoreSyncTable"]["deletedFieldName"]} = deleted; }");
      buffer.writeln("return entity;");
      buffer.writeln("}");
    }
    buffer.writeln("}");
    buffer.writeln(
        "throw NetCoreSyncException(\"Unexpected entity Type: \$entity\");");
    buffer.writeln("}");
    // END METHOD: updateSyncColumns

    buffer.writeln("}");
    // END CLASS: _$NetCoreSyncEngineUser

    // START EXTENSION: $NetCoreSyncClientExtension
    buffer.writeln();
    buffer
        .writeln("extension \$NetCoreSyncClientExtension on ${element.name} {");

    // START METHOD: netCoreSync_initialize
    buffer.writeln();
    buffer.writeln("Future<void> netCoreSyncInitialize() async {");
    buffer.writeln("await netCoreSyncInitializeClient(");
    buffer.writeln("_\$NetCoreSyncEngineUser(");
    buffer.writeln("{");
    for (var jsonPart in jsonParts) {
      Map<String, dynamic> part = jsonDecode(jsonPart);
      buffer.writeln('''
      ${part["dataClassName"]}: NetCoreSyncTableUser(
        ${ReCase(part["tableClassName"]).camelCase},
        NetCoreSyncTable.fromJson(${jsonEncode(part["netCoreSyncTable"])}),
        ${ReCase(part["tableClassName"]).camelCase}.${part["netCoreSyncTable"]["idFieldName"]}.escapedName,
        ${ReCase(part["tableClassName"]).camelCase}.${part["netCoreSyncTable"]["syncIdFieldName"]}.escapedName,
        ${ReCase(part["tableClassName"]).camelCase}.${part["netCoreSyncTable"]["knowledgeIdFieldName"]}.escapedName,
        ${ReCase(part["tableClassName"]).camelCase}.${part["netCoreSyncTable"]["syncedFieldName"]}.escapedName,
        ${ReCase(part["tableClassName"]).camelCase}.${part["netCoreSyncTable"]["deletedFieldName"]}.escapedName,
        ${jsonEncode(part["columnFieldNames"])},
      ),''');
    }
    buffer.writeln("},");
    buffer.writeln("),");
    buffer.writeln(");");
    buffer.writeln("netCoreSyncInitializeUser();");
    buffer.writeln("}");
    // END METHOD: netCoreSync_initialize

    buffer.writeln("}");
    // END EXTENSION: $NetCoreSyncClientExtension

    // START CLASSES: Sync Tables
    for (var jsonPart in jsonParts) {
      Map<String, dynamic> part = jsonDecode(jsonPart);
      buffer.writeln("");
      buffer.writeln('''
        class \$Sync${part["tableClassName"]}Table extends \$${part["tableClassName"]}Table implements SyncBaseTable<\$${part["tableClassName"]}Table, ${part["dataClassName"]}> {
          final String Function() _allSyncIds;
          \$Sync${part["tableClassName"]}Table(_\$${element.name} db, this._allSyncIds) : super(db);
          @override
          Type get type => ${part["dataClassName"]};
          @override
          String get entityName => "(SELECT * FROM \${super.entityName} WHERE \${super.${part["netCoreSyncTable"]["deletedFieldName"]}.escapedName} = 0 AND \${super.${part["netCoreSyncTable"]["syncIdFieldName"]}.escapedName} IN (\${_allSyncIds()}))";
        }
      ''');
    }
    // END CLASSES: Sync Tables

    // START MIXIN: NetCoreSyncClientUser
    buffer.writeln("");
    buffer.writeln("mixin NetCoreSyncClientUser on NetCoreSyncClient {");
    for (var jsonPart in jsonParts) {
      Map<String, dynamic> part = jsonDecode(jsonPart);
      buffer.writeln(
          "late \$Sync${part["tableClassName"]}Table _sync${part["tableClassName"]};");
    }
    buffer.writeln("");
    buffer.writeln("void netCoreSyncInitializeUser() {");
    for (var jsonPart in jsonParts) {
      Map<String, dynamic> part = jsonDecode(jsonPart);
      buffer.writeln(
          "_sync${part["tableClassName"]} = \$Sync${part["tableClassName"]}Table(netCoreSyncResolvedEngine, netCoreSyncAllSyncIds);");
    }
    buffer.writeln("}");

    for (var jsonPart in jsonParts) {
      Map<String, dynamic> part = jsonDecode(jsonPart);
      buffer.writeln("");
      buffer.writeln('''
        \$Sync${part["tableClassName"]}Table get sync${part["tableClassName"]} {
          if (!netCoreSyncInitialized) throw NetCoreSyncNotInitializedException();
          return _sync${part["tableClassName"]};
        }
      ''');
    }

    buffer.writeln("}");
    // END MIXIN: NetCoreSyncClientUser

    return buffer.toString();
  }
}
