import 'package:reflectable/reflectable.dart';
import 'sync_friendly_id.dart';
import 'sync_property.dart';

class SyncReflector extends Reflectable {
  const SyncReflector()
      : super(
          const MetadataCapability(),
          const DeclarationsCapability(),
          const InstanceInvokeMetaCapability(SyncFriendlyId),
          const InstanceInvokeMetaCapability(SyncProperty),
        );
}

const syncReflector = SyncReflector();
