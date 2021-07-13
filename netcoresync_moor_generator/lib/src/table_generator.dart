import 'dart:convert';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'exceptions.dart';

class TableGenerator extends GeneratorForAnnotation<NetCoreSyncTable> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement)
      throw NetCoreSyncMoorGeneratorException(
          "Element that is annotated with @NetCoreSyncTable is expected to be a Class");

    final netCoreSyncTable = NetCoreSyncTable(
      mapToClassName: annotation.read("mapToClassName").stringValue,
      idFieldName: annotation.read("idFieldName").stringValue,
      timeStampFieldName: annotation.read("timeStampFieldName").stringValue,
      deletedFieldName: annotation.read("deletedFieldName").stringValue,
      knowledgeIdFieldName: annotation.read("knowledgeIdFieldName").stringValue,
    );

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
      netCoreSyncTable.timeStampFieldName,
      "timeStampFieldName",
      "Column<int?>",
      "IntColumn",
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
    checkFieldError = _checkFields(
      element.name,
      visitor.fields,
      netCoreSyncTable.knowledgeIdFieldName,
      "knowledgeIdFieldName",
      "Column<String?>",
      "TextColumn",
    );
    if (checkFieldError != null) throw checkFieldError;

    String tableClassName = element.name;
    String? dataClassName = null;
    bool useRowClass = false;
    ElementAnnotation? elementAnnotation =
        _getElementAnnotation(element, "DataClassName");
    if (elementAnnotation != null) {
      dataClassName = elementAnnotation
          .computeConstantValue()!
          .getField("name")!
          .toStringValue();
    } else {
      elementAnnotation = _getElementAnnotation(element, "UseRowClass");
      if (elementAnnotation != null) {
        dataClassName = elementAnnotation
            .computeConstantValue()!
            .getField("type")!
            .toTypeValue()!
            .getDisplayString(withNullability: false);
        useRowClass = true;
      }
    }
    if (dataClassName == null)
      throw NetCoreSyncMoorGeneratorException(
          "Unable to detect the proper usage of Moor's @DataClassName or Moor's @UserRowClass on $tableClassName annotation");

    StringBuffer buffer = StringBuffer();
    Map<String, dynamic> content = {};
    content["tableClassName"] = tableClassName;
    content["dataClassName"] = dataClassName;
    content["useRowClass"] = useRowClass;
    content["netCoreSyncTable"] = netCoreSyncTable;
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
