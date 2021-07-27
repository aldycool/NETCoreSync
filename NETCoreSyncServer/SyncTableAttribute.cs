using System;
using System.Collections.Generic;
using System.Text;

namespace NETCoreSyncServer
{
    [AttributeUsage(AttributeTargets.Class, AllowMultiple = false)]
    public class SyncTableAttribute : Attribute
    {
        public string ClientClassName { get; set; }
        public int Order { get; set; }

        public SyncTableAttribute(string clientClassName = "", int order = 0)
        {
            ClientClassName = clientClassName;
            Order = order;
        }
    }
}
