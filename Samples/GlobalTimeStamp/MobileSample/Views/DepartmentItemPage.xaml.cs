using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Xamarin.Forms;
using Xamarin.Forms.Xaml;
using MobileSample.Models;
using MobileSample.ViewModels;

namespace MobileSample.Views
{
	[XamlCompilation(XamlCompilationOptions.Compile)]
	public partial class DepartmentItemPage : BaseContentPage<DepartmentItemViewModel>
	{
		public DepartmentItemPage(object initData) : base(initData)
		{
			InitializeComponent();
            BindingContext = ViewModel;

            if (ViewModel.IsNewData)
            {
                for (int i = 0; i < ToolbarItems.Count; i++)
                {
                    if (ToolbarItems[i].Text == "Delete")
                    {
                        ToolbarItems.Remove(ToolbarItems[i]);
                        break;
                    }
                }
            }
        }

        public DepartmentItemPage() : this(null)
        {
        }
    }
}