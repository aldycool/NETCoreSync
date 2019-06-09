using System;
using System.Collections.Generic;
using System.Text;

namespace NETCoreSync
{
    [AttributeUsage(AttributeTargets.Property, AllowMultiple = false)]
    public class SyncFriendlyIdAttribute : Attribute
    {
    }
}
