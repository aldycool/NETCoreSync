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
            SyncResult result = new SyncResult();
            
            try
            {
                long lastSync = syncEngine.InvokeGetClientLastSync();

                (byte[] compressed, long clientPayloadMaxTimeStamp, List<SyncLog.SyncLogData> logChanges) = syncEngine.PreparePayload(result.Log, synchronizationId, lastSync, customInfo);
                result.ClientLog.SentChanges.AddRange(logChanges);

                result.Log.Add($"Sending Data to {serverUrl}...");
                JObject jObjectResponse = null;
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
                            try
                            {
                                jObjectResponse = JsonConvert.DeserializeObject<JObject>(responseContent);
                            }
                            catch (Exception eInner)
                            {
                                throw new Exception($"Unable to parse Response as JObject: {eInner.Message}. Response: {responseContent}");
                            }
                            if (jObjectResponse.ContainsKey("errorMessage"))
                            {
                                AddServerLogIfExist(jObjectResponse, result);
                                throw new Exception($"ServerMessage: {jObjectResponse["errorMessage"].Value<string>()}");
                            }
                        }
                        else
                        {
                            throw new Exception($"Response StatusCode: {response.StatusCode}, ReasonPhrase: {response.ReasonPhrase}");
                        }
                    }
                }

                AddServerLogIfExist(jObjectResponse, result);
                result.Log.Add($"Processing Data from {serverUrl}...");
                string base64SyncDataBytes = jObjectResponse["payload"].Value<string>();
                byte[] syncDataBytes = Convert.FromBase64String(base64SyncDataBytes);
                (_, List<SyncLog.SyncLogData> inserts, List<SyncLog.SyncLogData> updates, List<SyncLog.SyncLogData> deletes, List<SyncLog.SyncLogConflict> conflicts) = syncEngine.ProcessPayload(result.Log, syncDataBytes);
                result.ClientLog.AppliedChanges.Inserts.AddRange(inserts);
                result.ClientLog.AppliedChanges.Updates.AddRange(updates);
                result.ClientLog.AppliedChanges.Deletes.AddRange(deletes);
                result.ClientLog.AppliedChanges.Conflicts.AddRange(conflicts);
                long serverMaxTimeStamp = jObjectResponse["maxTimeStamp"].Value<long>();
                long maxLastSync = lastSync;
                if (clientPayloadMaxTimeStamp > maxLastSync) maxLastSync = clientPayloadMaxTimeStamp;
                if (serverMaxTimeStamp > maxLastSync) maxLastSync = serverMaxTimeStamp;
                result.Log.Add($"LastSync Updated To: {maxLastSync}");
                syncEngine.SetClientLastSync(maxLastSync);
                result.Log.Add($"Synchronize Finished");
            }
            catch (Exception e)
            {
                result.ErrorMessage = e.Message;
                result.Log.Add($"Error: {e.Message}");
            }
            return result;
        }

        private void AddServerLogIfExist(JObject jObjectResponse, SyncResult result)
        {
            if (jObjectResponse.ContainsKey("log"))
            {
                List<string> serverLog = jObjectResponse["log"].ToObject<List<string>>();
                for (int i = 0; i < serverLog.Count; i++)
                {
                    result.Log.Add($"Server -> {serverLog[i]}");
                }
            }
            if (jObjectResponse.ContainsKey("sentChanges"))
            {
                List<SyncLog.SyncLogData> serverSentChanges = jObjectResponse["sentChanges"].ToObject<List<SyncLog.SyncLogData>>();
                result.ServerLog.SentChanges.AddRange(serverSentChanges);
            }
            if (jObjectResponse.ContainsKey("serverInserts"))
            {
                List<SyncLog.SyncLogData> serverInserts = jObjectResponse["serverInserts"].ToObject<List<SyncLog.SyncLogData>>();
                result.ServerLog.AppliedChanges.Inserts.AddRange(serverInserts);
            }
            if (jObjectResponse.ContainsKey("serverUpdates"))
            {
                List<SyncLog.SyncLogData> serverUpdates = jObjectResponse["serverUpdates"].ToObject<List<SyncLog.SyncLogData>>();
                result.ServerLog.AppliedChanges.Updates.AddRange(serverUpdates);
            }
            if (jObjectResponse.ContainsKey("serverDeletes"))
            {
                List<SyncLog.SyncLogData> serverDeletes = jObjectResponse["serverDeletes"].ToObject<List<SyncLog.SyncLogData>>();
                result.ServerLog.AppliedChanges.Deletes.AddRange(serverDeletes);
            }
            if (jObjectResponse.ContainsKey("serverConflicts"))
            {
                List<SyncLog.SyncLogConflict> serverConflicts = jObjectResponse["serverConflicts"].ToObject<List<SyncLog.SyncLogConflict>>();
                result.ServerLog.AppliedChanges.Conflicts.AddRange(serverConflicts);
            }
        }
    }
}
