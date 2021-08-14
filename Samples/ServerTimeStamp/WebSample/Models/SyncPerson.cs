using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;
using Microsoft.EntityFrameworkCore;
using NETCoreSyncServer;

namespace WebSample.Models
{
    [Index(nameof(SyncID), nameof(Name), IsUnique = true)]
    [SyncTable("Person", order: 2)]
    public class SyncPerson
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        [SyncProperty(SyncPropertyAttribute.PropertyIndicatorEnum.ID)]
        public Guid ID { get; set; }

        public string Name { get; set; } = null!;

        public DateTime Birthday { get; set; }

        public int Age { get; set; }

        public bool IsForeigner { get; set; }

        public bool? IsVaccinated { get; set; }

        public string? VaccineName { get; set; }

        public DateTime? VaccinationDate { get; set; }

        public int? VaccinePhase { get; set; }

        public Guid? VaccinationAreaID { get; set; }
        
        [JsonIgnore]
        public SyncArea? VaccinationArea { get; set; }

        [SyncProperty(SyncPropertyAttribute.PropertyIndicatorEnum.SyncID)]
        public string SyncID { get; set; } = null!;

        [SyncProperty(SyncPropertyAttribute.PropertyIndicatorEnum.KnowledgeID)]
        public string KnowledgeID { get; set; } = null!;

        [SyncProperty(SyncPropertyAttribute.PropertyIndicatorEnum.TimeStamp)]
        public long TimeStamp { get; set; }

        [SyncProperty(SyncPropertyAttribute.PropertyIndicatorEnum.Deleted)]
        public bool Deleted { get; set; }
    }
}
