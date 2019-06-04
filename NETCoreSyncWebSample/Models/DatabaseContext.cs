using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using NETCoreSyncWebSample.Models;

namespace NETCoreSyncWebSample.Models
{
    public class DatabaseContext : DbContext
    {
        public DatabaseContext(DbContextOptions<DatabaseContext> options) : base(options)
        {
        }

        public DbSet<SyncDepartment> Departments { get; set; }
        public DbSet<SyncDepartment> Employees { get; set; }
        public DbSet<NETCoreSyncWebSample.Models.SyncEmployee> SyncEmployee { get; set; }
    }
}
