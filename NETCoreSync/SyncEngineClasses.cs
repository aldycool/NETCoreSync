using System;
using System.Linq;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NETCoreSync.Exceptions;

namespace NETCoreSync
{
    public abstract partial class SyncEngine
    {
        internal enum PayloadAction
        {
            Synchronize,
            SynhronizeReverse,
            Knowledge
        }

        public enum OperationType
        {
            GetChanges = 1,
            ApplyChanges = 2,
            ProvisionKnowledge = 3
        }

        public enum ConflictType
        {
            NoConflict,
            ExistingDataIsNewerThanIncomingData,
            ExistingDataIsUpdatedByDifferentDatabaseInstanceId
        }

        public class KnowledgeInfo
        {
            public string DatabaseInstanceId { get; set; }
            public bool IsLocal { get; set; }
            public long MaxTimeStamp { get; set; }

            public override string ToString()
            {
                return $"{nameof(DatabaseInstanceId)}: {DatabaseInstanceId}, {nameof(IsLocal)}: {IsLocal}, {nameof(MaxTimeStamp)}: {MaxTimeStamp}";
            }
        }

        internal abstract class BaseInfo
        {
            public PayloadAction PayloadAction { get; set; }
            public string SynchronizationId { get; set; }
            public Dictionary<string, object> CustomInfo { get; set; } = new Dictionary<string, object>();

            public BaseInfo(PayloadAction payloadAction, string synchronizationId, Dictionary<string, object> customInfo)
            {
                PayloadAction = payloadAction;
                SynchronizationId = synchronizationId;
                if (customInfo != null) CustomInfo = customInfo;
            }
        }

        internal class GetChangesParameter : BaseInfo
        {
            public List<string> Log { get; set; } = new List<string>();
            public long LastSync { get; set; }
            public Dictionary<Type, List<object>> AppliedIds { get; set; } = new Dictionary<Type, List<object>>();
            public Dictionary<string, List<object>> PayloadAppliedIds { get; set; } = new Dictionary<string, List<object>>();

            public GetChangesParameter(PayloadAction payloadAction, string synchronizationId, Dictionary<string, object> customInfo) : base(payloadAction, synchronizationId, customInfo)
            {
            }

            public byte[] GetCompressed()
            {
                JObject payload = new JObject();
                payload[nameof(PayloadAction)] = PayloadAction.ToString();
                payload[nameof(SynchronizationId)] = SynchronizationId;
                payload[nameof(CustomInfo)] = JObject.FromObject(CustomInfo);
                payload[nameof(LastSync)] = LastSync;
                payload[nameof(PayloadAppliedIds)] = JObject.FromObject(PayloadAppliedIds);
                string json = JsonConvert.SerializeObject(payload);
                byte[] compressed = Compress(json);
                return compressed;
            }

            public static GetChangesParameter FromPayload(JObject payload, SyncEngine syncEngine)
            {
                string synchronizationId = payload[nameof(SynchronizationId)].Value<string>();
                Dictionary<string, object> customInfo = payload[nameof(CustomInfo)].ToObject<Dictionary<string, object>>();
                PayloadAction payloadAction = (PayloadAction)Enum.Parse(typeof(PayloadAction), payload[nameof(PayloadAction)].Value<string>());
                GetChangesParameter parameter = new GetChangesParameter(payloadAction, synchronizationId, customInfo);
                parameter.LastSync = payload[nameof(LastSync)].Value<long>();
                parameter.AppliedIds = PayloadHelper.GetAppliedIdsFromPayload(payload[nameof(PayloadAppliedIds)].ToObject<Dictionary<string, List<object>>>(), syncEngine, synchronizationId, customInfo);
                return parameter;
            }
        }

        internal class GetChangesResult : BaseInfo
        {
            public JArray Changes { get; set; } = new JArray();
            public long MaxTimeStamp { get; set; }
            public List<SyncLog.SyncLogData> LogChanges { get; set; } = new List<SyncLog.SyncLogData>();

