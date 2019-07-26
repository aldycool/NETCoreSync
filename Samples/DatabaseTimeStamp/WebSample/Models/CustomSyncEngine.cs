using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using NETCoreSync;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json.Serialization;
using Microsoft.EntityFrameworkCore;

namespace WebSample.Models
{
    public class CustomSyncEngine : SyncEngine
    {
        private readonly DatabaseContext databaseContext;
        private readonly Dictionary<Type, CustomContractResolver> customContractResolvers;

        public CustomSyncEngine(DatabaseContext databaseContext, SyncConfiguration syncConfiguration) : base(syncConfiguration)
        {
            this.databaseContext = databaseContext;
            customContractResolvers = new Dictionary<Type, CustomContractResolver>();
        }

        public override long GetNextTimeStamp()
        {
            DbQueryTimeStampResult result = databaseContext.DbQueryTimeStampResults.FromSql("SELECT CAST((EXTRACT(EPOCH FROM NOW() AT TIME ZONE 'UTC') * 1000) AS bigint) AS TimeStamp").First();
            return result.TimeStamp;
        }

        public override void CreateOrUpdateDatabaseInstanceInfo(DatabaseInstanceInfo databaseInstanceInfo)
        {
            Guid id = new Guid(databaseInstanceInfo.DatabaseInstanceId);
            Models.DatabaseInstanceInfo info = databaseContext.DatabaseInstanceInfos.Where(w => w.DatabaseInstanceId == id).FirstOrDefault();
            if (info == null)
            {
                info = new Models.DatabaseInstanceInfo();
                info.DatabaseInstanceId = id;
                databaseContext.Add(info);
                databaseContext.SaveChanges();
                info = databaseContext.DatabaseInstanceInfos.Where(w => w.DatabaseInstanceId == id).First();
            }
            info.IsLocal = databaseInstanceInfo.IsLocal;
            info.LastSyncTimeStamp = databaseInstanceInfo.LastSyncTimeStamp;
            databaseContext.Update(info);
            databaseContext.SaveChanges();
        }

        public override DatabaseInstanceInfo GetLocalDatabaseInstanceInfo()
        {
            return GetDatabaseInstanceInfoImpl(true, null);
        }

        public override DatabaseInstanceInfo GetRemoteDatabaseInstanceInfo(string databaseInstanceId)
        {
            return GetDatabaseInstanceInfoImpl(false, databaseInstanceId);
        }

        private DatabaseInstanceInfo GetDatabaseInstanceInfoImpl(bool isLocal, string databaseInstanceId)
        {
            Models.DatabaseInstanceInfo info = null;
            if (isLocal)
            {
                info = databaseContext.DatabaseInstanceInfos.Where(w => w.IsLocal).FirstOrDefault();
            }
            else
            {
                Guid id = new Guid(databaseInstanceId);
                info = databaseContext.DatabaseInstanceInfos.Where(w => w.DatabaseInstanceId == id).FirstOrDefault();
            }
            if (info == null) return null;
            DatabaseInstanceInfo databaseInstanceInfo = new DatabaseInstanceInfo()
            {
                DatabaseInstanceId = info.DatabaseInstanceId.ToString(),
                IsLocal = info.IsLocal,
                LastSyncTimeStamp = info.LastSyncTimeStamp
            };
            return databaseInstanceInfo;
        }

        public override IQueryable GetQueryable(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            if (classType == typeof(SyncDepartment)) return databaseContext.Departments.Where(w => w.SynchronizationID == synchronizationId).AsQueryable();
            if (classType == typeof(SyncEmployee)) return databaseContext.Employees.Where(w => w.SynchronizationID == synchronizationId).AsQueryable();
            throw new NotImplementedException();
        }

        public override string SerializeDataToJson(Type classType, object data, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            //SAMPE SINI!
            Dictionary<string, string> renameProperties = new Dictionary<string, string>();
            if (classType == typeof(SyncEmployee)) renameProperties.Add("DepartmentID", "DepartmentId");
            List<string> ignoreProperties = new List<string>();
            ignoreProperties.Add("SynchronizationID");
            if (classType == typeof(SyncDepartment)) ignoreProperties.Add("Employees");
            if (classType == typeof(SyncEmployee)) ignoreProperties.Add("Department");
            if (!customContractResolvers.ContainsKey(classType)) customContractResolvers.Add(classType, new CustomContractResolver(renameProperties, ignoreProperties));
            CustomContractResolver customContractResolver = customContractResolvers[classType];
            string json = JsonConvert.SerializeObject(data, new JsonSerializerSettings() { ContractResolver = customContractResolver });
            return json;
        }

        public override object DeserializeJsonToNewData(Type classType, JObject jObject, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            object data = Activator.CreateInstance(classType);
            JsonConvert.PopulateObject(jObject.ToString(), data);
            classType.GetProperty("SynchronizationID").SetValue(data, synchronizationId);
            return data;
        }

        public override object DeserializeJsonToExistingData(Type classType, JObject jObject, object data, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            JsonConvert.PopulateObject(jObject.ToString(), data);
            return data;
        }

        public override void PersistData(Type classType, object data, bool isNew, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            if (isNew)
            {
                databaseContext.Add(data);
            }
            else
            {
                databaseContext.Update(data);
            }
            databaseContext.SaveChanges();
        }

        public override object TransformIdType(Type classType, JValue id, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            return new Guid(id.Value<string>());
        }

        public override void PostEventDelete(Type classType, object id, string synchronizationId, Dictionary<string, object> customInfo)
        {
            if (classType == typeof(SyncDepartment))
            {
                Guid guidId = (Guid)id;
                List<SyncEmployee> dependentEmployees = databaseContext.Employees.Where(w => w.SynchronizationID == synchronizationId && w.DepartmentID == guidId).ToList();
                for (int i = 0; i < dependentEmployees.Count; i++)
                {
                    dependentEmployees[i].Department = null;
                    dependentEmployees[i].DepartmentID = null;
                    databaseContext.Update(dependentEmployees[i]);
                }
                databaseContext.SaveChanges();
            }
        }

        public class CustomContractResolver : DefaultContractResolver
        {
            private readonly Dictionary<string, string> renameProperties;
            private readonly List<string> ignoreProperties;

            public CustomContractResolver(Dictionary<string, string> renameProperties, List<string> ignoreProperties)
            {
                this.renameProperties = renameProperties;
                this.ignoreProperties = ignoreProperties;
            }

            protected override JsonProperty CreateProperty(MemberInfo member, MemberSerialization memberSerialization)
            {
                JsonProperty jsonProperty = base.CreateProperty(member, memberSerialization);
                if (renameProperties != null && renameProperties.ContainsKey(jsonProperty.PropertyName))
                {
                    jsonProperty.PropertyName = renameProperties[jsonProperty.PropertyName];
                }
                if (ignoreProperties != null && ignoreProperties.Contains(jsonProperty.PropertyName))
                {
                    jsonProperty.ShouldSerialize = i => false;
                    jsonProperty.Ignored = true;
                }
                return jsonProperty;
            }
        }

        public class DbQueryTimeStampResult
        {
            public long TimeStamp { get; set; }
        }
    }
}
