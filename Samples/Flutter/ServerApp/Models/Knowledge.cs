using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ServerApp.Models
{
    public class Knowledge
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public Guid ID { get; set; }

        public string SynchronizationID { get; set; }

        public string DatabaseInstanceId { get; set; }

        public bool IsLocal { get; set; }

        public long MaxTimeStamp { get; set; }
    }
}
