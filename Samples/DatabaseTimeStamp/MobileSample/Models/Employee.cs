using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using NETCoreSync;

namespace MobileSample.Models
{
    [SyncSchema(MapToClassName = "SyncEmployee")]
    public class Employee : Realms.RealmObject
    {
        [Realms.PrimaryKey()]
        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.Id)]
        public string Id { get; set; } = Guid.NewGuid().ToString();

        [SyncFriendlyId]
        public string Name { get; set; }

        public DateTimeOffset Birthday { get; set; }

        public int NumberOfComputers { get; set; }

        public long SavingAmount { get; set; }

        public bool IsActive { get; set; }

        public Department Department { get; set; }

        [Realms.Ignored]
        public ReferenceItem DepartmentRef { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.LastUpdated)]
        public long LastUpdated { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.Deleted)]
        public bool Deleted { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.DatabaseInstanceId)]
        public string DatabaseInstanceId { get; set; }
    }
}
