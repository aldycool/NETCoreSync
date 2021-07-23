using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;
using NETCoreSync;

namespace ServerApp.Models
{
    [Index(nameof(SynchronizationID), nameof(Name), IsUnique = true)]
    [SyncSchema(MapToClassName = "Person")]
    public class SyncPerson
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.Id)]
        public Guid ID { get; set; }

        public string SynchronizationID { get; set; }

        [SyncFriendlyId]
        public string Name { get; set; }

        public DateTime Birthday { get; set; }

        public int Age { get; set; }

        public bool IsForeigner { get; set; }

        public bool IsVaccinated { get; set; }

        public string VaccineName { get; set; }

        public DateTime VaccinationDate { get; set; }

        public int VaccinePhase { get; set; }

        public Guid? VaccinationAreaID { get; set; }
        public SyncArea VaccinationArea { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.LastUpdated)]
        public long LastUpdated { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.Deleted)]
        public bool Deleted { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.DatabaseInstanceId)]
        public string DatabaseInstanceId { get; set; }
    }
}
