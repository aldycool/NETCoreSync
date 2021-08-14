using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;
using Microsoft.EntityFrameworkCore;
using NETCoreSyncServer;

namespace WebSample.Models
{
    [Index(nameof(SyncID), nameof(City), nameof(District), IsUnique = true)]
    [SyncTable(clientClassName: "AreaData", order: 1)]
    public class SyncArea
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        [SyncProperty(SyncPropertyAttribute.PropertyIndicatorEnum.ID)]
        public Guid ID { get; set; }

        public string City { get; set; } = null!;

        public string District { get; set; } = null!;

        [JsonIgnore]
        public string CityDistrict { get { return $"{City} - {District}"; } }

        [JsonIgnore]
        [ForeignKey("VaccinationAreaID")]
        public ICollection<SyncPerson> Persons { get; set; } = null!;

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
