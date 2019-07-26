using System;
using System.Linq;
using System.Collections.Generic;
using System.Text;
using System.Reflection;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json.Serialization;
using MobileSample.Services;
using Realms;
using NETCoreSync;

namespace MobileSample.Models
{
    public class CustomSyncEngine : SyncEngine
    {
        public readonly Realm Realm;
        private readonly Dictionary<Type, CustomContractResolver> customContractResolvers;

        public CustomSyncEngine(DatabaseService databaseService, SyncConfiguration syncConfiguration) : base(syncConfiguration)
        {
            Realm = databaseService.GetInstance();
            customContractResolvers = new Dictionary<Type, CustomContractResolver>();
        }

        public override long GetNextTimeStamp()
        {
            TimeStamp timeStamp = Realm.All<TimeStamp>().FirstOrDefault();
            if (timeStamp == null)
            {
                timeStamp = new TimeStamp();
                Realm.Add(timeStamp);
                timeStamp = Realm.All<TimeStamp>().First();
            }
            timeStamp.Counter.Increment();
            return timeStamp.Counter;
        }

        public override void CreateOrUpdateDatabaseInstanceInfo(DatabaseInstanceInfo databaseInstanceInfo)
        {
            Realm.Write(() =>
            {
                Models.DatabaseInstanceInfo info = Realm.All<Models.DatabaseInstanceInfo>().Where(w => w.DatabaseInstanceId == databaseInstanceInfo.DatabaseInstanceId).FirstOrDefault();
                if (info == null)
                {
                    info = new Models.DatabaseInstanceInfo();
                    info.DatabaseInstanceId = databaseInstanceInfo.DatabaseInstanceId;
                    Realm.Add(info);
                    info = Realm.All<Models.DatabaseInstanceInfo>().Where(w => w.DatabaseInstanceId == databaseInstanceInfo.DatabaseInstanceId).First();
                }
                info.IsLocal = databaseInstanceInfo.IsLocal;
                info.LastSyncTimeStamp = databaseInstanceInfo.LastSyncTimeStamp;
            });
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
                info = Realm.All<Models.DatabaseInstanceInfo>().Where(w => w.IsLocal).FirstOrDefault();
            }
            else
            {
                info = Realm.All<Models.DatabaseInstanceInfo>().Where(w => w.DatabaseInstanceId == databaseInstanceId).FirstOrDefault();
            }
            if (info == null) return null;
            DatabaseInstanceInfo databaseInstanceInfo = new DatabaseInstanceInfo()
            {
                DatabaseInstanceId = info.DatabaseInstanceId,
                IsLocal = info.IsLocal,
                LastSyncTimeStamp = info.LastSyncTimeStamp
            };
            return databaseInstanceInfo;
        }

        public override object StartTransaction(Type classType, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            Transaction transaction = null;
            if (operationType == OperationType.ApplyChanges) transaction = Realm.BeginWrite();
            return transaction;
        }

        public override void CommitTransaction(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            if (transaction != null)
            {
                ((Transaction)transaction).Commit();
            }
        }

        public override void RollbackTransaction(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            if (transaction != null)
            {
                ((Transaction)transaction).Rollback();
            }
        }

        public override void EndTransaction(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            if (transaction != null)
            {
                ((Transaction)transaction).Dispose();
            }
        }

        public override IQueryable GetQueryable(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            if (classType == typeof(Department)) return Realm.All<Department>();
            if (classType == typeof(Employee)) return Realm.All<Employee>();
            throw new NotImplementedException();
        }

        public override string SerializeDataToJson(Type classType, object data, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            //SAMPE SINI!
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

        public override object DeserializeJsonToExistingData(Type classType, JObject jObject, object data, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            JsonConvert.PopulateObject(jObject.ToString(), data);
            return data;
        }

        public override void PersistData(Type classType, object data, bool isNew, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            //DatabaseContext databaseContext = databaseService.GetDatabaseContext();
            //if (isNew)
            //{
            //    databaseContext.Add(data);
            //}
            //else
            //{
            //    databaseContext.Update(data);
            //}
            //databaseContext.SaveChanges();
        }

        public override object TransformIdType(Type classType, JValue id, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            return id.Value<string>();
        }

        public override void PostEventDelete(Type classType, object id, string synchronizationId, Dictionary<string, object> customInfo)
        {
            //if (classType == typeof(Department))
            //{
            //    string stringId = (string)id;
            //    DatabaseContext databaseContext = databaseService.GetDatabaseContext();
            //    List<Employee> dependentEmployees = databaseContext.Employees.Where(w => w.DepartmentId == stringId).ToList();
            //    for (int i = 0; i < dependentEmployees.Count; i++)
            //    {
            //        dependentEmployees[i].Department = null;
            //        dependentEmployees[i].DepartmentId = null;
            //        databaseContext.Update(dependentEmployees[i]);
            //    }
            //    databaseContext.SaveChanges();
            //}
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
