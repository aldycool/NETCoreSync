using System;
using System.Linq;
using System.Collections.Generic;
using System.Text;
using NETCoreSyncMobileSample.Models;

namespace NETCoreSyncMobileSample.Services
{
    public class DatabaseService
    {
        public const string SYNCHRONIZATIONID_KEY = "SynchronizationId";
        public const string LASTSYNC_KEY = "LastSync";

        public DatabaseContext GetDatabaseContext()
        {
            DatabaseContext databaseContext = new DatabaseContext();
            return databaseContext;
        }

        public bool IsDatabaseReady()
        {
            using (var databaseContext = GetDatabaseContext())
            {
                Configuration configurationSynchronizationId = databaseContext.Configurations.Where(w => w.Key == SYNCHRONIZATIONID_KEY).FirstOrDefault();
                if (configurationSynchronizationId == null) return false;
            }
            return true;
        }

        public IQueryable<Department> GetDepartments(DatabaseContext databaseContext)
        {
            return databaseContext.Departments.Where(w => w.Deleted == null);
        }

        public IQueryable<Employee> GetEmployees(DatabaseContext databaseContext)
        {
            return databaseContext.Employees.Where(w => w.Deleted == null);
        }

        public long GetLastSync()
        {
            using (var databaseContext = GetDatabaseContext())
            {
                Configuration configurationLastSync = databaseContext.Configurations.Where(w => w.Key == LASTSYNC_KEY).FirstOrDefault();
                if (configurationLastSync == null)
                {
                    SetLastSync(TempHelper.GetMinValueTicks());
                    configurationLastSync = databaseContext.Configurations.Where(w => w.Key == LASTSYNC_KEY).First();
                }
                return Convert.ToInt64(configurationLastSync.Value);
            }
        }

        public void SetLastSync(long lastSync)
        {
            using (var databaseContext = GetDatabaseContext())
            {
                bool isNew = false;
                Configuration configurationLastSync = databaseContext.Configurations.Where(w => w.Key == LASTSYNC_KEY).FirstOrDefault();
                if (configurationLastSync == null)
                {
                    isNew = true;
                    configurationLastSync = new Configuration()
                    {
                        Id = Guid.NewGuid().ToString(),
                        Key = LASTSYNC_KEY
                    };
                }
                configurationLastSync.Value = Convert.ToString(lastSync);
                if (isNew)
                {
                    databaseContext.Add(configurationLastSync);
                }
                else
                {
                    databaseContext.Update(configurationLastSync);
                }
                databaseContext.SaveChanges();
            }
        }
    }
}
