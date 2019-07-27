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
    public class DatabaseService
    {
        private const string SYNCHRONIZATIONID_KEY = "SynchronizationId";
        private const string SERVERURL_KEY = "ServerUrl";

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

        private RealmConfiguration GetRealmConfiguration(string databaseFilePath = null)
        {
            if (string.IsNullOrEmpty(databaseFilePath)) databaseFilePath = GetDatabaseFilePath();
            RealmConfiguration realmConfiguration = new RealmConfiguration(databaseFilePath);
#if DEBUG
            realmConfiguration.ShouldDeleteIfMigrationNeeded = true;
#endif
            return realmConfiguration;
        }

        public void ResetInstance()
        {
            string databaseFilePath = GetDatabaseFilePath();
            RealmConfiguration realmConfiguration = GetRealmConfiguration(databaseFilePath);

            if (File.Exists(databaseFilePath))
            {
                Realm.DeleteRealm(realmConfiguration);
            }
        }

        public Realm GetInstance()
        {
            RealmConfiguration realmConfiguration = GetRealmConfiguration();
            Realm realm = Realm.GetInstance(realmConfiguration);
            return realm;
        }

        public bool IsDatabaseReady()
        {
            Realm realm = GetInstance();
            Configuration configurationSynchronizationId = realm.All<Configuration>().Where(w => w.Key == SYNCHRONIZATIONID_KEY).FirstOrDefault();
            return configurationSynchronizationId == null ? false : true;
        }

        public void ResetAllData()
        {
            Realm realm = GetInstance();
            realm.Write(() => 
            {
                realm.RemoveAll<Employee>();
                realm.RemoveAll<Department>();
                realm.RemoveAll<DatabaseInstanceInfo>();
                realm.RemoveAll<TimeStamp>();
            });
        }

        public string GetSynchronizationId()
        {
            Realm realm = GetInstance();
            Configuration configurationSynchronizationId = realm.All<Configuration>().Where(w => w.Key == SYNCHRONIZATIONID_KEY).FirstOrDefault();
            return configurationSynchronizationId == null ? null : configurationSynchronizationId.Value;
        }

        public void SetSynchronizationId(string synchronizationId)
        {
            Realm realm = GetInstance();
            realm.Write(() => 
            {
                bool isNew = false;
                Configuration configurationSynchronizationId = realm.All<Configuration>().Where(w => w.Key == SYNCHRONIZATIONID_KEY).FirstOrDefault();
                if (configurationSynchronizationId == null)
                {
                    isNew = true;
                    configurationSynchronizationId = new Configuration();
                    configurationSynchronizationId.Key = SYNCHRONIZATIONID_KEY;
                }
                configurationSynchronizationId.Value = synchronizationId;
                if (isNew) realm.Add(configurationSynchronizationId);
            });
        }

        public string GetServerUrl()
        {
            Realm realm = GetInstance();
            Configuration configurationServerUrl = realm.All<Configuration>().Where(w => w.Key == SERVERURL_KEY).FirstOrDefault();
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
                configurationServerUrl = realm.All<Configuration>().Where(w => w.Key == SERVERURL_KEY).First();
            }
            return configurationServerUrl.Value;
        }

        public void SetServerUrl(string serverUrl)
        {
            Realm realm = GetInstance();
            realm.Write(() =>
            {
                bool isNew = false;
                Configuration configurationServerUrl = realm.All<Configuration>().Where(w => w.Key == SERVERURL_KEY).FirstOrDefault();
                if (configurationServerUrl == null)
                {
                    isNew = true;
                    configurationServerUrl = new Configuration();
                    configurationServerUrl.Key = SERVERURL_KEY;
                }
                configurationServerUrl.Value = serverUrl;
                if (isNew) realm.Add(configurationServerUrl);
            });
        }

        public IQueryable<Department> GetDepartments(Realm realm)
        {
            return realm.All<Department>().Where(w => !w.Deleted);
        }

        public IQueryable<Employee> GetEmployees(Realm realm)
        {
            return realm.All<Employee>().Where(w => !w.Deleted);
        }
    }
}
