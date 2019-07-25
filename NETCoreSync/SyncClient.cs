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
                SyncEngine.PreparePayloadParameter baseParameter = null;

                if (syncEngine.SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.GlobalTimeStamp)
                {
                    baseParameter = new SyncEngine.PreparePayloadGlobalTimeStampParameter();
                }
                else if (syncEngine.SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.DatabaseTimeStamp)
                {
                    baseParameter = new SyncEngine.PreparePayloadDatabaseTimeStampParameter();
                }
                else
                {
                    throw new NotImplementedException(syncEngine.SyncConfiguration.TimeStampStrategy.ToString());
                }

                baseParameter.SynchronizationId = synchronizationId;
                baseParameter.CustomInfo = customInfo;
                baseParameter.Log = syncResult.Log;

                if (syncEngine.SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.GlobalTimeStamp)
                {
                    baseParameter.PayloadAction = SyncEngine.PayloadAction.Synchronize;

                    SyncEngine.PreparePayloadGlobalTimeStampParameter parameter = (SyncEngine.PreparePayloadGlobalTimeStampParameter)baseParameter; 
                    parameter.LastSync = syncEngine.InvokeGetClientLastSync();

                    SyncEngine.PreparePayloadGlobalTimeStampResult result = (SyncEngine.PreparePayloadGlobalTimeStampResult)syncEngine.PreparePayload(parameter);
                    syncResult.ClientLog.SentChanges.AddRange(result.LogChanges);

                    syncResult.Log.Add($"Sending Data to {serverUrl}...");
                    JObject jObjectResponse = await SendToServer(result.GetCompressed(), syncResult);
                    AddServerLogIfExist(jObjectResponse, syncResult);

                    syncResult.Log.Add($"Processing Data from {serverUrl}...");
                    string base64SyncDataBytes = jObjectResponse["payload"].Value<string>();
                    long serverMaxTimeStamp = jObjectResponse["maxTimeStamp"].Value<long>();
                    byte[] syncDataBytes = Convert.FromBase64String(base64SyncDataBytes);
                    
                    SyncEngine.ProcessPayloadGlobalTimeStampParameter processParameter = new SyncEngine.ProcessPayloadGlobalTimeStampParameter(syncDataBytes);
                    processParameter.Log = syncResult.Log;
                    processParameter.Inserts = syncResult.ClientLog.AppliedChanges.Inserts;
                    processParameter.Updates = syncResult.ClientLog.AppliedChanges.Updates;
                    processParameter.Deletes = syncResult.ClientLog.AppliedChanges.Deletes;
                    processParameter.Conflicts = syncResult.ClientLog.AppliedChanges.Conflicts;
                    syncEngine.ProcessPayload(processParameter);

                    long maxLastSync = parameter.LastSync.HasValue ? parameter.LastSync.Value : SyncEngine.GetMinValueTicks();
                    if (result.MaxTimeStamp > maxLastSync) maxLastSync = result.MaxTimeStamp;
                    if (serverMaxTimeStamp > maxLastSync) maxLastSync = serverMaxTimeStamp;
                    syncResult.Log.Add($"LastSync Updated To: {maxLastSync}");
                    syncEngine.SetClientLastSync(maxLastSync);
                    syncResult.Log.Add($"Synchronize Finished");
                }
                else if (syncEngine.SyncConfiguration.TimeStampStrategy == SyncConfiguration.TimeStampStrategyEnum.DatabaseTimeStamp)
                {

                }
                else
                {
                    throw new NotImplementedException(syncEngine.SyncConfiguration.TimeStampStrategy.ToString());
                }
            }
            catch (Exception e)
            {
                syncResult.ErrorMessage = e.Message;
                syncResult.Log.Add($"Error: {e.Message}");
            }
            return syncResult;
        }

        private async Task<JObject> SendToServer(byte[] compressed, SyncResult syncResult)
        {
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
                            throw new Exception($"Unable to parse Response as JObject: {eInner.Message}. Response: {responseContent}");
                        }
                        if (jObjectResponse.ContainsKey("errorMessage"))
                        {
                            AddServerLogIfExist(jObjectResponse, syncResult);
                            throw new Exception($"ServerMessage: {jObjectResponse["errorMessage"].Value<string>()}");
                        }
                        return jObjectResponse;
                    }
                    else
                    {
                        throw new Exception($"Response StatusCode: {response.StatusCode}, ReasonPhrase: {response.ReasonPhrase}");
                    }
                }
            }
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
