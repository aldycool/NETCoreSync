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
                if (syncEngine.SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.UseGlobalTimeStamp)
                {
                    SyncEngine.PreparePayloadGlobalTimeStampParameter parameter = new SyncEngine.PreparePayloadGlobalTimeStampParameter();
                    parameter.SynchronizationId = synchronizationId;
                    parameter.CustomInfo = customInfo;
                    parameter.PayloadAction = SyncEngine.PayloadAction.Synchronize;
                    parameter.Log = syncResult.Log;

                    parameter.LastSync = syncEngine.InvokeGetClientLastSync();

                    SyncEngine.PreparePayloadGlobalTimeStampResult result = (SyncEngine.PreparePayloadGlobalTimeStampResult)syncEngine.PreparePayload(parameter);

                    syncResult.ClientLog.SentChanges.AddRange(result.LogChanges);

                    syncResult.Log.Add($"Sending Data to {serverUrl}...");
                    JObject jObjectResponse = null;
                    using (var httpClient = new HttpClient())
                    {
                        using (var multipartFormDataContent = new MultipartFormDataContent())
                        {
                            ByteArrayContent byteArrayContent = new ByteArrayContent(result.GetCompressed());
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
                                    AddServerLogIfExist(jObjectResponse, syncResult);
                                    throw new Exception($"ServerMessage: {jObjectResponse["errorMessage"].Value<string>()}");
                                }
                            }
                            else
                            {
                                throw new Exception($"Response StatusCode: {response.StatusCode}, ReasonPhrase: {response.ReasonPhrase}");
                            }
                        }
                    }

                    AddServerLogIfExist(jObjectResponse, syncResult);
                    syncResult.Log.Add($"Processing Data from {serverUrl}...");
                    string base64SyncDataBytes = jObjectResponse["payload"].Value<string>();
                    long serverMaxTimeStamp = jObjectResponse["maxTimeStamp"].Value<long>();
                    byte[] syncDataBytes = Convert.FromBase64String(base64SyncDataBytes);
                    
                    SyncEngine.ProcessPayloadGlobalTimeStampParameter processParameter = new SyncEngine.ProcessPayloadGlobalTimeStampParameter(syncDataBytes);
                    SyncEngine.ProcessPayloadResult processResult = syncEngine.ProcessPayload(processParameter);
                    syncResult.Log.AddRange(processParameter.Log);

                    syncResult.ClientLog.AppliedChanges.Inserts.AddRange(processResult.Inserts);
                    syncResult.ClientLog.AppliedChanges.Updates.AddRange(processResult.Updates);
                    syncResult.ClientLog.AppliedChanges.Deletes.AddRange(processResult.Deletes);
                    syncResult.ClientLog.AppliedChanges.Conflicts.AddRange(processResult.Conflicts);

                    long maxLastSync = parameter.LastSync.HasValue ? parameter.LastSync.Value : SyncEngine.GetMinValueTicks();
                    if (result.MaxTimeStamp > maxLastSync) maxLastSync = result.MaxTimeStamp;
                    if (serverMaxTimeStamp > maxLastSync) maxLastSync = serverMaxTimeStamp;
                    syncResult.Log.Add($"LastSync Updated To: {maxLastSync}");
                    syncEngine.SetClientLastSync(maxLastSync);
                    syncResult.Log.Add($"Synchronize Finished");
                }

                if (syncEngine.SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.UseEachDatabaseInstanceTimeStamp)
                {
                }
            }
            catch (Exception e)
            {
                syncResult.ErrorMessage = e.Message;
                syncResult.Log.Add($"Error: {e.Message}");
            }
            return syncResult;
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