            public GetChangesResult(PayloadAction payloadAction, string synchronizationId, Dictionary<string, object> customInfo) : base(payloadAction, synchronizationId, customInfo)
            {
            }

            public byte[] GetCompressed()
            {
                JObject payload = new JObject();
                payload[nameof(PayloadAction)] = PayloadAction.ToString();
                payload[nameof(SynchronizationId)] = SynchronizationId;
                payload[nameof(CustomInfo)] = JObject.FromObject(CustomInfo);
                payload[nameof(Changes)] = Changes;
                payload[nameof(MaxTimeStamp)] = MaxTimeStamp;
                payload[nameof(LogChanges)] = JArray.FromObject(LogChanges);
                string json = JsonConvert.SerializeObject(payload);
                byte[] compressed = Compress(json);
                return compressed;
            }

            public static GetChangesResult FromPayload(JObject payload)
            {
                string synchronizationId = payload[nameof(SynchronizationId)].Value<string>();
                Dictionary<string, object> customInfo = payload[nameof(CustomInfo)].ToObject<Dictionary<string, object>>();
                PayloadAction payloadAction = (PayloadAction)Enum.Parse(typeof(PayloadAction), payload[nameof(PayloadAction)].Value<string>());
                GetChangesResult result = new GetChangesResult(payloadAction, synchronizationId, customInfo);
                result.Changes = payload[nameof(Changes)].ToObject<JArray>();
                result.MaxTimeStamp = payload[nameof(MaxTimeStamp)].Value<long>();
                result.LogChanges = payload[nameof(LogChanges)].ToObject<List<SyncLog.SyncLogData>>();
                return result;
            }
        }

        internal class ApplyChangesParameter : BaseInfo
        {
            public List<string> Log { get; set; } = new List<string>();
            public JArray Changes { get; set; } = new JArray();

            public ApplyChangesParameter(PayloadAction payloadAction, string synchronizationId, Dictionary<string, object> customInfo) : base(payloadAction, synchronizationId, customInfo)
            {
            }

            public byte[] GetCompressed()
            {
                JObject payload = new JObject();
                payload[nameof(PayloadAction)] = PayloadAction.ToString();
                payload[nameof(SynchronizationId)] = SynchronizationId;
                payload[nameof(CustomInfo)] = JObject.FromObject(CustomInfo);
                payload[nameof(Changes)] = Changes;
                string json = JsonConvert.SerializeObject(payload);
                byte[] compressed = Compress(json);
                return compressed;
            }

            public static ApplyChangesParameter FromPayload(JObject payload)
            {
                string synchronizationId = payload[nameof(SynchronizationId)].Value<string>();
                Dictionary<string, object> customInfo = payload[nameof(CustomInfo)].ToObject<Dictionary<string, object>>();
                PayloadAction payloadAction = (PayloadAction)Enum.Parse(typeof(PayloadAction), payload[nameof(PayloadAction)].Value<string>());
                ApplyChangesParameter parameter = new ApplyChangesParameter(payloadAction, synchronizationId, customInfo);
                parameter.Changes = payload[nameof(Changes)].Value<JArray>();
                return parameter;
            }
        }

        internal class ApplyChangesResult : BaseInfo
        {
            public List<SyncLog.SyncLogData> Inserts { get; set; } = new List<SyncLog.SyncLogData>();
            public List<SyncLog.SyncLogData> Updates { get; set; } = new List<SyncLog.SyncLogData>();
            public List<SyncLog.SyncLogData> Deletes { get; set; } = new List<SyncLog.SyncLogData>();
            public List<SyncLog.SyncLogConflict> Conflicts { get; set; } = new List<SyncLog.SyncLogConflict>();
            public Dictionary<Type, List<object>> AppliedIds { get; set; } = new Dictionary<Type, List<object>>();
            public Dictionary<string, List<object>> PayloadAppliedIds { get; set; } = new Dictionary<string, List<object>>();

