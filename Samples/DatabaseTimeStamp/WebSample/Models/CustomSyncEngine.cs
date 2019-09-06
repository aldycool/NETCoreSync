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
using Microsoft.EntityFrameworkCore.Storage;

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
            DbQueryTimeStampResult result = databaseContext.DbQueryTimeStampResults.FromSql("SELECT CAST((EXTRACT(EPOCH FROM NOW() AT TIME ZONE 'UTC') * 1000) AS bigint) AS timestamp").First();
            return result.timestamp;
        }

        public override List<KnowledgeInfo> GetAllKnowledgeInfos(string synchronizationId, Dictionary<string, object> customInfo)
        {
            return databaseContext.Knowledges.Where(w => w.SynchronizationID == synchronizationId).Select(s => new KnowledgeInfo()
            {
                DatabaseInstanceId = s.DatabaseInstanceId,
                IsLocal = s.IsLocal,
                MaxTimeStamp = s.MaxTimeStamp
            }).ToList();
        }

        public override void CreateOrUpdateKnowledgeInfo(KnowledgeInfo knowledgeInfo, string synchronizationId, Dictionary<string, object> customInfo)
        {
            Knowledge knowledge = databaseContext.Knowledges.Where(w => w.SynchronizationID == synchronizationId && w.DatabaseInstanceId == knowledgeInfo.DatabaseInstanceId).FirstOrDefault();
            if (knowledge == null)
            {
                knowledge = new Knowledge();
                knowledge.ID = Guid.NewGuid();
                knowledge.SynchronizationID = synchronizationId;
                knowledge.DatabaseInstanceId = knowledgeInfo.DatabaseInstanceId;
                databaseContext.Add(knowledge);
                databaseContext.SaveChanges();
                knowledge = databaseContext.Knowledges.Where(w => w.SynchronizationID == synchronizationId && w.DatabaseInstanceId == knowledgeInfo.DatabaseInstanceId).First();
            }
            knowledge.IsLocal = knowledgeInfo.IsLocal;
            knowledge.MaxTimeStamp = knowledgeInfo.MaxTimeStamp;
            databaseContext.Update(knowledge);
            databaseContext.SaveChanges();
        }

        public override object StartTransaction(Type classType, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            IDbContextTransaction transaction = null;
            if (operationType == OperationType.ApplyChanges || operationType == OperationType.ProvisionKnowledge) transaction = databaseContext.Database.BeginTransaction();
            return transaction;
        }

        public override void CommitTransaction(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            if (transaction != null)
            {
                ((IDbContextTransaction)transaction).Commit();
            }
        }

        public override void RollbackTransaction(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            if (transaction != null)
            {
                ((IDbContextTransaction)transaction).Rollback();
            }
        }

        public override void EndTransaction(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            if (transaction != null)
            {
                ((IDbContextTransaction)transaction).Dispose();
            }
        }

        public override IQueryable GetQueryable(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            if (classType == typeof(SyncDepartment)) return databaseContext.Departments.Where(w => w.SynchronizationID == synchronizationId).AsQueryable();
            if (classType == typeof(SyncEmployee)) return databaseContext.Employees.Where(w => w.SynchronizationID == synchronizationId).AsQueryable();
            throw new NotImplementedException();
        }

        public override string SerializeDataToJson(Type classType, object data, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            List<string> ignoreProperties = new List<string>();
            ignoreProperties.Add("SynchronizationID");
            if (classType == typeof(SyncDepartment)) ignoreProperties.Add("Employees");
            if (classType == typeof(SyncEmployee)) ignoreProperties.Add("Department");
            if (!customContractResolvers.ContainsKey(classType)) customContractResolvers.Add(classType, new CustomContractResolver(null, ignoreProperties));
            CustomContractResolver customContractResolver = customContractResolvers[classType];
            string json = JsonConvert.SerializeObject(data, new JsonSerializerSettings() { ContractResolver = customContractResolver });
            return json;
        }

        public override object DeserializeJsonToNewData(Type classType, JObject jObject, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            object data = Activator.CreateInstance(classType);
            ConvertClientObjectToLocal(classType, jObject, data);
            JsonConvert.PopulateObject(jObject.ToString(), data);
            classType.GetProperty("SynchronizationID").SetValue(data, synchronizationId);
            return data;
        }

        public override object DeserializeJsonToExistingData(Type classType, JObject jObject, object data, object transaction, OperationType operationType, ConflictType conflictType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            if (conflictType != ConflictType.NoConflict)
            {
                // Here you can react accordingly if there's a conflict during Updates.
                // For DatabaseTimeStamp, the possibilities of conflict types are:
                // 1. ConflictType.ExistingDataIsNewerThanIncomingData, means that the ExistingData (parameter: data) timestamp is newer than the IncomingData (parameter: jObject).
                // 2. ConflictType.ExistingDataIsUpdatedByDifferentDatabaseInstanceId, means that the ExistingData (parameter: data) is updated by different Database Instance Id (perhaps updated by other devices) than the IncomingData (parameter: jObject) Database Instance Id.
                //
                // If you return null here, then the update will be canceled and the conflict will be registered in the SyncResult's Conflict Log.
                // In this example, the conflict is ignored and continue with the data update.
            }
            ConvertClientObjectToLocal(classType, jObject, data);
            JsonConvert.PopulateObject(jObject.ToString(), data);
            return data;
        }

        private void ConvertClientObjectToLocal(Type classType, JObject jObject, object data)
        {
            if (classType == typeof(SyncEmployee))
            {
                JObject objDepartment = jObject.Value<JObject>("Department");
                string departmentId = objDepartment == null ? null : objDepartment.Value<string>("Id");
                if (!string.IsNullOrEmpty(departmentId))
                {
                    data.GetType().GetProperty("DepartmentID").SetValue(data, new Guid(departmentId));
                }
                jObject.Remove("Department");
            }
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
            public long timestamp { get; set; }
        }
    }
}
