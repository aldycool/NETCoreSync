using System;

namespace NETCoreSyncServer
{
    public class SyncEvent
    {
        public Func<HandshakeRequestPayload, string?>? OnHandshake { get; set; }
    }
}

