# NETCoreSync
***
## What is it?
It's a database-agnostic synchronization framework based on .NET Standard 2.0 to synchronize data between multiple clients and a single server, where both platforms are using technologies that compatible with .NET Standard 2.0, such as Xamarin Forms for the mobile clients and ASP .NET Core for the backend server. The main purpose of this framework is to enable multiple clients (where each client may have one or more devices) to synchronize data among their own devices against a single server that act as a repository for all of the clients data. Data which are stored locally within each device of a single client can all be synchronized after each device have successfully performed the synchronization operation.
***
## NuGet
Add the [NETCoreSync NuGet Package](https://www.nuget.org/packages/NETCoreSync) into your ASP .NET Core project (for the backend server), and also add the package into your client project (if you are using Xamarin Forms, add the package into the core project). NETCoreSync is designed with the most minimum dependency to avoid conflicts with existing packages.
***
## Why (yet) another Synchronization Framework?
Why oh why...
* It's based on .NET Standard 2.0, which is the latest technology (as per writing) on Microsoft stack.
* It's DATABASE-AGNOSTIC, means, it can be used with ANY KIND of database technology, as long as you can _direct_ it (technically by subclassing its _engine_) to the correct implementation on how to do _this-and-that_ in your specific database.
* Not like other synchronization frameworks, NETCoreSync doesn't use _tracking tables_ and _tombstone tables_ (I hate them, because most likely they will double up your row count and take storage space), BUT, you need to add some additional columns to your tables.
* Not like other synchronization frameworks, NETCoreSync doesn't use _triggers_ (I also hate triggers, because not all database technology support triggers, and it always feels like I have some unused left-over triggers somewhere in my tables...), BUT, in your application's insert/update/delete data functions, you have to call some hook methods before persisting the data into the table.
* Support two kinds of synchronization approach: **GlobalTimeStamp** and **DatabaseTimeStamp**, where both of them will be explained below.
***
## Synchronization Approaches
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
***
## The Caveats...
Here they come...
* **Soft Delete**

   Your existing database design MUST use the *Soft Delete* approach when deleting record from tables, means that the data is not physically deleted from the table, but only flag the record with a boolean column (such as IsDeleted) that indicates whether this record is already deleted or not.
   
* **Unique Primary Key**

   Your existing database tables must use Primary Keys that is unique, such as UUID / Guid, to ensure correct comparison of data during synchronization.

* **Data Representation as Objects**

   Your server and client database tables must be represented as objects in the server and client applications, known as POCO (Plain Old CLR Objects), because NETCoreSync needs to mark the object properties with some special attributes to indicate which field is the Primary Key, etc.
***
## Working Examples
Since there are two kinds of synchronization approach, there's also two samples, one for the **GlobalTimeStamp**, and the other one for the **DatabaseTimeStamp**.
### [**GlobalTimeStamp Sample**](https://github.com/aldycool/NETCoreSync/tree/master/Samples/GlobalTimeStamp)
* There's the [Server](https://github.com/aldycool/NETCoreSync/tree/master/Samples/GlobalTimeStamp/WebSample) which is created using ASP .NET Core 2.0, and also the client sample created using Xamarin Forms in three projects: [Core](https://github.com/aldycool/NETCoreSync/tree/master/Samples/GlobalTimeStamp/MobileSample), [Android](https://github.com/aldycool/NETCoreSync/tree/master/Samples/GlobalTimeStamp/MobileSample.Android), and [iOS](https://github.com/aldycool/NETCoreSync/tree/master/Samples/GlobalTimeStamp/MobileSample.iOS).
* The server side is using Entity Framework Core + [SQLite](https://www.sqlite.org). The client side also uses Entity Framework Core + [SQLite](https://www.sqlite.org).
### [**DatabaseTimeStamp Sample**](https://github.com/aldycool/NETCoreSync/tree/master/Samples/DatabaseTimeStamp)
* There's the [Server](https://github.com/aldycool/NETCoreSync/tree/master/Samples/DatabaseTimeStamp/WebSample) which is created using ASP .NET Core 2.0, and also the client sample created using Xamarin Forms in three projects: [Core](https://github.com/aldycool/NETCoreSync/tree/master/Samples/DatabaseTimeStamp/MobileSample), [Android](https://github.com/aldycool/NETCoreSync/tree/master/Samples/DatabaseTimeStamp/MobileSample.Android), and [iOS](https://github.com/aldycool/NETCoreSync/tree/master/Samples/DatabaseTimeStamp/MobileSample.iOS).
* The server side is using Entity Framework Core + [PostgreSQL](https://www.postgresql.org). The client side is using [Realm](https://realm.io).

These samples are demonstrating the proper use of this library. Both server and client have the necessary tables to be synchronized with each other, and both also have proper CRUD functions for testing inserts, updates, and deletes, and then synchronize them to see the results. The [SQLite](https://www.sqlite.org) database in **GlobalTimeStamp** was chosen on both components to allow quick test of these samples while keeping the dependency to minimum. While the [PostgreSQL](https://www.postgresql.org) and [Realm](https://realm.io) in **DatabaseTimeStamp** shows an advance usage of the library where it involves the usage of database transactions, and very close to a real-world situation. To run the sample, set your Visual Studio startup projects to start the Web project and Mobile project (either Android or iOS) simultaneously.
***
## Dive Into the Details
Still interested? :)

For **GlobalTimeStamp** approach:
* [How It Works](https://github.com/aldycool/NETCoreSync/wiki/How-It-Works-(GlobalTimeStamp))
* [Implementation Instruction](https://github.com/aldycool/NETCoreSync/wiki/Implementation-Instruction-(GlobalTimeStamp))

For **DatabaseTimeStamp** approach:
* [How It Works](https://github.com/aldycool/NETCoreSync/wiki/How-It-Works-(DatabaseTimeStamp))
* [Implementation Instruction](https://github.com/aldycool/NETCoreSync/wiki/Implementation-Instruction-(DatabaseTimeStamp))
***
## Final Words
This synchronization library is admittedly still far from being an ideal solution for perfect synchronization mechanism, considering data synchronization is VERY HARD and can have different implementations for different solutions. But still this may work if the required conditions and are met and the limitations are still accepted.


Please contact me if you have comments or suggestions. Thanks.
