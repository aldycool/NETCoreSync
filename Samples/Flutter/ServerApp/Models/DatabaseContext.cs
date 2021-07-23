using Microsoft.EntityFrameworkCore;

namespace ServerApp.Models
{
    public class DatabaseContext : DbContext
    {
        public DatabaseContext(DbContextOptions<DatabaseContext> options) : base(options)
        {
        }

        public DbSet<Knowledge> Knowledges { get; set; }
        public DbSet<SyncArea> Areas { get; set; }
        public DbSet<SyncPerson> Persons { get; set; }
        public DbSet<SyncCustomObject> CustomObjects { get; set; }

        public DbSet<CustomSyncEngine.DbQueryTimeStampResult> DbQueryTimeStampResults { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<CustomSyncEngine.DbQueryTimeStampResult>().HasNoKey().ToView(null);
        }
    }
}
