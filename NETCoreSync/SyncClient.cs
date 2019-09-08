using System;
using System.Linq;
using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using System.Text;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NETCoreSync.Exceptions;

namespace NETCoreSync
{
    public class SyncClient
    {
        private readonly string synchronizationId;
        private readonly SyncEngine syncEngine;
        private readonly string serverUrl;
        private readonly Dictionary<string, string> httpHeaders;

        public enum SynchronizationMethodEnum
        {
            PushThenPull,
            PullThenPush
        }

        public SyncClient(string synchronizationId, SyncEngine syncEngine, string serverUrl)
            : this(synchronizationId, syncEngine, serverUrl, null)
        {
        }

        public SyncClient(string synchronizationId, SyncEngine syncEngine, string serverUrl, Dictionary<string, string> httpHeaders)
        {
            this.synchronizationId = synchronizationId ?? throw new NullReferenceException(nameof(synchronizationId));
            this.syncEngine = syncEngine ?? throw new NullReferenceException(nameof(syncEngine));
            this.serverUrl = serverUrl ?? throw new NullReferenceException(nameof(serverUrl));
            this.httpHeaders = httpHeaders;
        }

        public async Task<SyncResult> SynchronizeAsync(SynchronizationMethodEnum synchronizationMethod = SynchronizationMethodEnum.PushThenPull, Dictionary<string, object> customInfo = null)
        {
            SyncResult syncResult = new SyncResult();
            
            try
            {
                syncResult.Log.Add($"=== Synchronize Started ===");

                if (syncEngine.SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.GlobalTimeStamp)
                {
                    await SynchronizeGlobalTimeStamp(synchronizationMethod, customInfo, syncResult);
                }
                else if (syncEngine.SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.DatabaseTimeStamp)
                {
                    await SynchronizeDatabaseTimeStamp(synchronizationMethod, customInfo, syncResult);
                }
                else
                {
                    throw new NotImplementedException(syncEngine.SyncConfiguration.TimeStampStrategy.ToString());
                }

                syncResult.Log.Add($"=== Synchronize Finished ===");
            }
            catch (Exception e)
            {
                syncResult.ErrorMessage = e.Message;
                syncResult.Log.Add($"=== Error: {e.Message} ===");
            }
            return syncResult;
        }

        private async Task SynchronizeDatabaseTimeStamp(SynchronizationMethodEnum synchronizationMethod, Dictionary<string, object> customInfo, SyncResult syncResult)
        {
            if (synchronizationMethod == SynchronizationMethodEnum.PushThenPull)
            {
                await SynchronizeDatabaseTimeStampOneWay(true, customInfo, syncResult);
                await SynchronizeDatabaseTimeStampOneWay(false, customInfo, syncResult);
            }
            else if (synchronizationMethod == SynchronizationMethodEnum.PullThenPush)
            {
                await SynchronizeDatabaseTimeStampOneWay(false, customInfo, syncResult);
                await SynchronizeDatabaseTimeStampOneWay(true, customInfo, syncResult);
            }
            else
            {
                throw new NotImplementedException(synchronizationMethod.ToString());
            }
        }

