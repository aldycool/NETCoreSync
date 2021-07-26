using Microsoft.Extensions.DependencyInjection;
using Microsoft.AspNetCore.Builder;

// NOTE: I don't know why all of these IS NOT NEEDED...
// The Main Project just do a reference to this class library, and IT JUST WORKS! No hooks whatsoever...
// FYI, For Reference, if sh*t happens someday, this is the main article: 
// https://stackoverflow.com/questions/64158102/register-web-api-controller-from-class-library
// And these are supporting articles:
// https://docs.microsoft.com/en-us/aspnet/core/fundamentals/target-aspnetcore?view=aspnetcore-5.0&tabs=visual-studio
// https://github.com/dotnet/AspNetCore.Docs/issues/22048

public static class IServiceCollectionExtensions
{
    public static IServiceCollection AddNETCoreSyncServer(this IServiceCollection services)
    {
        services.AddControllers().AddApplicationPart(typeof(IServiceCollectionExtensions).Assembly);
        return services;
    }
}

public static class IApplicationBuilderExtensions
{
    public static IApplicationBuilder AddNETCoreSyncServer(this IApplicationBuilder applicationBuilder)
    {
        applicationBuilder.UseRouting();
        applicationBuilder.UseEndpoints(endpoints => { endpoints.MapControllers(); });
        return applicationBuilder;
    }
}