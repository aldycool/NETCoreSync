using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using ServerApp.Models;

namespace ServerApp.Controllers
{
    public class SetupController : Controller
    {
        private readonly DatabaseContext databaseContext;

        public SetupController(DatabaseContext databaseContext)
        {
            this.databaseContext = databaseContext;
        }

        public IActionResult Index()
        {
            return View();
        }

        public IActionResult ResetDatabase()
        {
            databaseContext.Employees.RemoveRange(databaseContext.Employees);
            databaseContext.Departments.RemoveRange(databaseContext.Departments);
            databaseContext.Knowledges.RemoveRange(databaseContext.Knowledges);
            databaseContext.SaveChanges();

            return RedirectToAction("Index", "Home");
        }
    }
}
