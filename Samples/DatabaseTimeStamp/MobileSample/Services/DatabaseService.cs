using System;
using System.Linq;
using System.Collections.Generic;
using System.Text;
using MobileSample.Models;
using NETCoreSync;
using Xamarin.Forms;

namespace MobileSample.Services
{
    public class DatabaseService
    {
        private const string SYNCHRONIZATIONID_KEY = "SynchronizationId";
        private const string LASTSYNC_KEY = "LastSync";
        private const string SERVERURL_KEY = "ServerUrl";

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

        public string GetSynchronizationId()
        {
            using (var databaseContext = GetDatabaseContext())
            {
                Configuration configurationSynchronizationId = databaseContext.Configurations.Where(w => w.Key == SYNCHRONIZATIONID_KEY).FirstOrDefault();
                if (configurationSynchronizationId == null) return null;
                return configurationSynchronizationId.Value;
            }
        }

        public void SetSynchronizationId(string synchronizationId)
        {
            using (var databaseContext = GetDatabaseContext())
            {
                bool isNew = false;
                Configuration configurationSynchronizationId = databaseContext.Configurations.Where(w => w.Key == SYNCHRONIZATIONID_KEY).FirstOrDefault();
                if (configurationSynchronizationId == null)
                {
                    isNew = true;
                    configurationSynchronizationId = new Configuration()
                    {
                        Id = Guid.NewGuid().ToString(),
                        Key = SYNCHRONIZATIONID_KEY
                    };
                }
                configurationSynchronizationId.Value = synchronizationId;
                if (isNew)
                {
                    databaseContext.Add(configurationSynchronizationId);
                }
                else
                {
                    databaseContext.Update(configurationSynchronizationId);
                }
                databaseContext.SaveChanges();
            }
        }

        public long GetLastSync()
        {
            using (var databaseContext = GetDatabaseContext())
            {
                Configuration configurationLastSync = databaseContext.Configurations.Where(w => w.Key == LASTSYNC_KEY).FirstOrDefault();
                if (configurationLastSync == null)
                {
                    SetLastSync(0);
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

        public string GetServerUrl()
        {
            using (var databaseContext = GetDatabaseContext())
            {
                Configuration configurationServerUrl = databaseContext.Configurations.Where(w => w.Key == SERVERURL_KEY).FirstOrDefault();
                if (configurationServerUrl == null)
                {
                    string defaultServerUrl = null;
                    if (Device.RuntimePlatform == "Android")
                    {
                        defaultServerUrl = "http://10.0.2.2:5000/Sync";
                    }
                    else if (Device.RuntimePlatform == "iOS")
                    {
                        defaultServerUrl = "http://192.168.56.1:5000/Sync";
                    }
                    else
                    {
                        throw new NotImplementedException();
                    }

                    SetServerUrl(defaultServerUrl);
                    configurationServerUrl = databaseContext.Configurations.Where(w => w.Key == SERVERURL_KEY).FirstOrDefault();
                }
                return configurationServerUrl.Value;
            }
        }

        public void SetServerUrl(string serverUrl)
        {
            using (var databaseContext = GetDatabaseContext())
            {
                bool isNew = false;
                Configuration configurationServerUrl = databaseContext.Configurations.Where(w => w.Key == SERVERURL_KEY).FirstOrDefault();
                if (configurationServerUrl == null)
                {
                    isNew = true;
                    configurationServerUrl = new Configuration()
                    {
                        Id = Guid.NewGuid().ToString(),
                        Key = SERVERURL_KEY
                    };
                }
                configurationServerUrl.Value = serverUrl;
                if (isNew)
                {
                    databaseContext.Add(configurationServerUrl);
                }
                else
                {
                    databaseContext.Update(configurationServerUrl);
                }
                databaseContext.SaveChanges();
            }
        }
    }
}
