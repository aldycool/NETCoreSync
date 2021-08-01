using System;
using System.Collections.Generic;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using System.Net.WebSockets;
using Microsoft.AspNetCore.Http;

namespace NETCoreSyncServer
{
    internal class SyncMiddleware
    {
        private readonly RequestDelegate next;
        private readonly NETCoreSyncServerOptions netCoreSyncServerOptions;

        public SyncMiddleware(RequestDelegate next, NETCoreSyncServerOptions options)
        {
            this.next = next;
            netCoreSyncServerOptions = options;
        }

        public async Task Invoke(HttpContext httpContext, SyncService syncService)
        {
            if (httpContext.Request.Path != netCoreSyncServerOptions.Path)
            {
                await next(httpContext);
                return;
            }

            if (!httpContext.WebSockets.IsWebSocketRequest)
            {
                httpContext.Response.StatusCode = (int)StatusCodes.Status400BadRequest;
                return;
            }

            using (WebSocket webSocket = await httpContext.WebSockets.AcceptWebSocketAsync())
            {
                
                await RunAsync(webSocket);
            }
        }

        private async Task RunAsync(WebSocket webSocket)
        {
            int bufferSize = netCoreSyncServerOptions.SendReceiveBufferSizeInBytes;            
            while (true)
            {
                RequestMessage? requestMessage = null;

                using var msRequest = new MemoryStream();
                ArraySegment<byte> bufferReceive = new ArraySegment<byte>(new byte[bufferSize]);
                WebSocketReceiveResult? result;
                do
                {
                    result = await webSocket.ReceiveAsync(bufferReceive, CancellationToken.None);
                    if (bufferReceive.Array != null)
                    {
                        msRequest.Write(bufferReceive.Array!, bufferReceive.Offset, result.Count);
                    }
                } while (!result.CloseStatus.HasValue && !result.EndOfMessage);
                if (result.CloseStatus.HasValue)
                {
                    await webSocket.CloseAsync(result.CloseStatus.Value, result.CloseStatusDescription, CancellationToken.None);
                    return;
                }
                if (result.MessageType == WebSocketMessageType.Binary)
                {
                    requestMessage = await SyncMessages.Decompress(msRequest, bufferSize);
                }
                else
                {
                    throw new Exception($"Unexpected {nameof(result.MessageType)}: {result.MessageType.ToString()}");
                }

                byte[]? responseBytes = null;

                if (requestMessage != null && requestMessage.Action == PayloadActions.echoRequest.ToString())
                {
                    EchoRequestPayload echoRequestPayload = BasePayload.FromPayload<EchoRequestPayload>(requestMessage.Payload);
                    String echoMessage = echoRequestPayload.Message;
                    EchoResponsePayload echoResponsePayload = new EchoResponsePayload() { Message = echoMessage };
                    ResponseMessage echoResponse = ResponseMessage.FromPayload<EchoResponsePayload>(true, null, echoResponsePayload);
                    responseBytes = await SyncMessages.Compress(echoResponse);
                }

                if (requestMessage != null && requestMessage.Action == PayloadActions.handshakeRequest.ToString())
                {
                    HandshakeResponsePayload handshakeResponsePayload = new HandshakeResponsePayload()
                    {
                        OrderedClassNames = new List<string>() { "A", "B", "C" }
                    };
                    ResponseMessage handshakeResponse = ResponseMessage.FromPayload<HandshakeResponsePayload>(true, null, handshakeResponsePayload);
                    responseBytes = await SyncMessages.Compress(handshakeResponse);
                }

                if (responseBytes != null)
                {
                    using var msEncoded = new MemoryStream(responseBytes);
                    byte[] bufferResponse = new byte[bufferSize];
                    int totalBytesRead = 0;
                    int bytesRead = 0;
                    while ((bytesRead = await msEncoded.ReadAsync(bufferResponse, 0, bufferSize)) > 0)
                    {
                        ArraySegment<byte> bufferSend = new ArraySegment<byte>(bufferResponse, 0, bytesRead);
                        totalBytesRead += bytesRead;
                        bool endOfMessage = totalBytesRead == msEncoded.Length;
                        await webSocket.SendAsync(bufferSend, WebSocketMessageType.Binary, endOfMessage, CancellationToken.None);
                    }
                }
            }
        }
    }
}