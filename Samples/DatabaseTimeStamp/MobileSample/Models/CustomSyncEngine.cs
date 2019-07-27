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

        public override void CreateOrUpdateDatabaseInstanceInfo(string synchronizationId, DatabaseInstanceInfo databaseInstanceInfo)
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

        public override DatabaseInstanceInfo GetRemoteDatabaseInstanceInfo(string synchronizationId, string databaseInstanceId)
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
            if (!customContractResolvers.ContainsKey(classType)) customContractResolvers.Add(classType, new CustomContractResolver(classType));
            CustomContractResolver customContractResolver = customContractResolvers[classType];
            string json = JsonConvert.SerializeObject(data, new JsonSerializerSettings() { ContractResolver = customContractResolver });
            return json;
        }

        public override object DeserializeJsonToNewData(Type classType, JObject jObject, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            object data = Activator.CreateInstance(classType);
            ConvertServerObjectToLocal(classType, jObject, data);
            JsonConvert.PopulateObject(jObject.ToString(), data);
            return data;
        }

        public override object DeserializeJsonToExistingData(Type classType, JObject jObject, object data, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            ConvertServerObjectToLocal(classType, jObject, data);
            JsonConvert.PopulateObject(jObject.ToString(), data);
            return data;
        }

        private void ConvertServerObjectToLocal(Type classType, JObject jObject, object data)
        {
            if (classType == typeof(Employee))
            {
                string departmentId = jObject.Value<string>("DepartmentID");
                if (!string.IsNullOrEmpty(departmentId))
                {
                    data.GetType().GetProperty("Department").SetValue(data, Realm.Find<Department>(departmentId));
                }
                jObject.Remove("DepartmentID");
            }
        }

        public override void PersistData(Type classType, object data, bool isNew, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            if (isNew)
            {
                Realm.Add((RealmObject)data);
            }
        }

        public override object TransformIdType(Type classType, JValue id, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            return id.Value<string>();
        }

        public override void PostEventDelete(Type classType, object id, string synchronizationId, Dictionary<string, object> customInfo)
        {
            if (classType == typeof(Department))
            {
                Realm.Write(() =>
                {
                    string dataId = (string)id;
                    Department department = Realm.Find<Department>(dataId);
                    if (department != null)
                    {
                        List<Employee> employees = Realm.All<Employee>().Where(w => w.Department == department).ToList();
                        for (int i = 0; i < employees.Count; i++)
                        {
                            employees[i].Department = null;
                        }
                    }
                });
            }
        }

        public class CustomContractResolver : DefaultContractResolver
        {
            private readonly Type rootType;

            public CustomContractResolver(Type rootType)
            {
                this.rootType = rootType;
            }

            protected override IList<JsonProperty> CreateProperties(Type type, MemberSerialization memberSerialization)
            {
                var list = base.CreateProperties(type, memberSerialization);
                list = list.Where(w => w.DeclaringType.FullName == type.FullName).ToList();
                list = list.Where(w => !(w.PropertyType.IsGenericType && w.PropertyType.GetGenericTypeDefinition() == typeof(IQueryable<>))).ToList();
                if (type != rootType) list = list.Where(w => w.PropertyName == "Id").ToList();
                return list;
            }
        }
    }
}
