using System;
using System.Collections.Generic;
using System.Text;

namespace MobileSample.Models
{
    public class DatabaseInstanceInfo : Realms.RealmObject
    {
        [Realms.PrimaryKey()]
        public string DatabaseInstanceId { get; set; }
        public bool IsLocal { get; set; }
        public long LastSyncTimeStamp { get; set; }
    }
}