            public ApplyChangesResult(PayloadAction payloadAction, string synchronizationId, Dictionary<string, object> customInfo) : base(payloadAction, synchronizationId, customInfo)
            {
            }

            public byte[] GetCompressed()
            {
                JObject payload = new JObject();
                payload[nameof(PayloadAction)] = PayloadAction.ToString();
                payload[nameof(SynchronizationId)] = SynchronizationId;
                payload[nameof(CustomInfo)] = JObject.FromObject(CustomInfo);
                payload[nameof(Inserts)] = JArray.FromObject(Inserts);
                payload[nameof(Updates)] = JArray.FromObject(Updates);
                payload[nameof(Deletes)] = JArray.FromObject(Deletes);
                payload[nameof(Conflicts)] = JArray.FromObject(Conflicts);
                payload[nameof(PayloadAppliedIds)] = JObject.FromObject(PayloadHelper.GetAppliedIdsForPayload(AppliedIds));
                string json = JsonConvert.SerializeObject(payload);
                byte[] compressed = Compress(json);
                return compressed;
            }

            public static ApplyChangesResult FromPayload(JObject payload)
            {
                string synchronizationId = payload[nameof(SynchronizationId)].Value<string>();
                Dictionary<string, object> customInfo = payload[nameof(CustomInfo)].ToObject<Dictionary<string, object>>();
                PayloadAction payloadAction = (PayloadAction)Enum.Parse(typeof(PayloadAction), payload[nameof(PayloadAction)].Value<string>());
                ApplyChangesResult result = new ApplyChangesResult(payloadAction, synchronizationId, customInfo);
                result.Inserts = payload[nameof(Inserts)].ToObject<List<SyncLog.SyncLogData>>();
                result.Updates = payload[nameof(Updates)].ToObject<List<SyncLog.SyncLogData>>();
                result.Deletes = payload[nameof(Deletes)].ToObject<List<SyncLog.SyncLogData>>();
                result.Conflicts = payload[nameof(Conflicts)].ToObject<List<SyncLog.SyncLogConflict>>();
                result.PayloadAppliedIds = payload[nameof(PayloadAppliedIds)].ToObject<Dictionary<string, List<object>>>();
                return result;
            }
        }

        internal class GetKnowledgeParameter : BaseInfo
        {
            public List<string> Log { get; set; } = new List<string>();

            public GetKnowledgeParameter(PayloadAction payloadAction, string synchronizationId, Dictionary<string, object> customInfo) : base(payloadAction, synchronizationId, customInfo)
            {
            }

            public byte[] GetCompressed()
            {
                JObject payload = new JObject();
                payload[nameof(PayloadAction)] = PayloadAction.ToString();
                payload[nameof(SynchronizationId)] = SynchronizationId;
                payload[nameof(CustomInfo)] = JObject.FromObject(CustomInfo);
                string json = JsonConvert.SerializeObject(payload);
                byte[] compressed = Compress(json);
                return compressed;
            }

            public static GetKnowledgeParameter FromPayload(JObject payload)
            {
                string synchronizationId = payload[nameof(SynchronizationId)].Value<string>();
                Dictionary<string, object> customInfo = payload[nameof(CustomInfo)].ToObject<Dictionary<string, object>>();
                PayloadAction payloadAction = (PayloadAction)Enum.Parse(typeof(PayloadAction), payload[nameof(PayloadAction)].Value<string>());
                GetKnowledgeParameter result = new GetKnowledgeParameter(payloadAction, synchronizationId, customInfo);
                return result;
            }
        }

        internal class GetKnowledgeResult : BaseInfo
        {
            public List<KnowledgeInfo> KnowledgeInfos { get; set; } = new List<KnowledgeInfo>();

            public GetKnowledgeResult(PayloadAction payloadAction, string synchronizationId, Dictionary<string, object> customInfo) : base(payloadAction, synchronizationId, customInfo)
            {
            }

