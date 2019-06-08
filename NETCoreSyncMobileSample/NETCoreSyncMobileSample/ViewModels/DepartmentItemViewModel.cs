using System;
using System.Linq;
using System.Collections.Generic;
using System.Text;
using NETCoreSyncMobileSample.Models;

namespace NETCoreSyncMobileSample.ViewModels
{
    public class DepartmentItemViewModel : CustomBaseViewModel
    {
        public DepartmentItemViewModel()
        {
            Title = HomeMenuItem.GetMenus().Where(w => w.Id == MenuItemType.DepartmentList).First().Title;
        }

        public override void Init(object initData)
        {
            base.Init(initData);
        }
    }
}
