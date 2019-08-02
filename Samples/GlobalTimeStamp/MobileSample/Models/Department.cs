using System;
using System.Collections.Generic;
using System.Text;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using NETCoreSync;

namespace MobileSample.Models
{
    [SyncSchema(MapToClassName = "SyncDepartment")]
    public class Department
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.Id)]
        public string Id { get; set; }

        [SyncFriendlyId]
        public string Name { get; set; }

        [ForeignKey("DepartmentId")]
        public ICollection<Employee> Employees { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.LastUpdated)]
        public long LastUpdated { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.Deleted)]
        public long? Deleted { get; set; }

        public override string ToString()
        {
            return $"{nameof(Id)}: {Id}, {nameof(Name)}: {Name}, {nameof(LastUpdated)}: {LastUpdated}, {nameof(Deleted)}: {(Deleted == null ? "null" : Convert.ToString(Deleted.Value))}";
        }
    }
}
