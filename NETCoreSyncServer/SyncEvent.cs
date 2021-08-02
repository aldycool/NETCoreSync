using System;

namespace NETCoreSyncServer
{
    public class SyncEvent
    {
        public Func<HandshakeRequestPayload, HandshakeResponsePayload, string?>? OnHandshake { get; set; }
    }
}

