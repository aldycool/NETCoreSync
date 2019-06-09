using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.IO;
using Microsoft.EntityFrameworkCore;
using Xamarin.Forms;

namespace NETCoreSyncMobileSample.Models
{
    public class DatabaseContext : DbContext
    {
        public DatabaseContext()
        {
            Database.EnsureCreated();
        }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            string databaseFileName = nameof(NETCoreSyncMobileSample) + ".sqlite";
            string databaseFilePath = null;
            if (Device.RuntimePlatform == "Android")
            {
                databaseFilePath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Personal), databaseFileName);
            }
            else if (Device.RuntimePlatform == "iOS")
            {
                databaseFilePath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "..", "Library", databaseFileName);
            }
            if (string.IsNullOrEmpty(databaseFilePath)) throw new NotImplementedException();

            optionsBuilder.UseSqlite($"Filename={databaseFilePath}");
        }

        public DbSet<Department> Departments { get; set; }
        public DbSet<Employee> Employees { get; set; }
    }
}
