using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using System.Linq.Expressions;
using System.Linq.Dynamic.Core;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NETCoreSync.Exceptions;
using System.Reflection;
using System.IO;
using System.IO.Compression;

namespace NETCoreSync
{
    public abstract class SyncEngine
    {
        internal readonly SyncConfiguration SyncConfiguration;

        public SyncEngine(SyncConfiguration syncConfiguration)
        {
            SyncConfiguration = syncConfiguration ?? throw new NullReferenceException(nameof(syncConfiguration));
        }

        public enum OperationType
        {
            GetChanges = 1,
            ApplyChanges = 2
        }

        public abstract bool IsServerEngine();

        public abstract long GetClientLastSync();

        public abstract void SetClientLastSync(long lastSync);

        public virtual object StartTransaction(Type classType, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            return null;
        }

        public virtual void CommitTransaction(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
        }

        public virtual void RollbackTransaction(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
        }

        public virtual void EndTransaction(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
        }

        public abstract IQueryable GetQueryable(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo);

        public abstract string SerializeDataToJson(Type classType, object data, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo);

        public abstract object DeserializeJsonToNewData(Type classType, JObject jObject, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo);

        public abstract object DeserializeJsonToExistingData(Type classType, JObject jObject, object data, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo);

        public abstract void PersistData(Type classType, object data, bool isNew, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo);

        public virtual object TransformIdType(Type classType, JValue id, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            return id;
        }

        public virtual void PostEventDelete(Type classType, object id, string synchronizationId, Dictionary<string, object> customInfo)
        {
        }

        public void HookPreInsertOrUpdate(object data)
        {
            if (data == null) throw new NullReferenceException(nameof(data));
            long nowTicks = GetNowTicks();
            if (!IsServerEngine())
            {
                long lastSync = GetClientLastSync();
                if (nowTicks <= lastSync) throw new SyncEngineConstraintException("System Date and Time is older than the lastSync value");
            }
            SyncConfiguration.SchemaInfo schemaInfo = GetSchemaInfo(SyncConfiguration, data.GetType());
            data.GetType().GetProperty(schemaInfo.PropertyInfoLastUpdated.Name).SetValue(data, nowTicks);
        }

        public void HookPreDelete(object data)
        {
            if (data == null) throw new NullReferenceException(nameof(data));
            long nowTicks = GetNowTicks();
            if (!IsServerEngine())
            {
                long lastSync = GetClientLastSync();
                if (nowTicks <= lastSync) throw new SyncEngineConstraintException("System Date and Time is older than the lastSync value");
            }
            SyncConfiguration.SchemaInfo schemaInfo = GetSchemaInfo(SyncConfiguration, data.GetType());
            data.GetType().GetProperty(schemaInfo.PropertyInfoDeleted.Name).SetValue(data, nowTicks);
        }

        internal (byte[] compressed, long maxTimeStamp, List<SyncLog.SyncLogData> logChanges) PreparePayload(List<string> log, string synchronizationId, long? lastSync = null, Dictionary<string, object> customInfo = null, Dictionary<Type, List<object>> dictAppliedIds = null)
        {
            if (string.IsNullOrEmpty(synchronizationId)) throw new NullReferenceException(nameof(synchronizationId));
            if (lastSync == null) lastSync = GetMinValueTicks();
            if (customInfo == null) customInfo = new Dictionary<string, object>();
            long maxTimeStamp = GetMinValueTicks();
            List<SyncLog.SyncLogData> logChanges = new List<SyncLog.SyncLogData>();

            log.Add($"Preparing Data Since LastSync: {lastSync}");
            JObject payload = new JObject();
            payload[nameof(synchronizationId)] = synchronizationId;
            payload[nameof(lastSync)] = lastSync;
            payload[nameof(customInfo)] = JObject.FromObject(customInfo);

            JArray changes = new JArray();
            log.Add($"SyncTypes Count: {SyncConfiguration.SyncTypes.Count}");
            for (int i = 0; i < SyncConfiguration.SyncTypes.Count; i++)
            {
                Type syncType = SyncConfiguration.SyncTypes[i];
                log.Add($"Processing Type: {syncType.Name} ({i + 1} of {SyncConfiguration.SyncTypes.Count})");
                log.Add($"Getting Type Changes...");
                List<object> appliedIds = null;
                if (dictAppliedIds != null && dictAppliedIds.ContainsKey(syncType)) appliedIds = dictAppliedIds[syncType];
                (JObject typeChanges, int typeChangesCount, long typeMaxTimeStamp, List<SyncLog.SyncLogData> typeLogChanges) = GetTypeChanges(lastSync, syncType, synchronizationId, customInfo, appliedIds);
                log.Add($"Type Changes Count: {typeChangesCount}");
                if (typeChangesCount != 0 && typeChanges != null) changes.Add(typeChanges);
                if (typeMaxTimeStamp > maxTimeStamp) maxTimeStamp = typeMaxTimeStamp;
                logChanges.AddRange(typeLogChanges);
                log.Add($"Type: {syncType.Name} Processed");
            }
            payload[nameof(changes)] = changes;

            log.Add($"Compressing Type Changes...");
            string jsonPayload = JsonConvert.SerializeObject(payload);
            byte[] compressed = Compress(jsonPayload);
            log.Add($"Type Changes Compressed");

            return (compressed, maxTimeStamp, logChanges);
        }