        private async Task SynchronizeDatabaseTimeStampOneWay(bool runOnClient, Dictionary<string, object> customInfo, SyncResult syncResult)
        {
            string localName = null;
            string remoteName = null;
            SyncEngine.PayloadAction payloadAction = SyncEngine.PayloadAction.Synchronize;
            if (runOnClient)
            {
                localName = "Client";
                remoteName = "Server";
                payloadAction = SyncEngine.PayloadAction.Synchronize;
            }
            else
            {
                localName = "Server";
                remoteName = "Client";
                payloadAction = SyncEngine.PayloadAction.SynhronizeReverse;
            }

            syncResult.Log.Add($"=== {localName} Get Knowledge (As Local Knowledge) ===");
            SyncEngine.GetKnowledgeParameter localGetKnowledgeParameter = new SyncEngine.GetKnowledgeParameter(
                SyncEngine.PayloadAction.Knowledge,
                synchronizationId,
                customInfo);
            if (runOnClient) localGetKnowledgeParameter.Log = syncResult.Log;
            SyncEngine.GetKnowledgeResult localGetKnowledgeResult = null;
            if (runOnClient)
            {
                try
                {
                    syncEngine.GetKnowledge(localGetKnowledgeParameter, ref localGetKnowledgeResult);
                }
                catch (Exception)
                {
                    throw;
                }
            }
            else
            {
                (string localGetKnowledgeErrMsg, JObject jObjectLocalGetKnowledgeResult) = await ExecuteOnServer(localGetKnowledgeParameter.GetCompressed(), syncResult);
                if (jObjectLocalGetKnowledgeResult != null)
                {
                    localGetKnowledgeResult = SyncEngine.GetKnowledgeResult.FromPayload(jObjectLocalGetKnowledgeResult);
                }
                if (!string.IsNullOrEmpty(localGetKnowledgeErrMsg)) throw new Exception(localGetKnowledgeErrMsg);
            }

            syncResult.Log.Add($"=== {remoteName} Get Knowledge (As Remote Knowledge) ===");
            SyncEngine.GetKnowledgeParameter remoteGetKnowledgeParameter = new SyncEngine.GetKnowledgeParameter(
                SyncEngine.PayloadAction.Knowledge,
                synchronizationId,
                customInfo);
            if (!runOnClient) remoteGetKnowledgeParameter.Log = syncResult.Log;
            SyncEngine.GetKnowledgeResult remoteGetKnowledgeResult = null;
            if (runOnClient)
            {
                (string remoteGetKnowledgeErrMsg, JObject jObjectRemoteGetKnowledgeResult) = await ExecuteOnServer(remoteGetKnowledgeParameter.GetCompressed(), syncResult);
                if (jObjectRemoteGetKnowledgeResult != null)
                {
                    remoteGetKnowledgeResult = SyncEngine.GetKnowledgeResult.FromPayload(jObjectRemoteGetKnowledgeResult);
                }
                if (!string.IsNullOrEmpty(remoteGetKnowledgeErrMsg)) throw new Exception(remoteGetKnowledgeErrMsg);
            }
            else
            {
                try
                {
                    syncEngine.GetKnowledge(remoteGetKnowledgeParameter, ref remoteGetKnowledgeResult);
                }
                catch (Exception)
                {
                    throw;
                }
            }

            syncResult.Log.Add($"=== {localName} Get Changes based on {remoteName} Knowledge ===");
            SyncEngine.GetChangesByKnowledgeParameter getChangesByKnowledgeParameter = new SyncEngine.GetChangesByKnowledgeParameter(
                payloadAction,
                synchronizationId,
                customInfo);
            if (runOnClient) getChangesByKnowledgeParameter.Log = syncResult.Log;
            getChangesByKnowledgeParameter.LocalKnowledgeInfos = localGetKnowledgeResult.KnowledgeInfos;
            getChangesByKnowledgeParameter.RemoteKnowledgeInfos = remoteGetKnowledgeResult.KnowledgeInfos;
            SyncEngine.GetChangesByKnowledgeResult getChangesByKnowledgeResult = null;
            if (runOnClient)
            {
                try
                {
                    syncEngine.GetChangesByKnowledge(getChangesByKnowledgeParameter, ref getChangesByKnowledgeResult);

                }
                catch (Exception)
                {
                    throw;
                }
                finally
                {
                    if (getChangesByKnowledgeResult != null)
                    {
                        syncResult.ClientLog.SentChanges.AddRange(getChangesByKnowledgeResult.LogChanges);
                    }
                }
            }
            else
            {
                (string getChangesByKnowledgeErrMsg, JObject jObjectGetChangesByKnowledgeResult) = await ExecuteOnServer(getChangesByKnowledgeParameter.GetCompressed(), syncResult);
                if (jObjectGetChangesByKnowledgeResult != null)
                {
                    getChangesByKnowledgeResult = SyncEngine.GetChangesByKnowledgeResult.FromPayload(jObjectGetChangesByKnowledgeResult);
                    syncResult.ServerLog.SentChanges.AddRange(getChangesByKnowledgeResult.LogChanges);
                }
                if (!string.IsNullOrEmpty(getChangesByKnowledgeErrMsg)) throw new Exception(getChangesByKnowledgeErrMsg);
            }

            syncResult.Log.Add($"=== {remoteName} Apply Changes ===");
            SyncEngine.ApplyChangesByKnowledgeParameter applyChangesByKnowledgeParameter = new SyncEngine.ApplyChangesByKnowledgeParameter(
                payloadAction,
                synchronizationId,
                customInfo);
            if (!runOnClient) applyChangesByKnowledgeParameter.Log = syncResult.Log;
            applyChangesByKnowledgeParameter.Changes = getChangesByKnowledgeResult.Changes;
            applyChangesByKnowledgeParameter.SourceDatabaseInstanceId = localGetKnowledgeResult.KnowledgeInfos.Where(w => w.IsLocal).First().DatabaseInstanceId;
            applyChangesByKnowledgeParameter.DestinationDatabaseInstanceId = remoteGetKnowledgeResult.KnowledgeInfos.Where(w => w.IsLocal).First().DatabaseInstanceId;
            SyncEngine.ApplyChangesByKnowledgeResult applyChangesByKnowledgeResult = null;
            if (runOnClient)
            {
                (string applyChangesByKnowledgeErrMsg, JObject jObjectApplyChangesByKnowledgeResult) = await ExecuteOnServer(applyChangesByKnowledgeParameter.GetCompressed(), syncResult);
                if (jObjectApplyChangesByKnowledgeResult != null)
                {
                    applyChangesByKnowledgeResult = SyncEngine.ApplyChangesByKnowledgeResult.FromPayload(jObjectApplyChangesByKnowledgeResult);
                    syncResult.ServerLog.AppliedChanges.Inserts.AddRange(applyChangesByKnowledgeResult.Inserts);
                    syncResult.ServerLog.AppliedChanges.Updates.AddRange(applyChangesByKnowledgeResult.Updates);
                    syncResult.ServerLog.AppliedChanges.Deletes.AddRange(applyChangesByKnowledgeResult.Deletes);
                    syncResult.ServerLog.AppliedChanges.Conflicts.AddRange(applyChangesByKnowledgeResult.Conflicts);
                }
                if (!string.IsNullOrEmpty(applyChangesByKnowledgeErrMsg)) throw new Exception(applyChangesByKnowledgeErrMsg);
            }
            else
            {
                try
                {
                    syncEngine.ApplyChangesByKnowledge(applyChangesByKnowledgeParameter, ref applyChangesByKnowledgeResult);
                }
                catch (Exception)
                {
                    throw;
                }
                finally
                {
                    if (applyChangesByKnowledgeResult != null)
                    {
                        syncResult.ClientLog.AppliedChanges.Inserts.AddRange(applyChangesByKnowledgeResult.Inserts);
                        syncResult.ClientLog.AppliedChanges.Updates.AddRange(applyChangesByKnowledgeResult.Updates);
                        syncResult.ClientLog.AppliedChanges.Deletes.AddRange(applyChangesByKnowledgeResult.Deletes);
                        syncResult.ClientLog.AppliedChanges.Conflicts.AddRange(applyChangesByKnowledgeResult.Conflicts);
                    }
                }
            }
        }

