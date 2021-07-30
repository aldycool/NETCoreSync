using System;

namespace NETCoreSyncServer
{
    [AttributeUsage(AttributeTargets.Property, AllowMultiple = false)]
    public class SyncPropertyAttribute : Attribute
    {
        public enum PropertyIndicatorEnum
        {
            ID,
            SyncID,
            KnowledgeID,
            TimeStamp,
            Deleted
        }

        public PropertyIndicatorEnum PropertyIndicator { get; set; }

        public SyncPropertyAttribute(PropertyIndicatorEnum propertyIndicator)
        {
            PropertyIndicator = propertyIndicator;
        }
    }
}