        internal (JObject typeChanges, int typeChangesCount, long maxTimeStamp, List<SyncLog.SyncLogData> logChanges) GetTypeChanges(long? lastSync, Type syncType, string synchronizationId, Dictionary<string, object> customInfo, List<object> appliedIds)
        {
            if (string.IsNullOrEmpty(synchronizationId)) throw new NullReferenceException(nameof(synchronizationId));
            if (lastSync == null) lastSync = GetMinValueTicks();
            if (customInfo == null) customInfo = new Dictionary<string, object>();
            long maxTimeStamp = GetMinValueTicks();
            List<SyncLog.SyncLogData> logChanges = new List<SyncLog.SyncLogData>();
            SyncConfiguration.SchemaInfo schemaInfo = GetSchemaInfo(SyncConfiguration, syncType);
            JObject typeChanges = null;
            JArray datas = new JArray();

            OperationType operationType = OperationType.GetChanges;
            object transaction = StartTransaction(syncType, operationType, synchronizationId, customInfo);
            try
            {
                IQueryable queryable = InvokeGetQueryable(syncType, transaction, operationType, synchronizationId, customInfo);
                if (appliedIds == null || appliedIds.Count == 0)
                {
                    queryable = queryable.Where($"{schemaInfo.PropertyInfoLastUpdated.Name} > @0 || ({schemaInfo.PropertyInfoDeleted.Name} != null && {schemaInfo.PropertyInfoDeleted.Name} > @1)", lastSync.Value, lastSync);
                }
                else
                {
                    Type typeId = Type.GetType(schemaInfo.PropertyInfoId.PropertyType, true);
                    MethodInfo miCast = typeof(Enumerable).GetMethod("Cast").MakeGenericMethod(typeId);
                    object appliedIdsTypeId = miCast.Invoke(appliedIds, new object[] { appliedIds });
                    queryable = queryable.Where($"({schemaInfo.PropertyInfoLastUpdated.Name} > @0 || ({schemaInfo.PropertyInfoDeleted.Name} != null && {schemaInfo.PropertyInfoDeleted.Name} > @1)) && !(@2.Contains({schemaInfo.PropertyInfoId.Name}))", lastSync.Value, lastSync, appliedIdsTypeId);
                }
                queryable = queryable.OrderBy($"{schemaInfo.PropertyInfoDeleted.Name}, {schemaInfo.PropertyInfoLastUpdated.Name}");
                List<dynamic> dynamicDatas = queryable.ToDynamicList();
                if (dynamicDatas.Count > 0)
                {
                    typeChanges = new JObject();
                    typeChanges[nameof(syncType)] = syncType.Name;
                    typeChanges[nameof(schemaInfo)] = schemaInfo.ToJObject();
                    foreach (dynamic dynamicData in dynamicDatas)
                    {
                        JObject jObjectData = InvokeSerializeDataToJson(syncType, dynamicData, schemaInfo, transaction, operationType, synchronizationId, customInfo);
                        datas.Add(jObjectData);
                        long lastUpdated = jObjectData[schemaInfo.PropertyInfoLastUpdated.Name].Value<long>();
                        long? deleted = jObjectData[schemaInfo.PropertyInfoDeleted.Name].Value<long?>();
                        if (lastUpdated > maxTimeStamp) maxTimeStamp = lastUpdated;
                        if (deleted.HasValue && deleted.Value > maxTimeStamp) maxTimeStamp = deleted.Value;
                        logChanges.Add(SyncLog.SyncLogData.FromJObject(jObjectData, syncType, schemaInfo));
                    }
                    typeChanges[nameof(datas)] = datas;
                }
                CommitTransaction(syncType, transaction, operationType, synchronizationId, customInfo);
            }
            catch (Exception)
            {
                RollbackTransaction(syncType, transaction, operationType, synchronizationId, customInfo);
                throw;
            }
            finally
            {
                EndTransaction(syncType, transaction, operationType, synchronizationId, customInfo);
            }
            return (typeChanges, datas.Count, maxTimeStamp, logChanges);
        }

