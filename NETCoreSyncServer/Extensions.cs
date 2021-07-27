using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.AspNetCore.Builder;
using NETCoreSyncServer;

// NOTE: I don't know why all of these IS NOT NEEDED...
// The Main Project just do a reference to this class library, and IT JUST WORKS! No hooks whatsoever...
// FYI, For Reference, if sh*t happens someday, this is the main article: 
// https://stackoverflow.com/questions/64158102/register-web-api-controller-from-class-library
// And these are supporting articles:
// https://docs.microsoft.com/en-us/aspnet/core/fundamentals/target-aspnetcore?view=aspnetcore-5.0&tabs=visual-studio
// https://github.com/dotnet/AspNetCore.Docs/issues/22048

namespace Microsoft.Extensions.DependencyInjection
{
    public static class NETCoreSyncServerServiceCollectionExtensions
    {
        public static IServiceCollection AddNETCoreSyncServer(this IServiceCollection services)
        {
            Assembly? assembly = Assembly.GetEntryAssembly();
            if (assembly == null) throw new NETCoreSyncServerException("Unexpected null return value from Assembly.GetEntryAssembly(), are you calling from unmanaged code?");
            return AddNETCoreSyncServer(services, new [] { (Assembly)assembly });
        }

        public static IServiceCollection AddNETCoreSyncServer(this IServiceCollection services, Assembly[] assemblies)
        {
            Type[] types = assemblies.SelectMany(sm => sm.GetTypes()).Where(w => Attribute.IsDefined(w, typeof(SyncTableAttribute))).ToArray();
            return AddNETCoreSyncServer(services, types);
        }

        public static IServiceCollection AddNETCoreSyncServer(this IServiceCollection services, Type[] types)
        {
            if (types.Length == 0) throw new NETCoreSyncServerException("Cannot find classes annotated with SyncTableAttribute");
            Type[] invalidTypes = types.Where(w => !Attribute.IsDefined(w, typeof(SyncTableAttribute))).ToArray();
            if (invalidTypes.Length > 0) throw new NETCoreSyncServerException($"These classes are invalid: {string.Join(", ", invalidTypes.Select(s => s.FullName).ToArray())}. To continue, they should be annotated with SyncTableAttribute");
            SyncService syncService = new SyncService();
            syncService.Types = types.OrderBy(o => o.GetCustomAttribute<SyncTableAttribute>()!.Order).ToList();
            for (int i = 0; i < syncService.Types.Count; i++)
            {
                Type type = types[i];
                TableInfo tableInfo = new TableInfo();
                syncService.TableInfos[type] = tableInfo;
                tableInfo.SyncTable = type.GetCustomAttribute<SyncTableAttribute>()!;
                if (string.IsNullOrEmpty(tableInfo.SyncTable.ClientClassName)) tableInfo.SyncTable.ClientClassName = type.Name;

                PropertyInfo? propertyInfoID = type.GetProperties().Where(w => w.GetCustomAttribute<SyncPropertyAttribute>() != null && w.GetCustomAttribute<SyncPropertyAttribute>()!.PropertyIndicator == SyncPropertyAttribute.PropertyIndicatorEnum.ID).FirstOrDefault();
                if (propertyInfoID == null) throw new NETCoreSyncServerMissingSyncPropertyAttributeException(SyncPropertyAttribute.PropertyIndicatorEnum.ID, type);
                tableInfo.PropertyInfoID = propertyInfoID;

                PropertyInfo? propertyInfoSyncID = type.GetProperties().Where(w => w.GetCustomAttribute<SyncPropertyAttribute>() != null && w.GetCustomAttribute<SyncPropertyAttribute>()!.PropertyIndicator == SyncPropertyAttribute.PropertyIndicatorEnum.SyncID).FirstOrDefault();
                if (propertyInfoSyncID == null) throw new NETCoreSyncServerMissingSyncPropertyAttributeException(SyncPropertyAttribute.PropertyIndicatorEnum.SyncID, type);
                if (propertyInfoSyncID.PropertyType != typeof(string)) throw new NETCoreSyncServerMismatchPropertyTypeException(propertyInfoSyncID, typeof(string), type);
                tableInfo.PropertyInfoSyncID = propertyInfoSyncID;

                PropertyInfo? propertyInfoKnowledgeID = type.GetProperties().Where(w => w.GetCustomAttribute<SyncPropertyAttribute>() != null && w.GetCustomAttribute<SyncPropertyAttribute>()!.PropertyIndicator == SyncPropertyAttribute.PropertyIndicatorEnum.KnowledgeID).FirstOrDefault();
                if (propertyInfoKnowledgeID == null) throw new NETCoreSyncServerMissingSyncPropertyAttributeException(SyncPropertyAttribute.PropertyIndicatorEnum.KnowledgeID, type);
                if (propertyInfoKnowledgeID.PropertyType != typeof(string)) throw new NETCoreSyncServerMismatchPropertyTypeException(propertyInfoKnowledgeID, typeof(string), type);
                tableInfo.PropertyInfoKnowledgeID = propertyInfoKnowledgeID;

                PropertyInfo? propertyInfoTimeStamp = type.GetProperties().Where(w => w.GetCustomAttribute<SyncPropertyAttribute>() != null && w.GetCustomAttribute<SyncPropertyAttribute>()!.PropertyIndicator == SyncPropertyAttribute.PropertyIndicatorEnum.TimeStamp).FirstOrDefault();
                if (propertyInfoTimeStamp == null) throw new NETCoreSyncServerMissingSyncPropertyAttributeException(SyncPropertyAttribute.PropertyIndicatorEnum.TimeStamp, type);
                if (propertyInfoTimeStamp.PropertyType != typeof(long)) throw new NETCoreSyncServerMismatchPropertyTypeException(propertyInfoTimeStamp, typeof(long), type);
                tableInfo.PropertyInfoTimeStamp = propertyInfoTimeStamp;

                PropertyInfo? propertyInfoDeleted = type.GetProperties().Where(w => w.GetCustomAttribute<SyncPropertyAttribute>() != null && w.GetCustomAttribute<SyncPropertyAttribute>()!.PropertyIndicator == SyncPropertyAttribute.PropertyIndicatorEnum.Deleted).FirstOrDefault();
                if (propertyInfoDeleted == null) throw new NETCoreSyncServerMissingSyncPropertyAttributeException(SyncPropertyAttribute.PropertyIndicatorEnum.Deleted, type);
                if (propertyInfoDeleted.PropertyType != typeof(bool)) throw new NETCoreSyncServerMismatchPropertyTypeException(propertyInfoDeleted, typeof(bool), type);
                tableInfo.PropertyInfoDeleted = propertyInfoDeleted;
            }
            services.AddSingleton(syncService);
            return services;
        }
    }

    public static class NETCoreSyncServerApplicationBuilderExtensions
    {
        public static IApplicationBuilder UseNETCoreSyncServer(this IApplicationBuilder app, string path = "/netcoresyncserver")
        {
            return app.UseMiddleware<NETCoreSyncServer.SyncMiddleware>(path);
        }
    }
}
