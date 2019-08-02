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

        private RealmConfiguration GetRealmConfiguration()
        {
            string databaseFileName = Path.Combine(GetDatabaseFilePath(), GetDatabaseFileName());
            RealmConfiguration realmConfiguration = new RealmConfiguration(databaseFileName);
#if DEBUG
            realmConfiguration.ShouldDeleteIfMigrationNeeded = true;
#endif
            return realmConfiguration;
        }

        private string GetDatabaseFileName()
        {
            return $"{nameof(MobileSample)}.realm";
        }

        private string GetDatabaseFilePath()
        {
            string databaseFilePath = null;
            if (Device.RuntimePlatform == "Android")
            {
                databaseFilePath = Environment.GetFolderPath(Environment.SpecialFolder.Personal);
            }
            else if (Device.RuntimePlatform == "iOS")
            {
                databaseFilePath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "..", "Library");
            }
            if (string.IsNullOrEmpty(databaseFilePath)) throw new NotImplementedException(Device.RuntimePlatform);

            return databaseFilePath;
        }

        public void ResetInstance()
        {
            //NOTE: Realm (currently) has a serious bug, cannot delete the files.
            //The following listed the attempt to do so, but to no avail.

            //if (Realm != null)
            //{
            //    Realm.Dispose();
            //    Realm = null;
            //    
            //}

            //This approach is raising exception: Realms.Exceptions.RealmPermissionDeniedException: Unable to delete Realm because it is still open.
            //Realm.DeleteRealm(GetRealmConfiguration());

            //This manual approach also not working. The files are successfully deleted, but the instance seems to be retained in memory, so the objects are not cleared after doing these.
            //string databaseFilePath = GetDatabaseFilePath();
            //string databaseFileName = Path.Combine(databaseFilePath, GetDatabaseFileName());
            //try
            //{
            //    File.Delete(databaseFileName);
            //}
            //catch (Exception)
            //{
            //}
            //string databaseFileLock = Path.Combine(databaseFilePath, GetDatabaseFileName() + ".lock");
            //try
            //{
            //    File.Delete(databaseFileLock);
            //}
            //catch (Exception)
            //{
            //}
            //string databaseFileManagementDirectory = Path.Combine(databaseFilePath, GetDatabaseFileName() + ".management");
            //try
            //{
            //    Directory.Delete(databaseFileManagementDirectory, true);
            //}
            //catch (Exception)
            //{
            //}

            //CreateInstance();

            //NOTE: Until the bug above has resolved, perform the data clearing manually like below.
            Realm.Write(() => 
            {
                Realm.RemoveAll<Configuration>();
                Realm.RemoveAll<Employee>();
                Realm.RemoveAll<Department>();
                Realm.RemoveAll<Knowledge>();
                Realm.RemoveAll<TimeStamp>();
            });
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

        public void DumpLog()
        {
            Log($"{nameof(Configuration)}:");
            Realm.All<Configuration>().ToList().ForEach(data => Log(data.ToString()));
            Log("");
            Log($"{nameof(Department)}:");
            Realm.All<Department>().ToList().ForEach(data => Log(data.ToString()));
            Log("");
            Log($"{nameof(Employee)}:");
            Realm.All<Employee>().ToList().ForEach(data => Log(data.ToString()));
            Log("");
            Log($"{nameof(Knowledge)}:");
            Realm.All<Knowledge>().ToList().ForEach(data => Log(data.ToString()));
            Log("");
            Log($"{nameof(TimeStamp)}:");
            Realm.All<TimeStamp>().ToList().ForEach(data => Log(data.ToString()));
            Log("");
        }

        private void Log(string message)
        {
            System.Diagnostics.Debug.WriteLine(message);
        }
    }
}
