using System;
using System.Collections.Generic;
using System.Reflection;

namespace NETCoreSyncServer
{
    internal class SyncService 
    {
        public List<Type> Types { get; set; } = new List<Type>();
        public Dictionary<Type, TableInfo> TableInfos { get; set; } = new Dictionary<Type, TableInfo>();
    }

    internal class TableInfo 
    {
        public SyncTableAttribute SyncTable { get; set; } = null!;
        public PropertyInfo PropertyInfoID { get; set; } = null!;
        public PropertyInfo PropertyInfoSyncID { get; set; } = null!;
        public PropertyInfo PropertyInfoKnowledgeID { get; set; } = null!;
        public PropertyInfo PropertyInfoTimeStamp { get; set; } = null!;
        public PropertyInfo PropertyInfoDeleted { get; set; } = null!;
    }
}
