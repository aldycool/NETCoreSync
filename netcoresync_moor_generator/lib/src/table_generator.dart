import 'dart:convert';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'exceptions.dart';

class TableGenerator extends GeneratorForAnnotation<NetCoreSyncTable> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw NetCoreSyncMoorGeneratorException(
          "Element that is annotated with @NetCoreSyncTable is expected to be a Class");
    }

    final netCoreSyncTable = NetCoreSyncTable(
      idFieldName: annotation.read("idFieldName").stringValue,
      syncIdFieldName: annotation.read("syncIdFieldName").stringValue,
      knowledgeIdFieldName: annotation.read("knowledgeIdFieldName").stringValue,
      syncedFieldName: annotation.read("syncedFieldName").stringValue,
      deletedFieldName: annotation.read("deletedFieldName").stringValue,
    );
    List<String> columnFieldNames = element.fields
        .where((element) => element.type
            .getDisplayString(withNullability: true)
            .startsWith("Column<"))
        .map((e) => e.name)
        .toList();

    _ModelVisitor visitor = _ModelVisitor();
    element.visitChildren(visitor);
    NetCoreSyncMoorGeneratorException? checkFieldError;
    checkFieldError = _checkFields(
      element.name,
      visitor.fields,
      netCoreSyncTable.idFieldName,
      "idFieldName",
      "Column<String?>",
      "TextColumn",
    );
    if (checkFieldError != null) throw checkFieldError;
    checkFieldError = _checkFields(
      element.name,
      visitor.fields,
      netCoreSyncTable.syncIdFieldName,
      "syncIdFieldName",
      "Column<String?>",
      "TextColumn",
    );
    if (checkFieldError != null) throw checkFieldError;
    checkFieldError = _checkFields(
      element.name,
      visitor.fields,
      netCoreSyncTable.knowledgeIdFieldName,
      "knowledgeIdFieldName",
      "Column<String?>",
      "TextColumn",
    );
    if (checkFieldError != null) throw checkFieldError;
    checkFieldError = _checkFields(
      element.name,
      visitor.fields,
      netCoreSyncTable.syncedFieldName,
      "syncedFieldName",
      "Column<bool?>",
      "BoolColumn",
    );
    if (checkFieldError != null) throw checkFieldError;
    checkFieldError = _checkFields(
      element.name,
      visitor.fields,
      netCoreSyncTable.deletedFieldName,
      "deletedFieldName",
      "Column<bool?>",
      "BoolColumn",
    );
    if (checkFieldError != null) throw checkFieldError;

    String tableClassName = element.name;
    String? dataClassName;
    bool useRowClass = false;
    ElementAnnotation? elementAnnotation =
        _getElementAnnotation(element, "UseRowClass");
    if (elementAnnotation != null) {
      dataClassName = elementAnnotation
          .computeConstantValue()!
          .getField("type")!
          .toTypeValue()!
          .getDisplayString(withNullability: false);
      useRowClass = true;
      // Must check if toJson() and factory fromJson() methods are exists (Moor's DataClass subclasses are (expected according the standard code generation) already define these methods)
      MethodElement? methodToJson = (elementAnnotation
              .computeConstantValue()!
              .getField("type")!
              .toTypeValue()! as InterfaceType)
          .methods
          .where((w) => w.name == "toJson")
          .firstOrNull;
      if (methodToJson == null ||
          methodToJson.returnType.getDisplayString(withNullability: false) !=
              "Map<String, dynamic>") {
        throw NetCoreSyncMoorGeneratorException(
            "The $dataClassName class must have an instance method called 'toJson()' that returns 'Map<String, dynamic>'. It is required for the Dart's 'jsonEncode()' function later. Please take a look at the 'json_serializable' package on how to do this properly.");
      }
      ConstructorElement? constructorFromJson = (elementAnnotation
              .computeConstantValue()!
              .getField("type")!
              .toTypeValue()! as InterfaceType)
          .constructors
          .where((w) => w.name == "fromJson")
          .firstOrNull;
      if (constructorFromJson == null ||
          constructorFromJson.parameters.isEmpty ||
          constructorFromJson.parameters[0].type
                  .getDisplayString(withNullability: false) !=
              "Map<String, dynamic>") {
        throw NetCoreSyncMoorGeneratorException(
            "The $dataClassName class must have a constructor method called 'fromJson()' with type 'Map<String, dynamic>' on its first parameter. It is required for the Dart's 'jsonDecode()' function later. Please take a look at the 'json_serializable' package on how to do this properly.");
      }
      // Must check if toCompanion() method is exists. This is needed later because we want to generate the Companion version of the Row Class, so we can protect the sync fields (and also id field if using syncWrite) by setting them to Value.absent() during updates.
      MethodElement? methodToCompanion = (elementAnnotation
              .computeConstantValue()!
              .getField("type")!
              .toTypeValue()! as InterfaceType)
          .methods
          .where((w) => w.name == "toCompanion")
          .firstOrNull;
      String toCompanionError = "";
      if (methodToCompanion == null) {
        toCompanionError = "Instance Method 'toCompanion()' not exist";
      } else if (methodToCompanion.parameters.length != 1) {
        toCompanionError =
            "The expected parameter length is 1, actual is: ${methodToCompanion.parameters.length}";
      } else if (methodToCompanion.parameters[0].type
              .getDisplayString(withNullability: false) !=
          "bool") {
        toCompanionError =
            "The expected parameter type is bool, actual is: ${methodToCompanion.parameters[0].type.getDisplayString(withNullability: false)}";
        // Now we check the return type of the method. Unfortunately, our current mechanism only returns "dynamic" for the Companion types, so we have to dive into the source code with regex
      } else if (methodToCompanion.returnType
              .getDisplayString(withNullability: false) !=
          "dynamic") {
        toCompanionError =
            "The expected return type is ${tableClassName}Companion, actual is: ${methodToCompanion.returnType.getDisplayString(withNullability: false)}";
      } else if (!RegExp("${tableClassName}Companion toCompanion\\(")
          .hasMatch(methodToCompanion.source.contents.data)) {
        toCompanionError =
            "The expected return type is ${tableClassName}Companion, actual is: ${methodToCompanion.returnType.getDisplayString(withNullability: false)}";
      }
      if (toCompanionError.isNotEmpty) {
        throw NetCoreSyncMoorGeneratorException(
            "Error: $toCompanionError. NOTE: The $dataClassName class must have an instance method called 'toCompanion()' with 1 bool argument called 'nullToAbsent' that returns '${tableClassName}Companion'. This is required for the NETCoreSync's syncWrite() and syncReplace() internal implementations later during updates. This should be implemented exactly like Moor does, by returning an instance of '${tableClassName}Companion' where it is constructed by passing all of your Row Class fields values, and each of those fields values is wrapped with the 'Value()' class. Take a look on how Moor implement it for your tables that 'extends DataClass' in the generated '*.g.dart' file, especially when handling the 'nullToAbsent' argument, where it is expected to use Value.absent() for your nullable fields if the 'nullToAbsent' parameter is set to 'true'.");
      }
    } else {
      dataClassName = tableClassName.substring(0, tableClassName.length - 1);
      elementAnnotation = _getElementAnnotation(element, "DataClassName");
      if (elementAnnotation != null) {
        dataClassName = elementAnnotation
            .computeConstantValue()!
            .getField("name")!
            .toStringValue();
      }
    }

    StringBuffer buffer = StringBuffer();
    Map<String, dynamic> content = {};
    content["tableClassName"] = tableClassName;
    content["dataClassName"] = dataClassName;
    content["useRowClass"] = useRowClass;
    content["netCoreSyncTable"] = netCoreSyncTable;
    content["columnFieldNames"] = columnFieldNames;
    buffer.write("/* PART-MARKER */");
    buffer.write("// ${jsonEncode(content)}");
    return buffer.toString();
  }

  NetCoreSyncMoorGeneratorException? _checkFields(
      String className,
      Map<String, FieldElement> map,
      String name,
      String specName,
      String expectedType,
      String expectedTypeInfo) {
    if (!(map.containsKey(name) &&
        map[name]!.type.getDisplayString(withNullability: true) ==
            expectedType)) {
      return NetCoreSyncMoorGeneratorException(
          "$className requires a column with name: $name and type: $expectedTypeInfo to be present (as specified by its @NetCoreSyncTable's $specName annotation)");
    }
    return null;
  }

  ElementAnnotation? _getElementAnnotation(Element element, String typeName) {
    return element.metadata.firstWhereOrNull((w) =>
        w.element != null &&
        w.element is ConstructorElement &&
        (w.element as ConstructorElement)
                .returnType
                .getDisplayString(withNullability: true) ==
            typeName);
  }
}

class _ModelVisitor extends SimpleElementVisitor {
  Map<String, FieldElement> fields = {};

  @override
  visitFieldElement(FieldElement element) {
    fields[element.name] = element;
    return super.visitFieldElement(element);
  }
}
