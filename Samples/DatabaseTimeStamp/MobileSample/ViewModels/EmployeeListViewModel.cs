using System;
using System.Linq;
using System.Collections.Generic;
using System.Text;
using System.Collections.ObjectModel;
using System.Windows.Input;
using Xamarin.Forms;
using MobileSample.Models;
using MobileSample.Services;
using MobileSample.Views;

namespace MobileSample.ViewModels
{
    public class EmployeeListViewModel : BaseViewModel
    {
        private readonly INavigation navigation;
        private readonly DatabaseService databaseService;

        public EmployeeListViewModel(INavigation navigation, DatabaseService databaseService)
        {
            this.navigation = navigation;
            this.databaseService = databaseService;
        }

        private ObservableCollection<Employee> items;
        public ObservableCollection<Employee> Items
        {
            get { return items; }
            set { SetProperty(ref items, value); }
        }

        private Employee selectedItem;
        public Employee SelectedItem
        {
            get { return selectedItem; }
            set
            {
                SetProperty(ref selectedItem, value);
                EmployeeItemPage page = new EmployeeItemPage(selectedItem);
                navigation.PushAsync(page);
            }
        }

        protected override void ViewAppearing(object sender, EventArgs e)
        {
            base.ViewAppearing(sender, e);
            Title = MainMenuItem.GetMenus().Where(w => w.Id == MenuItemType.EmployeeList).First().Title;
            List<Employee> listData = null;
            using (var databaseContext = databaseService.GetDatabaseContext())
            {
                listData = databaseService.GetEmployees(databaseContext).ToList();
            }
            Items = new ObservableCollection<Employee>(listData);
        }

        public ICommand AddCommand => new Command(async () =>
        {
            EmployeeItemPage page = new EmployeeItemPage(null);
            await navigation.PushAsync(page);
        });
    }
}
