using System;
using System.Linq;
using System.Collections.Generic;
using System.Text;
using System.Reflection;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json.Serialization;
using MobileSample.Services;
using NETCoreSync;

namespace MobileSample.Models
{
    public class CustomSyncEngine : SyncEngine
    {
        private readonly DatabaseService databaseService;
        private readonly Dictionary<Type, CustomContractResolver> customContractResolvers;

        public CustomSyncEngine(DatabaseService databaseService, SyncConfiguration syncConfiguration) : base(syncConfiguration)
        {
            this.databaseService = databaseService;
            customContractResolvers = new Dictionary<Type, CustomContractResolver>();
        }

        public override bool IsServerEngine()
        {
            return false;
        }

        public override long GetClientLastSync()
        {
            return databaseService.GetLastSync();
        }

        public override void SetClientLastSync(long lastSync)
        {
            databaseService.SetLastSync(lastSync);
        }

        public override IQueryable GetQueryable(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            if (classType == typeof(Department)) return databaseService.GetDatabaseContext().Departments.AsQueryable();
            if (classType == typeof(Employee)) return databaseService.GetDatabaseContext().Employees.AsQueryable();
            throw new NotImplementedException();
        }

        public override string SerializeDataToJson(Type classType, object data, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            Dictionary<string, string> renameProperties = new Dictionary<string, string>();
            if (classType == typeof(Employee)) renameProperties.Add("DepartmentId", "DepartmentID");
            List<string> ignoreProperties = new List<string>();
            if (classType == typeof(Department)) ignoreProperties.Add("Employees");
            if (classType == typeof(Employee)) ignoreProperties.Add("Department");
            if (!customContractResolvers.ContainsKey(classType)) customContractResolvers.Add(classType, new CustomContractResolver(renameProperties, ignoreProperties));
            CustomContractResolver customContractResolver = customContractResolvers[classType];
            string json = JsonConvert.SerializeObject(data, new JsonSerializerSettings() { ContractResolver = customContractResolver });
            return json;
        }

        public override object DeserializeJsonToNewData(Type classType, JObject jObject, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            object data = Activator.CreateInstance(classType);
            JsonConvert.PopulateObject(jObject.ToString(), data);
            return data;
        }

        public override object DeserializeJsonToExistingData(Type classType, JObject jObject, object data, object transaction, OperationType operationType, ConflictType conflictType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            if (conflictType != ConflictType.NoConflict)
            {
                // Here you can react accordingly if there's a conflict during Updates.
                // For GlobalTimeStamp, the possibilities of conflict types are:
                // 1. ConflictType.ExistingDataIsNewerThanIncomingData, means that the ExistingData (parameter: data) timestamp is newer than the IncomingData (parameter: jObject).
                //
                // If you return null here, then the update will be canceled and the conflict will be registered in the SyncResult's Conflict Log.
                // In this example, the conflict is ignored and continue with the data update.
            }
            JsonConvert.PopulateObject(jObject.ToString(), data);
            return data;
        }

        public override void PersistData(Type classType, object data, bool isNew, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            DatabaseContext databaseContext = databaseService.GetDatabaseContext();
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
            return id.Value<string>();
        }

        public override void PostEventDelete(Type classType, object id, string synchronizationId, Dictionary<string, object> customInfo)
        {
            if (classType == typeof(Department))
            {
                string stringId = (string)id;
                DatabaseContext databaseContext = databaseService.GetDatabaseContext();
                List<Employee> dependentEmployees = databaseContext.Employees.Where(w => w.DepartmentId == stringId).ToList();
                for (int i = 0; i < dependentEmployees.Count; i++)
                {
                    dependentEmployees[i].Department = null;
                    dependentEmployees[i].DepartmentId = null;
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
    }
}