        internal (Dictionary<Type, List<object>> dictAppliedIds, List<SyncLog.SyncLogData> inserts, List<SyncLog.SyncLogData> updates, List<SyncLog.SyncLogData> deletes, List<SyncLog.SyncLogConflict> conflicts) ProcessPayload(List<string> log, byte[] syncDataBytes)
        {
            List<SyncLog.SyncLogData> inserts = new List<SyncLog.SyncLogData>();
            List<SyncLog.SyncLogData> updates = new List<SyncLog.SyncLogData>();
            List<SyncLog.SyncLogData> deletes = new List<SyncLog.SyncLogData>();
            List<SyncLog.SyncLogConflict> conflicts = new List<SyncLog.SyncLogConflict>();

            if (syncDataBytes == null) throw new Exception($"{nameof(syncDataBytes)} cannot be null");
            log.Add($"Decompressing Type Changes...");
            string content = Decompress(syncDataBytes);
            log.Add($"Type Changes Decompressed");
            log.Add($"Deserialize Data...");
            JObject payload = JsonConvert.DeserializeObject<JObject>(content);
            log.Add($"Data Deserialized");

            (string synchronizationId, long lastSync, Dictionary<string, object> customInfo) = ExtractInfo(payload);

            log.Add("Applying Data Type Changes...");
            JArray changes = payload["changes"].Value<JArray>();
            log.Add($"SyncTypes Count: {changes.Count}");
            Dictionary<Type, List<object>> dictAppliedIds = new Dictionary<Type, List<object>>();
            List<Type> postEventTypes = new List<Type>();
            Dictionary<Type, List<object>> dictDeletedIds = new Dictionary<Type, List<object>>();
            for (int i = 0; i < changes.Count; i++)
            {
                JObject typeChanges = changes[i].Value<JObject>();
                log.Add($"Applying Type: {typeChanges["syncType"].Value<string>()}...");
                (Type localSyncType, List<object> appliedIds, List<object> deletedIds, List<SyncLog.SyncLogData> typeInserts, List<SyncLog.SyncLogData> typeUpdates, List<SyncLog.SyncLogData> typeDeletes, List<SyncLog.SyncLogConflict> typeConflicts) = ApplyTypeChanges(log, typeChanges, synchronizationId, customInfo);
                inserts.AddRange(typeInserts);
                updates.AddRange(typeUpdates);
                deletes.AddRange(typeDeletes);
                conflicts.AddRange(typeConflicts);
                log.Add($"Type: {typeChanges["syncType"].Value<string>()} Applied, Count: {appliedIds.Count}");
                dictAppliedIds[localSyncType] = appliedIds;
                if (deletedIds.Count > 0)
                {
                    if (!postEventTypes.Contains(localSyncType)) postEventTypes.Add(localSyncType);
                    dictDeletedIds[localSyncType] = deletedIds;
                }
            }
            if (postEventTypes.Count > 0)
            {
                log.Add("Processing Post Events...");
                log.Add($"Post Event Types Count: {postEventTypes.Count}");
                for (int i = 0; i < postEventTypes.Count; i++)
                {
                    Type postEventType = postEventTypes[i];
                    if (dictDeletedIds.ContainsKey(postEventType))
                    {
                        log.Add($"Processing Post Event Delete for Type: {postEventType.Name}, Count: {dictDeletedIds[postEventType].Count}");
                        for (int j = 0; j < dictDeletedIds[postEventType].Count; j++)
                        {
                            PostEventDelete(postEventType, dictDeletedIds[postEventType][j], synchronizationId, customInfo);
                        }
                    }
                }
            }

            return (dictAppliedIds, inserts, updates, deletes, conflicts);
        }

