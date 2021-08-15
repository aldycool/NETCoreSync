using System;
using System.Linq;
using System.Text.Json;
using System.Collections.Generic;
using System.Reflection;

namespace NETCoreSyncServer
{
    public abstract class SyncEngine
    {
        public Dictionary<string, object?> CustomInfo { get; set; } = null!;

        abstract public long GetNextTimeStamp();
        abstract public IQueryable GetQueryable(Type type);
        abstract public void Insert(Type type, dynamic serverData);
        abstract public void Update(Type type, dynamic serverData);

        virtual public Dictionary<string, string> ClientPropertyNameToServerPropertyName(Type type)
        {
            return new Dictionary<string, string>();
        }

        virtual public dynamic PopulateServerData(Type type, Dictionary<string, object?> clientData, dynamic? serverData)
        {
            if (serverData == null)
            {
                serverData = Activator.CreateInstance(type)!;
            }
            List<PropertyInfo> properties = type.GetProperties(BindingFlags.Public | BindingFlags.Instance).Where(w => w.CanWrite).ToList();
            var keys = clientData.Keys.ToList();
            foreach (var key in keys)
            {
                var property = properties.Where(w => w.Name.ToLower() == key.ToLower()).FirstOrDefault();
                if (property == null) continue;
                var value = clientData[key];
                if (value is JsonElement)
                {
                    // The current Moor's default implementation of toJson() is converting DateTime to epoch milliseconds (in the _DefaultValueSerializer class).
                    // We now attempt to detect such condition for DateTime type.
                    if (property.PropertyType == typeof(DateTime) && ((JsonElement)value).ValueKind == JsonValueKind.Number)
                    {
                        value = DateTimeOffset.FromUnixTimeMilliseconds(((JsonElement)value).GetInt64()).LocalDateTime;
                    }
                    else
                    {
                        value = JsonSerializer.Deserialize(((JsonElement)value).GetRawText(), property.PropertyType);    
                    }
                }
                property.SetValue(serverData, value);
            }
            return serverData;
        }

        virtual public void ModifySerializedServerData(Dictionary<string, object?> serializedServerData)
        {
        }
    }
}

