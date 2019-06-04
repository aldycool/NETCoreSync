using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace NETCoreSyncWebSample
{
    public class TempHelper
    {
        public static long GetNowTicks()
        {
            return DateTime.Now.Ticks;
        }
    }
}
