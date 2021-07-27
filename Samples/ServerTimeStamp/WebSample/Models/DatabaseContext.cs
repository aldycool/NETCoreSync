using System.Linq;
using Microsoft.EntityFrameworkCore;

namespace WebSample.Models
{
    public class DatabaseContext : DbContext
    {
        public DatabaseContext(DbContextOptions<DatabaseContext> options) : base(options)
        {
        }

        public DbSet<SyncArea> Areas { get; set; } = null!;
        public DbSet<SyncPerson> Persons { get; set; } = null!;
        public DbSet<SyncCustomObject> CustomObjects { get; set; } = null!;

        public DbSet<DbQueryTimeStampResult> DbQueryTimeStampResults { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<DbQueryTimeStampResult>().HasNoKey().ToView(null);
        }

        public long GetNextTimeStamp()
        {
            DbQueryTimeStampResult result = DbQueryTimeStampResults.FromSqlRaw("SELECT CAST((EXTRACT(EPOCH FROM NOW() AT TIME ZONE 'UTC') * 1000) AS bigint) AS timestamp").First();
            return result.timestamp;
        }
    }

    [Keyless]
    public class DbQueryTimeStampResult
    {
        public long timestamp { get; set; }
    }
}
