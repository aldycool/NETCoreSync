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
    public class HomeController : Controller
    {
        private readonly DatabaseContext databaseContext;        

        public HomeController(DatabaseContext databaseContext)
        {
            this.databaseContext = databaseContext;
        }

        public IActionResult Index()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }

        public IActionResult ResetDatabase()
        {
            databaseContext.Persons.RemoveRange(databaseContext.Persons);
            databaseContext.Areas.RemoveRange(databaseContext.Areas);
            databaseContext.CustomObjects.RemoveRange(databaseContext.CustomObjects);
            databaseContext.SaveChanges();

            return RedirectToAction("Index", "Home");
        }
    }
}
