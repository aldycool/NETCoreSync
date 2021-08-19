using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using WebSample.Models;

namespace WebSample.Controllers
{
    public class CustomObjectController : Controller
    {
        private readonly DatabaseContext databaseContext;        

        public CustomObjectController(DatabaseContext databaseContext)
        {
            this.databaseContext = databaseContext;
        }

        public IActionResult Index()
        {
            return View(databaseContext.CustomObjects.OrderBy(o => o.FieldString).ToList());
        }
    }
}
