using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using WebSample.Models;
using NETCoreSync;
using Newtonsoft.Json.Linq;

namespace WebSample.Controllers
{
    public class SyncController : Controller
    {
        private readonly DatabaseContext databaseContext;
        private readonly SyncConfiguration syncConfiguration;

        public SyncController(DatabaseContext databaseContext, SyncConfiguration syncConfiguration)
        {
            this.databaseContext = databaseContext;
            this.syncConfiguration = syncConfiguration;
        }

        [HttpPost]
        [Consumes("multipart/form-data")]
        public IActionResult Index()
        {
            try
            {
                CustomSyncEngine customSyncEngine = new CustomSyncEngine(databaseContext, syncConfiguration);
                SyncServer syncServer = new SyncServer(customSyncEngine);

                IFormFile syncData = Request.Form.Files.FirstOrDefault();
                if (syncData == null) throw new NullReferenceException(nameof(syncData));
                byte[] syncDataBytes = null;
                using (var memoryStream = new MemoryStream())
                {
                    syncData.CopyTo(memoryStream);
                    memoryStream.Seek(0, SeekOrigin.Begin);
                    syncDataBytes = new byte[memoryStream.Length];
                    memoryStream.Read(syncDataBytes, 0, syncDataBytes.Length);
                }
                JObject result = syncServer.Process(syncDataBytes);
                return Json(result);
            }
            catch (Exception e)
            {
                return Json(SyncServer.JsonErrorResponse(e.Message));
            }
        }
    }
}
