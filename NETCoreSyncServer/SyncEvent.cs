using System;
using System.Collections.Generic;

namespace NETCoreSyncServer
{
    public class SyncEvent
    {
        public Func<HandshakeRequestPayload, Dictionary<string, object>, string?>? OnHandshake { get; set; }
    }
}

