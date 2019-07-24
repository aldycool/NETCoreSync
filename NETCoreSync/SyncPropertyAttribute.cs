using System;
using System.Collections.Generic;
using System.Text;

namespace NETCoreSync
{
    [AttributeUsage(AttributeTargets.Property, AllowMultiple = false)]
    public class SyncPropertyAttribute : Attribute
    {
        public enum PropertyIndicatorEnum
        {
            Id,
            LastUpdated,
            Deleted,
            DatabaseInstanceId
        }

        public PropertyIndicatorEnum PropertyIndicator { get; set; }
    }
}
