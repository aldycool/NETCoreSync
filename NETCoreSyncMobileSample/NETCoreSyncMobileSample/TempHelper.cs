using System;
using System.Collections.Generic;
using System.Text;

namespace NETCoreSyncMobileSample
{
    public class TempHelper
    {
        public static long GetMinValueTicks()
        {
            return DateTime.MinValue.Ticks;
        }

        public static long GetNowTicks()
        {
            return DateTime.Now.Ticks;
        }
    }
}
