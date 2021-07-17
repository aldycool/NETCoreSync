import 'dart:convert';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:recase/recase.dart';
import 'package:moor/moor.dart';
import 'exceptions.dart';

class NetCoreSyncClientGenerator extends GeneratorForAnnotation<UseMoor> {
  static const String NAME_CLASS_CLIENT = "NetCoreSyncClient";
  static const String NAME_CLASS_KNOWLEDGE = "NetCoreSyncKnowledges";

  @override
  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    // Pre-check some conditions
    if (element is! ClassElement)
      throw NetCoreSyncMoorGeneratorException(
          "Element that is annotated with @UseMoor is expected to be a Class");
    if (element.mixins
            .where((w) =>
                w.getDisplayString(withNullability: true) == NAME_CLASS_CLIENT)
            .length ==
        0)
      throw NetCoreSyncMoorGeneratorException(
          "The database class (${element.name}) is expected to be 'mixin' with $NAME_CLASS_CLIENT (for example: 'class Database extends _\$Database with $NAME_CLASS_CLIENT')");
    if (annotation
            .read("tables")
            .listValue
            .where((w) =>
                w
                    .toTypeValue()
                    ?.getDisplayString(withNullability: true)
                    .contains(NAME_CLASS_KNOWLEDGE) ??
                false)
            .length ==
        0)
      throw NetCoreSyncMoorGeneratorException(
          "The $NAME_CLASS_KNOWLEDGE table must be included in UseMoor's tables");

    // Collect NetCoreSyncTable's parts
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

    // Perform code generation
    StringBuffer buffer = StringBuffer();

