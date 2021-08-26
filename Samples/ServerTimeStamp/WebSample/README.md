# WebSample

This is the server-side .NET 5.0 ASP .NET Core example project for the Flutter version of [NETCoreSync](https://github.com/aldycool/NETCoreSync). This server-side example works in conjunction with its client-side example [here](https://github.com/aldycool/NETCoreSync/tree/master/Samples/ServerTimeStamp/clientsample). Read more about the Flutter version of NETCoreSync in the `netcoresync_moor`'s [README](https://github.com/aldycool/NETCoreSync/blob/master/netcoresync_moor/README.md).

## Getting Started

- Ensure the [Microsoft .NET 5.0 SDK](https://dotnet.microsoft.com/download) is installed.
- This example uses the [PostgreSQL](https://www.postgresql.org/download/) database. Ensure that it is installed and its service is running correctly.
- Clone this project to your local machine: `git clone https://github.com/aldycool/NETCoreSync.git`.
- This example uses the Entity Framework Core to communicate with the PostgreSQL. Navigate to the `NETCoreSync/Samples/ServerTimeStamp/WebSample` folder, and the connection string for the PostgreSQL is hardcoded inside the `Startup.cs`'s `ConfigureServices()` method like the following:
  ```csharp
  services.AddDbContext<DatabaseContext>(options =>
  {
      options.UseNpgsql("Host=localhost;Database=NETCoreSyncServerTimeStampDB;Username=NETCoreSyncServerTimeStamp_User;Password=NETCoreSyncServerTimeStamp_Password");
  });
  ```
  You may change the hardcoded connection string to your PostgreSQL database, or, if you want to follow the hardcoded settings, create a PostgreSQL database called `NETCoreSyncServerTimeStampDB`, and create a PostgreSQL Login Role called `NETCoreSyncServerTimeStamp_User` and its password is set to `NETCoreSyncServerTimeStamp_Password`. Make sure that the Login Role has Login privileges and allowed to access the database. Please consult the PostgreSQL documentation on how to configure these requirements.
- Navigate to the `WebSample` folder and run the app:
  ```sh
  cd NETCoreSync/Samples/ServerTimeStamp/WebSample
  dotnet restore
  dotnet run
  ```
- After the server has launched, you can use web browser to view its UI interface in the listening URL from the `dotnet run` output (such as: https://localhost:5001).
- At this point, the server is ready to receive client synchronization requests. Now you can try its client-side synchronization in the client example [here](https://github.com/aldycool/NETCoreSync/tree/master/Samples/ServerTimeStamp/clientsample).
> For more details on the client-side and server-side configuration, read the Flutter version of NETCoreSync in the `netcoresync_moor`'s [README](https://github.com/aldycool/NETCoreSync/blob/master/netcoresync_moor/README.md).