        internal (Type localSyncType, List<object> appliedIds, List<object> deletedIds, List<SyncLog.SyncLogData> inserts, List<SyncLog.SyncLogData> updates, List<SyncLog.SyncLogData> deletes, List<SyncLog.SyncLogConflict> conflicts) ApplyTypeChanges(List<string> log, JObject typeChanges, string synchronizationId, Dictionary<string, object> customInfo)
        {
            List<object> appliedIds = new List<object>();
            List<object> deletedIds = new List<object>();
            List<SyncLog.SyncLogData> inserts = new List<SyncLog.SyncLogData>();
            List<SyncLog.SyncLogData> updates = new List<SyncLog.SyncLogData>();
            List<SyncLog.SyncLogData> deletes = new List<SyncLog.SyncLogData>();
            List<SyncLog.SyncLogConflict> conflicts = new List<SyncLog.SyncLogConflict>();
            string syncTypeName = typeChanges["syncType"].Value<string>();
            JObject jObjectSchemaInfo = typeChanges["schemaInfo"].Value<JObject>();
            SyncConfiguration.SchemaInfo schemaInfo = SyncConfiguration.SchemaInfo.FromJObject(jObjectSchemaInfo);
            string localSyncTypeName = syncTypeName;
            if (!string.IsNullOrEmpty(schemaInfo.SyncSchemaAttribute.MapToClassName)) localSyncTypeName = schemaInfo.SyncSchemaAttribute.MapToClassName;
            Type localSyncType = SyncConfiguration.SyncTypes.Where(w => w.Name == localSyncTypeName).FirstOrDefault();
            if (localSyncType == null) throw new SyncEngineConstraintException($"Unable to find SyncType: {localSyncTypeName} in SyncConfiguration");
            SyncConfiguration.SchemaInfo localSchemaInfo = GetSchemaInfo(SyncConfiguration, localSyncType);

            OperationType operationType = OperationType.ApplyChanges;
            object transaction = StartTransaction(localSyncType, operationType, synchronizationId, customInfo);
            try
            {
                IQueryable queryable = InvokeGetQueryable(localSyncType, transaction, operationType, synchronizationId, customInfo);
                JArray datas = typeChanges["datas"].Value<JArray>();
                log.Add($"Data Count: {datas.Count}");
                for (int i = 0; i < datas.Count; i++)
                {
                    JObject jObjectData = datas[i].Value<JObject>();
                    JValue id = jObjectData[schemaInfo.PropertyInfoId.Name].Value<JValue>();
                    long lastUpdated = jObjectData[schemaInfo.PropertyInfoLastUpdated.Name].Value<long>();
                    long? deleted = jObjectData[schemaInfo.PropertyInfoDeleted.Name].Value<long?>();

                    object localId = TransformIdType(localSyncType, id, transaction, operationType, synchronizationId, customInfo);
                    dynamic dynamicData = queryable.Where($"{localSchemaInfo.PropertyInfoId.Name} == @0", localId).FirstOrDefault();
                    object localData = (object)dynamicData;
                    if (localData == null)
                    {
                        object newData = InvokeDeserializeJsonToNewData(localSyncType, jObjectData, transaction, operationType, synchronizationId, customInfo);
                        newData.GetType().GetProperty(localSchemaInfo.PropertyInfoId.Name).SetValue(newData, localId);
                        newData.GetType().GetProperty(localSchemaInfo.PropertyInfoLastUpdated.Name).SetValue(newData, lastUpdated);
                        newData.GetType().GetProperty(localSchemaInfo.PropertyInfoDeleted.Name).SetValue(newData, deleted);
                        PersistData(localSyncType, newData, true, transaction, operationType, synchronizationId, customInfo);
                        if (!appliedIds.Contains(localId)) appliedIds.Add(localId);
                        inserts.Add(SyncLog.SyncLogData.FromJObject(InvokeSerializeDataToJson(localSyncType, newData, localSchemaInfo, transaction, operationType, synchronizationId, customInfo), localSyncType, localSchemaInfo));
                    }
                    else
                    {
                        if (deleted == null)
                        {
                            long localLastUpdated = (long)localData.GetType().GetProperty(localSchemaInfo.PropertyInfoLastUpdated.Name).GetValue(localData);
                            if (lastUpdated > localLastUpdated)
                            {
                                object existingData = InvokeDeserializeJsonToExistingData(localSyncType, jObjectData, localData, localId, transaction, operationType, synchronizationId, customInfo, localSchemaInfo);
                                existingData.GetType().GetProperty(localSchemaInfo.PropertyInfoLastUpdated.Name).SetValue(existingData, lastUpdated);
                                PersistData(localSyncType, existingData, false, transaction, operationType, synchronizationId, customInfo);
                                if (!appliedIds.Contains(localId)) appliedIds.Add(localId);
                                updates.Add(SyncLog.SyncLogData.FromJObject(InvokeSerializeDataToJson(localSyncType, existingData, localSchemaInfo, transaction, operationType, synchronizationId, customInfo), localSyncType, localSchemaInfo));
                            }
                            else
                            {
                                log.Add($"CONFLICT Detected: Target Data is newer than Source Data. Id: {id}");
                                conflicts.Add(new SyncLog.SyncLogConflict(SyncLog.SyncLogConflict.ConflictTypeEnum.TargetDataIsNewerThanSource, SyncLog.SyncLogData.FromJObject(jObjectData, localSyncType, schemaInfo)));
                            }
                        }
                        else
                        {
                            object existingData = InvokeDeserializeJsonToExistingData(localSyncType, jObjectData, localData, localId, transaction, operationType, synchronizationId, customInfo, localSchemaInfo);
                            existingData.GetType().GetProperty(localSchemaInfo.PropertyInfoDeleted.Name).SetValue(existingData, deleted);
                            PersistData(localSyncType, existingData, false, transaction, operationType, synchronizationId, customInfo);
                            if (!appliedIds.Contains(localId)) appliedIds.Add(localId);
                            if (!deletedIds.Contains(localId)) deletedIds.Add(localId);
                            deletes.Add(SyncLog.SyncLogData.FromJObject(InvokeSerializeDataToJson(localSyncType, existingData, localSchemaInfo, transaction, operationType, synchronizationId, customInfo), localSyncType, localSchemaInfo));
                        }
                    }
                }
                CommitTransaction(localSyncType, transaction, operationType, synchronizationId, customInfo);
            }
            catch (Exception)
            {
                RollbackTransaction(localSyncType, transaction, operationType, synchronizationId, customInfo);
                throw;
            }
            finally
            {
                EndTransaction(localSyncType, transaction, operationType, synchronizationId, customInfo);
            }

            return (localSyncType, appliedIds, deletedIds, inserts, updates, deletes, conflicts);
        }

