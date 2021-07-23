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
    public class SyncAreaController : Controller
    {
        private readonly DatabaseContext _context;
        private SyncConfiguration syncConfiguration;

        public SyncAreaController(DatabaseContext context, SyncConfiguration syncConfiguration)
        {
            _context = context;
            this.syncConfiguration = syncConfiguration;
        }

        // GET: SyncArea
        public async Task<IActionResult> Index()
        {
            return View(await GetDatas().ToListAsync());
        }

        // GET: SyncArea/Details/5
        public async Task<IActionResult> Details(Guid? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var SyncArea = await GetDatas()
                .FirstOrDefaultAsync(m => m.ID == id);
            if (SyncArea == null)
            {
                return NotFound();
            }

            return View(SyncArea);
        }

        // GET: SyncArea/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: SyncArea/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("SynchronizationID,City,District")] SyncArea SyncArea)
        {
            if (string.IsNullOrEmpty(SyncArea.SynchronizationID)) ModelState.AddModelError("SynchronizationID", "SynchronizationID cannot be empty");

            if (ModelState.IsValid)
            {
                using (var transaction = _context.Database.BeginTransaction())
                {
                    try
                    {
                        SyncArea.ID = Guid.NewGuid();
                        CustomSyncEngine customSyncEngine = new CustomSyncEngine(_context, syncConfiguration);
                        customSyncEngine.HookPreInsertOrUpdateDatabaseTimeStamp(SyncArea, transaction, SyncArea.SynchronizationID, null);
                        _context.Add(SyncArea);
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
            return View(SyncArea);
        }

        // GET: SyncArea/Edit/5
        public async Task<IActionResult> Edit(Guid? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var SyncArea = await GetDatas().FirstOrDefaultAsync(m => m.ID == id);
            if (SyncArea == null)
            {
                return NotFound();
            }
            return View(SyncArea);
        }

        // POST: SyncArea/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(Guid id, [Bind("ID,SynchronizationID,City,District")] SyncArea SyncArea)
        {
            if (id != SyncArea.ID)
            {
                return NotFound();
            }

            if (string.IsNullOrEmpty(SyncArea.SynchronizationID)) ModelState.AddModelError("SynchronizationID", "SynchronizationID cannot be empty");

            if (ModelState.IsValid)
            {
                using (var transaction = _context.Database.BeginTransaction())
                {
                    try
                    {
                        CustomSyncEngine customSyncEngine = new CustomSyncEngine(_context, syncConfiguration);
                        customSyncEngine.HookPreInsertOrUpdateDatabaseTimeStamp(SyncArea, transaction, SyncArea.SynchronizationID, null);
                        _context.Update(SyncArea);
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
            return View(SyncArea);
        }

        // GET: SyncArea/Delete/5
        public async Task<IActionResult> Delete(Guid? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var SyncArea = await GetDatas()
                .FirstOrDefaultAsync(m => m.ID == id);
            if (SyncArea == null)
            {
                return NotFound();
            }

            return View(SyncArea);
        }

        // POST: SyncArea/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(Guid id)
        {
            var syncPersonController = new SyncPersonController(_context, syncConfiguration);
            var dependentPerson = await syncPersonController.GetDatas().Where(w => w.VaccinationAreaID == id).FirstOrDefaultAsync();
            if (dependentPerson != null) throw new Exception($"The data is already used by Person Name: {dependentPerson.Name}");

            var SyncArea = await GetDatas().FirstAsync(m => m.ID == id);

            if (string.IsNullOrEmpty(SyncArea.SynchronizationID)) throw new Exception("SynchronizationID cannot be empty");

            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    CustomSyncEngine customSyncEngine = new CustomSyncEngine(_context, syncConfiguration);
                    customSyncEngine.HookPreDeleteDatabaseTimeStamp(SyncArea, transaction, SyncArea.SynchronizationID, null);
                    _context.Update(SyncArea);
                    //_context.Areas.Remove(SyncArea);
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

        public IQueryable<SyncArea> GetDatas()
        {
            return _context.Areas.Where(w => !w.Deleted);
        }
    }
}
