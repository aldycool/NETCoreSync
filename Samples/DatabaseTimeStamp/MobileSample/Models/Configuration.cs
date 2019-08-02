using System;
using System.Collections.Generic;
using System.Text;

namespace MobileSample.Models
{
    public class Configuration : Realms.RealmObject
    {
        [Realms.PrimaryKey()]
        public string Id { get; set; } = Guid.NewGuid().ToString();
        public string Key { get; set; }
        public string Value { get; set; }

        public override string ToString()
        {
            return $"{nameof(Id)}: {Id}, {nameof(Key)}: {Key}, {nameof(Value)}: {Value}";
        }
    }
}
