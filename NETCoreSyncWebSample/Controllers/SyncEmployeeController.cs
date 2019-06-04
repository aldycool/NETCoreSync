using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using NETCoreSyncWebSample.Models;

namespace NETCoreSyncWebSample.Controllers
{
    public class SyncEmployeeController : Controller
    {
        private readonly DatabaseContext _context;

        public SyncEmployeeController(DatabaseContext context)
        {
            _context = context;
        }

        // GET: SyncEmployee
        public async Task<IActionResult> Index()
        {
            var databaseContext = _context.SyncEmployee.Include(s => s.Department);
            return View(await databaseContext.ToListAsync());
        }

        // GET: SyncEmployee/Details/5
        public async Task<IActionResult> Details(Guid? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var syncEmployee = await _context.SyncEmployee
                .Include(s => s.Department)
                .FirstOrDefaultAsync(m => m.ID == id);
            if (syncEmployee == null)
            {
                return NotFound();
            }

            return View(syncEmployee);
        }

        // GET: SyncEmployee/Create
        public IActionResult Create()
        {
            ViewData["DepartmentID"] = new SelectList(_context.Departments, "ID", "ID");
            return View();
        }

        // POST: SyncEmployee/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("Name,Birthday,NumberOfComputers,SavingAmount,IsActive,DepartmentID")] SyncEmployee syncEmployee)
        {
            if (ModelState.IsValid)
            {
                syncEmployee.ID = Guid.NewGuid();
                _context.Add(syncEmployee);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            ViewData["DepartmentID"] = new SelectList(_context.Departments, "ID", "ID", syncEmployee.DepartmentID);
            return View(syncEmployee);
        }

        // GET: SyncEmployee/Edit/5
        public async Task<IActionResult> Edit(Guid? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var syncEmployee = await _context.SyncEmployee.FindAsync(id);
            if (syncEmployee == null)
            {
                return NotFound();
            }
            ViewData["DepartmentID"] = new SelectList(_context.Departments, "ID", "ID", syncEmployee.DepartmentID);
            return View(syncEmployee);
        }

        // POST: SyncEmployee/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(Guid id, [Bind("ID,Name,Birthday,NumberOfComputers,SavingAmount,IsActive,DepartmentID")] SyncEmployee syncEmployee)
        {
            if (id != syncEmployee.ID)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(syncEmployee);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!SyncEmployeeExists(syncEmployee.ID))
                    {
                        return NotFound();
                    }
                    else
                    {
                        throw;
                    }
                }
                return RedirectToAction(nameof(Index));
            }
            ViewData["DepartmentID"] = new SelectList(_context.Departments, "ID", "ID", syncEmployee.DepartmentID);
            return View(syncEmployee);
        }

        // GET: SyncEmployee/Delete/5
        public async Task<IActionResult> Delete(Guid? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var syncEmployee = await _context.SyncEmployee
                .Include(s => s.Department)
                .FirstOrDefaultAsync(m => m.ID == id);
            if (syncEmployee == null)
            {
                return NotFound();
            }

            return View(syncEmployee);
        }

        // POST: SyncEmployee/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(Guid id)
        {
            var syncEmployee = await _context.SyncEmployee.FindAsync(id);
            _context.SyncEmployee.Remove(syncEmployee);
            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        private bool SyncEmployeeExists(Guid id)
        {
            return _context.SyncEmployee.Any(e => e.ID == id);
        }
    }
}
