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
    public class AreaController : Controller
    {
        private readonly DatabaseContext databaseContext;        

        public AreaController(DatabaseContext databaseContext)
        {
            this.databaseContext = databaseContext;
        }

        public IActionResult Index()
        {
            return View(databaseContext.Areas.OrderBy(o => o.City).ToList());
        }
    }
}
