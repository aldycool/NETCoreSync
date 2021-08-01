using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace NETCoreSyncServer
{
    internal class SyncMessages
    {
        public static JsonSerializerOptions serializeOptions => new JsonSerializerOptions() { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };
        public static JsonSerializerOptions deserializeOptions => new JsonSerializerOptions() { PropertyNameCaseInsensitive = true };

        public async static Task<byte[]> Compress(ResponseMessage responseMessage)
        {
            string jsonResponse = JsonSerializer.Serialize(responseMessage, serializeOptions);
            byte[] jsonResponseBytes = Encoding.UTF8.GetBytes(jsonResponse);
            using var msCompress = new MemoryStream();
            using var gsCompress = new GZipStream(msCompress, CompressionMode.Compress);
            await gsCompress.WriteAsync(jsonResponseBytes, 0, jsonResponseBytes.Length);
            // It turns out that GZipStream needs to be closed first, or else it will miss part of the data: https://stackoverflow.com/questions/3722192/how-do-i-use-gzipstream-with-system-io-memorystream
            // The underlying MemoryStream is also disposed, so we have to take out the encoded array
            gsCompress.Close();
            byte[] result = msCompress.ToArray();
            return result;
        }

        public async static Task<RequestMessage> Decompress(MemoryStream msRequest, int bufferSize)
        {
            msRequest.Seek(0, SeekOrigin.Begin);
            byte[] bufferDecompress = new byte[bufferSize];
            using var gsDecompress = new GZipStream(msRequest, CompressionMode.Decompress);
            using var msDecompress = new MemoryStream();
            int bytesReadDecompress = 0;
            while ((bytesReadDecompress = await gsDecompress.ReadAsync(bufferDecompress, 0, bufferDecompress.Length)) > 0)
            {
                await msDecompress.WriteAsync(bufferDecompress, 0, bytesReadDecompress);
            }
            msDecompress.Seek(0, SeekOrigin.Begin);
            using var srDecompress = new StreamReader(msDecompress, Encoding.UTF8);
            string jsonRequest = await srDecompress.ReadToEndAsync();
            RequestMessage result = JsonSerializer.Deserialize<RequestMessage>(jsonRequest, deserializeOptions)!;
            return result;
        }   
    }

    internal class SyncIdInfo
    {
        public string SyncId { get; set; } = null!;
        public List<string> LinkedSyncIds { get; set; } = null!;
    }

    internal enum PayloadActions
    {
        echoRequest,
        echoResponse,
        handshakeRequest,
        handshakeResponse
    }

    internal class RequestMessage
    {
        public string Action { get; set; } = null!;
        public int SchemaVersion { get; set; }
        public SyncIdInfo SyncIdInfo { get; set; } = null!;
        public Dictionary<string, object?> Payload { get; set; } = null!;

        public static RequestMessage FromPayload<T>(int schemaVersion, SyncIdInfo syncIdInfo, T basePayload) where T : BasePayload
        {
            return new RequestMessage() 
            { 
                Action = basePayload.Action, 
                SchemaVersion = schemaVersion, 
                SyncIdInfo = syncIdInfo, 
                Payload = basePayload.ToPayload<T>() 
            };
        }
    }

    internal class ResponseMessage
    {
        public string Action { get; set; } = null!;
        public bool IsOk { get; set; }
        public string? ErrorMessage { get; set; }
        public Dictionary<string, object?> Payload { get; set; } = null!;

        public static ResponseMessage FromPayload<T>(bool isOk, string? errorMessage, T basePayload) where T : BasePayload
        {
            return new ResponseMessage() 
            { 
                Action = basePayload.Action, 
                IsOk = isOk, 
                ErrorMessage = errorMessage, 
                Payload = basePayload.ToPayload<T>() 
            };
        }
    }

    internal abstract class BasePayload
    {
        abstract public string Action { get; }
        public Dictionary<string, object?> ToPayload<T>() where T : BasePayload
        {
            string jsonPayload = JsonSerializer.Serialize<T>((T)this, SyncMessages.serializeOptions);
            Dictionary<string, object?> result = JsonSerializer.Deserialize<Dictionary<string, object?>>(jsonPayload, SyncMessages.deserializeOptions)!;
            result.Remove(nameof(BasePayload.Action).ToLower());
            return result;
        }
        public static T FromPayload<T>(Dictionary<string, object?> payload) where T : BasePayload
        {
            string jsonPayload = JsonSerializer.Serialize(payload, SyncMessages.serializeOptions);
            T instance = JsonSerializer.Deserialize<T>(jsonPayload, SyncMessages.deserializeOptions)!;
            return instance;
        }
    }

    internal class EchoRequestPayload : BasePayload
    {
        override public string Action => PayloadActions.echoRequest.ToString();

        public String Message { get; set; } = null!;
    }

    internal class EchoResponsePayload : BasePayload
    {
        override public string Action => PayloadActions.echoResponse.ToString();

        public String Message { get; set; } = null!;
    }

    internal class HandshakeRequestPayload : BasePayload
    {
        override public string Action => PayloadActions.handshakeRequest.ToString();
    }

    internal class HandshakeResponsePayload : BasePayload
    {
        override public string Action => PayloadActions.handshakeResponse.ToString();

        public List<string> OrderedClassNames { get; set; } = null!;
    }
}