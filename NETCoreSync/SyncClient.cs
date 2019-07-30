using System;
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
                syncResult.Log.Add($"=== Synchronize Finished ===");
            }
            catch (Exception e)
            {
                syncResult.ErrorMessage = e.Message;
                syncResult.Log.Add($"=== Error: {e.Message} ===");
            }
            return syncResult;
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
