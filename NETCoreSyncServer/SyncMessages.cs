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
        public static JsonSerializerOptions serializeOptions => new JsonSerializerOptions() 
        { 
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            DictionaryKeyPolicy = JsonNamingPolicy.CamelCase,
        };
        public static JsonSerializerOptions deserializeOptions => new JsonSerializerOptions() 
        { 
            PropertyNameCaseInsensitive = true,
        };

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

    public class SyncIdInfo
    {
        public string SyncId { get; set; } = null!;
        public List<string> LinkedSyncIds { get; set; } = null!;
    }

    internal enum PayloadActions
    {
        handshakeRequest,
        handshakeResponse,
        echoRequest,
        echoResponse,
        delayRequest,
        delayResponse,
        exceptionRequest,
        exceptionResponse,
        logRequest,
        logResponse
    }
    
    internal class RequestMessage
    {
        public string ConnectionId { get; set; } = null!;
        public string Id { get; set; } = Guid.NewGuid().ToString();
        public string Action { get; set; } = null!;
        public Dictionary<string, object?> Payload { get; set; } = null!;

        public static RequestMessage FromPayload<T>(string connectionId, string id, T basePayload) where T : BasePayload
        {
            return new RequestMessage() 
            { 
                ConnectionId = connectionId,
                Id = id,
                Action = basePayload.Action, 
                Payload = basePayload.ToPayload<T>() 
            };
        }
    }

    internal class ResponseMessage
    {
        public string Id { get; set; } = null!;
        public string Action { get; set; } = null!;
        public string? ErrorMessage { get; set; }
        public Dictionary<string, object?> Payload { get; set; } = null!;

        public static ResponseMessage FromPayload<T>(string id,  string? errorMessage, T basePayload) where T : BasePayload
        {
            return new ResponseMessage() 
            { 
                Id = id,
                Action = basePayload.Action, 
                ErrorMessage = errorMessage, 
                Payload = basePayload.ToPayload<T>() 
            };
        }
    }

    public abstract class BasePayload
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

    public class HandshakeRequestPayload : BasePayload
    {
        override public string Action => PayloadActions.handshakeRequest.ToString();

        public int SchemaVersion { get; set; }
        public SyncIdInfo SyncIdInfo { get; set; } = null!;
    }

    public class HandshakeResponsePayload : BasePayload
    {
        override public string Action => PayloadActions.handshakeResponse.ToString();

        public List<string> OrderedClassNames { get; set; } = null!;
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

    internal class DelayRequestPayload : BasePayload
    {
        override public string Action => PayloadActions.delayRequest.ToString();

        public int DelayInMs { get; set; }
    }

    internal class DelayResponsePayload : BasePayload
    {
        override public string Action => PayloadActions.delayResponse.ToString();
    }

    internal class ExceptionRequestPayload : BasePayload
    {
        override public string Action => PayloadActions.exceptionRequest.ToString();

        public bool RaiseOnRemote { get; set; }
        public String ErrorMessage { get; set; } = null!;
    }

    internal class ExceptionResponsePayload : BasePayload
    {
        override public string Action => PayloadActions.exceptionResponse.ToString();
    }

    internal class LogRequestPayload : BasePayload
    {
        override public string Action => PayloadActions.logRequest.ToString();

        public Dictionary<string, object?> Log { get; set; } = null!;
    }

    internal class LogResponsePayload : BasePayload
    {
        override public string Action => PayloadActions.logResponse.ToString();
    }
}