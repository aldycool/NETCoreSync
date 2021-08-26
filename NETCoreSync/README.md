# NETCoreSync (Xamarin Version)

| NuGet |
| :---: |
| ![Nuget](https://img.shields.io/nuget/v/NETCoreSync?style=plastic) |

This is the **Xamarin** version of NETCoreSync - a database synchronization framework where each client's local offline database (on each client's multiple devices) can be synchronized on-demand via network into a single centralized database hosted on a server. The NETCoreSync for Xamarin version is built using Microsoft .NET Standard 2.0, and needs to be implemented on both of your client-side and server-side projects.

> To learn about NETCoreSync general requirements (characteristics such as database-agnostic, unique primary keys, soft-delete, etc.), visit the short-explanation on the root README [here](../README.md).

> If you're using [Flutter](https://flutter.dev) (which you should be :grin:), visit the Flutter version of NETCoreSync [here](../netcoresync_moor/README.md).

## NuGet

Add the [NETCoreSync NuGet Package](https://www.nuget.org/packages/NETCoreSync) into your ASP .NET Core project (for the backend server), and also add the package into your client project (if you are using Xamarin Forms, add the package into the core project). NETCoreSync is designed with the most minimum dependency to avoid conflicts with existing packages.

## Synchronization Approaches

The NETCoreSync for Xamarin version supports two kinds of synchronization approach: **GlobalTimeStamp** and **DatabaseTimeStamp**, where both of them will be explained below.

### GlobalTimeStamp

Data synchronization between server and clients will use the world clock (the system's Date Time) when comparing a data that exist in both source and destination, to determine whether the source data is newer or not than the destination data.

**Pros:**

* Simpler to implement (than the other one)

**Cons:**

* Relies heavily on the correctness of each system's Date Time (world clock) that will participate in the synchronization process. On servers this may be not an issue (servers usually always have correct Date Time), but in mobile clients, if for some reason your user change the phone's date to an earlier time after synchronization, the next synchronization will have conflicts in it. So this approach may be suitable if only performed between servers.

### DatabaseTimeStamp

Data synchronization between server and clients will use their own _internal time stamp_ (represented in `long` value) when comparing a data that exist in both source and destination. These so-called _internal time stamp_ will correctly determine whether the source data is newer or not than the destination data, regardless of what the system's world clock is.

**Pros:**

* Eliminates the **GlobalTimeStamp** weakness, therefore more suitable to use in mobile clients.

**Cons:**

* Harder to implement than the other one, and, will require one additional table (or some form of records persistence) to keep the _time stamp knowledge_.

## Working Examples

Since there are two kinds of synchronization approach, there's also two samples, one for the **GlobalTimeStamp**, and the other one for the **DatabaseTimeStamp**.

### [**GlobalTimeStamp Sample**](https://github.com/aldycool/NETCoreSync/tree/master/Samples/GlobalTimeStamp)

* There's the [Server](https://github.com/aldycool/NETCoreSync/tree/master/Samples/GlobalTimeStamp/WebSample) which is created using ASP .NET Core 2.1, and also the client sample created using Xamarin Forms in three projects: [Core](https://github.com/aldycool/NETCoreSync/tree/master/Samples/GlobalTimeStamp/MobileSample), [Android](https://github.com/aldycool/NETCoreSync/tree/master/Samples/GlobalTimeStamp/MobileSample.Android), and [iOS](https://github.com/aldycool/NETCoreSync/tree/master/Samples/GlobalTimeStamp/MobileSample.iOS).
* The server side is using Entity Framework Core + [SQLite](https://www.sqlite.org). The client side also uses Entity Framework Core + [SQLite](https://www.sqlite.org).

### [**DatabaseTimeStamp Sample**](https://github.com/aldycool/NETCoreSync/tree/master/Samples/DatabaseTimeStamp)

* There's the [Server](https://github.com/aldycool/NETCoreSync/tree/master/Samples/DatabaseTimeStamp/WebSample) which is created using ASP .NET Core 2.1, and also the client sample created using Xamarin Forms in three projects: [Core](https://github.com/aldycool/NETCoreSync/tree/master/Samples/DatabaseTimeStamp/MobileSample), [Android](https://github.com/aldycool/NETCoreSync/tree/master/Samples/DatabaseTimeStamp/MobileSample.Android), and [iOS](https://github.com/aldycool/NETCoreSync/tree/master/Samples/DatabaseTimeStamp/MobileSample.iOS).
* The server side is using Entity Framework Core + [PostgreSQL](https://www.postgresql.org). The client side is using [Realm](https://realm.io).

These samples are demonstrating the proper use of this library. Both server and client have the necessary tables to be synchronized with each other, and both also have proper CRUD functions for testing inserts, updates, and deletes, and then synchronize them to see the results. The [SQLite](https://www.sqlite.org) database in **GlobalTimeStamp** was chosen on both components to allow quick test of these samples while keeping the dependency to minimum. While the [PostgreSQL](https://www.postgresql.org) and [Realm](https://realm.io) in **DatabaseTimeStamp** shows an advance usage of the library where it involves the usage of database transactions, and very close to a real-world situation. To run the sample, set your Visual Studio startup projects to start the Web project and Mobile project (either Android or iOS) simultaneously.

## Dive Into the Details

Still interested? :)

For **GlobalTimeStamp** approach:

* [How It Works](docs/global-timestamp-how-it-works.md)
* [Implementation Instruction](docs/global-timestamp-implementation-instruction.md)

For **DatabaseTimeStamp** approach:

* [How It Works](docs/database-timestamp-how-it-works.md)
* [Implementation Instruction](docs/database-timestamp-implementation-instruction.md)
