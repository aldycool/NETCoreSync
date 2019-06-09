using System;
using System.Threading.Tasks;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;
using NETCoreSyncMobileSample.ViewModels;

namespace NETCoreSyncMobileSample.Views
{
	[XamlCompilation(XamlCompilationOptions.Compile)]
	public partial class SyncPage : BaseContentPage<SyncViewModel>
    {
		public SyncPage()
		{
			InitializeComponent();
            BindingContext = ViewModel;
		}
	}
}