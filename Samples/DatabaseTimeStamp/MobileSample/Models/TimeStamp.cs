using System;
using System.Collections.Generic;
using System.Text;

namespace MobileSample.Models
{
    public class TimeStamp : Realms.RealmObject
    {
        [Realms.PrimaryKey()]
        public string Id { get; set; } = Guid.NewGuid().ToString();
        public Realms.RealmInteger<long> Counter { get; set; }
    }
}