            public byte[] GetCompressed()
            {
                JObject payload = new JObject();
                payload[nameof(PayloadAction)] = PayloadAction.ToString();
                payload[nameof(SynchronizationId)] = SynchronizationId;
                payload[nameof(CustomInfo)] = JObject.FromObject(CustomInfo);
                payload[nameof(KnowledgeInfos)] = JArray.FromObject(KnowledgeInfos);
                string json = JsonConvert.SerializeObject(payload);
                byte[] compressed = Compress(json);
                return compressed;
            }

            public static GetKnowledgeResult FromPayload(JObject payload)
            {
                string synchronizationId = payload[nameof(SynchronizationId)].Value<string>();
                Dictionary<string, object> customInfo = payload[nameof(CustomInfo)].ToObject<Dictionary<string, object>>();
                PayloadAction payloadAction = (PayloadAction)Enum.Parse(typeof(PayloadAction), payload[nameof(PayloadAction)].Value<string>());
                GetKnowledgeResult result = new GetKnowledgeResult(payloadAction, synchronizationId, customInfo);
                result.KnowledgeInfos = payload[nameof(KnowledgeInfos)].ToObject<List<KnowledgeInfo>>();
                return result;
            }
        }

        internal class GetChangesByKnowledgeParameter : BaseInfo
        {
            public List<string> Log { get; set; } = new List<string>();
            public List<KnowledgeInfo> LocalKnowledgeInfos { get; set; } = new List<KnowledgeInfo>();
            public List<KnowledgeInfo> RemoteKnowledgeInfos { get; set; } = new List<KnowledgeInfo>();

            public GetChangesByKnowledgeParameter(PayloadAction payloadAction, string synchronizationId, Dictionary<string, object> customInfo) : base(payloadAction, synchronizationId, customInfo)
            {
            }

            public byte[] GetCompressed()
            {
                JObject payload = new JObject();
                payload[nameof(PayloadAction)] = PayloadAction.ToString();
                payload[nameof(SynchronizationId)] = SynchronizationId;
                payload[nameof(CustomInfo)] = JObject.FromObject(CustomInfo);
                payload[nameof(LocalKnowledgeInfos)] = JArray.FromObject(LocalKnowledgeInfos);
                payload[nameof(RemoteKnowledgeInfos)] = JArray.FromObject(RemoteKnowledgeInfos);
                string json = JsonConvert.SerializeObject(payload);
                byte[] compressed = Compress(json);
                return compressed;
            }

            public static GetChangesByKnowledgeParameter FromPayload(JObject payload)
            {
                string synchronizationId = payload[nameof(SynchronizationId)].Value<string>();
                Dictionary<string, object> customInfo = payload[nameof(CustomInfo)].ToObject<Dictionary<string, object>>();
                PayloadAction payloadAction = (PayloadAction)Enum.Parse(typeof(PayloadAction), payload[nameof(PayloadAction)].Value<string>());
                GetChangesByKnowledgeParameter parameter = new GetChangesByKnowledgeParameter(payloadAction, synchronizationId, customInfo);
                parameter.LocalKnowledgeInfos = payload[nameof(LocalKnowledgeInfos)].ToObject<List<KnowledgeInfo>>();
                parameter.RemoteKnowledgeInfos = payload[nameof(RemoteKnowledgeInfos)].ToObject<List<KnowledgeInfo>>();
                return parameter;
            }
        }

        internal class GetChangesByKnowledgeResult : BaseInfo
        {
            public JArray Changes { get; set; } = new JArray();
            public List<SyncLog.SyncLogData> LogChanges { get; set; } = new List<SyncLog.SyncLogData>();

            public GetChangesByKnowledgeResult(PayloadAction payloadAction, string synchronizationId, Dictionary<string, object> customInfo) : base(payloadAction, synchronizationId, customInfo)
            {
            }

