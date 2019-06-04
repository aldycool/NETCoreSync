using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace NETCoreSyncWebSample.Models
{
    public class SyncDepartment
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public Guid ID { get; set; }
        public string SynchronizationID { get; set; }
        public string Name { get; set; }

        [ForeignKey("DepartmentID")]
        public ICollection<SyncEmployee> Employees { get; set; }

        public long LastUpdated { get; set; }
        public long? Deleted { get; set; }
    }
}
