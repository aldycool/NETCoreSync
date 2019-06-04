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
    public class SyncDepartmentController : Controller
    {
        private readonly DatabaseContext _context;

        public SyncDepartmentController(DatabaseContext context)
        {
            _context = context;
        }

        // GET: SyncDepartment
        public async Task<IActionResult> Index()
        {
            return View(await _context.Departments.ToListAsync());
        }

        // GET: SyncDepartment/Details/5
        public async Task<IActionResult> Details(Guid? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var syncDepartment = await _context.Departments
                .FirstOrDefaultAsync(m => m.ID == id);
            if (syncDepartment == null)
            {
                return NotFound();
            }

            return View(syncDepartment);
        }

        // GET: SyncDepartment/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: SyncDepartment/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("Name")] SyncDepartment syncDepartment)
        {
            if (ModelState.IsValid)
            {
                syncDepartment.ID = Guid.NewGuid();
                _context.Add(syncDepartment);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            return View(syncDepartment);
        }

        // GET: SyncDepartment/Edit/5
        public async Task<IActionResult> Edit(Guid? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var syncDepartment = await _context.Departments.FindAsync(id);
            if (syncDepartment == null)
            {
                return NotFound();
            }
            return View(syncDepartment);
        }

        // POST: SyncDepartment/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(Guid id, [Bind("ID,Name")] SyncDepartment syncDepartment)
        {
            if (id != syncDepartment.ID)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(syncDepartment);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!SyncDepartmentExists(syncDepartment.ID))
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
            return View(syncDepartment);
        }

        // GET: SyncDepartment/Delete/5
        public async Task<IActionResult> Delete(Guid? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var syncDepartment = await _context.Departments
                .FirstOrDefaultAsync(m => m.ID == id);
            if (syncDepartment == null)
            {
                return NotFound();
            }

            return View(syncDepartment);
        }

        // POST: SyncDepartment/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(Guid id)
        {
            var syncDepartment = await _context.Departments.FindAsync(id);
            _context.Departments.Remove(syncDepartment);
            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        private bool SyncDepartmentExists(Guid id)
        {
            return _context.Departments.Any(e => e.ID == id);
        }
    }
}
