using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using NETCoreSync;

namespace WebSample.Models
{
    public class Knowledge
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public Guid DatabaseInstanceId { get; set; }

        public string SynchronizationID { get; set; }

        public bool IsLocal { get; set; }

        public long MaxTimeStamp { get; set; }
    }
}
