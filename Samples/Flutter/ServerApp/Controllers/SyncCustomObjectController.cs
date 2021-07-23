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
    public class SyncCustomObjectController : Controller
    {
        private readonly DatabaseContext _context;
        private readonly SyncConfiguration syncConfiguration;

        public SyncCustomObjectController(DatabaseContext context, SyncConfiguration syncConfiguration)
        {
            _context = context;
            this.syncConfiguration = syncConfiguration;
        }

        // GET: SyncCustomObject
        public async Task<IActionResult> Index()
        {
            var databaseContext = GetDatas();
            return View(await databaseContext.ToListAsync());
        }

        // GET: SyncCustomObject/Details/5
        public async Task<IActionResult> Details(Guid? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var SyncCustomObject = await GetDatas()
                .FirstOrDefaultAsync(m => m.ID == id);
            if (SyncCustomObject == null)
            {
                return NotFound();
            }

            return View(SyncCustomObject);
        }

        // GET: SyncCustomObject/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: SyncCustomObject/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("SynchronizationID,FieldString,FieldStringNullable,FieldInt,FieldIntNullable,FieldBoolean,FieldBooleanNullable,FieldDateTime,FieldDateTimeNullable")] SyncCustomObject SyncCustomObject)
        {
            if (string.IsNullOrEmpty(SyncCustomObject.SynchronizationID)) ModelState.AddModelError("SynchronizationID", "SynchronizationID cannot be empty");

            if (ModelState.IsValid)
            {
                using (var transaction = _context.Database.BeginTransaction())
                {
                    try
                    {
                        SyncCustomObject.ID = Guid.NewGuid();
                        CustomSyncEngine customSyncEngine = new CustomSyncEngine(_context, syncConfiguration);
                        customSyncEngine.HookPreInsertOrUpdateDatabaseTimeStamp(SyncCustomObject, transaction, SyncCustomObject.SynchronizationID, null);
                        _context.Add(SyncCustomObject);
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
            return View(SyncCustomObject);
        }

        // GET: SyncCustomObject/Edit/5
        public async Task<IActionResult> Edit(Guid? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var SyncCustomObject = await GetDatas().FirstOrDefaultAsync(m => m.ID == id);
            if (SyncCustomObject == null)
            {
                return NotFound();
            }
            return View(SyncCustomObject);
        }

        // POST: SyncCustomObject/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(Guid id, [Bind("ID,SynchronizationID,FieldString,FieldStringNullable,FieldInt,FieldIntNullable,FieldBoolean,FieldBooleanNullable,FieldDateTime,FieldDateTimeNullable")] SyncCustomObject SyncCustomObject)
        {
            if (id != SyncCustomObject.ID)
            {
                return NotFound();
            }

            if (string.IsNullOrEmpty(SyncCustomObject.SynchronizationID)) ModelState.AddModelError("SynchronizationID", "SynchronizationID cannot be empty");

            if (ModelState.IsValid)
            {
                using (var transaction = _context.Database.BeginTransaction())
                {
                    try
                    {
                        CustomSyncEngine customSyncEngine = new CustomSyncEngine(_context, syncConfiguration);
                        customSyncEngine.HookPreInsertOrUpdateDatabaseTimeStamp(SyncCustomObject, transaction, SyncCustomObject.SynchronizationID, null);
                        _context.Update(SyncCustomObject);
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
            return View(SyncCustomObject);
        }

        // GET: SyncCustomObject/Delete/5
        public async Task<IActionResult> Delete(Guid? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var SyncCustomObject = await GetDatas()
                .FirstOrDefaultAsync(m => m.ID == id);
            if (SyncCustomObject == null)
            {
                return NotFound();
            }

            return View(SyncCustomObject);
        }

        // POST: SyncCustomObject/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(Guid id)
        {
            var SyncCustomObject = await GetDatas().FirstAsync(m => m.ID == id);

            if (string.IsNullOrEmpty(SyncCustomObject.SynchronizationID)) throw new Exception("SynchronizationID cannot be empty");

            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    CustomSyncEngine customSyncEngine = new CustomSyncEngine(_context, syncConfiguration);
                    customSyncEngine.HookPreDeleteDatabaseTimeStamp(SyncCustomObject, transaction, SyncCustomObject.SynchronizationID, null);
                    _context.Update(SyncCustomObject);
                    //_context.SyncCustomObject.Remove(SyncCustomObject);
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

        public IQueryable<SyncCustomObject> GetDatas()
        {
            return _context.CustomObjects.Where(w => !w.Deleted);
        }
    }
}
