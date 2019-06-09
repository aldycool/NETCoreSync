using System;
using System.Linq;
using System.Collections.Generic;
using System.Text;
using System.Windows.Input;
using Xamarin.Forms;
using NETCoreSyncMobileSample.Models;
using NETCoreSyncMobileSample.Services;

namespace NETCoreSyncMobileSample.ViewModels
{
    public class DepartmentItemViewModel : CustomBaseViewModel
    {
        private readonly INavigation navigation;
        private readonly DatabaseService databaseService;

        public DepartmentItemViewModel(INavigation navigation, DatabaseService databaseService)
        {
            this.navigation = navigation;
            this.databaseService = databaseService;
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
            Data = (Department)initData;
            if (Data == null)
            {
                Title = $"Add {nameof(Department)}";
                isNewData = true;
                Data = new Department();
                Data.Id = Guid.NewGuid().ToString();
            }
            else
            {
                Title = $"Edit {nameof(Department)}";
            }
        }

        public ICommand SaveCommand => new Command(async () =>
        {
            using (var databaseContext = databaseService.GetDatabaseContext())
            {
                if (IsNewData)
                {
                    databaseContext.Add(Data);
                }
                else
                {
                    databaseContext.Update(Data);
                }
                await databaseContext.SaveChangesAsync();   
            }

            await navigation.PopAsync();
        });

        public ICommand DeleteCommand => new Command(async () =>
        {
            if (IsNewData) return;

            using (var databaseContext = databaseService.GetDatabaseContext())
            {
                databaseContext.Remove(Data);
                await databaseContext.SaveChangesAsync();
            }

            await navigation.PopAsync();
        });
    }
}
