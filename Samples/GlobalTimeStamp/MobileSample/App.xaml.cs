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
