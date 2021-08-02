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
                RequestMessage? request = null;

                using var msRequest = new MemoryStream();
                ArraySegment<byte> bufferReceive = new ArraySegment<byte>(new byte[bufferSize]);
                WebSocketReceiveResult? result;
                do
                {
                    try
                    {
                        result = await webSocket.ReceiveAsync(bufferReceive, CancellationToken.None);    
                    }
                    catch (WebSocketException wse)
                    {
                        // The remote party closed the WebSocket connection without completing the close handshake.
                        if (wse.ErrorCode == 333514224)
                        {
                            return;
                        }
                        throw;
                    }
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
                    request = await SyncMessages.Decompress(msRequest, bufferSize);
                }
                else
                {
                    throw new Exception($"Unexpected {nameof(result.MessageType)}: {result.MessageType.ToString()}");
                }

                byte[]? responseBytes = null;

                if (request != null && request.Action == PayloadActions.echoRequest.ToString())
                {
                    EchoRequestPayload requestPayload = BasePayload.FromPayload<EchoRequestPayload>(request.Payload);
                    String echoMessage = requestPayload.Message;
                    EchoResponsePayload responsePayload = new EchoResponsePayload() { Message = echoMessage };
                    ResponseMessage response = ResponseMessage.FromPayload<EchoResponsePayload>(true, null, responsePayload);
                    responseBytes = await SyncMessages.Compress(response);
                }

                if (request != null && request.Action == PayloadActions.handshakeRequest.ToString())
                {
                    HandshakeResponsePayload responsePayload = new HandshakeResponsePayload()
                    {
                        OrderedClassNames = new List<string>() { "A", "B", "C" }
                    };
                    ResponseMessage response = ResponseMessage.FromPayload<HandshakeResponsePayload>(true, null, responsePayload);
                    responseBytes = await SyncMessages.Compress(response);
                }

                if (responseBytes != null)
                {
                    using var msResponse = new MemoryStream(responseBytes);
                    byte[] bufferResponse = new byte[bufferSize];
                    int totalBytesRead = 0;
                    int bytesRead = 0;
                    while ((bytesRead = await msResponse.ReadAsync(bufferResponse, 0, bufferSize)) > 0)
                    {
                        ArraySegment<byte> bufferSend = new ArraySegment<byte>(bufferResponse, 0, bytesRead);
                        totalBytesRead += bytesRead;
                        bool endOfMessage = totalBytesRead == msResponse.Length;
                        await webSocket.SendAsync(bufferSend, WebSocketMessageType.Binary, endOfMessage, CancellationToken.None);
                    }
                }
            }
        }
    }
}