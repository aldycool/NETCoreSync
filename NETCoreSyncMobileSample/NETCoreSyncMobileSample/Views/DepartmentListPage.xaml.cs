﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace NETCoreSyncMobileSample.Views
{
	[XamlCompilation(XamlCompilationOptions.Compile)]
	public partial class DepartmentListPage
	{
		public DepartmentListPage()
		{
			InitializeComponent();
            BindingContext = ViewModel;
		}
	}
}