## Implementation Instruction - Global TimeStamp
> The best way to implement this correctly is to check the [working sample](https://github.com/aldycool/NETCoreSync/tree/master/Samples/GlobalTimeStamp), and also read the rest for a complete instruction.

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
The data classes that have been marked with the attributes needs to be registered during the startup process of application. On client using Xamarin Forms, this can be done in the `App.xml.cs` in the App Constructor after `InitializeComponent()`, like this:
```
    List<Type> syncTypes = new List<Type>() { typeof(Department), typeof(Employee) };
    SyncConfiguration syncConfiguration = new SyncConfiguration(syncTypes.ToArray(), SyncConfiguration.TimeStampStrategyEnum.GlobalTimeStamp);
    builder.RegisterInstance(syncConfiguration);
```
The `syncConfiguration` instance is registered using IoC, and then this instance can be retrieved as needed in the view models.

On server, this can be done in the `Startup.cs` during the `ConfigureServices()` like this:
```
    List<Type> syncTypes = new List<Type>() { typeof(SyncDepartment), typeof(SyncEmployee) };
    SyncConfiguration syncConfiguration = new SyncConfiguration(syncTypes.ToArray(), SyncConfiguration.TimeStampStrategyEnum.GlobalTimeStamp);
    services.AddSingleton(syncConfiguration);
```
The server also register the `syncConfiguration` in IoC, and will retrieve the instance in its controllers later.

### Subclass the SyncEngine ###
NETCoreSync provide an abstract engine class called `SyncEngine`, and it needs to be subclassed on both server and client. The purpose of this engine is to provide a database-agnostic way in server and client to instruct NETCoreSync on how to save the data, how to serialize the data, and so on. It is up to you to implement each of the function in the `SyncEngine` class that is suitable for your existing database. 

Please check the [Models/CustomSyncEngine.cs](https://github.com/aldycool/NETCoreSync/blob/master/Samples/GlobalTimeStamp/WebSample/Models/CustomSyncEngine.cs) on server, and [Models/CustomSyncEngine.cs](https://github.com/aldycool/NETCoreSync/blob/master/Samples/GlobalTimeStamp/MobileSample/Models/CustomSyncEngine.cs) on client, on how to subclass this if using Entity Framework Core + SQLite on server and client.

The following lists the **abstract** methods that needs to be implemented:
***
`bool IsServerEngine()`

Must return `true` if this is a subclass on the server, and return `false` if this is a subclass on the client.
***
`long GetClientLastSync()`

Must return a `long` value (that is stored somewhere in your client application) that indicates the last time this client have synced successfully. This value is set by the counterpart method, `SetClientLastSync`. The `long` value is obtained from `DateTime.Ticks` property. If the client have not sync at all, this should return `0`. This method is never called when subclassed on server, so you don't have to implement this method on server subclass.
***
`void SetClientLastSync(long lastSync)`

Must save the `lastSync` value in storage somewhere in your client application, and the return it during the counterpart method, `GetClientLastSync`. This method is never called when subclassed on server, so you don't have to implement this method on server subclass.
***
`IQueryable GetQueryable(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)`

Must return an `IQueryable` depending on the `classType` parameter. The rest of the parameters will be explained in the following documentation.
***
`string SerializeDataToJson(Type classType, object data, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)`

Must return a JSON string of the `data` parameter. The `classType` parameter will indicate which class that the `data` type is. The rest of the parameters will be explained in the following documentation.
***
`object DeserializeJsonToNewData(Type classType, JObject jObject, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)`

Must return a new `object` with the data type `classType`, and the returned `object` properties must be populated with information obtained fom the `jObject` parameter. The rest of the parameters will be explained in the following documentation.
***
`object DeserializeJsonToExistingData(Type classType, JObject jObject, object data, object transaction, OperationType operationType, ConflictType conflictType, string synchronizationId, Dictionary<string, object> customInfo)`

The `data` parameter is an existing data with the type `classType`, and this `data` properties must be populated with information obtained from the `jObject` parameter. When finished, the `data` must be returned at the end of this method. As for the `conflictType` parameter, this will carry conflict information during updates and deletes. For GlobalTimeStamp updates, the `conflictType` can be either: `NoConflict`, means that there are no conflict happened, or, `ExistingDataIsNewerThanIncomingData`, means that the ExistingData (`data` parameter) timestamp is newer than the IncomingData (`jObject` parameter). If conflict happens, you can either return `null` to cancel the update and the conflict will be registered in the `SyncResult`'s Conflict Log, or, you can still return the `data` (which the conflict have been handled manually as reflected in the returned `data`) and the update will continue normally. If you return `null` but the `conflictType` is `NoConflict`, then this will raise an exception. For GlobalTimeStamp deletes, the `conflictType` value will always be `NoConflict` and `data` should always be returned (cannot return `null`). The rest of the parameters will be explained in the following documentation.
***
`void PersistData(Type classType, object data, bool isNew, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)`

The `data` parameter (with type `classType`) must be persisted in your database here. The `isNew` parameter will indicate whether this is a new data to be inserted, or an existing data to be updated. The rest of the parameters will be explained in the following documentation.
***
The following lists the **virtual** methods that may or may not be implemented on your subclass, depending on your requirement:
***
`object StartTransaction(Type classType, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)`

Any changes that NETCoreSync will make can be started with a database transaction. This method should be omitted if database transaction is not required. This method should return a transaction object, which will be different for each database implementation. For example, for SQL Server, this can be an `SqlTransaction` object which can be committed or rollbacked later. Or for Realm, this can be a `Transaction` object of Realm. For Realm, transactions should always be used when modifying data, so this is useful for such situations. The returned object will be passed as a parameter called `transaction` with data type `object` in all methods. The rest of the parameters will be explained in the following documentation.
***
`void CommitTransaction(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)`

The `transaction` parameter should be committed here (how to commit it depends on your database implementation). The rest of the parameters will be explained in the following documentation.
***
`void RollbackTransaction(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)`

The `transaction` parameter should be rollbacked here (how to rollback it depends on your database implementation). The rest of the parameters will be explained in the following documentation.
***
`void EndTransaction(Type classType, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)`

This method will give you chance to dispose your `transaction` object if needed. You should dispose (or release any other resources) here to cleanly close your database transaction. The rest of the parameters will be explained in the following documentation.
***
`object TransformIdType(Type classType, JValue id, object transaction, OperationType operationType, string synchronizationId, Dictionary<string, object> customInfo)`

If you have different data type for primary key on server and client, the value transformation can be done here. the `id` parameter is a `JValue` data type that can be converted into the correct primary key data type, and returned at the end of this method. Please see the sample where `Guid` is used as a primary key on server, while `string` is used as a primary key on client. The rest of the parameters will be explained in the following documentation.
***
`void PostEventDelete(Type classType, object id, string synchronizationId, Dictionary<string, object> customInfo)`

This method is raised whenever some deletion of data occurs. The `id` parameter will indicate the primary key of the data, and the `classType` will indicate the class  type of the data that have been deleted. This method should give you opportunity to perform some clean up (such as setting `null` to the referencing properties of dependent objects, etc). The rest of the parameters will be explained in the following documentation.
***
> The `operationType` parameter that passed on the above methods will indicate the whether the method is executed for the purpose of getting the data changes (`OperationType.GetChanges`), or for the purpose of applying changes (`OperationType.ApplyChanges`), so you could react accordingly in each of those methods if necessary.
***
### Execute SynchronizeAsync on Client ###
Please see the client sample, [ViewModels/SyncViewModel.cs](https://github.com/aldycool/NETCoreSync/blob/master/Samples/GlobalTimeStamp/MobileSample/ViewModels/SyncViewModel.cs), in the `SynchronizeCommand` method, on how to start synchronizing with the server by calling the `SynchronizeAsync()` method of a `SyncClient` instance. 

When creating the `SyncClient` instance, the **synchonizationId** parameter is required. The Synchronization ID is a unique id with `string` data type that uniquely separates each clients, which can be taken from user account (or email address), etc. This Synchronization ID will act as an indicator to separate / partition data among clients. The Synchronization ID will be passed as a parameter called `synchronizationId` on the `SyncEngine` subclassed methods, so the server (or client) can act accordingly when receiving this information (such as querying by different account on server). Therefore, a single client should use the same Synchronization ID within its devices to ensure the same set of data will be distributed among the client devices.

When calling the `SynchronizeAsync` method, a custom information with type `Dictionary<string, object>` can also be passed as a parameter, which in turns will be passed into a parameter called `customInfo` on the `SyncEngine` subclassed methods. This can be useful if you need to pass custom information to be processed in the `SyncEngine`.

The `SynchronizeAsync` method will return a `SyncResult` instance that can indicate whether the synchronization process is successful or not, which also carries error message (if failed) and lots of other information that maybe useful, such as what records that that client have sent to the server, which of those records that have been successfully applied (inserted/updated/deleted), conflicted records, and so on. Please see the `SyncResult` usage in the example for more detailed information.

### Prepare Synchronization Controller on Server ###
Before executing the `SynchronizeAsync` on client, the server needs to be prepared first to receive and process the payload. Please see the [Controllers/SyncController.cs](https://github.com/aldycool/NETCoreSync/blob/master/Samples/GlobalTimeStamp/WebSample/Controllers/SyncController.cs) on how to do this correctly. The `Index` method will receive HTTP POST data from client, and process it by calling the `Process` method of a `SyncServer` instance. The result will be sent as an HTTP response back to the client.

The `Index` method in the sample provide the most basic and minimal way, so it is recommended to use this pattern in your implementation.

There is an additional feature on the server which will queue the client synchronization process IF the same Synchronization ID tries to synchronize simultaneously. This behaviour is designed to avoid unexpected results, so clients with the same Synchronization ID shall be processed sequentially.

### Hook Modification Methods on All Existing Insert / Update / Delete Methods ###
Your existing Inserts, Updates, and Deletes method in your application should be modified accordingly to update the `LastUpdate` and `Deleted` fields correctly. The recommended way is to use the provided methods in the `SyncEngine` instance, called `HookPreInsertOrUpdateGlobalTimeStamp` for insert and update operation, and `HookPreDeleteGlobalTimeStamp` for delete operation. This is taken from the mobile sample during insert and update operation:

```
public ICommand SaveCommand => new Command(async () =>
{
    CustomSyncEngine customSyncEngine = new CustomSyncEngine(databaseService, syncConfiguration);
    customSyncEngine.HookPreInsertOrUpdateGlobalTimeStamp(Data);

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
This is taken from the mobile sample during delete operation:
```
public ICommand DeleteCommand => new Command(async () =>
{
    using (var databaseContext = databaseService.GetDatabaseContext())
    {
        CustomSyncEngine customSyncEngine = new CustomSyncEngine(databaseService, syncConfiguration);
        customSyncEngine.HookPreDeleteGlobalTimeStamp(Data);

        databaseContext.Update(Data);
        //databaseContext.Remove(Data); //We're not actually deleting the data because we use SOFT DELETE approach
        await databaseContext.SaveChangesAsync();
    }
    await navigation.PopAsync();
});
```
Please notice that the `HookPreInsertOrUpdateGlobalTimeStamp` is called right before saving into the database, also the `HookPreDeleteGlobalTimeStamp` is called right before _deleting_ the data. These methods are mandatory to be called right before persisting the changes into the database. For GlobalTimeStamp, by default, it will always perform _time stamp validity_ first by comparing the system's current Date and Time against the `lastSync` value obtained from the `GetClientLastSync` implementation during these hooks calls. If the system's current Date Time is older than the `lastSync` value, then it will raise an `Exception`. This scenario could happened if the mobile users are deliberately changing its system's Date Time settings to an older Date Time. To allow this behavior (do not raise an `Exception` if this happens), set the `GlobalTimeStampAllowHooksToUpdateWithOlderSystemDateTime` of the `SyncConfiguration` to `true` during the `SyncConfiguration` creation in startup. For example:
```
    List<Type> syncTypes = new List<Type>() { typeof(Department), typeof(Employee) };
    SyncConfiguration syncConfiguration = new SyncConfiguration(syncTypes.ToArray(), SyncConfiguration.TimeStampStrategyEnum.GlobalTimeStamp);
    syncConfiguration.SetOptions(options => 
    {
        options.GlobalTimeStampAllowHooksToUpdateWithOlderSystemDateTime = true;
    });
    builder.RegisterInstance(syncConfiguration);
```
But, by allowing this behavior, conflicts can happen during synchronization. Therefore, the conflicts should be handled accordingly in the `DeserializeJsonToExistingData` method in the server's `SyncEngine` subclass.
