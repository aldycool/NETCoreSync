using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace NETCoreSync
{
    public abstract partial class SyncEngine
    {
        public class DatabaseInstanceInfo
        {
            public string DatabaseInstanceId { get; set; }
            public bool IsLocal { get; set; }
            public long LastSyncTimeStamp { get; set; }
        }

        internal abstract class PreparePayloadParameter
        {
            public PayloadAction PayloadAction { get; set; }
            public string SynchronizationId { get; set; }
            public Dictionary<string, object> CustomInfo { get; set; }
            public List<string> Log { get; set; } = new List<string>();
        }

        internal class PreparePayloadGlobalTimeStampParameter : PreparePayloadParameter
        {
            public long? LastSync { get; set; }
            public Dictionary<Type, List<object>> AppliedIds { get; set; }
        }

        internal class PreparePayloadDatabaseTimeStampParameter : PreparePayloadParameter
        {
        }

        internal abstract class PreparePayloadResult
        {
            private readonly JObject Payload;

            public PreparePayloadResult(PreparePayloadParameter parameter)
            {
                Payload = new JObject();
                Payload[nameof(parameter.SynchronizationId)] = parameter.SynchronizationId;
                Payload[nameof(parameter.CustomInfo)] = JObject.FromObject(parameter.CustomInfo);
                Payload[nameof(parameter.PayloadAction)] = parameter.PayloadAction.ToString();

                if (parameter is PreparePayloadGlobalTimeStampParameter)
                {
                    Payload[nameof(PreparePayloadGlobalTimeStampParameter.LastSync)] = ((PreparePayloadGlobalTimeStampParameter)parameter).LastSync;
                }
            }

            public void SetCustomPayload(string key, JToken value)
            {
                Payload[key] = value;
            }

            public byte[] GetCompressed()
            {
                string json = JsonConvert.SerializeObject(Payload);
                byte[] compressed = Compress(json);
                return compressed;
            }
        }

        internal class PreparePayloadGlobalTimeStampResult : PreparePayloadResult
        {
            public long MaxTimeStamp { get; set; }
            public List<SyncLog.SyncLogData> LogChanges { get; set; } = new List<SyncLog.SyncLogData>();

            public PreparePayloadGlobalTimeStampResult(PreparePayloadParameter parameter) : base(parameter)
            {
            }
        }

        internal class PreparePayloadDatabaseTimeStampResult : PreparePayloadResult
        {
            public PreparePayloadDatabaseTimeStampResult(PreparePayloadParameter parameter) : base(parameter)
            {
            }
        }

        internal abstract class ProcessPayloadParameter
        {
            public readonly JObject Payload;
            public readonly PayloadAction PayloadAction;
            public readonly string SynchronizationId;
            public readonly Dictionary<string, object> CustomInfo;
            public List<string> Log { get; set; } = new List<string>();
            public List<SyncLog.SyncLogData> Inserts = new List<SyncLog.SyncLogData>();
            public List<SyncLog.SyncLogData> Updates = new List<SyncLog.SyncLogData>();
            public List<SyncLog.SyncLogData> Deletes = new List<SyncLog.SyncLogData>();
            public List<SyncLog.SyncLogConflict> Conflicts = new List<SyncLog.SyncLogConflict>();

            public ProcessPayloadParameter(byte[] syncDataBytes)
            {
                string json = Decompress(syncDataBytes);
                Payload = JsonConvert.DeserializeObject<JObject>(json);
                SynchronizationId = Payload[nameof(SynchronizationId)].Value<string>();
                CustomInfo = Payload[nameof(CustomInfo)].ToObject<Dictionary<string, object>>();
                PayloadAction = (PayloadAction)Enum.Parse(typeof(PayloadAction), Payload[nameof(PayloadAction)].Value<string>());
            }

            public JToken GetCustomPayload(string key)
            {
                JToken token = Payload[key];
                return token;
            }
        }

        internal class ProcessPayloadGlobalTimeStampParameter : ProcessPayloadParameter
        {
            public readonly long LastSync;

            public ProcessPayloadGlobalTimeStampParameter(byte[] syncDataBytes) : base(syncDataBytes)
            {
                LastSync = Payload[nameof(LastSync)].Value<long>();
            }
        }

        internal class ProcessPayloadDatabaseTimeStampParameter : ProcessPayloadParameter
        {
            public ProcessPayloadDatabaseTimeStampParameter(byte[] syncDataBytes) : base(syncDataBytes)
            {
            }
        }

        internal class ProcessPayloadResult
        {
        }

        internal class ProcessPayloadGlobalTimeStampResult : ProcessPayloadResult
        {
            public readonly Dictionary<Type, List<object>> AppliedIds = new Dictionary<Type, List<object>>();
        }

        internal class ProcessPayloadDtabaseTimeStampResult : ProcessPayloadResult
        {
        }
    }
}
