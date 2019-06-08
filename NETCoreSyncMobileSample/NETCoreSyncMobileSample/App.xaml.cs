using System;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;
using NETCoreSyncMobileSample.Views;
using Autofac;
using Xamarin.Forms.Internals;
using NETCoreSyncMobileSample.Models;
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

            builder.RegisterType<DatabaseContext>();

            builder.RegisterType<AboutViewModel>();
            builder.RegisterType<DepartmentListViewModel>();
            builder.RegisterType<EmployeeListViewModel>();

            Container = builder.Build();

            MainPage = new MainPage();
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
