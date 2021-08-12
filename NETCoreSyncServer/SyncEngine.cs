using System;
using System.Linq;
using System.Text.Json;
using System.Collections.Generic;
using System.Reflection;

namespace NETCoreSyncServer
{
    public abstract class SyncEngine
    {
        abstract public long GetNextTimeStamp();
        abstract public IQueryable GetQueryable(Type type);
        abstract public void Insert(Type type, dynamic serverData);
        abstract public void Update(Type type, dynamic serverData);

        virtual public Dictionary<string, string> ClientPropertyNameToServerPropertyName(Type type)
        {
            return new Dictionary<string, string>();
        }

        public dynamic Populate(Type type, object clientData, dynamic? serverData)
        {
            if (serverData == null)
            {
                serverData = Activator.CreateInstance(type);
            }
            Type rowType = serverData!.GetType();
            List<PropertyInfo> serverProperties = rowType.GetProperties(BindingFlags.Public | BindingFlags.Instance).Where(w => w.CanWrite).ToList();
            for (int i = 0; i < serverProperties.Count; i++)
            {
                var property = serverProperties[i];
                property.SetValue(serverData, property.GetValue(clientData));
            }
            return serverData;
        }
    }
}

