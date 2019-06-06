using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.CompilerServices;

using Xamarin.Forms;

using NETCoreSyncMobileSample.Models;
using NETCoreSyncMobileSample.Services;

namespace NETCoreSyncMobileSample.ViewModels
{
    public class CustomBaseViewModel : INotifyPropertyChanged
    {
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
