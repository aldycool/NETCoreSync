# NETCoreSync

NETCoreSync is a database synchronization framework where each client's local offline database (on each client's multiple devices) can be synchronized on-demand via network into a single centralized database hosted on a server. Data which are stored locally within each device of a single client can all be synchronized after each device have successfully performed the synchronization operation.

This framework has two components that needs to be implemented in each of your client and server projects, and this framework has two versions that is determined by how you've built your client projects.

## Flutter Version

[![build](https://github.com/aldycool/NETCoreSync/actions/workflows/netcoresync_moor_build.yml/badge.svg?event=push)](https://github.com/aldycool/NETCoreSync/actions/workflows/netcoresync_moor_build.yml?query=event%3Apush) [![codecov](https://codecov.io/gh/aldycool/NETCoreSync/branch/master/graph/badge.svg?token=S2GTBOB7XB)](https://codecov.io/gh/aldycool/NETCoreSync)

If the client is built using **[Flutter](https://flutter.dev/)**, use the Flutter version of NETCoreSync. This version provides `netcoresync_moor` package for the client side, and the `NETCorSyncServer` package for the server side. The client's `netcoresync_moor` package is built on top of Flutter's [Moor](https://github.com/simolus3/moor) library, and the server's `NETCoreSyncServer` package is built using Microsoft .NET 5.0 ASP .NET Core Middleware.

### Repository Folders

The repository folders are
- [netcoresync_moor](netcoresync_moor): Client-side Flutter package
- [netcoresync_moor_generator](netcoresync_moor_generator): Client-side Flutter code generator
- [NETCoreSyncServer]: Server-side .NET 5.0 Middleware package
- [Samples/ServerTimeStamp/clientsample](Samples/ServerTimeStamp/clientsample): Client-side Flutter project example
- [Samples/ServerTimeStamp/WebSample](Samples/ServerTimeStamp/WebSample): Server-side .NET 5.0 ASP Core project example

## Xamarin Version

| NETCoreSync |
| :---: |
| [![Nuget](https://img.shields.io/nuget/v/NETCoreSync)](https://www.nuget.org/packages/NETCoreSync) |

If the client is built using **[Xamarin](https://dotnet.microsoft.com/apps/xamarin)**, use the Xamarin version of NETCoreSync. This version provides `NETCoreSync` package for both client and server side. The `NETCoreSync` package is built using Microsoft .NET Standard 2.0.

### Repository Folders

The repository folders are
- [NETCoreSync](NETCoreSync): Client-side and Server-side .NET Standard 2.0 package
- [Samples/GlobalTimeStamp](Samples/GlobalTimeStamp): Client-side Xamarin and Server-Side .NET Core 3.1 project example for the *GlobalTimeStamp* synchronization approach
- [Samples/DatabaseTimeStamp](Samples/DatabaseTimeStamp): Client-side Xamarin and Server-Side .NET Core 3.1 project example for the *DatabaseTimeStamp* synchronization approach

## Characteristics

The following lists the characteristics of this framework (applies for both Flutter and Xamarin versions):

- It's database-agnostic, means, it can be used with any kind of database technology, as long as you can _direct_ it (technically by subclassing its _engine_) to the correct implementation on how to do _this-and-that_ in your specific database.
  - For **Flutter** version, the client side framework is built on top of `Moor` and will use any database that is configured with it, so therefore the client side is not database-agnostic, while the server side framework is still database-agnostic.
  - For **Xamarin** version, the client and server side framework are fully database-agnostic.
- Not like other synchronization frameworks, NETCoreSync doesn't use _tracking tables_ and _tombstone tables_ (I hate them, because most likely they will double up your row count and take storage space), but, you need to add some additional columns to your tables.
- Not like other synchronization frameworks, NETCoreSync doesn't use _triggers_ (I also hate triggers, because not all database technology support triggers, and it always feels like I have some unused left-over triggers somewhere in my tables...), but, you have to modify your application's insert/update/delete data functions.
  - For **Flutter** version, you will have to change the standard calls to `Moor`'s insert/update/delete methods in the client project into this framework ones.
  - For **Xamarin** version, you have to call some hook methods in the client project before persisting the data into the table.
- This framework requires that all of your data in your database to have a unique primary key.
  - For **Flutter** version, your `Moor` table's primary key is expected to be a `TextColumn` type and should contain unique Uuid values (probably generated from the `uuid` package).
  - For **Xamarin** version, the type of your table's primary key is not enforced to a specific data type, but commonly it should use `Guid` values (and therefore the table's column type is usually a `string`) to ensure its uniqueness.
- Your database design must use the **Soft Delete** approach when deleting record from tables, means that for any delete operation, the data is not physically deleted from the table, but only flag the record with a boolean column that indicates whether this record is already deleted or not.

## Version Comparison

The **Flutter** version is actually newer than the **Xamarin** version (the Xamarin version was the initial framework when NETCoreSync was built). Flutter has become one of the hottest framework nowadays to easily build a beautiful, performant, single code-base application that works on **ALL** platforms (android, ios, web, windows, macos, linux), so naturally, NETCoreSync is adapted to work with Flutter. There are several advantages of the Flutter version:

- The Flutter version has a feature called "linkedSyncId" where a single user account can be linked with several different user accounts to allow them to share data among themselves (they can modify each other data), and those changes can still be synchronized back to each user account devices.
- The client-side component for Flutter version (which is built on top of Moor library) has much less integration work compared to the Xamarin version, so it requires only minimal modification on the client project. Of course this makes the client project depended on the Moor library, but by doing this, the integration is very minimal, and Moor itself is considered as one of the leading sqlite database framework for Flutter.
- The server-side component for Flutter version has been rewritten using the latest .NET 5.0 (as per writing), and also rewritten to use WebSockets to allow efficient network communication, and implemented as an ASP .NET Core Middleware component to also minimize the integration work.

Moving forward, the Flutter version will be the primary development to have periodical updates and improvements, while the Xamarin version will remain as a backward-compatible solution only.

To read more about the **Flutter** version of NETCoreSync, visit the `netcoresync_moor` [here](netcoresync_moor/README.md).

To read more about the **Xamarin** version of NETCoreSync, visit the `NETCoreSync` [here](NETCoreSync/README.md).
