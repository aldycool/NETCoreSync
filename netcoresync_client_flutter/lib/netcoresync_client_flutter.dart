library netcoresync_client_flutter;

export 'src/annotations/sync_schema.dart';
export 'src/annotations/sync_property.dart';
export 'src/annotations/sync_friendly_id.dart';
export 'src/annotations/sync_reflector.dart';

import 'package:netcoresync_client_flutter/src/annotations/sync_friendly_id.dart';
import 'package:netcoresync_client_flutter/src/annotations/sync_property.dart';
import 'package:netcoresync_client_flutter/src/annotations/sync_reflector.dart';
import 'package:netcoresync_client_flutter/src/annotations/sync_schema.dart';
import 'package:reflectable/reflectable.dart';

void netcoresync_doTests(Function() initializeReflectable, Object testData) {
  initializeReflectable();
  for (ClassMirror item in syncReflector.annotatedClasses) {
    print("annotatedClass: ${item.reflectedType}");
  }
  ClassMirror classMirror = syncReflector.annotatedClasses.first;
  Iterable<Object> syncSchemas =
      classMirror.metadata.where((element) => element is SyncSchema);
  if (syncSchemas.length > 0) {
    print(
        "SyncSchema.mapToClassName = ${(syncSchemas.first as SyncSchema).mapToClassName}");
  }
  InstanceMirror instanceMirror = syncReflector.reflect(testData);
  classMirror.declarations.forEach((key, value) {
    Iterable<Object> syncFriendlyIds =
        value.metadata.where((element) => element is SyncFriendlyId);
    Iterable<Object> syncProperties =
        value.metadata.where((element) => element is SyncProperty);
    if (syncFriendlyIds.length > 0) {
      print("$key = SyncFriendlyId");
      instanceMirror.invokeSetter(key, "ABCDEF");
      print("setter + getter: ${instanceMirror.invokeGetter(key)}");
    } else if (syncProperties.length > 0) {
      SyncProperty syncProperty = syncProperties.first as SyncProperty;
      print(
          "$key = SyncProperty: ${syncProperty.propertyIndicator.toString()}");
      if (syncProperty.propertyIndicator == PropertyIndicatorEnum.id) {
        instanceMirror.invokeSetter(key, "ABCDEF");
        print("setter + getter: ${instanceMirror.invokeGetter(key)}");
      } else if (syncProperty.propertyIndicator ==
          PropertyIndicatorEnum.lastUpdated) {
        instanceMirror.invokeSetter(key, 123456);
        print("setter + getter: ${instanceMirror.invokeGetter(key)}");
      } else if (syncProperty.propertyIndicator ==
          PropertyIndicatorEnum.deleted) {
        instanceMirror.invokeSetter(key, true);
        print("setter + getter: ${instanceMirror.invokeGetter(key)}");
      }
    }
  });
}

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}