        private IQueryable InvokeGetQueryable(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            IQueryable queryable = GetQueryable(classType, transaction, operationType, synchronizationId, customInfo);
            if (queryable == null) throw new SyncEngineConstraintException($"{nameof(GetQueryable)} must not return null");
            if (queryable.ElementType.FullName != classType.FullName) throw new SyncEngineConstraintException($"{nameof(GetQueryable)} must return IQueryable with ElementType: {classType.FullName}");
            return queryable;
        }

        private JObject InvokeSerializeDataToJson(Type classType, object data, SyncConfiguration.SchemaInfo schemaInfo, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            string json = SerializeDataToJson(classType, data, transaction, operationType, synchronizationId, customInfo);
            if (string.IsNullOrEmpty(json)) throw new SyncEngineConstraintException($"{nameof(SerializeDataToJson)} must not return null or empty string");
            JObject jObject = null;
            try
            {
                jObject = JsonConvert.DeserializeObject<JObject>(json);
            }
            catch (Exception e)
            {
                throw new SyncEngineConstraintException($"The returned value from {nameof(SerializeDataToJson)} cannot be parsed as JSON Object (JObject). Error: {e.Message}. Returned Value: {json}");
            }
            if (!jObject.ContainsKey(schemaInfo.PropertyInfoId.Name)) throw new SyncEngineConstraintException($"The parsed JSON Object (JObject) does not contain key: {schemaInfo.PropertyInfoId.Name} (SyncProperty Id)");
            if (!jObject.ContainsKey(schemaInfo.PropertyInfoLastUpdated.Name)) throw new SyncEngineConstraintException($"The parsed JSON Object (JObject) does not contain key: {schemaInfo.PropertyInfoLastUpdated.Name} (SyncProperty LastUpdated)");
            if (!jObject.ContainsKey(schemaInfo.PropertyInfoDeleted.Name)) throw new SyncEngineConstraintException($"The parsed JSON Object (JObject) does not contain key: {schemaInfo.PropertyInfoDeleted.Name} (SyncProperty Deleted)");
            return jObject;
        }

