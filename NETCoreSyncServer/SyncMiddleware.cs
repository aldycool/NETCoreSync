using System.IO;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.AspNetCore.Routing;

namespace NETCoreSyncServer
{
    internal class SyncMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly string _path;

        public SyncMiddleware(RequestDelegate next, string path)
        {
            _next = next;
            _path = path;
        }

        public async Task Invoke(HttpContext httpContext, SyncService syncService)
        {
            if (httpContext.Request.Path != _path)
            {
                await _next(httpContext);
                return;
            }

            if (!httpContext.Request.HasFormContentType)
            {
                await httpContext.Response.WriteAsync("Must invoke with HTTP POST");
                return;
            }

            IFormFile? file = httpContext.Request.Form.Files.FirstOrDefault();

            await httpContext.Response.WriteAsync("OK!");
        }

    }
}