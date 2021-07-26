using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace NETCoreSyncServer.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SyncController : ControllerBase
    {
        private readonly ILogger<SyncController> _logger;

        public SyncController(ILogger<SyncController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public String Get()
        {
            return "OK!";
        }
    }
}
