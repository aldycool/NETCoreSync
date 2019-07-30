using System;
using System.Linq;
using System.IO;
using System.Collections.Generic;
using System.Text;
using MobileSample.Models;
using NETCoreSync;
using Xamarin.Forms;
using Realms;

namespace MobileSample.Services
{
    public class DatabaseService : IDisposable
    {
        private const string SYNCHRONIZATIONID_KEY = "SynchronizationId";
        private const string SERVERURL_KEY = "ServerUrl";

        public Realm Realm { get; private set; } = null;

        public DatabaseService()
        {
            CreateInstance();
        }

        private void CreateInstance()
        {
            RealmConfiguration realmConfiguration = GetRealmConfiguration();
            Realm = Realm.GetInstance(realmConfiguration);
        }

        private RealmConfiguration GetRealmConfiguration(string databaseFilePath = null)
        {
            if (string.IsNullOrEmpty(databaseFilePath)) databaseFilePath = GetDatabaseFilePath();
            RealmConfiguration realmConfiguration = new RealmConfiguration(databaseFilePath);
#if DEBUG
            realmConfiguration.ShouldDeleteIfMigrationNeeded = true;
#endif
            return realmConfiguration;
        }

        private string GetDatabaseFilePath()
        {
            string databaseFileName = $"{nameof(MobileSample)}.realm";
            string databaseFilePath = null;
            if (Device.RuntimePlatform == "Android")
            {
                databaseFilePath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Personal), databaseFileName);
            }
            else if (Device.RuntimePlatform == "iOS")
            {
                databaseFilePath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "..", "Library", databaseFileName);
            }
            if (string.IsNullOrEmpty(databaseFilePath)) throw new NotImplementedException();

            return databaseFilePath;
        }

        public void ResetInstance()
        {
            DisposeManagedObjects();

            string databaseFilePath = GetDatabaseFilePath();
            RealmConfiguration realmConfiguration = GetRealmConfiguration(databaseFilePath);
            if (File.Exists(databaseFilePath))
            {
                Realm.DeleteRealm(realmConfiguration);
            }

            CreateInstance();
        }

        public bool IsDatabaseReady()
        {
            Configuration configurationSynchronizationId = Realm.All<Configuration>().Where(w => w.Key == SYNCHRONIZATIONID_KEY).FirstOrDefault();
            return configurationSynchronizationId == null ? false : true;
        }

        public string GetSynchronizationId()
        {
            Configuration configurationSynchronizationId = Realm.All<Configuration>().Where(w => w.Key == SYNCHRONIZATIONID_KEY).FirstOrDefault();
            return configurationSynchronizationId == null ? null : configurationSynchronizationId.Value;
        }

        public void SetSynchronizationId(string synchronizationId)
        {
            Realm.Write(() => 
            {
                bool isNew = false;
                Configuration configurationSynchronizationId = Realm.All<Configuration>().Where(w => w.Key == SYNCHRONIZATIONID_KEY).FirstOrDefault();
                if (configurationSynchronizationId == null)
                {
                    isNew = true;
                    configurationSynchronizationId = new Configuration();
                    configurationSynchronizationId.Key = SYNCHRONIZATIONID_KEY;
                }
                configurationSynchronizationId.Value = synchronizationId;
                if (isNew) Realm.Add(configurationSynchronizationId);
            });
        }

        public string GetServerUrl()
        {
            Configuration configurationServerUrl = Realm.All<Configuration>().Where(w => w.Key == SERVERURL_KEY).FirstOrDefault();
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
                configurationServerUrl = Realm.All<Configuration>().Where(w => w.Key == SERVERURL_KEY).First();
            }
            return configurationServerUrl.Value;
        }

        public void SetServerUrl(string serverUrl)
        {
            Realm.Write(() =>
            {
                bool isNew = false;
                Configuration configurationServerUrl = Realm.All<Configuration>().Where(w => w.Key == SERVERURL_KEY).FirstOrDefault();
                if (configurationServerUrl == null)
                {
                    isNew = true;
                    configurationServerUrl = new Configuration();
                    configurationServerUrl.Key = SERVERURL_KEY;
                }
                configurationServerUrl.Value = serverUrl;
                if (isNew) Realm.Add(configurationServerUrl);
            });
        }

        public IQueryable<Department> GetDepartments()
        {
            return Realm.All<Department>().Where(w => !w.Deleted);
        }

        public IQueryable<Employee> GetEmployees()
        {
            return Realm.All<Employee>().Where(w => !w.Deleted);
        }

        #region IDisposable Pattern

        private bool disposed = false;

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (disposed) return;

            if (disposing)
            {
                DisposeManagedObjects();
            }
            DisposeUnmanagedObjects();
            disposed = true;
        }

        private void DisposeManagedObjects()
        {
            if (Realm != null)
            {
                Realm.Dispose();
                Realm = null;
            }
        }

        private void DisposeUnmanagedObjects()
        {
        }

        ~DatabaseService()
        {
            Dispose(false);
        }

        #endregion
    }
}