        private async Task SynchronizeGlobalTimeStamp(SynchronizationMethodEnum synchronizationMethod, Dictionary<string, object> customInfo, SyncResult syncResult)
        {
            if (synchronizationMethod != SynchronizationMethodEnum.PushThenPull)
            {
                throw new SyncEngineConstraintException($"{nameof(synchronizationMethod)} other than {SynchronizationMethodEnum.PushThenPull.ToString()} is not supported, because {nameof(SyncConfiguration.TimeStampStrategyEnum.GlobalTimeStamp)} is already using Global DateTime (World Clock) as the time stamp, therefore, performing PushThenPull / PullThenPush will not have different effect (due to the same kind of time stamp being compared)");
            }

            syncResult.Log.Add("=== Client Get Changes ===");
            SyncEngine.GetChangesParameter clientGetChangesParameter = new SyncEngine.GetChangesParameter(
                SyncEngine.PayloadAction.Synchronize,
                synchronizationId,
                customInfo);
            clientGetChangesParameter.Log = syncResult.Log;
            clientGetChangesParameter.LastSync = syncEngine.InvokeGetClientLastSync();
            SyncEngine.GetChangesResult clientGetChangesResult = null;
            try
            {
                syncEngine.GetChanges(clientGetChangesParameter, ref clientGetChangesResult);
            }
            catch (Exception)
            {
                throw;
            }
            finally
            {
                if (clientGetChangesResult != null)
                {
                    syncResult.ClientLog.SentChanges.AddRange(clientGetChangesResult.LogChanges);
                }
            }

            syncResult.Log.Add("=== Server Apply Changes ===");
            SyncEngine.ApplyChangesParameter serverApplyChangesParameter = new SyncEngine.ApplyChangesParameter(
                SyncEngine.PayloadAction.Synchronize,
                synchronizationId,
                customInfo);
            serverApplyChangesParameter.Changes = clientGetChangesResult.Changes;
            SyncEngine.ApplyChangesResult serverApplyChangesResult = null;
            (string serverApplyChangesErrMsg, JObject jObjectServerApplyChangesResult) = await ExecuteOnServer(serverApplyChangesParameter.GetCompressed(), syncResult);
            if (jObjectServerApplyChangesResult != null)
            {
                serverApplyChangesResult = SyncEngine.ApplyChangesResult.FromPayload(jObjectServerApplyChangesResult);
                syncResult.ServerLog.AppliedChanges.Inserts.AddRange(serverApplyChangesResult.Inserts);
                syncResult.ServerLog.AppliedChanges.Updates.AddRange(serverApplyChangesResult.Updates);
                syncResult.ServerLog.AppliedChanges.Deletes.AddRange(serverApplyChangesResult.Deletes);
                syncResult.ServerLog.AppliedChanges.Conflicts.AddRange(serverApplyChangesResult.Conflicts);
            }
            if (!string.IsNullOrEmpty(serverApplyChangesErrMsg)) throw new Exception(serverApplyChangesErrMsg);

            syncResult.Log.Add("=== Server Get Changes ===");
            SyncEngine.GetChangesParameter serverGetChangesParameter = new SyncEngine.GetChangesParameter(
                SyncEngine.PayloadAction.SynhronizeReverse,
                synchronizationId,
                customInfo);
            serverGetChangesParameter.LastSync = clientGetChangesParameter.LastSync;
            serverGetChangesParameter.PayloadAppliedIds = serverApplyChangesResult.PayloadAppliedIds;
            SyncEngine.GetChangesResult serverGetChangesResult = null;
            (string serverGetChangesErrMsg, JObject jObjectServerGetChangesResult) = await ExecuteOnServer(serverGetChangesParameter.GetCompressed(), syncResult);
            if (jObjectServerGetChangesResult != null)
            {
                serverGetChangesResult = SyncEngine.GetChangesResult.FromPayload(jObjectServerGetChangesResult);
                syncResult.ServerLog.SentChanges.AddRange(serverGetChangesResult.LogChanges);
            }
            if (!string.IsNullOrEmpty(serverGetChangesErrMsg)) throw new Exception(serverGetChangesErrMsg);

            syncResult.Log.Add("=== Client Apply Changes ===");
            SyncEngine.ApplyChangesParameter clientApplyChangesParameter = new SyncEngine.ApplyChangesParameter(
                SyncEngine.PayloadAction.Synchronize,
                synchronizationId,
                customInfo);
            clientApplyChangesParameter.Log = syncResult.Log;
            clientApplyChangesParameter.Changes = serverGetChangesResult.Changes;
            SyncEngine.ApplyChangesResult clientApplyChangesResult = null;
            try
            {
                syncEngine.ApplyChanges(clientApplyChangesParameter, ref clientApplyChangesResult);
            }
            catch (Exception)
            {
                throw;
            }
            finally
            {
                if (clientApplyChangesResult != null)
                {
                    syncResult.ClientLog.AppliedChanges.Inserts.AddRange(clientApplyChangesResult.Inserts);
                    syncResult.ClientLog.AppliedChanges.Updates.AddRange(clientApplyChangesResult.Updates);
                    syncResult.ClientLog.AppliedChanges.Deletes.AddRange(clientApplyChangesResult.Deletes);
                    syncResult.ClientLog.AppliedChanges.Conflicts.AddRange(clientApplyChangesResult.Conflicts);
                }
            }

            syncResult.Log.Add($"===LastSync from Client Get Changes Parameter: {clientGetChangesParameter.LastSync} ===");
            syncResult.Log.Add($"===MaxTimeStamp from Client Get Changes Result: {clientGetChangesResult.MaxTimeStamp} ===");
            syncResult.Log.Add($"===MaxTimeStamp from Server Get Changes Result: {serverGetChangesResult.MaxTimeStamp} ===");
            long maxLastSync = clientGetChangesParameter.LastSync;
            if (clientGetChangesResult.MaxTimeStamp > maxLastSync) maxLastSync = clientGetChangesResult.MaxTimeStamp;
            if (serverGetChangesResult.MaxTimeStamp > maxLastSync) maxLastSync = serverGetChangesResult.MaxTimeStamp;
            syncResult.Log.Add($"=== LastSync Updated To: {maxLastSync} ===");
            syncEngine.SetClientLastSync(maxLastSync);
        }

