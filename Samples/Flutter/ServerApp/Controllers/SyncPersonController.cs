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
    public class SyncPersonController : Controller
    {
        private readonly DatabaseContext _context;
        private readonly SyncConfiguration syncConfiguration;

        public SyncPersonController(DatabaseContext context, SyncConfiguration syncConfiguration)
        {
            _context = context;
            this.syncConfiguration = syncConfiguration;
        }

        // GET: SyncPerson
        public async Task<IActionResult> Index()
        {
            var databaseContext = GetDatas().Include(s => s.VaccinationArea);
            return View(await databaseContext.ToListAsync());
        }

        // GET: SyncPerson/Details/5
        public async Task<IActionResult> Details(Guid? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var SyncPerson = await GetDatas()
                .Include(s => s.VaccinationArea)
                .FirstOrDefaultAsync(m => m.ID == id);
            if (SyncPerson == null)
            {
                return NotFound();
            }

            return View(SyncPerson);
        }

        // GET: SyncPerson/Create
        public IActionResult Create()
        {
            ViewData["VaccinationAreaID"] = GetSelectListArea(null);
            return View();
        }

        // POST: SyncPerson/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("SynchronizationID,Name,Birthday,Age,IsForeigner,IsVaccinated,VaccineName,VaccinationDate,VaccinePhase,VaccinationAreaID")] SyncPerson SyncPerson)
        {
            if (string.IsNullOrEmpty(SyncPerson.SynchronizationID)) ModelState.AddModelError("SynchronizationID", "SynchronizationID cannot be empty");

            if (ModelState.IsValid)
            {
                using (var transaction = _context.Database.BeginTransaction())
                {
                    try
                    {
                        SyncPerson.ID = Guid.NewGuid();
                        if (SyncPerson.VaccinationAreaID == Guid.Empty) SyncPerson.VaccinationAreaID = null;
                        CustomSyncEngine customSyncEngine = new CustomSyncEngine(_context, syncConfiguration);
                        customSyncEngine.HookPreInsertOrUpdateDatabaseTimeStamp(SyncPerson, transaction, SyncPerson.SynchronizationID, null);
                        _context.Add(SyncPerson);
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
            ViewData["VaccinationAreaID"] = GetSelectListArea(SyncPerson.VaccinationAreaID);
            return View(SyncPerson);
        }

        // GET: SyncPerson/Edit/5
        public async Task<IActionResult> Edit(Guid? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var SyncPerson = await GetDatas().FirstOrDefaultAsync(m => m.ID == id);
            if (SyncPerson == null)
            {
                return NotFound();
            }
            ViewData["VaccinationAreaID"] = GetSelectListArea(SyncPerson.VaccinationAreaID);
            return View(SyncPerson);
        }

        // POST: SyncPerson/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(Guid id, [Bind("ID,SynchronizationID,Name,Birthday,Age,IsForeigner,IsVaccinated,VaccineName,VaccinationDate,VaccinePhase,VaccinationAreaID")] SyncPerson SyncPerson)
        {
            if (id != SyncPerson.ID)
            {
                return NotFound();
            }

            if (string.IsNullOrEmpty(SyncPerson.SynchronizationID)) ModelState.AddModelError("SynchronizationID", "SynchronizationID cannot be empty");

            if (ModelState.IsValid)
            {
                using (var transaction = _context.Database.BeginTransaction())
                {
                    try
                    {
                        if (SyncPerson.VaccinationAreaID == Guid.Empty) SyncPerson.VaccinationAreaID = null;
                        CustomSyncEngine customSyncEngine = new CustomSyncEngine(_context, syncConfiguration);
                        customSyncEngine.HookPreInsertOrUpdateDatabaseTimeStamp(SyncPerson, transaction, SyncPerson.SynchronizationID, null);
                        _context.Update(SyncPerson);
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
            ViewData["VaccinationAreaID"] = GetSelectListArea(SyncPerson.VaccinationAreaID);
            return View(SyncPerson);
        }

        // GET: SyncPerson/Delete/5
        public async Task<IActionResult> Delete(Guid? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var SyncPerson = await GetDatas()
                .Include(s => s.VaccinationArea)
                .FirstOrDefaultAsync(m => m.ID == id);
            if (SyncPerson == null)
            {
                return NotFound();
            }

            return View(SyncPerson);
        }

        // POST: SyncPerson/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(Guid id)
        {
            var SyncPerson = await GetDatas().FirstAsync(m => m.ID == id);

            if (string.IsNullOrEmpty(SyncPerson.SynchronizationID)) throw new Exception("SynchronizationID cannot be empty");

            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    CustomSyncEngine customSyncEngine = new CustomSyncEngine(_context, syncConfiguration);
                    customSyncEngine.HookPreDeleteDatabaseTimeStamp(SyncPerson, transaction, SyncPerson.SynchronizationID, null);
                    _context.Update(SyncPerson);
                    //_context.SyncPerson.Remove(SyncPerson);
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

        public IQueryable<SyncPerson> GetDatas()
        {
            return _context.Persons.Where(w => !w.Deleted);
        }

        public SelectList GetSelectListArea(object selectedValue)
        {
            var syncAreaController = new SyncAreaController(_context, syncConfiguration);
            IQueryable<SyncArea> areas = syncAreaController.GetDatas();
            List<SyncArea> listArea = new List<SyncArea>();
            SyncArea emptyArea = new SyncArea() { ID = Guid.Empty, District = "[None]" };
            listArea.Add(emptyArea);
            listArea.AddRange(areas.ToList());
            if (selectedValue == null) selectedValue = emptyArea;
            SelectList selectList = new SelectList(listArea, "ID", "CityDistrict", selectedValue);
            return selectList;
        }
    }
}
