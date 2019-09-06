using System;
using System.Collections.Generic;
using System.Text;

namespace MobileSample.Models
{
    public class Knowledge : Realms.RealmObject
    {
        [Realms.PrimaryKey()]
        public string Id { get; set; } = Guid.NewGuid().ToString();

        public string DatabaseInstanceId { get; set; }
        public bool IsLocal { get; set; }
        public long MaxTimeStamp { get; set; }

        public override string ToString()
        {
            return $"{nameof(DatabaseInstanceId)}: {DatabaseInstanceId}, {nameof(IsLocal)}: {IsLocal}, {nameof(MaxTimeStamp)}: {MaxTimeStamp}";
        }
    }
}
