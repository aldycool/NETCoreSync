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
    public abstract partial class SyncEngine
    {
        internal readonly SyncConfiguration SyncConfiguration;

        public SyncEngine(SyncConfiguration syncConfiguration)
        {
            SyncConfiguration = syncConfiguration ?? throw new NullReferenceException(nameof(syncConfiguration));
        }

        internal void GetChanges(GetChangesParameter parameter, ref GetChangesResult result)
        {
            if (parameter == null) throw new NullReferenceException(nameof(parameter));
            result = new GetChangesResult(parameter.PayloadAction, parameter.SynchronizationId, parameter.CustomInfo);
            result.MaxTimeStamp = GetMinValueTicks();
            if (parameter.LastSync == 0) parameter.LastSync = GetMinValueTicks();

            parameter.Log.Add($"Preparing Data Since LastSync: {parameter.LastSync}");
            parameter.Log.Add($"SyncTypes Count: {SyncConfiguration.SyncTypes.Count}");
            for (int i = 0; i < SyncConfiguration.SyncTypes.Count; i++)
            {
                Type syncType = SyncConfiguration.SyncTypes[i];
                parameter.Log.Add($"Processing Type: {syncType.Name} ({i + 1} of {SyncConfiguration.SyncTypes.Count})");
                parameter.Log.Add($"Getting Type Changes...");
                List<object> appliedIds = null;
                if (parameter.AppliedIds != null && parameter.AppliedIds.ContainsKey(syncType)) appliedIds = parameter.AppliedIds[syncType];
                (JObject typeChanges, int typeChangesCount, long typeMaxTimeStamp, List<SyncLog.SyncLogData> typeLogChanges) = GetTypeChanges(parameter.LastSync, syncType, parameter.SynchronizationId, parameter.CustomInfo, appliedIds);
                parameter.Log.Add($"Type Changes Count: {typeChangesCount}");
                if (typeChangesCount != 0 && typeChanges != null) result.Changes.Add(typeChanges);
                if (typeMaxTimeStamp > result.MaxTimeStamp) result.MaxTimeStamp = typeMaxTimeStamp;
                result.LogChanges.AddRange(typeLogChanges);
                parameter.Log.Add($"Type: {syncType.Name} Processed");
            }
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

        internal void ApplyChanges(ApplyChangesParameter parameter, ref ApplyChangesResult result)
        {
            if (parameter == null) throw new NullReferenceException(nameof(parameter));
            result = new ApplyChangesResult(parameter.PayloadAction, parameter.SynchronizationId, parameter.CustomInfo);
            
            parameter.Log.Add("Applying Data Type Changes...");
            parameter.Log.Add($"SyncTypes Count: {parameter.Changes.Count}");
            List<Type> postEventTypes = new List<Type>();
            Dictionary<Type, List<object>> dictDeletedIds = new Dictionary<Type, List<object>>();
            for (int i = 0; i < parameter.Changes.Count; i++)
            {
                JObject typeChanges = parameter.Changes[i].Value<JObject>();
                parameter.Log.Add($"Applying Type: {typeChanges["syncType"].Value<string>()}...");
                (Type localSyncType, List<object> appliedIds, List<object> deletedIds) = ApplyTypeChanges(parameter.Log, result.Inserts, result.Updates, result.Deletes, result.Conflicts, typeChanges, parameter.SynchronizationId, parameter.CustomInfo, null, null);
                parameter.Log.Add($"Type: {typeChanges["syncType"].Value<string>()} Applied, Count: {appliedIds.Count}");
                result.AppliedIds[localSyncType] = appliedIds;
                if (deletedIds.Count > 0)
                {
                    if (!postEventTypes.Contains(localSyncType)) postEventTypes.Add(localSyncType);
                    dictDeletedIds[localSyncType] = deletedIds;
                }
            }
            ProcessPostEvents(parameter.Log, postEventTypes, dictDeletedIds, parameter.SynchronizationId, parameter.CustomInfo);
        }

        internal void GetKnowledge(GetKnowledgeParameter parameter, ref GetKnowledgeResult result)
        {
            if (parameter == null) throw new NullReferenceException(nameof(parameter));
            result = new GetKnowledgeResult(parameter.PayloadAction, parameter.SynchronizationId, parameter.CustomInfo);

            result.KnowledgeInfos = GetAllKnowledgeInfos(parameter.SynchronizationId, parameter.CustomInfo);
            if (result.KnowledgeInfos == null) result.KnowledgeInfos = new List<KnowledgeInfo>();
            parameter.Log.Add($"All KnowledgeInfos Count: {result.KnowledgeInfos.Count}");
            if (result.KnowledgeInfos.Where(w => w.IsLocal).Count() > 1) throw new SyncEngineConstraintException("Found multiple KnowledgeInfo with IsLocal equals to true. IsLocal should be 1 (one) data only");
            if (result.KnowledgeInfos.Where(w => w.IsLocal).Count() == 1) return;

            parameter.Log.Add("Local KnowledgeInfo is not found. Creating a new Local KnowledgeInfo and Provisioning existing data...");
            OperationType operationType = OperationType.ProvisionKnowledge;
            object transaction = StartTransaction(null, operationType, parameter.SynchronizationId, parameter.CustomInfo);
            try
            {
                parameter.Log.Add("Getting Next TimeStamp...");
                long nextTimeStamp = InvokeGetNextTimeStamp();

                UpdateLocalKnowledgeTimeStamp(nextTimeStamp, parameter.SynchronizationId, parameter.CustomInfo, parameter.Log, transaction);

                CommitTransaction(null, transaction, operationType, parameter.SynchronizationId, parameter.CustomInfo);
            }
            catch (Exception)
            {
                RollbackTransaction(null, transaction, operationType, parameter.SynchronizationId, parameter.CustomInfo);
                throw;
            }
            finally
            {
                EndTransaction(null, transaction, operationType, parameter.SynchronizationId, parameter.CustomInfo);
            }

            result.KnowledgeInfos = GetAllKnowledgeInfos(parameter.SynchronizationId, parameter.CustomInfo);
            if (result.KnowledgeInfos.Where(w => w.IsLocal).Count() != 1) throw new SyncEngineConstraintException($"KnowledgeInfo with IsLocal equals to true is still not 1 (one) data. Check your {nameof(CreateOrUpdateKnowledgeInfo)} implementation.");
        }

        internal void UpdateLocalKnowledgeTimeStamp(long timeStamp, string synchronizationId, Dictionary<string, object> customInfo, List<string> log, object transaction)
        {
            bool isNewlyCreated = false;

            List<KnowledgeInfo> infos = GetAllKnowledgeInfos(synchronizationId, customInfo);
            KnowledgeInfo localKnowledgeInfo = infos.Where(w => w.IsLocal).FirstOrDefault();
            if (localKnowledgeInfo == null)
            {
                isNewlyCreated = true;
                localKnowledgeInfo = new KnowledgeInfo()
                {
                    DatabaseInstanceId = Guid.NewGuid().ToString(),
                    IsLocal = true
                };
            }
            else
            {
                isNewlyCreated = false;
            }
            localKnowledgeInfo.MaxTimeStamp = timeStamp;
            CreateOrUpdateKnowledgeInfo(localKnowledgeInfo, synchronizationId, customInfo);

            if (isNewlyCreated)
            {
                ProvisionExistingData(log, timeStamp, transaction, OperationType.ProvisionKnowledge, synchronizationId, customInfo);
            }
        }

        internal void ProvisionExistingData(List<string> log, long timeStamp, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            if (log == null) log = new List<string>();

            log.Add("Provisioning All Existing Local Data with the acquired TimeStamp...");
            log.Add($"SyncTypes Count: {SyncConfiguration.SyncTypes.Count}");
            for (int i = 0; i < SyncConfiguration.SyncTypes.Count; i++)
            {
                Type syncType = SyncConfiguration.SyncTypes[i];
                log.Add($"Processing Type: {syncType.Name} ({i + 1} of {SyncConfiguration.SyncTypes.Count})");
                int dataCount = 0;
                SyncConfiguration.SchemaInfo schemaInfo = GetSchemaInfo(SyncConfiguration, syncType);
                IQueryable queryable = InvokeGetQueryable(syncType, transaction, operationType, synchronizationId, customInfo);
                queryable = queryable.Where($"{schemaInfo.PropertyInfoDatabaseInstanceId.Name} = null || {schemaInfo.PropertyInfoDatabaseInstanceId.Name} = \"\"");
                System.Collections.IEnumerator enumerator = queryable.GetEnumerator();
                while (enumerator.MoveNext())
                {
                    dataCount += 1;
                    object data = enumerator.Current;
                    data.GetType().GetProperty(schemaInfo.PropertyInfoDatabaseInstanceId.Name).SetValue(data, null);
                    data.GetType().GetProperty(schemaInfo.PropertyInfoLastUpdated.Name).SetValue(data, timeStamp);
                    PersistData(syncType, data, false, transaction, operationType, synchronizationId, customInfo);
                }
                log.Add($"Type: {syncType.Name} Processed. Provisioned Data Count: {dataCount}");
            }
        }

        internal void GetChangesByKnowledge(GetChangesByKnowledgeParameter parameter, ref GetChangesByKnowledgeResult result)
        {
            if (parameter == null) throw new NullReferenceException(nameof(parameter));
            result = new GetChangesByKnowledgeResult(parameter.PayloadAction, parameter.SynchronizationId, parameter.CustomInfo);

            parameter.Log.Add($"Get Changes By Knowledge");
            parameter.Log.Add($"Local Knowledge Count: {parameter.LocalKnowledgeInfos.Count}");
            for (int i = 0; i < parameter.LocalKnowledgeInfos.Count; i++)
            {
                parameter.Log.Add($"{i + 1}. {parameter.LocalKnowledgeInfos[i].ToString()}");
            }
            parameter.Log.Add($"Remote Knowledge Count: {parameter.RemoteKnowledgeInfos.Count}");
            for (int i = 0; i < parameter.RemoteKnowledgeInfos.Count; i++)
            {
                parameter.Log.Add($"{i + 1}. {parameter.RemoteKnowledgeInfos[i].ToString()}");
            }
            if (parameter.LocalKnowledgeInfos.Where(w => w.IsLocal).Count() != 1) throw new SyncEngineConstraintException($"{nameof(parameter.LocalKnowledgeInfos)} must have 1 IsLocal property equals to true");
            if (parameter.RemoteKnowledgeInfos.Where(w => w.IsLocal).Count() != 1) throw new SyncEngineConstraintException($"{nameof(parameter.RemoteKnowledgeInfos)} must have 1 IsLocal property equals to true");
            KnowledgeInfo localInfo = parameter.LocalKnowledgeInfos.Where(w => w.IsLocal).First();
            parameter.Log.Add($"SyncTypes Count: {SyncConfiguration.SyncTypes.Count}");
            for (int i = 0; i < SyncConfiguration.SyncTypes.Count; i++)
            {
                Type syncType = SyncConfiguration.SyncTypes[i];
                parameter.Log.Add($"Processing Type: {syncType.Name} ({i + 1} of {SyncConfiguration.SyncTypes.Count})");
                (JObject typeChanges, int typeChangesCount, List<SyncLog.SyncLogData> typeLogChanges) = GetTypeChangesByKnowledge(syncType, localInfo.DatabaseInstanceId, parameter.RemoteKnowledgeInfos, parameter.SynchronizationId, parameter.CustomInfo);
                parameter.Log.Add($"Type Changes Count: {typeChangesCount}");
                if (typeChangesCount != 0 && typeChanges != null) result.Changes.Add(typeChanges);
                result.LogChanges.AddRange(typeLogChanges);
                parameter.Log.Add($"Type: {syncType.Name} Processed");
            }
        }

        internal (JObject typeChanges, int typeChangesCount, List<SyncLog.SyncLogData> logChanges) GetTypeChangesByKnowledge(Type syncType, string localDatabaseInstanceId, List<KnowledgeInfo> remoteKnowledgeInfos, string synchronizationId, Dictionary<string, object> customInfo)
        {
            if (string.IsNullOrEmpty(synchronizationId)) throw new NullReferenceException(nameof(synchronizationId));
            if (customInfo == null) customInfo = new Dictionary<string, object>();

            List<SyncLog.SyncLogData> logChanges = new List<SyncLog.SyncLogData>();
            SyncConfiguration.SchemaInfo schemaInfo = GetSchemaInfo(SyncConfiguration, syncType);
            JObject typeChanges = null;
            JArray datas = new JArray();

            OperationType operationType = OperationType.GetChanges;
            object transaction = StartTransaction(syncType, operationType, synchronizationId, customInfo);
            try
            {
                IQueryable queryable = InvokeGetQueryable(syncType, transaction, operationType, synchronizationId, customInfo);

                string predicate = "";
                string predicateUnknown = "";
                for (int i = 0; i < remoteKnowledgeInfos.Count; i++)
                {
                    KnowledgeInfo info = remoteKnowledgeInfos[i];

                    string knownDatabaseInstanceId = null;
                    if (info.DatabaseInstanceId == localDatabaseInstanceId)
                    {
                        knownDatabaseInstanceId = "null";
                    }
                    else
                    {
                        knownDatabaseInstanceId = $"\"{info.DatabaseInstanceId}\"";
                    }

                    if (!string.IsNullOrEmpty(predicate)) predicate += " || ";
                    predicate += "(";
                    predicate += $"{schemaInfo.PropertyInfoDatabaseInstanceId.Name} = {knownDatabaseInstanceId} ";
                    predicate += $" && {schemaInfo.PropertyInfoLastUpdated.Name} > {info.MaxTimeStamp}";
                    predicate += ")";

                    if (!string.IsNullOrEmpty(predicateUnknown)) predicateUnknown += " && ";
                    predicateUnknown += $"{schemaInfo.PropertyInfoDatabaseInstanceId.Name} != {knownDatabaseInstanceId}";
                }
                queryable = queryable.Where($"{predicate} || ({predicateUnknown})");
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
            return (typeChanges, datas.Count, logChanges);
        }

        internal void ApplyChangesByKnowledge(ApplyChangesByKnowledgeParameter parameter, ref ApplyChangesByKnowledgeResult result)
        {
            if (parameter == null) throw new NullReferenceException(nameof(parameter));
            result = new ApplyChangesByKnowledgeResult(parameter.PayloadAction, parameter.SynchronizationId, parameter.CustomInfo);

            if (GetAllKnowledgeInfos(parameter.SynchronizationId, parameter.CustomInfo).Where(w => w.DatabaseInstanceId == parameter.DestinationDatabaseInstanceId && w.IsLocal).Count() == 0)
            {
                throw new SyncEngineConstraintException("Unexpected Knowledge Info State on Destination. Destination is not provisioned yet.");
            }

            parameter.Log.Add("Applying Data Type Changes...");
            parameter.Log.Add($"SyncTypes Count: {parameter.Changes.Count}");
            List<Type> postEventTypes = new List<Type>();
            Dictionary<Type, List<object>> dictDeletedIds = new Dictionary<Type, List<object>>();
            for (int i = 0; i < parameter.Changes.Count; i++)
            {
                JObject typeChanges = parameter.Changes[i].Value<JObject>();
                parameter.Log.Add($"Applying Type: {typeChanges["syncType"].Value<string>()}...");
                (Type localSyncType, List<object> appliedIds, List<object> deletedIds) = ApplyTypeChanges(parameter.Log, result.Inserts, result.Updates, result.Deletes, result.Conflicts, typeChanges, parameter.SynchronizationId, parameter.CustomInfo, parameter.SourceDatabaseInstanceId, parameter.DestinationDatabaseInstanceId);
                parameter.Log.Add($"Type: {typeChanges["syncType"].Value<string>()} Applied, Count: {appliedIds.Count}");
                if (deletedIds.Count > 0)
                {
                    if (!postEventTypes.Contains(localSyncType)) postEventTypes.Add(localSyncType);
                    dictDeletedIds[localSyncType] = deletedIds;
                }
            }
            ProcessPostEvents(parameter.Log, postEventTypes, dictDeletedIds, parameter.SynchronizationId, parameter.CustomInfo);
        }

        internal (Type localSyncType, List<object> appliedIds, List<object> deletedIds) ApplyTypeChanges(List<string> log, List<SyncLog.SyncLogData> inserts, List<SyncLog.SyncLogData> updates, List<SyncLog.SyncLogData> deletes, List<SyncLog.SyncLogConflict> conflicts, JObject typeChanges, string synchronizationId, Dictionary<string, object> customInfo, string sourceDatabaseInstanceId, string destinationDatabaseInstanceId)
        {
            if (SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.GlobalTimeStamp)
            {
                if (!string.IsNullOrEmpty(sourceDatabaseInstanceId) || !string.IsNullOrEmpty(destinationDatabaseInstanceId)) throw new Exception($"{SyncConfiguration.TimeStampStrategy.ToString()} must have {nameof(sourceDatabaseInstanceId)} and {nameof(destinationDatabaseInstanceId)} equals to null");
            }
            else if (SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.DatabaseTimeStamp)
            {
                if (string.IsNullOrEmpty(sourceDatabaseInstanceId) || string.IsNullOrEmpty(destinationDatabaseInstanceId)) throw new Exception($"{SyncConfiguration.TimeStampStrategy.ToString()} must have {nameof(sourceDatabaseInstanceId)} and {nameof(destinationDatabaseInstanceId)} both not null");
            }
            else
            {
                throw new NotImplementedException(SyncConfiguration.TimeStampStrategy.ToString());
            }

            List<object> appliedIds = new List<object>();
            List<object> deletedIds = new List<object>();
            Dictionary<string, long> databaseInstanceMaxTimeStamps = new Dictionary<string, long>();
            if (inserts == null) inserts = new List<SyncLog.SyncLogData>();
            if (updates == null) updates = new List<SyncLog.SyncLogData>();
            if (deletes == null) deletes = new List<SyncLog.SyncLogData>();
            if (conflicts == null) conflicts = new List<SyncLog.SyncLogConflict>();
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

                    long? deletedGlobalTimeStamp = null;
                    bool deletedDatabaseTimeStamp = false;
                    string databaseInstanceId = null;
                    if (SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.GlobalTimeStamp)
                    {
                        deletedGlobalTimeStamp = jObjectData[schemaInfo.PropertyInfoDeleted.Name].Value<long?>();
                    }
                    if (SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.DatabaseTimeStamp)
                    {
                        deletedDatabaseTimeStamp = jObjectData[schemaInfo.PropertyInfoDeleted.Name].Value<bool>();
                        databaseInstanceId = jObjectData[schemaInfo.PropertyInfoDatabaseInstanceId.Name].Value<string>();
                    }

                    object localId = TransformIdType(localSyncType, id, transaction, operationType, synchronizationId, customInfo);
                    dynamic dynamicData = queryable.Where($"{localSchemaInfo.PropertyInfoId.Name} == @0", localId).FirstOrDefault();
                    object localData = (object)dynamicData;

                    if (localData == null)
                    {
                        object newData = InvokeDeserializeJsonToNewData(localSyncType, jObjectData, transaction, operationType, synchronizationId, customInfo);
                        newData.GetType().GetProperty(localSchemaInfo.PropertyInfoId.Name).SetValue(newData, localId);
                        newData.GetType().GetProperty(localSchemaInfo.PropertyInfoLastUpdated.Name).SetValue(newData, lastUpdated);

                        if (SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.GlobalTimeStamp)
                        {
                            newData.GetType().GetProperty(localSchemaInfo.PropertyInfoDeleted.Name).SetValue(newData, deletedGlobalTimeStamp);
                        }
                        if (SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.DatabaseTimeStamp)
                        {
                            newData.GetType().GetProperty(localSchemaInfo.PropertyInfoDeleted.Name).SetValue(newData, deletedDatabaseTimeStamp);
                            newData.GetType().GetProperty(localSchemaInfo.PropertyInfoDatabaseInstanceId.Name).SetValue(newData, GetCorrectDatabaseInstanceId(databaseInstanceId, sourceDatabaseInstanceId, destinationDatabaseInstanceId, databaseInstanceMaxTimeStamps, lastUpdated));
                        }

                        PersistData(localSyncType, newData, true, transaction, operationType, synchronizationId, customInfo);
                        if (!appliedIds.Contains(localId)) appliedIds.Add(localId);
                        inserts.Add(SyncLog.SyncLogData.FromJObject(InvokeSerializeDataToJson(localSyncType, newData, localSchemaInfo, transaction, operationType, synchronizationId, customInfo), localSyncType, localSchemaInfo));
                    }
                    else
                    {
                        bool isDeleted = false;
                        if (SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.GlobalTimeStamp)
                        {
                            if (deletedGlobalTimeStamp != null) isDeleted = true;
                        }
                        if (SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.DatabaseTimeStamp)
                        {
                            if (deletedDatabaseTimeStamp) isDeleted = true;
                        }

                        if (!isDeleted)
                        {
                            long localLastUpdated = (long)localData.GetType().GetProperty(localSchemaInfo.PropertyInfoLastUpdated.Name).GetValue(localData);
                            string localDatabaseInstanceId = null;
                            bool shouldUpdate = false;
                            if (SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.GlobalTimeStamp)
                            {
                                if (lastUpdated > localLastUpdated) shouldUpdate = true;
                            }
                            if (SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.DatabaseTimeStamp)
                            {
                                localDatabaseInstanceId = (string)localData.GetType().GetProperty(localSchemaInfo.PropertyInfoDatabaseInstanceId.Name).GetValue(localData);
                                string correctDatabaseInstanceId = GetCorrectDatabaseInstanceId(databaseInstanceId, sourceDatabaseInstanceId, destinationDatabaseInstanceId, null, 0);
                                if (localDatabaseInstanceId == correctDatabaseInstanceId)
                                {
                                    if (lastUpdated > localLastUpdated) shouldUpdate = true;
                                }
                                else
                                {
                                    shouldUpdate = true;
                                }
                            }
                            if (shouldUpdate)
                            {
                                object existingData = InvokeDeserializeJsonToExistingData(localSyncType, jObjectData, localData, localId, transaction, operationType, synchronizationId, customInfo, localSchemaInfo);
                                existingData.GetType().GetProperty(localSchemaInfo.PropertyInfoLastUpdated.Name).SetValue(existingData, lastUpdated);

                                if (SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.DatabaseTimeStamp)
                                {
                                    existingData.GetType().GetProperty(localSchemaInfo.PropertyInfoDatabaseInstanceId.Name).SetValue(existingData, GetCorrectDatabaseInstanceId(databaseInstanceId, sourceDatabaseInstanceId, destinationDatabaseInstanceId, databaseInstanceMaxTimeStamps, lastUpdated));
                                }

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

                            if (SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.GlobalTimeStamp)
                            {
                                existingData.GetType().GetProperty(localSchemaInfo.PropertyInfoDeleted.Name).SetValue(existingData, deletedGlobalTimeStamp);
                            }
                            if (SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.DatabaseTimeStamp)
                            {
                                existingData.GetType().GetProperty(localSchemaInfo.PropertyInfoDeleted.Name).SetValue(existingData, deletedDatabaseTimeStamp);
                                existingData.GetType().GetProperty(localSchemaInfo.PropertyInfoDatabaseInstanceId.Name).SetValue(existingData, GetCorrectDatabaseInstanceId(databaseInstanceId, sourceDatabaseInstanceId, destinationDatabaseInstanceId, databaseInstanceMaxTimeStamps, lastUpdated));
                            }

                            PersistData(localSyncType, existingData, false, transaction, operationType, synchronizationId, customInfo);
                            if (!appliedIds.Contains(localId)) appliedIds.Add(localId);
                            if (!deletedIds.Contains(localId)) deletedIds.Add(localId);
                            deletes.Add(SyncLog.SyncLogData.FromJObject(InvokeSerializeDataToJson(localSyncType, existingData, localSchemaInfo, transaction, operationType, synchronizationId, customInfo), localSyncType, localSchemaInfo));
                        }
                    }
                }
                if (SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.DatabaseTimeStamp)
                {
                    foreach (var item in databaseInstanceMaxTimeStamps)
                    {
                        KnowledgeInfo knowledgeInfo = GetAllKnowledgeInfos(synchronizationId, customInfo).Where(w => w.DatabaseInstanceId == item.Key).FirstOrDefault();
                        if (knowledgeInfo != null && knowledgeInfo.MaxTimeStamp > item.Value) continue;
                        if (knowledgeInfo == null && item.Key == destinationDatabaseInstanceId)
                        {
                            throw new SyncEngineConstraintException("Unexpected Knowledge Info State on Destination. Destination is not provisioned yet.");
                        }
                        if (knowledgeInfo == null)
                        {
                            knowledgeInfo = new KnowledgeInfo()
                            {
                                DatabaseInstanceId = item.Key,
                                IsLocal = false
                            };
                        }
                        knowledgeInfo.MaxTimeStamp = item.Value;
                        CreateOrUpdateKnowledgeInfo(knowledgeInfo, synchronizationId, customInfo);
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

            return (localSyncType, appliedIds, deletedIds);
        }

        private string GetCorrectDatabaseInstanceId(string databaseInstanceId, string sourceDatabaseInstanceId, string destinationDatabaseInstanceId, Dictionary<string, long> databaseInstanceMaxTimeStamps, long lastUpdated)
        {
            string correct = null;
            string key = null;
            if (string.IsNullOrEmpty(databaseInstanceId))
            {
                correct = sourceDatabaseInstanceId;
                key = sourceDatabaseInstanceId;
            }
            else if (databaseInstanceId == destinationDatabaseInstanceId)
            {
                correct = null;
                key = destinationDatabaseInstanceId;
            }
            else
            {
                correct = databaseInstanceId;
                key = databaseInstanceId;
            }
            if (databaseInstanceMaxTimeStamps != null)
            {
                if (!databaseInstanceMaxTimeStamps.ContainsKey(key)) databaseInstanceMaxTimeStamps[key] = 0;
                if (lastUpdated > databaseInstanceMaxTimeStamps[key]) databaseInstanceMaxTimeStamps[key] = lastUpdated;
            }
            return correct;
        }

        private void ProcessPostEvents(List<string> log, List<Type> postEventTypes, Dictionary<Type, List<object>> dictDeletedIds, string synchronizationId, Dictionary<string, object> customInfo)
        {
            if (postEventTypes != null && postEventTypes.Count > 0)
            {
                log.Add("Processing Post Events...");
                log.Add($"Post Event Types Count: {postEventTypes.Count}");
                for (int i = 0; i < postEventTypes.Count; i++)
                {
                    Type postEventType = postEventTypes[i];
                    if (dictDeletedIds != null && dictDeletedIds.ContainsKey(postEventType))
                    {
                        log.Add($"Processing Post Event Delete for Type: {postEventType.Name}, Count: {dictDeletedIds[postEventType].Count}");
                        for (int j = 0; j < dictDeletedIds[postEventType].Count; j++)
                        {
                            PostEventDelete(postEventType, dictDeletedIds[postEventType][j], synchronizationId, customInfo);
                        }
                    }
                }
            }
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

        internal long InvokeGetNextTimeStamp()
        {
            long nextTimeStamp = GetNextTimeStamp();
            if (nextTimeStamp == 0) throw new SyncEngineConstraintException("GetNextTimeStamp should return value greater than zero");
            return nextTimeStamp;
        }
    }
}