            public byte[] GetCompressed()
            {
                JObject payload = new JObject();
                payload[nameof(PayloadAction)] = PayloadAction.ToString();
                payload[nameof(SynchronizationId)] = SynchronizationId;
                payload[nameof(CustomInfo)] = JObject.FromObject(CustomInfo);
                payload[nameof(Changes)] = Changes;
                payload[nameof(LogChanges)] = JArray.FromObject(LogChanges);
                string json = JsonConvert.SerializeObject(payload);
                byte[] compressed = Compress(json);
                return compressed;
            }

            public static GetChangesByKnowledgeResult FromPayload(JObject payload)
            {
                string synchronizationId = payload[nameof(SynchronizationId)].Value<string>();
                Dictionary<string, object> customInfo = payload[nameof(CustomInfo)].ToObject<Dictionary<string, object>>();
                PayloadAction payloadAction = (PayloadAction)Enum.Parse(typeof(PayloadAction), payload[nameof(PayloadAction)].Value<string>());
                GetChangesByKnowledgeResult result = new GetChangesByKnowledgeResult(payloadAction, synchronizationId, customInfo);
                result.Changes = payload[nameof(Changes)].ToObject<JArray>();
                result.LogChanges = payload[nameof(LogChanges)].ToObject<List<SyncLog.SyncLogData>>();
                return result;
            }
        }

        internal class ApplyChangesByKnowledgeParameter : BaseInfo
        {
            public List<string> Log { get; set; } = new List<string>();
            public JArray Changes { get; set; } = new JArray();
            public string SourceDatabaseInstanceId { get; set; }
            public string DestinationDatabaseInstanceId { get; set; }

            public ApplyChangesByKnowledgeParameter(PayloadAction payloadAction, string synchronizationId, Dictionary<string, object> customInfo) : base(payloadAction, synchronizationId, customInfo)
            {
            }

            public byte[] GetCompressed()
            {
                JObject payload = new JObject();
                payload[nameof(PayloadAction)] = PayloadAction.ToString();
                payload[nameof(SynchronizationId)] = SynchronizationId;
                payload[nameof(CustomInfo)] = JObject.FromObject(CustomInfo);
                payload[nameof(Changes)] = Changes;
                payload[nameof(SourceDatabaseInstanceId)] = SourceDatabaseInstanceId;
                payload[nameof(DestinationDatabaseInstanceId)] = DestinationDatabaseInstanceId;
                string json = JsonConvert.SerializeObject(payload);
                byte[] compressed = Compress(json);
                return compressed;
            }

            public static ApplyChangesByKnowledgeParameter FromPayload(JObject payload)
            {
                string synchronizationId = payload[nameof(SynchronizationId)].Value<string>();
                Dictionary<string, object> customInfo = payload[nameof(CustomInfo)].ToObject<Dictionary<string, object>>();
                PayloadAction payloadAction = (PayloadAction)Enum.Parse(typeof(PayloadAction), payload[nameof(PayloadAction)].Value<string>());
                ApplyChangesByKnowledgeParameter parameter = new ApplyChangesByKnowledgeParameter(payloadAction, synchronizationId, customInfo);
                parameter.Changes = payload[nameof(Changes)].Value<JArray>();
                parameter.SourceDatabaseInstanceId = payload[nameof(SourceDatabaseInstanceId)].Value<string>();
                parameter.DestinationDatabaseInstanceId = payload[nameof(DestinationDatabaseInstanceId)].Value<string>();
                return parameter;
            }
        }

        internal class ApplyChangesByKnowledgeResult : BaseInfo
        {
            public List<SyncLog.SyncLogData> Inserts { get; set; } = new List<SyncLog.SyncLogData>();
            public List<SyncLog.SyncLogData> Updates { get; set; } = new List<SyncLog.SyncLogData>();
            public List<SyncLog.SyncLogData> Deletes { get; set; } = new List<SyncLog.SyncLogData>();
            public List<SyncLog.SyncLogConflict> Conflicts { get; set; } = new List<SyncLog.SyncLogConflict>();

