using System;
using System.Linq;
using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using System.Text;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace NETCoreSync
{
    public class SyncClient
    {
        private readonly string synchronizationId;
        private readonly SyncEngine syncEngine;
        private readonly string serverUrl;

        public SyncClient(string synchronizationId, SyncEngine syncEngine, string serverUrl)
        {
            this.synchronizationId = synchronizationId ?? throw new NullReferenceException(nameof(synchronizationId));
            this.syncEngine = syncEngine ?? throw new NullReferenceException(nameof(syncEngine));
            this.serverUrl = serverUrl ?? throw new NullReferenceException(nameof(serverUrl));
        }

        public async Task<SyncResult> SynchronizeAsync(Dictionary<string, object> customInfo = null)
        {
            SyncResult syncResult = new SyncResult();
            
            try
            {
                syncResult.Log.Add($"=== Synchronize Started ===");

                if (syncEngine.SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.GlobalTimeStamp)
                {
                    await SynchronizeGlobalTimeStamp(customInfo, syncResult);
                }
                else if (syncEngine.SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.DatabaseTimeStamp)
                {
                    await SynchronizeDatabaseTimeStamp(customInfo, syncResult);
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

        private async Task SynchronizeDatabaseTimeStamp(Dictionary<string, object> customInfo, SyncResult syncResult)
        {
            syncResult.Log.Add("=== Server Get Knowledge (As Remote Knowledge) ===");
            SyncEngine.GetKnowledgeParameter serverGetKnowledgeParameter = new SyncEngine.GetKnowledgeParameter(
                SyncEngine.PayloadAction.Knowledge,
                synchronizationId,
                customInfo);
            SyncEngine.GetKnowledgeResult serverGetKnowledgeResult = null;
            (string serverGetKnowledgeErrMsg, JObject jObjectServerGetKnowledgeResult) = await ExecuteOnServer(serverGetKnowledgeParameter.GetCompressed(), syncResult);
            if (jObjectServerGetKnowledgeResult != null)
            {
                serverGetKnowledgeResult = SyncEngine.GetKnowledgeResult.FromPayload(jObjectServerGetKnowledgeResult);
            }
            if (!string.IsNullOrEmpty(serverGetKnowledgeErrMsg)) throw new Exception(serverGetKnowledgeErrMsg);

            syncResult.Log.Add("=== Client Get Knowledge (As Local Knowledge) ===");
            SyncEngine.GetKnowledgeParameter clientGetKnowledgeParameter = new SyncEngine.GetKnowledgeParameter(
                SyncEngine.PayloadAction.Knowledge,
                synchronizationId,
                customInfo);
            clientGetKnowledgeParameter.Log = syncResult.Log;
            SyncEngine.GetKnowledgeResult clientGetKnowledgeResult = null;
            try
            {
                syncEngine.GetKnowledge(clientGetKnowledgeParameter, ref clientGetKnowledgeResult);
            }
            catch (Exception)
            {
                throw;
            }

            syncResult.Log.Add("=== Client Get Changes based on Server Knowledge ===");
            SyncEngine.GetChangesByKnowledgeParameter clientGetChangesByKnowledgeParameter = new SyncEngine.GetChangesByKnowledgeParameter(
                SyncEngine.PayloadAction.Synchronize,
                synchronizationId,
                customInfo);
            clientGetChangesByKnowledgeParameter.Log = syncResult.Log;
            clientGetChangesByKnowledgeParameter.LocalKnowledgeInfos = clientGetKnowledgeResult.KnowledgeInfos;
            clientGetChangesByKnowledgeParameter.RemoteKnowledgeInfos = serverGetKnowledgeResult.KnowledgeInfos;
            SyncEngine.GetChangesByKnowledgeResult clientGetChangesByKnowledgeResult = null;
            try
            {
                syncEngine.GetChangesByKnowledge(clientGetChangesByKnowledgeParameter, ref clientGetChangesByKnowledgeResult);
                
            }
            catch (Exception)
            {
                throw;
            }
            finally
            {
                if (clientGetChangesByKnowledgeResult != null)
                {
                    syncResult.ClientLog.SentChanges.AddRange(clientGetChangesByKnowledgeResult.LogChanges);
                }
            }

            syncResult.Log.Add("=== Server Apply Changes ===");
            SyncEngine.ApplyChangesByKnowledgeParameter serverApplyChangesByKnowledgeParameter = new SyncEngine.ApplyChangesByKnowledgeParameter(
                SyncEngine.PayloadAction.Synchronize,
                synchronizationId,
                customInfo);
            serverApplyChangesByKnowledgeParameter.Changes = clientGetChangesByKnowledgeResult.Changes;
            serverApplyChangesByKnowledgeParameter.SourceDatabaseInstanceId = clientGetKnowledgeResult.KnowledgeInfos.Where(w => w.IsLocal).First().DatabaseInstanceId;
            serverApplyChangesByKnowledgeParameter.DestinationDatabaseInstanceId = serverGetKnowledgeResult.KnowledgeInfos.Where(w => w.IsLocal).First().DatabaseInstanceId;
            SyncEngine.ApplyChangesByKnowledgeResult serverApplyChangesByKnowledgeResult = null;
            (string serverApplyChangesByKnowledgeErrMsg, JObject jObjectServerApplyChangesByKnowledgeResult) = await ExecuteOnServer(serverApplyChangesByKnowledgeParameter.GetCompressed(), syncResult);
            if (jObjectServerApplyChangesByKnowledgeResult != null)
            {
                serverApplyChangesByKnowledgeResult = SyncEngine.ApplyChangesByKnowledgeResult.FromPayload(jObjectServerApplyChangesByKnowledgeResult);
                syncResult.ServerLog.AppliedChanges.Inserts.AddRange(serverApplyChangesByKnowledgeResult.Inserts);
                syncResult.ServerLog.AppliedChanges.Updates.AddRange(serverApplyChangesByKnowledgeResult.Updates);
                syncResult.ServerLog.AppliedChanges.Deletes.AddRange(serverApplyChangesByKnowledgeResult.Deletes);
                syncResult.ServerLog.AppliedChanges.Conflicts.AddRange(serverApplyChangesByKnowledgeResult.Conflicts);
            }
            if (!string.IsNullOrEmpty(serverApplyChangesByKnowledgeErrMsg)) throw new Exception(serverApplyChangesByKnowledgeErrMsg);

            syncResult.Log.Add("=== Server Get Knowledge (As Local Knowledge) ===");
            serverGetKnowledgeParameter = new SyncEngine.GetKnowledgeParameter(
                SyncEngine.PayloadAction.Knowledge,
                synchronizationId,
                customInfo);
            serverGetKnowledgeResult = null;
            (serverGetKnowledgeErrMsg, jObjectServerGetKnowledgeResult) = await ExecuteOnServer(serverGetKnowledgeParameter.GetCompressed(), syncResult);
            if (jObjectServerGetKnowledgeResult != null)
            {
                serverGetKnowledgeResult = SyncEngine.GetKnowledgeResult.FromPayload(jObjectServerGetKnowledgeResult);
            }
            if (!string.IsNullOrEmpty(serverGetKnowledgeErrMsg)) throw new Exception(serverGetKnowledgeErrMsg);

            syncResult.Log.Add("=== Client Get Knowledge (As Remote Knowledge) ===");
            clientGetKnowledgeParameter = new SyncEngine.GetKnowledgeParameter(
                SyncEngine.PayloadAction.Knowledge,
                synchronizationId,
                customInfo);
            clientGetKnowledgeParameter.Log = syncResult.Log;
            clientGetKnowledgeResult = null;
            try
            {
                syncEngine.GetKnowledge(clientGetKnowledgeParameter, ref clientGetKnowledgeResult);
            }
            catch (Exception)
            {
                throw;
            }

            syncResult.Log.Add("=== Server Get Changes based on Client Knowledge ===");
            SyncEngine.GetChangesByKnowledgeParameter serverGetChangesByKnowledgeParameter = new SyncEngine.GetChangesByKnowledgeParameter(
                SyncEngine.PayloadAction.SynhronizeReverse,
                synchronizationId,
                customInfo);
            serverGetChangesByKnowledgeParameter.LocalKnowledgeInfos = serverGetKnowledgeResult.KnowledgeInfos;
            serverGetChangesByKnowledgeParameter.RemoteKnowledgeInfos = clientGetKnowledgeResult.KnowledgeInfos;
            SyncEngine.GetChangesByKnowledgeResult serverGetChangesByKnowledgeResult = null;
            (string serverGetChangesByKnowledgeErrMsg, JObject jObjectServerGetChangesByKnowledgeResult) = await ExecuteOnServer(serverGetChangesByKnowledgeParameter.GetCompressed(), syncResult);
            if (jObjectServerGetChangesByKnowledgeResult != null)
            {
                serverGetChangesByKnowledgeResult = SyncEngine.GetChangesByKnowledgeResult.FromPayload(jObjectServerGetChangesByKnowledgeResult);
                syncResult.ServerLog.SentChanges.AddRange(serverGetChangesByKnowledgeResult.LogChanges);
            }
            if (!string.IsNullOrEmpty(serverGetChangesByKnowledgeErrMsg)) throw new Exception(serverGetChangesByKnowledgeErrMsg);

            syncResult.Log.Add("=== Client Apply Changes ===");
            SyncEngine.ApplyChangesByKnowledgeParameter clientApplyChangesByKnowledgeParameter = new SyncEngine.ApplyChangesByKnowledgeParameter(
                SyncEngine.PayloadAction.SynhronizeReverse,
                synchronizationId,
                customInfo);
            clientApplyChangesByKnowledgeParameter.Log = syncResult.Log;
            clientApplyChangesByKnowledgeParameter.Changes = serverGetChangesByKnowledgeResult.Changes;
            clientApplyChangesByKnowledgeParameter.SourceDatabaseInstanceId = serverGetKnowledgeResult.KnowledgeInfos.Where(w => w.IsLocal).First().DatabaseInstanceId;
            clientApplyChangesByKnowledgeParameter.DestinationDatabaseInstanceId = clientGetKnowledgeResult.KnowledgeInfos.Where(w => w.IsLocal).First().DatabaseInstanceId;
            SyncEngine.ApplyChangesByKnowledgeResult clientApplyChangesByKnowledgeResult = null;
            try
            {
                syncEngine.ApplyChangesByKnowledge(clientApplyChangesByKnowledgeParameter, ref clientApplyChangesByKnowledgeResult);
            }
            catch (Exception)
            {
                throw;
            }
            finally
            {
                if (clientApplyChangesByKnowledgeResult != null)
                {
                    syncResult.ClientLog.AppliedChanges.Inserts.AddRange(clientApplyChangesByKnowledgeResult.Inserts);
                    syncResult.ClientLog.AppliedChanges.Updates.AddRange(clientApplyChangesByKnowledgeResult.Updates);
                    syncResult.ClientLog.AppliedChanges.Deletes.AddRange(clientApplyChangesByKnowledgeResult.Deletes);
                    syncResult.ClientLog.AppliedChanges.Conflicts.AddRange(clientApplyChangesByKnowledgeResult.Conflicts);
                }
            }
        }

        private async Task SynchronizeGlobalTimeStamp(Dictionary<string, object> customInfo, SyncResult syncResult)
        {
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