    if (jsonParts.length == 0) {
      buffer.writeln(
          "// NOTE: NetCoreSyncExtension does not generate any codes because classes annotated with @NetCoreSyncTable were not found");
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

    // START METHOD: getSyncColumnValue
    buffer.writeln();
    buffer.writeln("@override");
    buffer.writeln(
        "Object? getSyncColumnValue<D>(Insertable<D> entity, String fieldName) {");
    buffer.writeln("if (entity is UpdateCompanion<D>) {");
    for (var jsonPart in jsonParts) {
      Map<String, dynamic> part = jsonDecode(jsonPart);
      buffer.writeln("if (D == ${part["dataClassName"]}) {");
      buffer.writeln("switch (fieldName) {");
      buffer.writeln("case\"id\":");
      buffer.writeln(
          "return (entity as ${part["tableClassName"]}Companion).${part["netCoreSyncTable"]["idFieldName"]} == Value.absent() ? null : (entity as ${part["tableClassName"]}Companion).${part["netCoreSyncTable"]["idFieldName"]}.value;");
      buffer.writeln("case\"timeStamp\":");
      buffer.writeln(
          "return (entity as ${part["tableClassName"]}Companion).${part["netCoreSyncTable"]["timeStampFieldName"]} == Value.absent() ? null : (entity as ${part["tableClassName"]}Companion).${part["netCoreSyncTable"]["timeStampFieldName"]}.value;");
      buffer.writeln("case\"deleted\":");
      buffer.writeln(
          "return (entity as ${part["tableClassName"]}Companion).${part["netCoreSyncTable"]["deletedFieldName"]} == Value.absent() ? null : (entity as ${part["tableClassName"]}Companion).${part["netCoreSyncTable"]["deletedFieldName"]}.value;");
      buffer.writeln("case\"knowledgeId\":");
      buffer.writeln(
          "return (entity as ${part["tableClassName"]}Companion).${part["netCoreSyncTable"]["knowledgeIdFieldName"]} == Value.absent() ? null : (entity as ${part["tableClassName"]}Companion).${part["netCoreSyncTable"]["knowledgeIdFieldName"]}.value;");
      buffer.writeln("}");
      buffer.writeln("}");
    }
    buffer.writeln("} else {");
    for (var jsonPart in jsonParts) {
      Map<String, dynamic> part = jsonDecode(jsonPart);
      buffer.writeln("if (entity is ${part["dataClassName"]}) {");
      buffer.writeln("switch (fieldName) {");
      buffer.writeln("case\"id\":");
      buffer.writeln(
          "return (entity as ${part["dataClassName"]}).${part["netCoreSyncTable"]["idFieldName"]};");
      buffer.writeln("case\"timeStamp\":");
      buffer.writeln(
          "return (entity as ${part["dataClassName"]}).${part["netCoreSyncTable"]["timeStampFieldName"]};");
      buffer.writeln("case\"deleted\":");
      buffer.writeln(
          "return (entity as ${part["dataClassName"]}).${part["netCoreSyncTable"]["deletedFieldName"]};");
      buffer.writeln("case\"knowledgeId\":");
      buffer.writeln(
          "return (entity as ${part["dataClassName"]}).${part["netCoreSyncTable"]["knowledgeIdFieldName"]};");
      buffer.writeln("}");
      buffer.writeln("}");
    }
    buffer.writeln("}");
    buffer.writeln(
        "throw NetCoreSyncException(\"Unexpected entity Type: \$entity, fieldName: \$fieldName\");");
    buffer.writeln("}");
    // END METHOD: getSyncColumnValue

    // START METHOD: updateSyncColumns
    buffer.writeln();
    buffer.writeln("@override");
    buffer.writeln(
        "Insertable<D> updateSyncColumns<D>(Insertable<D> entity, {required int timeStamp, bool? deleted,}) {");
    buffer.writeln("if (entity is RawValuesInsertable<D>) {");
    buffer.writeln(
        "entity.data[tables[D]!.timeStampEscapedName] = Constant(timeStamp);");
    buffer.writeln(
        "entity.data[tables[D]!.knowledgeIdEscapedName] = Constant(null);");
    buffer.writeln(
        "if (deleted != null) entity.data[tables[D]!.deletedEscapedName] = Constant(deleted);");
    buffer.writeln("return entity;");
    buffer.writeln("} else if (entity is UpdateCompanion<D>) {");
    for (var jsonPart in jsonParts) {
      Map<String, dynamic> part = jsonDecode(jsonPart);
      buffer.writeln("if (D == ${part["dataClassName"]}) {");
      buffer.writeln(
          "return (entity as ${part["tableClassName"]}Companion).copyWith(");
      buffer.writeln(
          "${part["netCoreSyncTable"]["timeStampFieldName"]}: Value(timeStamp),");
      buffer.writeln(
          "${part["netCoreSyncTable"]["knowledgeIdFieldName"]}: Value(null),");
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
      buffer.writeln(
          "${part["netCoreSyncTable"]["timeStampFieldName"]}: timeStamp,");
      buffer.writeln(
          "${part["netCoreSyncTable"]["knowledgeIdFieldName"]}: null,");
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
          "(entity as ${part["dataClassName"]}).${part["netCoreSyncTable"]["timeStampFieldName"]} = timeStamp;");
      buffer.writeln(
          "(entity as ${part["dataClassName"]}).${part["netCoreSyncTable"]["knowledgeIdFieldName"]} = null;");
      buffer.writeln(
          "if (deleted != null) (entity as ${part["dataClassName"]}).${part["netCoreSyncTable"]["deletedFieldName"]} = deleted;");
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
    buffer.writeln("Future<void> netCoreSync_initialize() async {");
    buffer.writeln("await netCoreSync_initializeImpl(");
    buffer.writeln("_\$NetCoreSyncEngineUser(");
    buffer.writeln("{");
    for (var jsonPart in jsonParts) {
      Map<String, dynamic> part = jsonDecode(jsonPart);
      buffer.writeln('''
      ${part["dataClassName"]}: NetCoreSyncTableUser(
        ${ReCase(part["tableClassName"]).camelCase},
        NetCoreSyncTable.fromJson(${jsonEncode(part["netCoreSyncTable"])}),
        ${ReCase(part["tableClassName"]).camelCase}.${part["netCoreSyncTable"]["idFieldName"]}.escapedName,
        ${ReCase(part["tableClassName"]).camelCase}.${part["netCoreSyncTable"]["timeStampFieldName"]}.escapedName,
        ${ReCase(part["tableClassName"]).camelCase}.${part["netCoreSyncTable"]["deletedFieldName"]}.escapedName,
        ${ReCase(part["tableClassName"]).camelCase}.${part["netCoreSyncTable"]["knowledgeIdFieldName"]}.escapedName,
      ),''');
    }
    buffer.writeln("},");
    buffer.writeln("),");
    buffer.writeln(");");
    buffer.writeln("}");
    // END METHOD: netCoreSync_initialize

    buffer.writeln("}");
    // END EXTENSION: $NetCoreSyncClientExtension

    return buffer.toString();
  }
}
