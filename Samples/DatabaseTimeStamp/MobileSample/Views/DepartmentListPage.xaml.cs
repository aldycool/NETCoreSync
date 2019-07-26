using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Xamarin.Forms;
using Xamarin.Forms.Xaml;

using MobileSample.ViewModels;

namespace MobileSample.Views
{
	[XamlCompilation(XamlCompilationOptions.Compile)]
	public partial class DepartmentListPage : BaseContentPage<DepartmentListViewModel>
	{
		public DepartmentListPage() : base(null)
		{
			InitializeComponent();
            BindingContext = ViewModel;
		}
	}
}