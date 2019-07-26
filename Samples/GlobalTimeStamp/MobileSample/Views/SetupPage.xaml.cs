using System;
using System.Threading.Tasks;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;
using MobileSample.ViewModels;

namespace MobileSample.Views
{
	[XamlCompilation(XamlCompilationOptions.Compile)]
	public partial class SetupPage : BaseContentPage<SetupViewModel>
    {
		public SetupPage()
		{
			InitializeComponent();
            BindingContext = ViewModel;
        }
    }
}