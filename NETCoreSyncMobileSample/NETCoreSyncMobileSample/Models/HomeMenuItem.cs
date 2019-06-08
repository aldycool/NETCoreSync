using System;
using System.Collections.Generic;
using System.Text;

namespace NETCoreSyncMobileSample.Models
{
    public enum MenuItemType
    {
        About,
        DepartmentList,
        EmployeeList,
        Browse
    }

    public class HomeMenuItem
    {
        public MenuItemType Id { get; set; }
        public string Title { get; set; }

        public static List<HomeMenuItem> GetMenus()
        {
            List<HomeMenuItem> menus = new List<HomeMenuItem>();
            menus.Add(new HomeMenuItem() { Id = MenuItemType.About, Title = "About" });
            menus.Add(new HomeMenuItem() { Id = MenuItemType.DepartmentList, Title = "Departments" });
            menus.Add(new HomeMenuItem() { Id = MenuItemType.EmployeeList, Title = "Employees" });
            return menus;
        }
    }
}
