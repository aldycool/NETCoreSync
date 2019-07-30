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
        private readonly DatabaseService databaseService;
        private readonly Dictionary<Type, CustomContractResolver> customContractResolvers;
        public Realm Realm { get { return databaseService.Realm; } }

        public CustomSyncEngine(DatabaseService databaseService, SyncConfiguration syncConfiguration) : base(syncConfiguration)
        {
            this.databaseService = databaseService;
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

        public override List<KnowledgeInfo> GetAllKnowledgeInfos(string synchronizationId, Dictionary<string, object> customInfo)
        {
            List<Knowledge> knowledges = Realm.All<Knowledge>().ToList();
            List<KnowledgeInfo> result = new List<KnowledgeInfo>();
            for (int i = 0; i < knowledges.Count; i++)
            {
                result.Add(new KnowledgeInfo()
                {
                    DatabaseInstanceId = knowledges[i].DatabaseInstanceId,
                    IsLocal = knowledges[i].IsLocal,
                    LastSyncTimeStamp = knowledges[i].LastSyncTimeStamp
                });
            }
            return result;
        }

        public override void CreateOrUpdateKnowledgeInfo(KnowledgeInfo knowledgeInfo, string synchronizationId, Dictionary<string, object> customInfo)
        {
            Realm.Write(() =>
            {
                Knowledge knowledge = Realm.All<Knowledge>().Where(w => w.DatabaseInstanceId == knowledgeInfo.DatabaseInstanceId).FirstOrDefault();
                if (knowledge == null)
                {
                    knowledge = new Knowledge();
                    knowledge.DatabaseInstanceId = knowledgeInfo.DatabaseInstanceId;
                    Realm.Add(knowledge);
                    knowledge = Realm.All<Knowledge>().Where(w => w.DatabaseInstanceId == knowledgeInfo.DatabaseInstanceId).First();
                }
                knowledge.IsLocal = knowledgeInfo.IsLocal;
                knowledge.LastSyncTimeStamp = knowledgeInfo.LastSyncTimeStamp;
            });
        }

        public override object StartTransaction(Type classType, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)
        {
            Transaction transaction = null;
            if (operationType == OperationType.ApplyChanges || operationType == OperationType.ProvisionKnowledge) transaction = Realm.BeginWrite();
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
