using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;
using NETCoreSync;

namespace ServerApp.Models
{
    [SyncSchema(MapToClassName = "CustomObject")]
    public class SyncCustomObject
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.Id)]
        public Guid ID { get; set; }

        public string SynchronizationID { get; set; }

        [SyncFriendlyId]
        public string FieldString { get; set; }

        public string FieldStringNullable { get; set; }

        public int FieldInt { get; set; }

        public int FieldIntNullable { get; set; }

        public bool FieldBoolean { get; set; }

        public bool FieldBooleanNullable { get; set; }

        public DateTime FieldDateTime { get; set; }

        public DateTime FieldDateTimeNullable { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.LastUpdated)]
        public long LastUpdated { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.Deleted)]
        public bool Deleted { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.DatabaseInstanceId)]
        public string DatabaseInstanceId { get; set; }
    }
}
