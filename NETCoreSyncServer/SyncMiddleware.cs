using System;
using System.Linq;
using System.Collections.Generic;
using System.Collections.Concurrent;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using System.Net.WebSockets;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;


namespace NETCoreSyncServer
{
    internal class SyncMiddleware
    {
        private readonly RequestDelegate next;
        private readonly NETCoreSyncServerOptions netCoreSyncServerOptions;
        private ConcurrentDictionary<string, SyncIdInfo> activeConnections = new ConcurrentDictionary<string, SyncIdInfo>();
        ILogger<SyncMiddleware>? logger;

        public SyncMiddleware(RequestDelegate next, NETCoreSyncServerOptions options)
        {
            this.next = next;
            netCoreSyncServerOptions = options;
        }

        public async Task Invoke(HttpContext httpContext, SyncService syncService, ILogger<SyncMiddleware> logger)
        {
            this.logger = logger;

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
                await RunAsync(webSocket, syncService);
            }
        }

        private async Task RunAsync(WebSocket webSocket, SyncService syncService)
        {
            Log("Server Opened");
            int bufferSize = netCoreSyncServerOptions.SendReceiveBufferSizeInBytes;
            string? connectionId = null;
            try
            {
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
                            if (wse.Message == "The remote party closed the WebSocket connection without completing the close handshake.")
                            {
                                Log("Server Forced Closed");
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
                        Log("Server Normal Closed");
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

                    ResponseMessage? response = null;

                    if (request != null && request.Action == PayloadActions.handshakeRequest.ToString())
                    {
                        connectionId = RegisterConnection(request);
                        response = HandleHandshake(request, syncService);
                    }
                    else if (request != null && request.Action == PayloadActions.echoRequest.ToString())
                    {
                        response = HandleEcho(request);
                    } 
                    else if (request != null && request.Action == PayloadActions.logRequest.ToString())
                    {
                        response = HandleLog(request);
                    } 
                    else if (request != null)
                    {
                        throw new Exception($"Unexpected {nameof(request.Action)}: {request.Action}");
                    }
                    else
                    {
                        throw new Exception($"Unexpected {nameof(request)}: null");
                    }

                    if (response != null)
                    {
                        byte[] responseBytes = await SyncMessages.Compress(response);
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
            catch (System.Exception)
            {
                throw;
            }
            finally
            {
                UnregisterConnection(connectionId);
            }           
        }

        private string RegisterConnection(RequestMessage request)
        {
            lock (this)
            {
                HandshakeRequestPayload requestPayload = BasePayload.FromPayload<HandshakeRequestPayload>(request.Payload);
                if (!activeConnections.TryAdd(request.ConnectionId, requestPayload.SyncIdInfo))
                {
                    throw new Exception("Connection is still active");    
                }
                Log($"Register ConnectionId: {request.ConnectionId}, activeConnections: {activeConnections.Count()}");
                return request.ConnectionId;
            }
        }
        private void UnregisterConnection(string? connectionId)
        {
            lock (this)
            {
                if (connectionId != null)
                {
                    activeConnections.Remove(connectionId, out _);
                }
                Log($"Unregister ConnectionId: {connectionId ?? "null"}, activeConnections: {activeConnections.Count()}");
            }
        }

        private ResponseMessage? HandleHandshake(RequestMessage request, SyncService syncService)
        {
            HandshakeRequestPayload requestPayload = BasePayload.FromPayload<HandshakeRequestPayload>(request.Payload);
            HandshakeResponsePayload responsePayload = new HandshakeResponsePayload()
            {
                OrderedClassNames = new List<string>(syncService.Types.Select(s => syncService.TableInfos[s].SyncTable.ClientClassName).ToArray())
            };
            string? errorMessage = null;
            if (syncService.SyncEvent != null && syncService.SyncEvent.OnHandshake != null) 
            {
                errorMessage = syncService.SyncEvent.OnHandshake.Invoke(requestPayload, responsePayload);
            }

            return ResponseMessage.FromPayload<HandshakeResponsePayload>(request.Id, errorMessage, responsePayload);
        }

        private ResponseMessage? HandleEcho(RequestMessage request)
        {
            EchoRequestPayload requestPayload = BasePayload.FromPayload<EchoRequestPayload>(request.Payload);
            String echoMessage = requestPayload.Message;
            EchoResponsePayload responsePayload = new EchoResponsePayload() { Message = echoMessage };
            return ResponseMessage.FromPayload<EchoResponsePayload>(request.Id, null, responsePayload);
        }

        private ResponseMessage? HandleLog(RequestMessage request)
        {
            LogRequestPayload requestPayload = BasePayload.FromPayload<LogRequestPayload>(request.Payload);
            Log(requestPayload.Message);
            LogResponsePayload responsePayload = new LogResponsePayload();
            return ResponseMessage.FromPayload<LogResponsePayload>(request.Id, null, responsePayload);
        }

        void Log(string message)
        {
            if (logger != null)
            {
                logger.LogDebug(message);
            }
            else
            {
                System.Diagnostics.Debug.WriteLine(message);
            }
        }
    }
}