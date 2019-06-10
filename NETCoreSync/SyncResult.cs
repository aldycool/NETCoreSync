using System.Collections.Generic;

namespace NETCoreSync
{
    public class SyncResult
    {
        public string ErrorMessage { get; set; }
        public List<string> Log { get; } = new List<string>();
        public SyncLog ClientLog { get; } = new SyncLog();
        public SyncLog ServerLog { get; } = new SyncLog();
    }
}
