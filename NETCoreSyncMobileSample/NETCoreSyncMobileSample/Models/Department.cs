using System;
using System.Collections.Generic;
using System.Text;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace NETCoreSyncMobileSample.Models
{
    public class Department
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public string Id { get; set; }
        public string Name { get; set; }

        [ForeignKey("DepartmentId")]
        public ICollection<Employee> Employees { get; set; }

        public long LastUpdated { get; set; }
        public long? Deleted { get; set; }
    }
}
