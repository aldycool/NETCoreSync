using System;
using System.Collections.Generic;
using System.Text;

namespace MobileSample.Models
{
    public enum MenuItemType
    {
        About,
        DepartmentList,
        EmployeeList,
        Sync,
        Setup
    }

    public class MainMenuItem
    {
        public MenuItemType Id { get; set; }
        public string Title { get; set; }

        public static List<MainMenuItem> GetMenus()
        {
            List<MainMenuItem> menus = new List<MainMenuItem>();
            menus.Add(new MainMenuItem() { Id = MenuItemType.About, Title = "About" });
            menus.Add(new MainMenuItem() { Id = MenuItemType.DepartmentList, Title = "Departments" });
            menus.Add(new MainMenuItem() { Id = MenuItemType.EmployeeList, Title = "Employees" });
            menus.Add(new MainMenuItem() { Id = MenuItemType.Sync, Title = "Sync" });
            menus.Add(new MainMenuItem() { Id = MenuItemType.Setup, Title = "Setup" });
            return menus;
        }
    }
}
