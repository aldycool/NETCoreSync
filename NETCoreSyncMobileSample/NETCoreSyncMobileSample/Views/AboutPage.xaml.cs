using System;

using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace NETCoreSyncMobileSample.Views
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class AboutPage
    {
        public AboutPage()
        {
            InitializeComponent();
            BindingContext = ViewModel;
        }
    }
}