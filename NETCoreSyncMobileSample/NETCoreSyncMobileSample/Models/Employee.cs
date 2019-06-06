using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace NETCoreSyncMobileSample.Models
{
    public class Employee
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public string Id { get; set; }
        public string Name { get; set; }
        public DateTime Birthday { get; set; }
        public int NumberOfComputers { get; set; }
        public decimal SavingAmount { get; set; }
        public bool IsActive { get; set; }

        public string DepartmentId { get; set; }
        public Department Department { get; set; }

        public long LastUpdated { get; set; }
        public long? Deleted { get; set; }
    }
}
