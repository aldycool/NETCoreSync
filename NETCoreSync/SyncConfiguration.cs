using System;
using System.Collections.Generic;
using System.Text;
using System.Reflection;
using System.Linq;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NETCoreSync.Exceptions;

namespace NETCoreSync
{
    public class SyncConfiguration
    {
        public enum TimeStampStrategyEnum
        {
            UseGlobalTimeStamp,
            UseEachDatabaseInstanceTimeStamp
        }

        internal TimeStampStrategyEnum TimeStampStrategy = TimeStampStrategyEnum.UseGlobalTimeStamp;
        internal readonly List<Type> SyncTypes = new List<Type>();
        internal readonly Dictionary<Type, SchemaInfo> SyncSchemaInfos = new Dictionary<Type, SchemaInfo>();

        public SyncConfiguration(Assembly[] assemblies) : this(assemblies, TimeStampStrategyEnum.UseGlobalTimeStamp)
        {
        }

        public SyncConfiguration(Assembly[] assemblies, TimeStampStrategyEnum timeStampStrategy)
        {
            if (assemblies == null) throw new NullReferenceException(nameof(assemblies));
            Type[] types = assemblies.SelectMany(sm => sm.GetTypes()).Where(w => Attribute.IsDefined(w, typeof(SyncSchemaAttribute))).ToArray();
            Build(types, timeStampStrategy);
        }

        public SyncConfiguration(Type[] types) : this(types, TimeStampStrategyEnum.UseGlobalTimeStamp)
        {
        }

        public SyncConfiguration(Type[] types, TimeStampStrategyEnum timeStampStrategy)
        {
            if (types == null) throw new NullReferenceException(nameof(types));
            Build(types, timeStampStrategy);
        }

        private void Build(Type[] types, TimeStampStrategyEnum timeStampStrategy)
        {
            TimeStampStrategy = timeStampStrategy;

            SyncTypes.Clear();
            SyncSchemaInfos.Clear();

            for (int i = 0; i < types.Length; i++)
            {
                Type type = types[i];
                if (SyncTypes.Contains(type)) throw new SyncConfigurationDuplicateTypeException(type);

                SchemaInfo schemaInfo = new SchemaInfo();

                schemaInfo.SyncSchemaAttribute = type.GetCustomAttribute<SyncSchemaAttribute>();
                if (schemaInfo.SyncSchemaAttribute == null) throw new SyncConfigurationMissingSyncSchemaAttributeException(type);

                PropertyInfo propertyInfoId = type.GetProperties().Where(w => w.GetCustomAttribute<SyncPropertyAttribute>() != null && w.GetCustomAttribute<SyncPropertyAttribute>().PropertyIndicator == SyncPropertyAttribute.PropertyIndicatorEnum.Id).FirstOrDefault();
                if (propertyInfoId == null) throw new SyncConfigurationMissingSyncPropertyAttributeException(SyncPropertyAttribute.PropertyIndicatorEnum.Id, type);
                schemaInfo.PropertyInfoId = new SchemaInfoProperty() { Name = propertyInfoId.Name, PropertyType = propertyInfoId.PropertyType.FullName };

                PropertyInfo propertyInfoLastUpdated = type.GetProperties().Where(w => w.GetCustomAttribute<SyncPropertyAttribute>() != null && w.GetCustomAttribute<SyncPropertyAttribute>().PropertyIndicator == SyncPropertyAttribute.PropertyIndicatorEnum.LastUpdated).FirstOrDefault();
                if (propertyInfoLastUpdated == null) throw new SyncConfigurationMissingSyncPropertyAttributeException(SyncPropertyAttribute.PropertyIndicatorEnum.LastUpdated, type);
                if (propertyInfoLastUpdated.PropertyType != typeof(long)) throw new SyncConfigurationMismatchPropertyTypeException(propertyInfoLastUpdated, typeof(long), type);
                schemaInfo.PropertyInfoLastUpdated = new SchemaInfoProperty() { Name = propertyInfoLastUpdated.Name, PropertyType = propertyInfoLastUpdated.PropertyType.FullName };

                PropertyInfo propertyInfoDeleted = type.GetProperties().Where(w => w.GetCustomAttribute<SyncPropertyAttribute>() != null && w.GetCustomAttribute<SyncPropertyAttribute>().PropertyIndicator == SyncPropertyAttribute.PropertyIndicatorEnum.Deleted).FirstOrDefault();
                if (propertyInfoDeleted == null) throw new SyncConfigurationMissingSyncPropertyAttributeException(SyncPropertyAttribute.PropertyIndicatorEnum.Deleted, type);
                if (TimeStampStrategy == TimeStampStrategyEnum.UseGlobalTimeStamp && propertyInfoDeleted.PropertyType != typeof(long?)) throw new SyncConfigurationMismatchPropertyTypeException(propertyInfoDeleted, typeof(long?), type);
                if (TimeStampStrategy == TimeStampStrategyEnum.UseEachDatabaseInstanceTimeStamp && propertyInfoDeleted.PropertyType != typeof(bool)) throw new SyncConfigurationMismatchPropertyTypeException(propertyInfoDeleted, typeof(bool), type);
                schemaInfo.PropertyInfoDeleted = new SchemaInfoProperty() { Name = propertyInfoDeleted.Name, PropertyType = propertyInfoDeleted.PropertyType.FullName };

                PropertyInfo propertyInfoFriendlyId = type.GetProperties().Where(w => w.GetCustomAttribute<SyncFriendlyIdAttribute>() != null).FirstOrDefault();
                if (propertyInfoFriendlyId != null)
                {
                    if (propertyInfoFriendlyId.PropertyType != typeof(string)) throw new SyncConfigurationMismatchPropertyTypeException(propertyInfoFriendlyId, typeof(string), type);
                    schemaInfo.PropertyInfoFriendlyId = new SchemaInfoProperty() { Name = propertyInfoFriendlyId.Name, PropertyType = propertyInfoFriendlyId.PropertyType.FullName };
                }

                if (TimeStampStrategy == TimeStampStrategyEnum.UseEachDatabaseInstanceTimeStamp)
                {
                    PropertyInfo propertyInfoDatabaseInstanceId = type.GetProperties().Where(w => w.GetCustomAttribute<SyncPropertyAttribute>() != null && w.GetCustomAttribute<SyncPropertyAttribute>().PropertyIndicator == SyncPropertyAttribute.PropertyIndicatorEnum.DatabaseInstanceId).FirstOrDefault();
                    if (propertyInfoDatabaseInstanceId == null) throw new SyncConfigurationMissingSyncPropertyAttributeException(SyncPropertyAttribute.PropertyIndicatorEnum.DatabaseInstanceId, type);
                    if (propertyInfoDatabaseInstanceId.PropertyType != typeof(string)) throw new SyncConfigurationMismatchPropertyTypeException(propertyInfoDatabaseInstanceId, typeof(string), type);
                    schemaInfo.PropertyInfoDatabaseInstanceId = new SchemaInfoProperty() { Name = propertyInfoDatabaseInstanceId.Name, PropertyType = propertyInfoDatabaseInstanceId.PropertyType.FullName };
                }

                SyncTypes.Add(type);
                SyncSchemaInfos.Add(type, schemaInfo);
            }
        }