            public ApplyChangesByKnowledgeResult(PayloadAction payloadAction, string synchronizationId, Dictionary<string, object> customInfo) : base(payloadAction, synchronizationId, customInfo)
            {
            }

            public byte[] GetCompressed()
            {
                JObject payload = new JObject();
                payload[nameof(PayloadAction)] = PayloadAction.ToString();
                payload[nameof(SynchronizationId)] = SynchronizationId;
                payload[nameof(CustomInfo)] = JObject.FromObject(CustomInfo);
                payload[nameof(Inserts)] = JArray.FromObject(Inserts);
                payload[nameof(Updates)] = JArray.FromObject(Updates);
                payload[nameof(Deletes)] = JArray.FromObject(Deletes);
                payload[nameof(Conflicts)] = JArray.FromObject(Conflicts);
                string json = JsonConvert.SerializeObject(payload);
                byte[] compressed = Compress(json);
                return compressed;
            }

            public static ApplyChangesByKnowledgeResult FromPayload(JObject payload)
            {
                string synchronizationId = payload[nameof(SynchronizationId)].Value<string>();
                Dictionary<string, object> customInfo = payload[nameof(CustomInfo)].ToObject<Dictionary<string, object>>();
                PayloadAction payloadAction = (PayloadAction)Enum.Parse(typeof(PayloadAction), payload[nameof(PayloadAction)].Value<string>());
                ApplyChangesByKnowledgeResult result = new ApplyChangesByKnowledgeResult(payloadAction, synchronizationId, customInfo);
                result.Inserts = payload[nameof(Inserts)].ToObject<List<SyncLog.SyncLogData>>();
                result.Updates = payload[nameof(Updates)].ToObject<List<SyncLog.SyncLogData>>();
                result.Deletes = payload[nameof(Deletes)].ToObject<List<SyncLog.SyncLogData>>();
                result.Conflicts = payload[nameof(Conflicts)].ToObject<List<SyncLog.SyncLogConflict>>();
                return result;
            }
        }

        internal class PayloadHelper
        {
            public static Dictionary<Type, List<object>> GetAppliedIdsFromPayload(Dictionary<string, List<object>> safeAppliedIds, SyncEngine syncEngine, string synchronizationId, Dictionary<string, object> customInfo)
            {
                Dictionary<Type, List<object>> result = new Dictionary<Type, List<object>>();
                foreach (var item in safeAppliedIds)
                {
                    string fullName = UnsafeFullName(item.Key);
                    Type localType = syncEngine.SyncConfiguration.SyncTypes.Where(w => w.FullName == fullName).FirstOrDefault();
                    if (localType == null) throw new SyncEngineConstraintException($"Missing localType: {fullName} from AppliedIds");
                    if (!result.ContainsKey(localType)) result[localType] = new List<object>();
                    for (int i = 0; i < item.Value.Count; i++)
                    {
                        JValue value = new JValue(item.Value[i]);
                        object localId = syncEngine.TransformIdType(localType, value, null, OperationType.GetChanges, synchronizationId, customInfo);
                        result[localType].Add(localId);
                    }
                }
                return result;
            }

            public static Dictionary<string, List<object>> GetAppliedIdsForPayload(Dictionary<Type, List<object>> appliedIds)
            {
                Dictionary<string, List<object>> result = new Dictionary<string, List<object>>();
                foreach (var item in appliedIds)
                {
                    string fullName = SafeFullName(item.Key.FullName);
                    if (!result.ContainsKey(fullName)) result[fullName] = new List<object>();
                    for (int i = 0; i < item.Value.Count; i++)
                    {
                        result[fullName].Add(item.Value[i]);
                    }
                }
                return result;
            }

            private static string SafeFullName(string fullName)
            {
                return fullName.Replace(".", "_");
            }

            private static string UnsafeFullName(string safeFullName)
            {
                return safeFullName.Replace("_", ".");
            }
        }
    }
}
