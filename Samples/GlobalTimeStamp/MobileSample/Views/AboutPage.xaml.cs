using System;

using Xamarin.Forms;
using Xamarin.Forms.Xaml;
using MobileSample.ViewModels;

namespace MobileSample.Views
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class AboutPage : BaseContentPage<AboutViewModel>
    {
        public AboutPage()
        {
            InitializeComponent();
            BindingContext = ViewModel;
        }
    }
}