        internal class SchemaInfo
        {
            public SyncSchemaAttribute SyncSchemaAttribute { get; set; }
            public SchemaInfoProperty PropertyInfoId { get; set; }
            public SchemaInfoProperty PropertyInfoLastUpdated { get; set; }
            public SchemaInfoProperty PropertyInfoDeleted { get; set; }
            public SchemaInfoProperty PropertyInfoFriendlyId { get; set; }
            public SchemaInfoProperty PropertyInfoDatabaseInstanceId { get; set; }

            public static SchemaInfo FromJObject(JObject jObject)
            {
                SchemaInfo schemaInfo = new SchemaInfo();

                schemaInfo.SyncSchemaAttribute = new SyncSchemaAttribute()
                {
                    MapToClassName = jObject.SelectToken($"{nameof(SyncSchemaAttribute)}.{nameof(schemaInfo.SyncSchemaAttribute.MapToClassName)}").Value<string>()
                };

                schemaInfo.PropertyInfoId = new SchemaInfoProperty()
                {
                    Name = jObject.SelectToken($"{nameof(PropertyInfoId)}.{nameof(schemaInfo.PropertyInfoId.Name)}").Value<string>(),
                    PropertyType = jObject.SelectToken($"{nameof(PropertyInfoId)}.{nameof(schemaInfo.PropertyInfoId.PropertyType)}").Value<string>()
                };

                schemaInfo.PropertyInfoLastUpdated = new SchemaInfoProperty()
                {
                    Name = jObject.SelectToken($"{nameof(PropertyInfoLastUpdated)}.{nameof(schemaInfo.PropertyInfoLastUpdated.Name)}").Value<string>(),
                    PropertyType = jObject.SelectToken($"{nameof(PropertyInfoLastUpdated)}.{nameof(schemaInfo.PropertyInfoLastUpdated.PropertyType)}").Value<string>()
                };

                schemaInfo.PropertyInfoDeleted = new SchemaInfoProperty()
                {
                    Name = jObject.SelectToken($"{nameof(PropertyInfoDeleted)}.{nameof(schemaInfo.PropertyInfoDeleted.Name)}").Value<string>(),
                    PropertyType = jObject.SelectToken($"{nameof(PropertyInfoDeleted)}.{nameof(schemaInfo.PropertyInfoDeleted.PropertyType)}").Value<string>()
                };

                if (jObject[nameof(PropertyInfoFriendlyId)] != null)
                {
                    schemaInfo.PropertyInfoFriendlyId = new SchemaInfoProperty()
                    {
                        Name = jObject.SelectToken($"{nameof(PropertyInfoFriendlyId)}.{nameof(schemaInfo.PropertyInfoFriendlyId.Name)}").Value<string>(),
                        PropertyType = jObject.SelectToken($"{nameof(PropertyInfoFriendlyId)}.{nameof(schemaInfo.PropertyInfoFriendlyId.PropertyType)}").Value<string>()
                    };
                }

                if (jObject[nameof(PropertyInfoDatabaseInstanceId)] != null)
                {
                    schemaInfo.PropertyInfoDatabaseInstanceId = new SchemaInfoProperty()
                    {
                        Name = jObject.SelectToken($"{nameof(PropertyInfoDatabaseInstanceId)}.{nameof(schemaInfo.PropertyInfoDatabaseInstanceId.Name)}").Value<string>(),
                        PropertyType = jObject.SelectToken($"{nameof(PropertyInfoDatabaseInstanceId)}.{nameof(schemaInfo.PropertyInfoDatabaseInstanceId.PropertyType)}").Value<string>()
                    };
                }

                return schemaInfo;
            }

