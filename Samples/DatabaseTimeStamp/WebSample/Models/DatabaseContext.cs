using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using WebSample.Models;

namespace WebSample.Models
{
    public class DatabaseContext : DbContext
    {
        public DatabaseContext(DbContextOptions<DatabaseContext> options) : base(options)
        {
        }

        public DbSet<Knowledge> Knowledges { get; set; }
        public DbSet<SyncDepartment> Departments { get; set; }
        public DbSet<SyncEmployee> Employees { get; set; }

        public DbQuery<CustomSyncEngine.DbQueryTimeStampResult> DbQueryTimeStampResults { get; set; }
    }
}
