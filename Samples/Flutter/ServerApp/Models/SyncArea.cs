using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;
using NETCoreSync;

namespace ServerApp.Models
{
    [Index(nameof(SynchronizationID), nameof(City), nameof(District), IsUnique = true)]
    [SyncSchema(MapToClassName = "AreaData")]
    public class SyncArea
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.Id)]
        public Guid ID { get; set; }

        public string SynchronizationID { get; set; }

        public string City { get; set; }

        [SyncFriendlyId]
        public string District { get; set; }

        public string CityDistrict { get { return $"{City} - {District}"; } }

        [ForeignKey("VaccinationAreaID")]
        public ICollection<SyncPerson> Persons { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.LastUpdated)]
        public long LastUpdated { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.Deleted)]
        public bool Deleted { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.DatabaseInstanceId)]
        public string DatabaseInstanceId { get; set; }
    }
}