            public JObject ToJObject()
            {
                JObject jObject = new JObject();

                JObject jObjectSyncSchemaAttribute = new JObject();
                jObjectSyncSchemaAttribute[nameof(SyncSchemaAttribute.MapToClassName)] = SyncSchemaAttribute.MapToClassName;
                jObject[nameof(SyncSchemaAttribute)] = jObjectSyncSchemaAttribute;

                JObject jObjectPropertyInfoId = new JObject();
                jObjectPropertyInfoId[nameof(PropertyInfoId.Name)] = PropertyInfoId.Name;
                jObjectPropertyInfoId[nameof(PropertyInfoId.PropertyType)] = PropertyInfoId.PropertyType;
                jObject[nameof(PropertyInfoId)] = jObjectPropertyInfoId;

                JObject jObjectPropertyInfoLastUpdated = new JObject();
                jObjectPropertyInfoLastUpdated[nameof(PropertyInfoLastUpdated.Name)] = PropertyInfoLastUpdated.Name;
                jObjectPropertyInfoLastUpdated[nameof(PropertyInfoLastUpdated.PropertyType)] = PropertyInfoLastUpdated.PropertyType;
                jObject[nameof(PropertyInfoLastUpdated)] = jObjectPropertyInfoLastUpdated;

                JObject jObjectPropertyInfoDeleted = new JObject();
                jObjectPropertyInfoDeleted[nameof(PropertyInfoDeleted.Name)] = PropertyInfoDeleted.Name;
                jObjectPropertyInfoDeleted[nameof(PropertyInfoDeleted.PropertyType)] = PropertyInfoDeleted.PropertyType;
                jObject[nameof(PropertyInfoDeleted)] = jObjectPropertyInfoDeleted;

                if (PropertyInfoFriendlyId != null)
                {
                    JObject jObjectPropertyInfoFriendlyId = new JObject();
                    jObjectPropertyInfoFriendlyId[nameof(PropertyInfoFriendlyId.Name)] = PropertyInfoFriendlyId.Name;
                    jObjectPropertyInfoFriendlyId[nameof(PropertyInfoFriendlyId.PropertyType)] = PropertyInfoFriendlyId.PropertyType;
                    jObject[nameof(PropertyInfoFriendlyId)] = jObjectPropertyInfoFriendlyId;
                }

                if (PropertyInfoDatabaseInstanceId != null)
                {
                    JObject jObjectPropertyInfoDatabaseInstanceId = new JObject();
                    jObjectPropertyInfoDatabaseInstanceId[nameof(PropertyInfoDatabaseInstanceId.Name)] = PropertyInfoDatabaseInstanceId.Name;
                    jObjectPropertyInfoDatabaseInstanceId[nameof(PropertyInfoDatabaseInstanceId.PropertyType)] = PropertyInfoDatabaseInstanceId.PropertyType;
                    jObject[nameof(PropertyInfoDatabaseInstanceId)] = jObjectPropertyInfoDatabaseInstanceId;
                }

                return jObject;
            }
        }

        internal class SchemaInfoProperty
        {
            public string Name { get; set; }
            public string PropertyType { get; set; }
        }
    }
}
