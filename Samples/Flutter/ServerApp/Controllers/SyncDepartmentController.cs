using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using ServerApp.Models;
using NETCoreSync;

namespace ServerApp.Controllers
{
    public class SyncDepartmentController : Controller
    {
        private readonly DatabaseContext _context;
        private SyncConfiguration syncConfiguration;

        public SyncDepartmentController(DatabaseContext context, SyncConfiguration syncConfiguration)
        {
            _context = context;
            this.syncConfiguration = syncConfiguration;
        }

        // GET: SyncDepartment
        public async Task<IActionResult> Index()
        {
            return View(await GetDatas().ToListAsync());
        }

        // GET: SyncDepartment/Details/5
        public async Task<IActionResult> Details(Guid? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var syncDepartment = await GetDatas()
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
        public async Task<IActionResult> Create([Bind("SynchronizationID,Name")] SyncDepartment syncDepartment)
        {
            if (string.IsNullOrEmpty(syncDepartment.SynchronizationID)) ModelState.AddModelError("SynchronizationID", "SynchronizationID cannot be empty");

            if (ModelState.IsValid)
            {
                using (var transaction = _context.Database.BeginTransaction())
                {
                    try
                    {
                        syncDepartment.ID = Guid.NewGuid();
                        CustomSyncEngine customSyncEngine = new CustomSyncEngine(_context, syncConfiguration);
                        customSyncEngine.HookPreInsertOrUpdateDatabaseTimeStamp(syncDepartment, transaction, syncDepartment.SynchronizationID, null);
                        _context.Add(syncDepartment);
                        await _context.SaveChangesAsync();
                        transaction.Commit();
                    }
                    catch (Exception)
                    {
                        transaction.Rollback();
                        throw;
                    }                    
                }
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

            var syncDepartment = await GetDatas().FirstOrDefaultAsync(m => m.ID == id);
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
        public async Task<IActionResult> Edit(Guid id, [Bind("ID,SynchronizationID,Name")] SyncDepartment syncDepartment)
        {
            if (id != syncDepartment.ID)
            {
                return NotFound();
            }

            if (string.IsNullOrEmpty(syncDepartment.SynchronizationID)) ModelState.AddModelError("SynchronizationID", "SynchronizationID cannot be empty");

            if (ModelState.IsValid)
            {
                using (var transaction = _context.Database.BeginTransaction())
                {
                    try
                    {
                        CustomSyncEngine customSyncEngine = new CustomSyncEngine(_context, syncConfiguration);
                        customSyncEngine.HookPreInsertOrUpdateDatabaseTimeStamp(syncDepartment, transaction, syncDepartment.SynchronizationID, null);
                        _context.Update(syncDepartment);
                        await _context.SaveChangesAsync();
                        transaction.Commit();
                    }
                    catch (Exception)
                    {
                        transaction.Rollback();
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

            var syncDepartment = await GetDatas()
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
            var syncEmployeeController = new SyncEmployeeController(_context, syncConfiguration);
            var dependentEmployee = await syncEmployeeController.GetDatas().Where(w => w.DepartmentID == id).FirstOrDefaultAsync();
            if (dependentEmployee != null) throw new Exception($"The data is already used by Employee Name: {dependentEmployee.Name}");

            var syncDepartment = await GetDatas().FirstAsync(m => m.ID == id);

            if (string.IsNullOrEmpty(syncDepartment.SynchronizationID)) throw new Exception("SynchronizationID cannot be empty");

            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    CustomSyncEngine customSyncEngine = new CustomSyncEngine(_context, syncConfiguration);
                    customSyncEngine.HookPreDeleteDatabaseTimeStamp(syncDepartment, transaction, syncDepartment.SynchronizationID, null);
                    _context.Update(syncDepartment);
                    //_context.Departments.Remove(syncDepartment);
                    await _context.SaveChangesAsync();
                    transaction.Commit();
                }
                catch (Exception)
                {
                    transaction.Rollback();
                    throw;
                }
            }
            return RedirectToAction(nameof(Index));
        }

        public IQueryable<SyncDepartment> GetDatas()
        {
            return _context.Departments.Where(w => !w.Deleted);
        }
    }
}
