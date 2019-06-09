using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;
using Autofac;
using NETCoreSyncMobileSample.Models;
using NETCoreSyncMobileSample.ViewModels;

namespace NETCoreSyncMobileSample.Views
{
    public class BaseContentPage<T> : ContentPage where T : CustomBaseViewModel
    {
        public T ViewModel { get; set; }

        public BaseContentPage(object initData)
        {
            using (var scope = App.Container.BeginLifetimeScope(builder => builder.RegisterInstance(Navigation).As<INavigation>())) 
            {
                ViewModel = scope.Resolve<T>();
                ViewModel.WireEvents(this);
                ViewModel.Init(initData);
            }
        }

        public BaseContentPage() : this(null)
        {
        }
    }
}
