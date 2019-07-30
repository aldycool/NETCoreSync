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

            SyncServerLockObject syncServerLockObject = null;
            bool lockTaken = false;

            SyncEngine.PayloadAction payloadAction = SyncEngine.PayloadAction.Synchronize;
            SyncEngine.ApplyChangesResult applyChangesResult = null;
            SyncEngine.GetChangesResult getChangesResult = null;
            List<string> log = new List<string>();

            try
            {
                string json = SyncEngine.Decompress(syncDataBytes);
                JObject payload = JsonConvert.DeserializeObject<JObject>(json);
                string synchronizationId = payload[nameof(SyncEngine.BaseInfo.SynchronizationId)].Value<string>();
                payloadAction = (SyncEngine.PayloadAction)Enum.Parse(typeof(SyncEngine.PayloadAction), payload[nameof(SyncEngine.BaseInfo.PayloadAction)].Value<string>());

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

                if (payloadAction == SyncEngine.PayloadAction.Synchronize)
                {
                    SyncEngine.ApplyChangesParameter applyChangesParameter = SyncEngine.ApplyChangesParameter.FromPayload(payload);
                    applyChangesParameter.Log = log;
                    syncEngine.ApplyChanges(applyChangesParameter, ref applyChangesResult);
                }
                else if (payloadAction == SyncEngine.PayloadAction.SynhronizeReverse)
                {
                    SyncEngine.GetChangesParameter getChangesParameter = SyncEngine.GetChangesParameter.FromPayload(payload, syncEngine);
                    getChangesParameter.Log = log;
                    syncEngine.GetChanges(getChangesParameter, ref getChangesResult);
                }
            }
            catch (Exception e)
            {
                jsonResult["isOK"] = false;
                jsonResult["errorMessage"] = e.Message;
                log.Add(e.Message);
            }
            finally
            {
                if (payloadAction == SyncEngine.PayloadAction.Synchronize)
                {
                    if (applyChangesResult != null)
                    {
                        try
                        {
                            jsonResult["payload"] = Convert.ToBase64String(applyChangesResult.GetCompressed());
                        }
                        catch (Exception e)
                        {
                            string errMsg = $"jsonResult payload in applyChangesResult Error: {e.Message}";
                            jsonResult["isOK"] = false;
                            jsonResult["errorMessage"] = errMsg;
                            log.Add(errMsg);
                        }
                        
                    }
                }
                else if (payloadAction == SyncEngine.PayloadAction.SynhronizeReverse)
                {
                    if (getChangesResult != null)
                    {
                        try
                        {
                            jsonResult["payload"] = Convert.ToBase64String(getChangesResult.GetCompressed());
                        }
                        catch (Exception e)
                        {
                            string errMsg = $"jsonResult payload in getChangesResult Error: {e.Message}";
                            jsonResult["isOK"] = false;
                            jsonResult["errorMessage"] = errMsg;
                            log.Add(errMsg);
                        }
                    }
                }

                jsonResult["log"] = JArray.FromObject(log);

                if (lockTaken)
                {
                    Monitor.Exit(syncServerLockObject);
                }
            }

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
