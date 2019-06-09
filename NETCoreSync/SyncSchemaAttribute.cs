using System;
using System.Collections.Generic;
using System.Text;

namespace NETCoreSync
{
    [AttributeUsage(AttributeTargets.Class, AllowMultiple = false)]
    public class SyncSchemaAttribute : Attribute
    {
        public string MapToClassName { get; set; }
    }
}
