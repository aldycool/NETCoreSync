﻿using System;
using System.Linq;
using System.Collections.Generic;
using System.Text;
using NETCoreSync;

namespace MobileSample.Models
{
    [SyncSchema(MapToClassName = "SyncDepartment")]
    public class Department : Realms.RealmObject
    {
        [Realms.PrimaryKey()]
        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.Id)]
        public string Id { get; set; } = Guid.NewGuid().ToString();

        [SyncFriendlyId]
        public string Name { get; set; }

        [Realms.Backlink(nameof(Employee.Department))]
        public IQueryable<Employee> Employees { get; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.LastUpdated)]
        public long LastUpdated { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.Deleted)]
        public bool Deleted { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.DatabaseInstanceId)]
        public string DatabaseInstanceId { get; set; }

        public override string ToString()
        {
            return $"{nameof(Id)}: {Id}, {nameof(Name)}: {Name}, {nameof(LastUpdated)}: {LastUpdated}, {nameof(Deleted)}: {Deleted}, {nameof(DatabaseInstanceId)}: {DatabaseInstanceId}";
        }
    }
}
