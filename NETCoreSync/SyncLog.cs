using System;
using System.Collections.Generic;
using System.Text;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace NETCoreSync
{
    public class SyncLog
    {
        public List<SyncLogData> SentChanges { get; } = new List<SyncLogData>();
        public AppliedInfo AppliedChanges { get; } = new AppliedInfo();

        public class AppliedInfo
        {
            public List<SyncLogData> Inserts { get; } = new List<SyncLogData>();
            public List<SyncLogData> Updates { get; } = new List<SyncLogData>();
            public List<SyncLogData> Deletes { get; } = new List<SyncLogData>();
            public List<SyncLogConflict> Conflicts { get; } = new List<SyncLogConflict>();
        }

        public class SyncLogData
        {
            public string TypeName { get; set; }
            public string Id { get; set; }
            public long LastUpdated { get; set; }
            public long? Deleted { get; set; }
            public string JsonData { get; set; }
            public string FriendlyId { get; set; }

            public static SyncLogData FromJObject(JObject jObject, Type syncType, SyncConfiguration.SchemaInfo schemaInfo)
            {
                SyncLogData syncLogData = new SyncLogData();
                syncLogData.TypeName = syncType.Name;
                syncLogData.Id = Convert.ToString(jObject[schemaInfo.PropertyInfoId.Name].Value<object>());
                syncLogData.LastUpdated = jObject[schemaInfo.PropertyInfoLastUpdated.Name].Value<long>();
                syncLogData.Deleted = jObject[schemaInfo.PropertyInfoDeleted.Name].Value<long?>();
                syncLogData.JsonData = jObject.ToString();
                if (schemaInfo.PropertyInfoFriendlyId != null)
                {
                    syncLogData.FriendlyId = jObject[schemaInfo.PropertyInfoFriendlyId.Name].Value<string>();
                }
                return syncLogData;
            }
        }

        public class SyncLogConflict
        {
            public enum ConflictTypeEnum
            {
                TargetDataIsNewerThanSource
            }

            public ConflictTypeEnum ConflictType { get; set; }
            public SyncLogData Data { get; set; }

            public SyncLogConflict(ConflictTypeEnum conflictType, SyncLogData data)
            {
                ConflictType = conflictType;
                Data = data;
            }
        }
    }

}