        private async Task<(string errorMessage, JObject payload)> ExecuteOnServer(byte[] compressed, SyncResult syncResult)
        {
            JObject payload = null;

            using (var httpClient = new HttpClient())
            {
                if (httpHeaders != null)
                {
                    httpHeaders.ToList().ForEach(kvp => 
                    {
                        if (httpClient.DefaultRequestHeaders.Contains(kvp.Key)) httpClient.DefaultRequestHeaders.Remove(kvp.Key);
                        httpClient.DefaultRequestHeaders.Add(kvp.Key, kvp.Value);
                    });
                }

                using (var multipartFormDataContent = new MultipartFormDataContent())
                {
                    ByteArrayContent byteArrayContent = new ByteArrayContent(compressed);
                    multipartFormDataContent.Add(byteArrayContent, "files", "compressed.data");
                    var response = await httpClient.PostAsync(serverUrl, multipartFormDataContent);
                    if (response.IsSuccessStatusCode)
                    {
                        string responseContent = await response.Content.ReadAsStringAsync();
                        JObject jObjectResponse = null;
                        try
                        {
                            jObjectResponse = JsonConvert.DeserializeObject<JObject>(responseContent);
                        }
                        catch (Exception eInner)
                        {
                            return ($"Unable to parse Response as JObject: {eInner.Message}. Response: {responseContent}", payload);
                        }
                        List<string> serverLog = jObjectResponse["log"].ToObject<List<string>>();
                        for (int i = 0; i < serverLog.Count; i++)
                        {
                            syncResult.Log.Add($"Server -> {serverLog[i]}");
                        }
                        if (jObjectResponse.ContainsKey("payload"))
                        {
                            byte[] compressedResponse = Convert.FromBase64String(jObjectResponse["payload"].Value<string>());
                            string jsonResponse = SyncEngine.Decompress(compressedResponse);
                            payload = JsonConvert.DeserializeObject<JObject>(jsonResponse);
                        }
                        if (jObjectResponse.ContainsKey("errorMessage"))
                        {
                            return ($"ServerMessage: {jObjectResponse["errorMessage"].Value<string>()}", payload);
                        }
                        return (null, payload);
                    }
                    else
                    {
                        return ($"Response StatusCode: {response.StatusCode}, ReasonPhrase: {response.ReasonPhrase}", payload);
                    }
                }
            }
        }
    }
}
