using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using NETCoreSyncServer;

namespace WebSample.Models
{
    [SyncTable(clientClassName: "CustomObject", order: 3)]
    public class SyncCustomObject
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        [SyncProperty(SyncPropertyAttribute.PropertyIndicatorEnum.ID)]
        public Guid ID { get; set; }

        public string FieldString { get; set; } = null!;

        public string? FieldStringNullable { get; set; }

        public int FieldInt { get; set; }

        public int? FieldIntNullable { get; set; }

        public bool FieldBoolean { get; set; }

        public bool? FieldBooleanNullable { get; set; }

        public DateTime FieldDateTime { get; set; }

        public DateTime? FieldDateTimeNullable { get; set; }

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
