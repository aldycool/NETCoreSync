using System;
using System.Collections.Generic;
using System.Text;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MobileSample.Models
{
    public class Configuration
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public string Id { get; set; }
        public string Key { get; set; }
        public string Value { get; set; }

        public override string ToString()
        {
            return $"{nameof(Id)}: {Id}, {nameof(Key)}: {Key}, {nameof(Value)}: {Value}";
        }
    }
}
