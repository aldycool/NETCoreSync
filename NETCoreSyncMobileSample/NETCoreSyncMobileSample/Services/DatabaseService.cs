using System;
using System.Collections.Generic;
using System.Text;
using NETCoreSyncMobileSample.Models;

namespace NETCoreSyncMobileSample.Services
{
    public class DatabaseService
    {
        public DatabaseContext GetDatabaseContext()
        {
            DatabaseContext databaseContext = new DatabaseContext();
            return databaseContext;
        }
    }
}
