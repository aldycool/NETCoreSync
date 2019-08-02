using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
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

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.LastUpdated)]
        public long LastUpdated { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.Deleted)]
        public bool Deleted { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.DatabaseInstanceId)]
        public string DatabaseInstanceId { get; set; }

        public override string ToString()
        {
            return $"{nameof(Id)}: {Id}, {nameof(Name)}: {Name}, {nameof(Birthday)}: {Birthday.ToString("dd-MMM-yyyy")}, {nameof(NumberOfComputers)}: {NumberOfComputers}, {nameof(SavingAmount)}: {SavingAmount}, {nameof(IsActive)}: {IsActive}, {nameof(Department)}: {Department?.Id}, {nameof(LastUpdated)}: {LastUpdated}, {nameof(Deleted)}: {Deleted}, {nameof(DatabaseInstanceId)}: {DatabaseInstanceId}";
        }
    }
}