        private object InvokeDeserializeJsonToNewData(Type classType, JObject jObject, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            object newData = DeserializeJsonToNewData(classType, jObject, transaction, operationType, synchronizationId, customInfo);
            if (newData == null) throw new SyncEngineConstraintException($"{nameof(DeserializeJsonToNewData)} must not return null");
            if (newData.GetType().FullName != classType.FullName) throw new SyncEngineConstraintException($"Expected returned Type: {classType.FullName} during {nameof(DeserializeJsonToNewData)}, but Type: {newData.GetType().FullName} is returned instead.");
            return newData;
        }

        private object InvokeDeserializeJsonToExistingData(Type classType, JObject jObject, object data, object localId, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo, SyncConfiguration.SchemaInfo localSchemaInfo)
        {
            object existingData = DeserializeJsonToExistingData(classType, jObject, data, transaction, operationType, synchronizationId, customInfo);
            if (existingData == null) throw new SyncEngineConstraintException($"{nameof(DeserializeJsonToExistingData)} must not return null");
            if (existingData.GetType().FullName != classType.FullName) throw new SyncEngineConstraintException($"Expected returned Type: {classType.FullName} during {nameof(DeserializeJsonToExistingData)}, but Type: {existingData.GetType().FullName} is returned instead.");
            object existingDataId = classType.GetProperty(localSchemaInfo.PropertyInfoId.Name).GetValue(existingData);
            if (!existingDataId.Equals(localId)) throw new SyncEngineConstraintException($"The returned Object Id ({existingDataId}) is different than the existing data Id: {localId}");
            return existingData;
        }

        internal long InvokeGetClientLastSync()
        {
            long lastSync = GetClientLastSync();
            long minValueTicks = GetMinValueTicks();
            if (lastSync < minValueTicks) lastSync = minValueTicks;
            return lastSync;
        }

        private static SyncConfiguration.SchemaInfo GetSchemaInfo(SyncConfiguration syncConfiguration, Type type)
        {
            if (syncConfiguration == null) throw new NullReferenceException(nameof(syncConfiguration));
            if (!syncConfiguration.SyncSchemaInfos.ContainsKey(type)) throw new SyncEngineMissingTypeInSyncConfigurationException(type);
            return syncConfiguration.SyncSchemaInfos[type];
        }

        internal static (string synchronizationId, long lastSync, Dictionary<string, object> customInfo) ExtractInfo(byte[] syncDataBytes)
        {
            if (syncDataBytes == null) throw new Exception($"{nameof(syncDataBytes)} cannot be null");
            string content = Decompress(syncDataBytes);
            JObject payload = JsonConvert.DeserializeObject<JObject>(content);
            return ExtractInfo(payload);
        }

        private static (string synchronizationId, long lastSync, Dictionary<string, object> customInfo) ExtractInfo(JObject payload)
        {
            string synchronizationId = payload["synchronizationId"].Value<string>();
            long lastSync = payload["lastSync"].Value<long>();
            Dictionary<string, object> customInfo = payload["customInfo"].ToObject<Dictionary<string, object>>();
            return (synchronizationId, lastSync, customInfo);
        }

