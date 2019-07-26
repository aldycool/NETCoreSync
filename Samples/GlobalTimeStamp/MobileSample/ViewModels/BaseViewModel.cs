using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;

using Xamarin.Forms;

using MobileSample.Models;
using MobileSample.Services;

namespace MobileSample.ViewModels
{
    public class BaseViewModel : INotifyPropertyChanged
    {
        private string title = string.Empty;
        public string Title
        {
            get { return title; }
            set { SetProperty(ref title, value); }
        }

        protected bool SetProperty<T>(ref T backingStore, T value, [CallerMemberName]string propertyName = "", Action onChanged = null)
        {
            if (EqualityComparer<T>.Default.Equals(backingStore, value)) return false;
            backingStore = value;
            onChanged?.Invoke();
            OnPropertyChanged(propertyName);
            return true;
        }

        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string propertyName = "")
        {
            var changed = PropertyChanged;
            if (changed == null) return;
            changed.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        public virtual void Init(object initData)
        {
        }

        public void WireEvents(Page page)
        {
            page.Appearing += ViewAppearing;
            page.Disappearing += ViewDisappearing;
        }

        protected virtual void ViewAppearing(object sender, EventArgs e)
        {
        }

        protected virtual void ViewDisappearing(object sender, EventArgs e)
        {
        }
    }
}
