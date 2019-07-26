using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using NETCoreSync;

namespace WebSample.Models
{
    [SyncSchema(MapToClassName = "Employee")]
    public class SyncEmployee
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.Id)]
        public Guid ID { get; set; }

        public string SynchronizationID { get; set; }

        [SyncFriendlyId]
        public string Name { get; set; }

        public DateTime Birthday { get; set; }

        public int NumberOfComputers { get; set; }

        public decimal SavingAmount { get; set; }

        public bool IsActive { get; set; }

        public Guid? DepartmentID { get; set; }
        public SyncDepartment Department { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.LastUpdated)]
        public long LastUpdated { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.Deleted)]
        public bool Deleted { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.DatabaseInstanceId)]
        public string DatabaseInstanceId { get; set; }
    }
}
