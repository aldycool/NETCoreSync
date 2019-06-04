using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace NETCoreSyncWebSample.Models
{
    public class SyncEmployee
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public Guid ID { get; set; }
        public string SynchronizationID { get; set; }
        public string Name { get; set; }
        public DateTime Birthday { get; set; }
        public int NumberOfComputers { get; set; }
        public decimal SavingAmount { get; set; }
        public bool IsActive { get; set; }

        public Guid? DepartmentID { get; set; }
        public SyncDepartment Department { get; set; }

        public long LastUpdated { get; set; }
        public long? Deleted { get; set; }
    }
}
