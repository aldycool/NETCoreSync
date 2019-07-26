using System;
using System.Linq;
using System.Collections.Generic;
using System.Text;
using System.Windows.Input;
using Xamarin.Forms;
using Microsoft.EntityFrameworkCore;
using MobileSample.Models;
using MobileSample.Services;
using NETCoreSync;
using Realms;

namespace MobileSample.ViewModels
{
    public class EmployeeItemViewModel : BaseViewModel
    {
        private readonly INavigation navigation;
        private readonly CustomSyncEngine customSyncEngine;
        private readonly Transaction transaction;

        private List<bool> isActiveItems;
        public List<bool> IsActiveItems
        {
            get { return isActiveItems; }
            set { SetProperty(ref isActiveItems, value); }
        }

        private List<ReferenceItem> departmentItems;
        public List<ReferenceItem> DepartmentItems
        {
            get { return departmentItems; }
            set { SetProperty(ref departmentItems, value); }
        }

        public EmployeeItemViewModel(INavigation navigation, DatabaseService databaseService, SyncConfiguration syncConfiguration)
        {
            this.navigation = navigation;
            customSyncEngine = new CustomSyncEngine(databaseService, syncConfiguration);
            transaction = customSyncEngine.Realm.BeginWrite();

            IsActiveItems = new List<bool>() { true, false };
            DepartmentItems = new List<ReferenceItem>();
            DepartmentItems.Add(new ReferenceItem() { Id = Guid.Empty.ToString(), Name = "[None]" });
            DepartmentItems.AddRange(databaseService.GetDepartments(customSyncEngine.Realm).Select(s => new ReferenceItem() { Id = s.Id, Name = s.Name }).ToList());
        }

        private bool isNewData;
        public bool IsNewData
        {
            get { return isNewData; }
            set { SetProperty(ref isNewData, value); }
        }

        private Employee data;
        public Employee Data
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
                Data = customSyncEngine.Realm.All<Employee>().Where(w => w.Id == id).FirstOrDefault();
            }
            if (Data == null)
            {
                Title = $"Add {nameof(Employee)}";
                IsNewData = true;
                Data = new Employee();
                Data.Birthday = DateTime.Now;
            }
            else
            {
                Title = $"Edit {nameof(Employee)}";
            }

            //Prepare the navigation property for binding
            if (Data.Department == null)
            {
                Data.DepartmentRef = DepartmentItems.Where(w => w.Id == Guid.Empty.ToString()).First();
            }
            else
            {
                ReferenceItem referenceItem = DepartmentItems.Where(w => w.Id == Data.Department.Id).FirstOrDefault();
                if (referenceItem == null)
                {
                    Data.DepartmentRef = DepartmentItems.Where(w => w.Id == Guid.Empty.ToString()).First();
                }
                else
                {
                    Data.DepartmentRef = referenceItem;
                }
            }
        }

        public ICommand SaveCommand => new Command(async () =>
        {
            if (Data.DepartmentRef == null && Data.DepartmentRef.Id == Guid.Empty.ToString())
            {
                Data.Department = null;
            }
            else
            {
                Data.Department = customSyncEngine.Realm.All<Department>().Where(w => w.Id == Data.DepartmentRef.Id).First();
            }

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
