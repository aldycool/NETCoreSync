using System;
using System.Linq;
using System.Windows.Input;
using Xamarin.Forms;
using MobileSample.Models;

namespace MobileSample.ViewModels
{
    public class AboutViewModel : BaseViewModel
    {
        public AboutViewModel()
        {
            Title = MainMenuItem.GetMenus().Where(w => w.Id == MenuItemType.About).First().Title;
            OpenWebCommand = new Command(() => Device.OpenUri(new Uri("https://xamarin.com/platform")));
        }

        public ICommand OpenWebCommand { get; }
    }
}