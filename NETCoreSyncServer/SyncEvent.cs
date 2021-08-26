using System;
using System.Collections.Generic;

namespace NETCoreSyncServer
{
    public class SyncEvent
    {
        public Func<HandshakeRequestPayload, string?>? OnHandshake { get; set; }
    }
}

