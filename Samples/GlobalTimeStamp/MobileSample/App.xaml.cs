using System;
using System.Collections.Generic;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;
using MobileSample.Views;
using Autofac;
using Xamarin.Forms.Internals;
using MobileSample.Services;
using MobileSample.Models;
using MobileSample.ViewModels;
using NETCoreSync;

[assembly: XamlCompilation(XamlCompilationOptions.Compile)]
namespace MobileSample
{
    public partial class App : Application
    {
        public static IContainer Container;
        private static readonly ContainerBuilder builder = new ContainerBuilder();

        public App()
        {
            InitializeComponent();

            DependencyResolver.ResolveUsing(type => Container.IsRegistered(type) ? Container.Resolve(type) : null);

            builder.RegisterType<DatabaseService>();

            builder.RegisterType<AboutViewModel>();
            builder.RegisterType<DepartmentListViewModel>();
            builder.RegisterType<DepartmentItemViewModel>();
            builder.RegisterType<EmployeeListViewModel>();
            builder.RegisterType<EmployeeItemViewModel>();
            builder.RegisterType<SyncViewModel>();
            builder.RegisterType<SetupViewModel>();
            //NOTE: Navigation (INavigation) is registered per life time scope basis on  BaseContentPage.cs

            List<Type> syncTypes = new List<Type>() { typeof(Department), typeof(Employee) };
            SyncConfiguration syncConfiguration = new SyncConfiguration(syncTypes.ToArray(), SyncConfiguration.TimeStampStrategyEnum.GlobalTimeStamp);
            syncConfiguration.SetOptions(options => 
            {
                // On this example, we set the GlobalTimeStampAllowHooksToUpdateWithOlderSystemDateTime to true,
                // This allows the mobile apps to continue executing HookPreInsertOrUpdateGlobalTimeStamp and HookPreDeleteGlobalTimeStamp without raising errors if the device's Date Time is older than the last sync value.
                // FYI, the mobile system's Date and Time is actually CAN be older if the mobile users are deliberately changing its system's Date Time settings to an older Date Time.
                // So if this option is set to true, the hooks will not raise errors, BUT, conflicts can happened during synchronization. You should handle the conflicts accordingly in the DeserializeJsonToExistingData method in the server's SyncEngine subclass.
                // By default, this option is set to false.
                options.GlobalTimeStampAllowHooksToUpdateWithOlderSystemDateTime = true;
            });
            builder.RegisterInstance(syncConfiguration);

            Container = builder.Build();

            DatabaseService databaseService = Container.Resolve<DatabaseService>();

            if (!databaseService.IsDatabaseReady())
            {
                MainPage = new NavigationPage(new SetupPage());
            }
            else
            {
                MainPage = new MainPage();
            }
        }

        protected override void OnStart()
        {
            // Handle when your app starts
        }

        protected override void OnSleep()
        {
            // Handle when your app sleeps
        }

        protected override void OnResume()
        {
            // Handle when your app resumes
        }
    }
}
