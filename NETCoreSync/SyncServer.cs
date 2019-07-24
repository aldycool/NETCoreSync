using System;
using System.Linq;
using System.IO;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace NETCoreSync
{
    public class SyncServer
    {
        private static object serverLock = new object();
        private static Dictionary<string, SyncServerLockObject> serverLockObjects = new Dictionary<string, SyncServerLockObject>();

        private readonly SyncEngine syncEngine;

        public SyncServer(SyncEngine syncEngine)
        {
            this.syncEngine = syncEngine;
        }

        private static JObject JsonDefaultResponse()
        {
            JObject jsonResponse = new JObject();
            jsonResponse["isOK"] = true;
            return jsonResponse;
        }

        public static JObject JsonErrorResponse(string message)
        {
            JObject jsonError = JsonDefaultResponse();
            jsonError["isOK"] = false;
            jsonError["errorMessage"] = message;
            return jsonError;
        }

        public JObject Process(byte[] syncDataBytes)
        {
            if (syncDataBytes == null) throw new NullReferenceException(nameof(syncDataBytes));

            JObject jsonResult = JsonDefaultResponse();
            List<string> log = new List<string>();
            List<SyncLog.SyncLogData> sentChanges = new List<SyncLog.SyncLogData>();
            List<SyncLog.SyncLogData> serverInserts = new List<SyncLog.SyncLogData>();
            List<SyncLog.SyncLogData> serverUpdates = new List<SyncLog.SyncLogData>();
            List<SyncLog.SyncLogData> serverDeletes = new List<SyncLog.SyncLogData>();
            List<SyncLog.SyncLogConflict> serverConflicts = new List<SyncLog.SyncLogConflict>();

            if (syncEngine.SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.UseGlobalTimeStamp)
            {
                (string synchronizationId, long lastSync, Dictionary<string, object> customInfo) = SyncEngine.ExtractInfo(syncDataBytes);
                SyncServerLockObject syncServerLockObject = null;
                bool lockTaken = false;

                try
                {
                    lock (serverLock)
                    {
                        if (!serverLockObjects.ContainsKey(synchronizationId))
                        {
                            SyncServerLockObject newLockObject = new SyncServerLockObject(synchronizationId);
                            serverLockObjects.Add(synchronizationId, newLockObject);
                        }
                        syncServerLockObject = serverLockObjects[synchronizationId];
                    }

                    Monitor.TryEnter(syncServerLockObject, 0, ref lockTaken);
                    if (!lockTaken) throw new Exception($"{nameof(SyncServerLockObject.SynchronizationId)}: {syncServerLockObject.SynchronizationId}, Synchronization process is already in progress");

                    (Dictionary<Type, List<object>> dictAppliedIds, List<SyncLog.SyncLogData> inserts, List<SyncLog.SyncLogData> updates, List<SyncLog.SyncLogData> deletes, List<SyncLog.SyncLogConflict> conflicts) = syncEngine.ProcessPayload(log, syncDataBytes);
                    serverInserts.AddRange(inserts);
                    serverUpdates.AddRange(updates);
                    serverDeletes.AddRange(deletes);
                    serverConflicts.AddRange(conflicts);
                    (byte[] compressed, long maxTimeStamp, List<SyncLog.SyncLogData> logChanges) = syncEngine.PreparePayload(log, synchronizationId, lastSync, customInfo, dictAppliedIds);
                    sentChanges.AddRange(logChanges);
                    string base64Compressed = Convert.ToBase64String(compressed);
                    jsonResult["payload"] = base64Compressed;
                    jsonResult["maxTimeStamp"] = maxTimeStamp;
                }
                catch (Exception e)
                {
                    jsonResult["isOK"] = false;
                    jsonResult["errorMessage"] = e.Message;
                    log.Add($"Error: {e.Message}");
                }
                finally
                {
                    if (lockTaken)
                    {
                        Monitor.Exit(syncServerLockObject);
                    }
                }
            }

            jsonResult[nameof(log)] = JArray.FromObject(log);
            jsonResult[nameof(sentChanges)] = JArray.FromObject(sentChanges);
            jsonResult[nameof(serverInserts)] = JArray.FromObject(serverInserts);
            jsonResult[nameof(serverUpdates)] = JArray.FromObject(serverUpdates);
            jsonResult[nameof(serverDeletes)] = JArray.FromObject(serverDeletes);
            jsonResult[nameof(serverConflicts)] = JArray.FromObject(serverConflicts);
            return jsonResult;
        }

        private class SyncServerLockObject
        {
            public readonly string SynchronizationId;

            public SyncServerLockObject(string synchronizationId)
            {
                SynchronizationId = synchronizationId;
            }
        }
    }
}