        private static byte[] Compress(string text)
        {
            var bytes = Encoding.Unicode.GetBytes(text);
            using (var mso = new MemoryStream())
            {
                using (var gs = new GZipStream(mso, CompressionMode.Compress))
                {
                    gs.Write(bytes, 0, bytes.Length);
                }
                return mso.ToArray();
            }
        }

        private static string Decompress(byte[] data)
        {
            // Read the last 4 bytes to get the length
            byte[] lengthBuffer = new byte[4];
            Array.Copy(data, data.Length - 4, lengthBuffer, 0, 4);
            int uncompressedSize = BitConverter.ToInt32(lengthBuffer, 0);

            var buffer = new byte[uncompressedSize];
            using (var ms = new MemoryStream(data))
            {
                using (var gzip = new GZipStream(ms, CompressionMode.Decompress))
                {
                    gzip.Read(buffer, 0, uncompressedSize);
                }
            }
            return Encoding.Unicode.GetString(buffer);
        }

        internal static long GetNowTicks()
        {
            return DateTime.Now.Ticks;
        }

        internal static long GetMinValueTicks()
        {
            return DateTime.MinValue.Ticks;
        }

        //NOTE: OBSOLETE, now using System.Linq.Dynamic.Core
        //private void FilterForPush(IQueryable queryable, SyncConfiguration.SchemaInfo schemaInfo, DateTimeOffset? lastSync)
        //{
        //    if (lastSync == null) throw new SyncEngineConstraintException($"{nameof(lastSync)} cannot be null");

        //    ParameterExpression parameterExpression = Expression.Parameter(queryable.ElementType);
        //    MemberExpression propertyLastUpdated = Expression.Property(parameterExpression, schemaInfo.PropertyInfoLastUpdated.Name);
        //    ConstantExpression constantLastSyncOffset = Expression.Constant(lastSync.Value, typeof(DateTimeOffset));
        //    BinaryExpression binaryLastUpdatedGreaterThanOrEqualLastSyncOffset = Expression.GreaterThanOrEqual(propertyLastUpdated, constantLastSyncOffset);

        //    MemberExpression propertyDeleted = Expression.Property(parameterExpression, schemaInfo.PropertyInfoDeleted.Name);
        //    ConstantExpression constantNullDateTimeOffsetNullable = Expression.Constant(null, typeof(DateTimeOffset?));
        //    BinaryExpression binaryDeletedNotNull = Expression.NotEqual(propertyDeleted, constantNullDateTimeOffsetNullable);

        //    ConstantExpression constantLastSyncOffsetNullable = Expression.Constant(lastSync, typeof(DateTimeOffset?));
        //    BinaryExpression binaryDeletedGreaterThanOrEqualLastSyncOffset = Expression.GreaterThanOrEqual(propertyDeleted, constantLastSyncOffsetNullable);

        //    BinaryExpression binaryDeleted = Expression.And(binaryDeletedNotNull, binaryDeletedGreaterThanOrEqualLastSyncOffset);
        //    BinaryExpression binaryWhere = Expression.Or(binaryLastUpdatedGreaterThanOrEqualLastSyncOffset, binaryDeleted);

        //    Type delegateType = typeof(Func<,>).MakeGenericType(queryable.ElementType, typeof(bool));
        //    LambdaExpression predicate = Expression.Lambda(delegateType, binaryWhere, parameterExpression);

        //    var whereMethods = typeof(Queryable).GetMethods(BindingFlags.Static | BindingFlags.Public).Where(mi => mi.Name == "Where");
        //    MethodInfo whereMethod = null;
        //    foreach (var methodInfo in whereMethods)
        //    {
        //        var expressionType = methodInfo.GetParameters()[1].ParameterType;
        //        var funcType = expressionType.GetGenericArguments()[0];
        //        if (funcType.GetGenericArguments().Count() == 2)
        //        {
        //            // we are looking for Expression<Func<TSource, bool>>, the other has 3
        //            whereMethod = methodInfo;
        //            break;
        //        }
        //    }
        //    if (whereMethod == null) throw new Exception("whereMethod is null");
        //    whereMethod = whereMethod.MakeGenericMethod(queryable.ElementType);
        //    queryable = whereMethod.Invoke(queryable, new object[] { queryable, predicate }) as IQueryable;
        //}
    }
}
