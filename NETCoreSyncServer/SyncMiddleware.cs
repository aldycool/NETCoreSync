using System;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Text.Json;
using System.Collections.Generic;
using System.Collections.Concurrent;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using System.Net.WebSockets;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Hosting;

namespace NETCoreSyncServer
{
    internal class SyncMiddleware
    {
        private readonly RequestDelegate next;
        private readonly NETCoreSyncServerOptions netCoreSyncServerOptions;
        private ConcurrentDictionary<string, SyncIdInfo> activeConnectionsOld = new ConcurrentDictionary<string, SyncIdInfo>();
        private ConcurrentDictionary<string, Dictionary<string, Object>> activeConnections = new ConcurrentDictionary<string, Dictionary<string, object>>();
        ILogger<SyncMiddleware>? logger;

        public SyncMiddleware(RequestDelegate next, NETCoreSyncServerOptions options)
        {
            this.next = next;
            netCoreSyncServerOptions = options;
        }

        public async Task Invoke(HttpContext httpContext, IHostApplicationLifetime hostApplicationLifetime, SyncService syncService, SyncEngine syncEngine, ILogger<SyncMiddleware> logger)
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
                await RunAsync(hostApplicationLifetime, syncService, syncEngine, webSocket);
            }
        }

        private async Task RunAsync(IHostApplicationLifetime hostApplicationLifetime, SyncService syncService, SyncEngine syncEngine, WebSocket webSocket)
        {
            int bufferSize = netCoreSyncServerOptions.SendReceiveBufferSizeInBytes;
            string connectionId = Guid.NewGuid().ToString();
            AddConnection(connectionId);
            bool notifyConnected = false;
            try
            {
                while (webSocket.State.HasFlag(WebSocketState.Open))
                {
                    if (!notifyConnected)
                    {
                        var connectedResponse = ResponseMessage.FromPayload<ConnectedNotificationPayload>(connectionId, null, new ConnectedNotificationPayload());
                        await Send(webSocket, connectedResponse, bufferSize, hostApplicationLifetime.ApplicationStopping);
                        notifyConnected = true;
                    }

                    RequestMessage? request = null;
                    using var msRequest = new MemoryStream();
                    ArraySegment<byte> bufferReceive = new ArraySegment<byte>(new byte[bufferSize]);
                    WebSocketReceiveResult? result;
                    do
                    {
                        result = await webSocket.ReceiveAsync(bufferReceive, hostApplicationLifetime.ApplicationStopping);    
                        if (bufferReceive.Array != null)
                        {
                            msRequest.Write(bufferReceive.Array!, bufferReceive.Offset, result.Count);
                        }
                    } while (!result.CloseStatus.HasValue && !result.EndOfMessage);
                    if (result.CloseStatus.HasValue)
                    {
                        break;
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
                    if (request != null && request.Action == PayloadActions.commandRequest.ToString())
                    {
                        CommandRequestPayload requestPayload = BasePayload.FromPayload<CommandRequestPayload>(request.Payload);
                        if (requestPayload.Data.ContainsKey("commandName")) 
                        {
                            string commandName = Convert.ToString(requestPayload.Data["commandName"]) ?? "";
                            if (commandName == "delay")
                            {
                                if (int.TryParse(Convert.ToString(requestPayload.Data["delayInMs"]), out int delayInMs))
                                {
                                    LogRequestState(connectionId, request.Id, request.Action, $"commandName: {commandName}, delayInMs: {delayInMs}", false);
                                    await Task.Delay(delayInMs, hostApplicationLifetime.ApplicationStopping);
                                    LogRequestState(connectionId, request.Id, request.Action, $"commandName: {commandName}, delayInMs: {delayInMs}", true);
                                }
                            }
                            if (commandName == "exception")
                            {
                                string commandErrorMessage = Convert.ToString(requestPayload.Data["errorMessage"]) ?? "null";
                                LogRequestState(connectionId, request.Id, request.Action, $"commandName: {commandName}, errorMessage: {commandErrorMessage}", false);
                                throw new Exception(commandErrorMessage);
                            }
                        }
                        CommandResponsePayload responsePayload = new CommandResponsePayload();
                        responsePayload.Data = new Dictionary<string, object?>(requestPayload.Data);
                        response = ResponseMessage.FromPayload<CommandResponsePayload>(request.Id, null, responsePayload);
                    }
                    else if (request != null && request.Action == PayloadActions.handshakeRequest.ToString())
                    {
                        HandshakeRequestPayload requestPayload = BasePayload.FromPayload<HandshakeRequestPayload>(request.Payload);
                        HandshakeResponsePayload responsePayload = new HandshakeResponsePayload()
                        {
                            OrderedClassNames = new List<string>(syncService.Types.Select(s => syncService.TableInfos[s].SyncTable.ClientClassName).ToArray())
                        };
                        string? errorMessage = null;
                        if (syncService.SyncEvent != null && syncService.SyncEvent.OnHandshake != null) 
                        {
                            errorMessage = syncService.SyncEvent.OnHandshake.Invoke(requestPayload, requestPayload.CustomInfo!);
                        }
                        if (string.IsNullOrEmpty(errorMessage))
                        {
                            errorMessage = HandshakeSyncIdInfo(connectionId, requestPayload.SyncIdInfo);
                        }
                        response = ResponseMessage.FromPayload<HandshakeResponsePayload>(request.Id, errorMessage, responsePayload);                        
                    }
                    else if (request != null && request.Action == PayloadActions.syncTableRequest.ToString())
                    {
                        response = SyncTable(connectionId, syncService, syncEngine, request);
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
                        await Send(webSocket, response, bufferSize, hostApplicationLifetime.ApplicationStopping);
                    }
                }
            }
            catch(Exception ex)
            {
                if (ex is WebSocketException && ex.Message == "The remote party closed the WebSocket connection without completing the close handshake.")
                {
                    LogPrematureClosure(connectionId);
                }
                else if (ex is OperationCanceledException)
                {
                    LogCanceledOperation(connectionId);
                }
                else
                {
                    throw;
                }
            }
            finally
            {
                RemoveConnection(connectionId);
                try
                {
                    await webSocket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Socket Closed", hostApplicationLifetime.ApplicationStopping);
                }
                catch {}
            }
        }

        void AddConnection(String connectionId)
        {
            activeConnections.TryAdd(connectionId, new Dictionary<string, object>());
            LogConnectionState(connectionId, true);
        }

        void RemoveConnection(String connectionId)
        {
            activeConnections.Remove(connectionId, out _);
            LogConnectionState(connectionId, false);
        }

        async Task Send(WebSocket webSocket, ResponseMessage response, int bufferSize, CancellationToken cancellationToken) {
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
                await webSocket.SendAsync(bufferSend, WebSocketMessageType.Binary, endOfMessage, cancellationToken);
            }
        }

        string? HandshakeSyncIdInfo(string connectionId, SyncIdInfo syncIdInfo)
        {
            lock(this)
            {
                if (!activeConnections.ContainsKey(connectionId))
                {
                    return GetServerExceptionErrorMessageMissingConnectionId(connectionId);
                }
                List<String> allSyncIds = syncIdInfo.GetAllSyncIds();
                var overlappedSyncIdInfo = activeConnections.Where(w => w.Value.ContainsKey("SyncIdInfo") && ((SyncIdInfo)(w.Value["SyncIdInfo"])).GetAllSyncIds().Intersect(allSyncIds).Count() > 0).Select(s => (SyncIdInfo)s.Value["SyncIdInfo"]).ToList();
                if (overlappedSyncIdInfo != null && overlappedSyncIdInfo.Count > 0)
                {
                    Dictionary<string, object> serverException = new Dictionary<string, object>();
                    serverException["type"] = "NetCoreSyncServerSyncIdInfoOverlappedException";
                    serverException["overlappedSyncIds"] = overlappedSyncIdInfo;
                    return JsonSerializer.Serialize(serverException, SyncMessages.serializeOptions);
                }
                activeConnections[connectionId]["SyncIdInfo"] = syncIdInfo;
                return null;
            }
        }

        ResponseMessage SyncTable(string connectionId, SyncService syncService, SyncEngine syncEngine, RequestMessage request)
        {
            string? errorMessage = null;
            SyncTableResponsePayload responsePayload = new SyncTableResponsePayload();
            responsePayload.Annotations = new Dictionary<string, object?>();
            responsePayload.UnsyncedRows = new List<Dictionary<string, object?>>();
            responsePayload.Knowledges = new List<Dictionary<string, object?>>();
            responsePayload.DeletedIds = new List<string>();
            responsePayload.Logs = new List<Dictionary<string, object?>>();

            ResponseMessage createResponse(string? errorMessage, SyncTableResponsePayload responsePayload)
            {
                if (responsePayload == null) responsePayload = new SyncTableResponsePayload();
                return ResponseMessage.FromPayload<SyncTableResponsePayload>(request.Id, errorMessage, responsePayload);
            }

            Dictionary<string, object?> createLog(string action, Dictionary<string, object?> data)
            {
                return new Dictionary<string, object?>()
                {
                    ["action"] = action,
                    ["data"] = data
                };
            }

            string? updateKnowledges(List<Dictionary<string, object?>> knowledges, object syncId, object knowledgeId, long timeStamp, bool shouldAddIfNotExist)
            {
                var knowledgeDict = knowledges.Where(w => Convert.ToString(w["syncId"])!.ToLower() == Convert.ToString(syncId)!.ToLower() && Convert.ToString(w["id"])!.ToLower() == Convert.ToString(knowledgeId)!.ToLower()).FirstOrDefault();
                if (knowledgeDict == null)
                {
                    if (!shouldAddIfNotExist)
                    {
                        return GetServerExceptionErrorMessage($"Knowledge is expected to have syncId: {syncId} and knowledgeId: {knowledgeId}");
                    }
                    else
                    {
                        knowledgeDict = new Dictionary<string, object?>()
                        {
                            ["id"] = knowledgeId,
                            ["syncId"] = syncId,
                            ["local"] = false,
                            ["lastTimeStamp"] = 0,
                            ["meta"] = ""
                        };
                    }                        
                }
                long lastTimeStamp = Convert.ToInt64(knowledgeDict!["lastTimeStamp"]!);
                if (lastTimeStamp < timeStamp) knowledgeDict["lastTimeStamp"] = timeStamp;
                return null;
            }

            if (!activeConnections.ContainsKey(connectionId))
            {
                errorMessage = GetServerExceptionErrorMessageMissingConnectionId(connectionId);
                return createResponse(errorMessage, responsePayload);
            }
            if (!activeConnections[connectionId].ContainsKey("SyncIdInfo"))
            {
                errorMessage = GetServerExceptionErrorMessageHandshakeNotPerformed();
                return createResponse(errorMessage, responsePayload);
            }
            SyncIdInfo syncIdInfo = (SyncIdInfo)activeConnections[connectionId]["SyncIdInfo"];
            SyncTableRequestPayload requestPayload = BasePayload.FromPayload<SyncTableRequestPayload>(request.Payload);
            syncEngine.CustomInfo = requestPayload.CustomInfo;
            Type? classType = syncService.TableInfos.Where(w => w.Value.SyncTable.ClientClassName == requestPayload.ClassName).Select(s => s.Key).FirstOrDefault();
            if (classType == null)
            {
                errorMessage = GetServerExceptionErrorMessage($"Invalid ClientClassName: {requestPayload.ClassName}");
                return createResponse(errorMessage, responsePayload);
            }
            responsePayload.ClassName = requestPayload.ClassName;
            requestPayload.Knowledges.ForEach((item) => 
            {
                var knowledgeDict = new Dictionary<string, object?>(item);
                knowledgeDict["lastTimeStamp"] = ((JsonElement)knowledgeDict!["lastTimeStamp"]!).GetInt64();
                responsePayload.Knowledges.Add(knowledgeDict);
            });
            TableInfo tableInfo = syncService.TableInfos[classType];
            responsePayload.Annotations["idFieldName"] = JsonNamingPolicy.CamelCase.ConvertName(tableInfo.PropertyInfoID.Name);
            responsePayload.Annotations["syncIdFieldName"] = JsonNamingPolicy.CamelCase.ConvertName(tableInfo.PropertyInfoSyncID.Name);
            responsePayload.Annotations["knowledgeIdFieldName"] = JsonNamingPolicy.CamelCase.ConvertName(tableInfo.PropertyInfoKnowledgeID.Name);
            responsePayload.Annotations["syncedFieldName"] = Convert.ToString(requestPayload.Annotations["syncedFieldName"])!;
            responsePayload.Annotations["deletedFieldName"] = JsonNamingPolicy.CamelCase.ConvertName(tableInfo.PropertyInfoDeleted.Name);
            IQueryable queryable = syncEngine.GetQueryable(classType!);
            string syncedFieldName = Convert.ToString(requestPayload.Annotations["syncedFieldName"])!;
            string idFieldName = Convert.ToString(requestPayload.Annotations["idFieldName"])!;
            string syncIdFieldName = Convert.ToString(requestPayload.Annotations["syncIdFieldName"])!;
            string knowledgeIdFieldName = Convert.ToString(requestPayload.Annotations["knowledgeIdFieldName"])!;
            string deletedFieldName = Convert.ToString(requestPayload.Annotations["deletedFieldName"])!;
            List<object> processedIds = new List<object>();
            for (int i = 0; i < requestPayload.UnsyncedRows.Count; i++)
            {
                var clientData = requestPayload.UnsyncedRows[i];
                foreach (var kvp in syncEngine.ClientPropertyNameToServerPropertyName(classType))
                {
                    clientData[kvp.Value] = clientData[kvp.Key];
                    clientData.Remove(kvp.Key);
                }
                var id = clientData[idFieldName];
                clientData.Remove(idFieldName);
                clientData[tableInfo.PropertyInfoID.Name] = id;
                var syncId = clientData[syncIdFieldName];
                clientData.Remove(syncIdFieldName);
                clientData[tableInfo.PropertyInfoSyncID.Name] = syncId;
                var knowledgeId = clientData[knowledgeIdFieldName];
                clientData.Remove(knowledgeIdFieldName);
                clientData[tableInfo.PropertyInfoKnowledgeID.Name] = knowledgeId;
                var deleted = clientData[deletedFieldName];
                clientData.Remove(deletedFieldName);
                clientData[tableInfo.PropertyInfoDeleted.Name] = deleted;
                clientData[tableInfo.PropertyInfoTimeStamp.Name] = syncEngine.GetNextTimeStamp();
                clientData.Remove(syncedFieldName);
                object? parsedId = null;
                if (clientData[tableInfo.PropertyInfoID.Name] is JsonElement)
                {
                    parsedId = JsonSerializer.Deserialize(((JsonElement)clientData[tableInfo.PropertyInfoID.Name]!).GetRawText(), tableInfo.PropertyInfoID.PropertyType);
                }
                else
                {
                    parsedId = clientData[tableInfo.PropertyInfoID.Name];
                }
                processedIds.Add(parsedId!);
                bool parsedDeleted = false;
                if (clientData[tableInfo.PropertyInfoDeleted.Name] is JsonElement)
                {
                    parsedDeleted = Convert.ToBoolean(JsonSerializer.Deserialize(((JsonElement)clientData[tableInfo.PropertyInfoDeleted.Name]!).GetRawText(), tableInfo.PropertyInfoDeleted.PropertyType));
                }
                else
                {
                    parsedDeleted = Convert.ToBoolean(clientData[tableInfo.PropertyInfoDeleted.Name]);
                }
                var serverData = queryable.Where($"{tableInfo.PropertyInfoID.Name} = @0", parsedId).FirstOrDefault();
                bool shouldInsert = serverData == null;
                bool shouldIgnore = false;
                if (!shouldInsert)
                {
                    bool serverDeleted = tableInfo.PropertyInfoDeleted.GetValue(serverData);
                    if (serverDeleted)
                    {
                        shouldIgnore = true;
                        responsePayload.Logs.Add(createLog("ignored", clientData));
                        if (!parsedDeleted)
                        {
                            responsePayload.DeletedIds.Add(Convert.ToString(id)!);
                        }
                    }
                }
                serverData = syncEngine.PopulateServerData(classType, clientData, serverData);
                if (shouldInsert)
                {
                    if (!shouldIgnore)
                    {
                        syncEngine.Insert(classType, serverData);
                        responsePayload.Logs.Add(createLog("insert", clientData));
                    }
                }
                else
                {
                    if (!shouldIgnore)
                    {
                        syncEngine.Update(classType, serverData);
                        if (!parsedDeleted)
                        {
                            responsePayload.Logs.Add(createLog("update", clientData));
                        }
                        else
                        {
                            responsePayload.Logs.Add(createLog("delete", clientData));
                        }
                    }
                }
                var parsedSyncId = tableInfo.PropertyInfoSyncID.GetValue(serverData);
                var parsedKnowledgeId = tableInfo.PropertyInfoKnowledgeID.GetValue(serverData);
                long parsedTimeStamp = Convert.ToInt64(tableInfo.PropertyInfoTimeStamp.GetValue(serverData));
                errorMessage = updateKnowledges(responsePayload.Knowledges, parsedSyncId, parsedKnowledgeId, parsedTimeStamp, false);
                if (errorMessage != null)
                {
                    return createResponse(errorMessage, responsePayload);
                }
            }

            List<string> knownKnowledgeCriterias = new List<string>();
            List<string> knowledgeIdsForUnknownQuery = new List<string>();
            for (int i = 0; i < requestPayload.Knowledges.Count; i++)
            {
                var knowledgeDict = requestPayload.Knowledges[i];
                string knowledgeId = Convert.ToString(knowledgeDict["id"])!.ToLower();
                knownKnowledgeCriterias.Add($"{tableInfo.PropertyInfoKnowledgeID.Name}.ToLower() = \"{knowledgeId}\" AND {tableInfo.PropertyInfoTimeStamp.Name} > {Convert.ToString(knowledgeDict["lastTimeStamp"])}");
                knowledgeIdsForUnknownQuery.Add(knowledgeId);
            }
            string knowledgeCriteria = $"{string.Join(" OR ", knownKnowledgeCriterias.Select(s => $"({s})").ToList())} OR (!@1.Contains({tableInfo.PropertyInfoKnowledgeID.Name}.ToLower()))";
            string whereQuery = $"@0.Contains({tableInfo.PropertyInfoSyncID.Name}) AND ({knowledgeCriteria})";
            var serverDatas = queryable.Where(whereQuery, syncIdInfo.GetAllSyncIds(), knowledgeIdsForUnknownQuery).ToDynamicList();
            for (int i = 0; i < serverDatas.Count; i++)
            {
                var serverData = serverDatas[i];
                if (processedIds.Contains(tableInfo.PropertyInfoID.GetValue(serverData))) continue;
                Dictionary<string, object?> serializedServerData = syncEngine.SerializeServerData(serverData);
                serializedServerData[Convert.ToString(responsePayload.Annotations["syncedFieldName"])!] = true;
                serializedServerData.Remove(JsonNamingPolicy.CamelCase.ConvertName(tableInfo.PropertyInfoTimeStamp.Name));
                responsePayload.UnsyncedRows.Add(serializedServerData);
                var parsedSyncId = tableInfo.PropertyInfoSyncID.GetValue(serverData);
                var parsedKnowledgeId = tableInfo.PropertyInfoKnowledgeID.GetValue(serverData);
                long parsedTimeStamp = Convert.ToInt64(tableInfo.PropertyInfoTimeStamp.GetValue(serverData));
                errorMessage = updateKnowledges(responsePayload.Knowledges, parsedSyncId, parsedKnowledgeId, parsedTimeStamp, true);
                if (errorMessage != null)
                {
                    return createResponse(errorMessage, responsePayload);
                }
            }
            return createResponse(errorMessage, responsePayload);
        }

        string GetServerExceptionErrorMessageMissingConnectionId(string connectionId)
        {
            return GetServerExceptionErrorMessage($"Unable to find the current connectionId: ${connectionId} in the server's active connections. Most probably the client connection has been dropped.");
        }

        string GetServerExceptionErrorMessageHandshakeNotPerformed()
        {
            return GetServerExceptionErrorMessage("Handshake must be performed first before starting the synchronization");
        }

        string GetServerExceptionErrorMessage(String message)
        {
            Dictionary<string, object> serverException = new Dictionary<string, object>();
            serverException["type"] = "NetCoreSyncServerException";
            serverException["message"] = message;
            return JsonSerializer.Serialize(serverException, SyncMessages.serializeOptions);
        }

        void LogRequestState(String connectionId, String requestId, String action, String data, bool isFinished)
        {
            Log(new Dictionary<string, object?>() 
            { 
                ["Type"] = "RequestState",
                ["ConnectionId"] = connectionId,
                ["RequestId"] = requestId,
                ["Action"] = action,
                ["Data"] = data,
                ["State"] = isFinished ? "Finished" : "Started"
            });
        }

        void LogConnectionState(String connectionId, bool isOpened)
        {
            Log(new Dictionary<string, object?>() 
            { 
                ["Type"] = "ConnectionState",
                ["ConnectionId"] = connectionId,
                ["State"] = isOpened ? "Open" : "Closed",
            });
        }

        void LogPrematureClosure(String connectionId)
        {
            Log(new Dictionary<string, object?>() 
            { 
                ["Type"] = "PrematureClosure",
                ["ConnectionId"] = connectionId
            });
        }

        void LogCanceledOperation(String connectionId)
        {
            Log(new Dictionary<string, object?>()
            {
                ["Type"] = "CanceledOperation",
                ["ConnectionId"] = connectionId,
        });
        }

        void Log(Dictionary<string, object?> log)
        {
            string jsonLog = JsonSerializer.Serialize(log, SyncMessages.serializeOptions);
            if (logger != null)
            {
                
                logger.LogDebug(jsonLog);
            }
            else
            {
                System.Diagnostics.Debug.WriteLine(log);
            }
        }
   }
}