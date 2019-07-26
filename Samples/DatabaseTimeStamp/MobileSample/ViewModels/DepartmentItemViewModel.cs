using System;
using System.Linq;
using System.Collections.Generic;
using System.Text;
using System.Windows.Input;
using Xamarin.Forms;
using MobileSample.Models;
using MobileSample.Services;
using NETCoreSync;
using Realms;

namespace MobileSample.ViewModels
{
    public class DepartmentItemViewModel : BaseViewModel
    {
        private readonly INavigation navigation;
        private readonly CustomSyncEngine customSyncEngine;
        private readonly Transaction transaction;

        public DepartmentItemViewModel(INavigation navigation, DatabaseService databaseService, SyncConfiguration syncConfiguration)
        {
            this.navigation = navigation;
            customSyncEngine = new CustomSyncEngine(databaseService, syncConfiguration);
            transaction = customSyncEngine.Realm.BeginWrite();
        }

        private bool isNewData;
        public bool IsNewData
        {
            get { return isNewData; }
            set { SetProperty(ref isNewData, value);  }
        }

        private Department data;
        public Department Data
        {
            get { return data; }
            set { SetProperty(ref data, value); }
        }

        public override void Init(object initData)
        {
            base.Init(initData);
            string id = (string)initData;
            if (!string.IsNullOrEmpty(id))
            {
                Data = customSyncEngine.Realm.All<Department>().Where(w => w.Id == id).FirstOrDefault();
            }
            if (Data == null)
            {
                Title = $"Add {nameof(Department)}";
                IsNewData = true;
                Data = new Department();
            }
            else
            {
                Title = $"Edit {nameof(Department)}";
            }
        }

        public ICommand SaveCommand => new Command(async () =>
        {
            customSyncEngine.HookPreInsertOrUpdate(Data);

            if (IsNewData)
            {
                customSyncEngine.Realm.Add(Data);
            }

            transaction.Commit();

            await navigation.PopAsync();
        });

        public ICommand DeleteCommand => new Command(async () =>
        {
            if (IsNewData) return;

            Employee dependentEmployee = customSyncEngine.Realm.All<Employee>().Where(w => w.Department.Id == Data.Id).FirstOrDefault();
            if (dependentEmployee != null)
            {
                await Application.Current.MainPage.DisplayAlert("Data Already Used", $"The data is already used by Employee Name: {dependentEmployee.Name}", "OK");
                return;
            }

            customSyncEngine.HookPreDelete(Data);

            transaction.Commit();

            await navigation.PopAsync();
        });

        protected override void ViewDisappearing(object sender, EventArgs e)
        {
            transaction.Dispose();
        }
    }
}
