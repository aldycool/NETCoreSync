using System;

namespace NETCoreSyncServer
{
    public class NETCoreSyncServerOptions
    {
        public String Path { get; set; } = "/netcoresyncserver";
        public double KeepAliveIntervalInSeconds { get; set; } = 120;
        public int ReceiveBufferInBytes { get; set; } = 1024 * 4;
    }
}