# NETCoreSync
Database-agnostic synchronization framework based on .NET Standard 2.0 to synchronize data between multiple clients and a single server, where both platforms are using technologies that compatible with .NET Standard 2.0, such as Xamarin Forms for the mobile clients and ASP .NET Core for the backend server.

## Install Instruction
Add the [NETCoreSync NuGet Package](https://www.nuget.org/packages/NETCoreSync) into your ASP .NET Core project (for the backend server), and also add the package into your client project (if you are using Xamarin.Forms, add the package into the core project). NETCoreSync is designed with the most minimum dependency to avoid conflicts with existing packages.

## Working Sample
Please check the samples ([NETCoreSyncWebSample](https://github.com/aldycool/NETCoreSync/tree/master/NETCoreSyncWebSample) and [NETCoreSyncMobileSample](https://github.com/aldycool/NETCoreSync/tree/master/NETCoreSyncMobileSample)) in this repository, these are the working sample for both server and client, demonstrating the proper use of this library. The NETCoreSyncWebSample is the server backend component using ASP .NET Core 2.0 with Entity Framework Core + SQLite as the database. The NETCoreSyncMobileComponent is the mobile client using Xamarin.Forms with .NET Standard 2.0 and Android and iOS as its supported platforms, and also using Entity Framework Core + SQLite as its database. Both server and client have the necessary tables to be synchronized with each other, and both also have proper CRUD functions for testing inserts, updates, and deletes, and then synchronize them to see the results. The SQLite database was chosen on both components to allow quick test of these samples while keeping the dependency to minimum. To run the sample, set your Visual Studio startup projects to start the Web project and Mobile Project (either Android or iOS) simulataneously.

## Foreword
This work is heavily inspired by a greatly-written article: [Mobile Database Bi-Directional Synchronization with a REST API](https://xamarinhelp.com/mobile-database-bi-directional-synchronization-rest-api/).

NETCoreSync is a library or framework that is written in C# as a .NET Standard 2.0 assembly for data synchronization operations. The main purpose of this framework is to enable multiple clients (where each client may have one or more devices) to synchronize data among their own devices against a single server that act as a repository for all of the clients data. Data which are stored locally within each device of a single client can all be synchronized after each device have successfully performed the synchronization operation.

## How It Works
When starting the synchronization process, the client will upload the data changes that have happened since the last time it have synced successfully. The server will apply the received changes into its repository, and respond back to the client with changes that have happened in the server repository since the last time the client have synced. The received server changes will also be applied by the client in its local database at the end of the synchronization process. The same synchronization process also applied to other devices that belong to that particular client, therefore, each device for a single client can keep its data updated by executing the synchronization process.

## Requirements
The following will lists all the requirements for using this library.

* **Soft Delete**

   Your existing database design MUST use the *Soft Delete* approach when deleting record from tables, means that the data is not physically deleted from the table, but only flag the record with a boolean column (such as IsDeleted) that indicates whether this record is already deleted or not. This approach is necessary because NETCoreSync does not use additional table to record any deleted data (such as Tombstone table) like other sync frameworks.
   
* **Unique Primary Key**

   Your existing database tables must use Primary Keys that is unique, such as UUID / Guid, to ensure correct comparison of data during synchronization.

* **Real-World Date and Time on both Server and Client**

   Both of your server and mobile client application must have up-to-date and accurate Date and Time system running, because NETCoreSync will use this information to accurately detect changes and mark the data when it is updated. The server and the client must be connected to Date and Time reliable source (such as network time for server and mobile clients). 

* **Data Representation as Objects**

   Your server and client database tables must be represented as objects in the server and client applications, known as POCO (Plain Old CLR Objects), because NETCoreSync needs to mark the object properties with some special attributes to indicate which field is the Primary Key, etc. 

## Implementation Instruction   
> The best way to implement this correcty is to check the working sample above, [NETCoreSyncWebSample](https://github.com/aldycool/NETCoreSync/tree/master/NETCoreSyncWebSample) for web sample, and [NETCoreSyncMobileSample](https://github.com/aldycool/NETCoreSync/tree/master/NETCoreSyncMobileSample) for mobile sample, and also read the rest for a complete instruction.

### Decorate Data Classes with Special Attributes
For each class that needs to be synchronized, this class properties needs to be marked with some special attributes. This applies on both server data classes and client data classes. In addition, two new fields needs to be added to indicate when this data is updated (`LastUpdated`) and when it is deleted (`Deleted`). These two new fields also needs to be marked with attributes.

For example, this is the `Department` data class on client:
```
    [SyncSchema(MapToClassName = "SyncDepartment")]
    public class Department
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.Id)]
        public string Id { get; set; }

        [SyncFriendlyId]
        public string Name { get; set; }

        [ForeignKey("DepartmentId")]
        public ICollection<Employee> Employees { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.LastUpdated)]
        public long LastUpdated { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.Deleted)]
        public long? Deleted { get; set; }
    }
```
And this is the `Department` data class on server:
```
    [SyncSchema(MapToClassName = "Department")]
    public class SyncDepartment
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.Id)]
        public Guid ID { get; set; }

        public string SynchronizationID { get; set; }

        [SyncFriendlyId]
        public string Name { get; set; }

        [ForeignKey("DepartmentID")]
        public ICollection<SyncEmployee> Employees { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.LastUpdated)]
        public long LastUpdated { get; set; }

        [SyncProperty(PropertyIndicator = SyncPropertyAttribute.PropertyIndicatorEnum.Deleted)]
        public long? Deleted { get; set; }
    }
```
**SyncSchemaAttribute** needs to be applied at the class-level, with **MapToClassName** to indicate the counterpart class name. On the client, the `MapToClassName` should indicate the name of the class on the server, and vice versa. If both class name are the same, this can be omitted.

**SyncPropertyAttribute** needs to be applied at the property-level, with **PropertyIndicator** set to either **Id** for the primary key property, **LastUpdated** for the last updated information property, and **Deleted** for the delete time information property. The `LastUpdated` property must have `long` data type, and the `Deleted` property must have `long?` (nullable-long) data type.

**SyncFriendlyIdAttribute** is an optional attribute to provide friendly name for each of the data in the log results. This property needs to have `string` as its data type.

### Create and Register Configuration

The data classes that have been marked with the attributes needs to be registered during the startup process of application. On client using Xamarin.Forms, this can be done in the `App.xml.cs` in the App Constructor after `InitializeComponent()`, like this:
```
    List<Type> syncTypes = new List<Type>() { typeof(Department), typeof(Employee) };
    SyncConfiguration syncConfiguration = new SyncConfiguration(syncTypes.ToArray());
    builder.RegisterInstance(syncConfiguration);
```
The `syncConfiguration` instance is registered using IoC, and then this instance can be retrieved as needed in the view models.

On server, this can be done in the `Startup.cs` during the `ConfigureServices()` like this:
```
    List<Type> syncTypes = new List<Type>() { typeof(SyncDepartment), typeof(SyncEmployee) };
    SyncConfiguration syncConfiguration = new SyncConfiguration(syncTypes.ToArray());
    services.AddSingleton(syncConfiguration);
```
The server also register the `syncConfiguration` in IoC, and will retrieve the instance in its controllers later.

### Subclass the SyncEngine ###
NETCoreSync provide an abstract engine class called `SyncEngine`, and it needs to be subclassed on both server and client. The purpose of this engine is to provide a database-agnostic way in server and client to instruct NETCoreSync on how to save the data, how to serialize the data, and so on. It is up to you to implement each of the function in the `SyncEngine` class that is suitable for your existing database. 

Please check the [Models/CustomSyncEngine.cs](https://github.com/aldycool/NETCoreSync/blob/master/NETCoreSyncWebSample/Models/CustomSyncEngine.cs) on server, and [Models/CustomSyncEngine.cs](https://github.com/aldycool/NETCoreSync/blob/master/NETCoreSyncMobileSample/NETCoreSyncMobileSample/Models/CustomSyncEngine.cs) on client, on how to subclass this if using Entity Framework Core + SQLite on server and client.

The following lists the **abstract** methods that needs to be implemented.

**bool IsServerEngine()**
Must return `true` if this is a subclass on the server, and return `false` if this is a subclass on the client.

**long GetClientLastSync()**
Must return a `long` value (that is stored somewhere in your client application) that indicates the last time this client have synced successfully. This value is set by the counterpart method, `SetClientLastSync`. The `long` value is obtained from `DateTime.Ticks` property. If the client have not sync at all, this should return `0`. This method is never called when subclassed on server, so you can safely call `throw new NotImplementedException()` in server.

**void SetClientLastSync(long lastSync)**
Must save the `lastSync` value in storage somewhere in your client application, and the return it during the counterpart method, `GetClientLastSync`. This method is never called when subclassed on server, so you can safely call `throw new NotImplementedException()` in server.

**IQueryable GetQueryable(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)**
Must return an `IQueryable` depending on the `classType` parameter. The rest of the parameters will be explained in the following documentation.

**string SerializeDataToJson(Type classType, object data, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)**
Must return a JSON string of the `data` parameter. The `classType` parameter will indicate which class that the `data` type is. The rest of the parameters will be explained in the following documentation.

**object DeserializeJsonToNewData(Type classType, JObject jObject, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)**
Must return a new `object` with the data type `classType`, and the returned `object` properties must be populated with information obtained fom the `jObject` parameter. The rest of the parameters will be explained in the following documentation.

**object DeserializeJsonToExistingData(Type classType, JObject jObject, object data, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)**
The `data` parameter is an existing data with the type `classType`, and this `data` properties must be populated with information obtained from the `jObject` parameter. When finished, the `data` must be returned at the end of this method. The rest of the parameters will be explained in the following documentation.

**void PersistData(Type classType, object data, bool isNew, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)**
The `data` parameter (with type `classType`) must be persisted in your database here. The `isNew` parameter will indicate whether this is a new data to be inserted, or an existing data to be updated. The rest of the parameters will be explained in the following documentation.

The following lists the **virtual** methods that may or may not be implemented on your subclass, depending on your requirement.

**object StartTransaction(Type classType, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)**
Any changes that NETCoreSync will made can be started with a database transaction. This method should be omitted if database transaction is not required. This method should return a transaction object, which will be different for each database implementation. For example, for SQL Server, this can be an `SqlTransaction` object which can be committed or rollbacked later. Or for Realm, this can be a `Transaction` object of Realm. For Realm, transactions should always be used when modifying data, so this is useful for such situations. The returned object will be passed as a parameter called `transaction` with data type `object` in all methods. The rest of the parameters will be explained in the following documentation.

**void CommitTransaction(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)**
The `transaction` parameter should be committed here (depends on your database implementation). The rest of the parameters will be explained in the following documentation.

**void RollbackTransaction(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)**
The `transaction` parameter should be rollbacked here (depends on your database implementation). The rest of the parameters will be explained in the following documentation.

**void EndTransaction(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)**
This method will give you chance to dispose your `transaction` object if needed. You should dispose (or release any other resources) here to cleanly close your database transaction. The rest of the parameters will be explained in the following documentation.

**object TransformIdType(Type classType, JValue id, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)**
If you have different data type for primary key on server and client, the value transformation can be done here. the `id` parameter is a `JValue` data type that can be converted into the correct primary key data type, and returned at the end of this method. Please see the sample where `Guid` is used as a primary key on server, while `string` is used as a primary key on client. The rest of the parameters will be explained in the following documentation.

**void PostEventDelete(Type classType, object id, string synchronizationId, Dictionary<string, object> customInfo)**
This method is raised whenever some deletion of data occurs. The `id` parameter will indicate the primary key of the data, and the `classType` will indicate the class  type of the data that have been deleted. This method should give you opportunity to perform some clean up (such as setting `null` to the referencing properties of dependent objects, etc). The rest of the parameters will be explained in the following documentation.

The `operationType` parameter that passed on the above methods will indicate the whether the method is executed for the purpose of getting the data changes (`OperationType.GetChanges`), or for the purpose of applying changes (`OperationType.ApplyChanges`), so you could react accordingly in each of those methods if necessary.

### Execute SynchronizeAsync on Client ###
Please see the client sample, [ViewModels/SyncViewModel.cs](https://github.com/aldycool/NETCoreSync/blob/master/NETCoreSyncMobileSample/NETCoreSyncMobileSample/ViewModels/SyncViewModel.cs), in the `SynchronizeCommand` method, on how to start synchronizing with the server by calling the `SynchronizeAsync()` method of a `SyncClient` instance. 

When creating the `SyncClient` instance, the **synchonizationId** parameter is required. The Synchronization ID is a unique id with `string` data type that uniquely separates each clients, which can be taken from user account (or email address), etc. This Synchronization ID will act as an indicator to separate / partition data among clients. The Synchronization ID will be passed as a parameter called `synchronizationId` on the `SyncEngine` subclassed methods, so the server (or client) can act accordingly when receiving this information (such as querying by different account on server). Therefore, a single client should use the same Synchronization ID within its devices to ensure the same set of data will be distributed among the client devices.

When calling the `SynchronizeAsync` method, a custom information with type `Dictionary<string, object>` can also be passed as a parameter, which in turns will be passed into a parameter called `customInfo` on the `SyncEngine` subclassed methods. This can be usefule if you need to pass custom information to be processed in the `SyncEngine`.

### Prepare Synchronization Controller on Server ###
Before executing the `SynchronizeAsync` on client, the server needs to be prepared first to receive and process the payload. Please see the [Controllers/SyncController.cs](https://github.com/aldycool/NETCoreSync/blob/master/NETCoreSyncWebSample/Controllers/SyncController.cs) on how to do this correctly. The `Index` method will receive HTTP POST data from client, and process it by calling the `Process` method of a `SyncServer` instance. The result will be sent as an HTTP response back to the client.

The `Index` method in the sample provide the most basic and minimal way, so it is recommended to use this pattern in your implementation.

There is an additional feature on the server which will queue the client synchronization process IF the same Synchronization ID tries to synchronize simultaneously. This behaviour is designed to avoid unexpected results, so clients with the same Synchronization ID shall be processed sequentially.

### Hook Modification Methods on All Existing Insert / Update / Delete Methods ###
Your existing Inserts, Updates, and Deletes method in your application should be modified accordingly to update the `LastUpdate` and `Deleted` fields correctly. The recommended way is to use the provided methods in the `SyncEngine` instance, called `HookPreInsertOrUpdate` for insert and update operation, and `HookPreDelete` for delete operation. This is taken from the mobile sample during insert and update operation:

```
public ICommand SaveCommand => new Command(async () =>
{
    CustomSyncEngine customSyncEngine = new CustomSyncEngine(databaseService, syncConfiguration);
    customSyncEngine.HookPreInsertOrUpdate(Data);

    using (var databaseContext = databaseService.GetDatabaseContext())
    {
        if (IsNewData)
        {
            databaseContext.Add(Data);
        }
        else
        {
            databaseContext.Update(Data);
        }
        await databaseContext.SaveChangesAsync();   
    }

    await navigation.PopAsync();
});
```
Please notice that the `HookPreInsertOrUpdate` is called right before saving into the database. The same approach should also be used for `HookPreDelete` (called right before delete) before persisting the changes into the database.

## Final Words ##
This synchronization library is admittedly still far from being an ideal solution for perfect synchronization mechanism, considering data synchronization is VERY HARD and can have different implementations for different solutions. But still this may work if the required conditions and are met and the limitations are still accepted.

Please contact me if you have comments or suggestions. Thanks.
