using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using WebSample.Models;
using NETCoreSync;

namespace WebSample.Controllers
{
    public class SyncEmployeeController : Controller
    {
        private readonly DatabaseContext _context;
        private readonly SyncConfiguration syncConfiguration;

        public SyncEmployeeController(DatabaseContext context, SyncConfiguration syncConfiguration)
        {
            _context = context;
            this.syncConfiguration = syncConfiguration;
        }

        // GET: SyncEmployee
        public async Task<IActionResult> Index()
        {
            var databaseContext = GetDatas().Include(s => s.Department);
            return View(await databaseContext.ToListAsync());
        }

        // GET: SyncEmployee/Details/5
        public async Task<IActionResult> Details(Guid? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var syncEmployee = await GetDatas()
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
            ViewData["DepartmentID"] = GetSelectListDepartment(null);
            return View();
        }

        // POST: SyncEmployee/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("SynchronizationID,Name,Birthday,NumberOfComputers,SavingAmount,IsActive,DepartmentID")] SyncEmployee syncEmployee)
        {
            if (string.IsNullOrEmpty(syncEmployee.SynchronizationID)) ModelState.AddModelError("SynchronizationID", "SynchronizationID cannot be empty");

            if (ModelState.IsValid)
            {
                syncEmployee.ID = Guid.NewGuid();
                if (syncEmployee.DepartmentID == Guid.Empty) syncEmployee.DepartmentID = null;

                CustomSyncEngine customSyncEngine = new CustomSyncEngine(_context, syncConfiguration);
                customSyncEngine.HookPreInsertOrUpdateDatabaseTimeStamp(syncEmployee, null, syncEmployee.SynchronizationID, null);

                _context.Add(syncEmployee);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            ViewData["DepartmentID"] = GetSelectListDepartment(syncEmployee.DepartmentID);
            return View(syncEmployee);
        }

        // GET: SyncEmployee/Edit/5
        public async Task<IActionResult> Edit(Guid? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var syncEmployee = await GetDatas().FirstOrDefaultAsync(m => m.ID == id);
            if (syncEmployee == null)
            {
                return NotFound();
            }
            ViewData["DepartmentID"] = GetSelectListDepartment(syncEmployee.DepartmentID);
            return View(syncEmployee);
        }

        // POST: SyncEmployee/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(Guid id, [Bind("ID,SynchronizationID,Name,Birthday,NumberOfComputers,SavingAmount,IsActive,DepartmentID")] SyncEmployee syncEmployee)
        {
            if (id != syncEmployee.ID)
            {
                return NotFound();
            }

            if (string.IsNullOrEmpty(syncEmployee.SynchronizationID)) ModelState.AddModelError("SynchronizationID", "SynchronizationID cannot be empty");

            if (ModelState.IsValid)
            {
                try
                {
                    if (syncEmployee.DepartmentID == Guid.Empty) syncEmployee.DepartmentID = null;

                    CustomSyncEngine customSyncEngine = new CustomSyncEngine(_context, syncConfiguration);
                    customSyncEngine.HookPreInsertOrUpdateDatabaseTimeStamp(syncEmployee, null, syncEmployee.SynchronizationID, null);

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
            ViewData["DepartmentID"] = GetSelectListDepartment(syncEmployee.DepartmentID);
            return View(syncEmployee);
        }

        // GET: SyncEmployee/Delete/5
        public async Task<IActionResult> Delete(Guid? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var syncEmployee = await GetDatas()
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
            var syncEmployee = await GetDatas().FirstAsync(m => m.ID == id);

            if (string.IsNullOrEmpty(syncEmployee.SynchronizationID)) throw new Exception("SynchronizationID cannot be empty");

            CustomSyncEngine customSyncEngine = new CustomSyncEngine(_context, syncConfiguration);
            customSyncEngine.HookPreDeleteDatabaseTimeStamp(syncEmployee, null, syncEmployee.SynchronizationID, null);

            _context.Update(syncEmployee);
            //_context.SyncEmployee.Remove(syncEmployee);
            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        private bool SyncEmployeeExists(Guid id)
        {
            return GetDatas().Any(e => e.ID == id);
        }

        public IQueryable<SyncEmployee> GetDatas()
        {
            return _context.Employees.Where(w => !w.Deleted);
        }

        public SelectList GetSelectListDepartment(object selectedValue)
        {
            var syncDepartmentController = new SyncDepartmentController(_context, syncConfiguration);
            IQueryable<SyncDepartment> departments = syncDepartmentController.GetDatas();
            List<SyncDepartment> listDepartment = new List<SyncDepartment>();
            SyncDepartment emptyDepartment = new SyncDepartment() { ID = Guid.Empty, Name = "[None]" };
            listDepartment.Add(emptyDepartment);
            listDepartment.AddRange(departments.ToList());
            if (selectedValue == null) selectedValue = emptyDepartment;
            SelectList selectList = new SelectList(listDepartment, "ID", "Name", selectedValue);
            return selectList;
        }
    }
}
