enum PropertyIndicatorEnum {
  id,
  lastUpdated,
  deleted,
  databaseInstanceId,
}

class SyncProperty {
  final PropertyIndicatorEnum propertyIndicator;
  const SyncProperty({required this.propertyIndicator});
}
