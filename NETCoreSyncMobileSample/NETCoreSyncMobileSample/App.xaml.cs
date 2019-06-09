using System;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;
using NETCoreSyncMobileSample.Views;
using Autofac;
using Xamarin.Forms.Internals;
using NETCoreSyncMobileSample.Services;
using NETCoreSyncMobileSample.ViewModels;

[assembly: XamlCompilation(XamlCompilationOptions.Compile)]
namespace NETCoreSyncMobileSample
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
            builder.RegisterType<SetupViewModel>();

            //NOTE: Navigation (INavigation) is registered per life time scope basis on  BaseContentPage.cs

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
