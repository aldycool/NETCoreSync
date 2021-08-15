using System;
using System.Linq;
using System.Collections.Generic;
using NETCoreSyncServer;

namespace WebSample.Models
{
    public class CustomSyncEngine : SyncEngine
    {
        private readonly DatabaseContext databaseContext;

        public CustomSyncEngine(DatabaseContext databaseContext)
        {
            this.databaseContext = databaseContext;
        }

        override public long GetNextTimeStamp()
        {
            return databaseContext.GetNextTimeStamp();
        }

        override public IQueryable GetQueryable(Type type)
        {
            if (type == typeof(SyncArea)) return databaseContext.Areas.AsQueryable();
            if (type == typeof(SyncPerson)) return databaseContext.Persons.AsQueryable();
            if (type == typeof(SyncCustomObject)) return databaseContext.CustomObjects.AsQueryable();
            throw new NotImplementedException();
        }

        override public Dictionary<string, string> ClientPropertyNameToServerPropertyName(Type type)
        {
            if (type == typeof(SyncPerson))
            {
                return new Dictionary<string, string>() { ["vaccinationAreaPk"] = "VaccinationAreaID" };
            }
            return base.ClientPropertyNameToServerPropertyName(type);
        }

        override public void Insert(Type type, dynamic serverData)
        {
            if (type == typeof(SyncArea)) databaseContext.Areas.Add(serverData);
            else if (type == typeof(SyncPerson)) databaseContext.Persons.Add(serverData);
            else if (type == typeof(SyncCustomObject)) databaseContext.CustomObjects.Add(serverData);
            else throw new NotImplementedException();
            databaseContext.SaveChanges();
        }

        override public void Update(Type type, dynamic serverData)
        {
            if (type == typeof(SyncArea)) databaseContext.Areas.Update(serverData);
            else if (type == typeof(SyncPerson)) databaseContext.Persons.Update(serverData);
            else if (type == typeof(SyncCustomObject)) databaseContext.CustomObjects.Update(serverData);
            else throw new NotImplementedException();
            databaseContext.SaveChanges();
        }
    }
}
