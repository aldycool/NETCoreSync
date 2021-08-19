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
    public class PersonController : Controller
    {
        private readonly DatabaseContext databaseContext;        

        public PersonController(DatabaseContext databaseContext)
        {
            this.databaseContext = databaseContext;
        }

        public IActionResult Index()
        {
            return View(databaseContext.Persons.OrderBy(o => o.Name).ToList());
        }
    }
}
