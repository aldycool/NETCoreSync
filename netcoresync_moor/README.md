[![build](https://github.com/aldycool/NETCoreSync/actions/workflows/netcoresync_moor_build.yml/badge.svg?event=push)](https://github.com/aldycool/NETCoreSync/actions/workflows/netcoresync_moor_build.yml?query=event%3Apush)

A database synchronization framework where each client's local offline database (on each client's multiple devices) can be synchronized on-demand via network into a single centralized database hosted on a server. Data which are stored locally within each device of a single client can all be synchronized after each device have successfully performed the synchronization operation. This is the Flutter version of the original [NETCoreSync](https://github.com/aldycool/NETCoreSync) framework.

## Features
- Supports synchronizing offline local database for each user with multiple devices. A single user is identified with a unique *"syncId"*, which can have one or more databases on each separate devices on all platforms (android, ios, macos, windows, linux, and web).
- Each user's *"syncId"* can be linked with several different users' *"syncId"* (known as *"linkedSyncIds"*) to allow that user to read and modify the linked user's data, and those changes can still be synchronized back to each linked user's databases.

## Requirements

- This framework is built on top of Flutter's [Moor](https://moor.simonbinder.eu/) library, so it is required to use Moor as the database API in the project.
- There's also a separate package called [netcoresync_moor_generator](https://github.com/aldycool/NETCoreSync/tree/master/netcoresync_moor_generator) that is required to be listed as the project's `dev_dependencies` in the `pubspec.yaml`. This package is to generate the needed source code during development time in the project.
- The single centralized database hosted on a server can be any kind of relational database (RDBMS such as PostgreSQL, MySQL, SQL Server, etc.), and it is controlled by a separate server application. The server application needs to be written in Microsoft .NET 5.0, and it will use a server component called [NETCoreSyncServer](https://github.com/aldycool/NETCoreSync/tree/master/NETCoreSyncServer), which is an ASP .NET Core Middleware component that use WebSockets for its network communication with the Flutter clients.
- Not like other synchronization frameworks, this framework doesn't use _tracking tables_,  _tombstone tables_, and _triggers_. So the tables in the database needs to add some additional columns to indicate certain states for the synchronization purposes, and the standard Moor's function calls for data insert / update / delete must be converted into this framework ones.
- This framework requires that all of your data in your database to have a unique primary key. The Moor table's primary key is expected to be a `TextColumn` type and should contain unique Uuid values (probably generated from the `uuid` package).
- The database design must use the **Soft Delete** approach when deleting record from tables, means that for any delete operation, the data is not physically deleted from the table, but only flag the record with a boolean column that indicates whether this record is already deleted or not.

## How It Works

To know how the synchronization works in detail, there is a special **in-depth explanation** page that covers the step-by-step logic of the synchronization, along with some activity simulation examples in this page [here](https://github.com/aldycool/NETCoreSync/blob/master/netcoresync_moor/docs/server-timestamp-logic.md). These simulation steps are also already made as a unit test in the `netcoresync_moor` package [here](https://github.com/aldycool/NETCoreSync/blob/master/netcoresync_moor/test/integration_tests/netcoresync_sync_test.dart) (in a `test` section called _SyncSession Synchronize_) to ensure the synchronization logic is always work as intended.

## Example

Check the built-in example on the Github repository:
- The client project (called `clientsample`) [here](https://github.com/aldycool/NETCoreSync/tree/master/Samples/ServerTimeStamp/clientsample) is a Flutter project that uses `moor` (and it's generator),  `netcoresync_moor` and `netcoresync_moor_generator` packages. This client project can run on all platforms (android, ios, macos, windows, linux, and web). This client project has a database (SQLite from Moor) with tables that can be synchronized with the server-side database.
- The server project (called `WebSample`) [here](https://github.com/aldycool/NETCoreSync/tree/master/Samples/ServerTimeStamp/WebSample) is a Microsoft .NET 5.0 ASP .NET Core project, with PostgreSQL database controlled by Entity Framework Core library. The synchronization request from clients is handled by the `NETCoreSyncServer` middleware component that is inserted inside the server project's request pipeline. 
- Each client's database table has a corresponding table on the server side's database. For example, the client `Persons` table is synchronized into the server `SyncPerson` table, etc. These tables also added with special columns, which explained in detail in the usage section below.
- After each client inserts or modify any local data, client can invoke the synchronization function on-demand to start synchronizing its local data with the server's database. 

## Usage

This section shows examples in detail for all required tasks, both in the client and server projects. For clarity, the guide jumps back and forth between client and server's code in chronological order to illustrate relationship between them.

> All of the usage explanation below are demonstrated correctly in the built-in [Example](#example).

- [Prerequisites](#prerequisites)
- [Dependencies Registration](#dependencies-registration)
  - [Client Side Dependencies](#client-side-dependencies)
  - [Server Side Dependencies](#server-side-dependencies)
- [Client Side Data Annotation](#client-side-data-annotation)
  - [Moor Data Classes](#moor-data-classes)
  - [Moor Custom Row Classes](#moor-custom-row-classes)
- [Server Side Data Annotation](#server-side-data-annotation)
  - [SyncTable Annotation](#synctable-annotation)
  - [SyncProperty Annotation](#syncproperty-annotation)
- [Client Side Code Generation](#client-side-code-generation)
- [Client Side Initialization](#client-side-initialization)
- [Client Side Moor Code Adaptation](#client-side-moor-code-adaptation)
- [Server Side SyncEngine Implementation](#server-side-syncengine-implementation)
- [Server Side Middleware Configuration](#server-side-middleware-configuration)
  - [Intercept Synchronization Request](#intercept-synchronization-request)
  - [Register SyncEngine Implementation Class Service](#register-syncengine-implementation-class-service)
  - [Register NETCoreSyncServer Service](#register-netcoresyncserver-service)
  - [Register NETCoreSyncServer Middleware Pipeline](#register-netcoresyncserver-middleware-pipeline)
- [Client Side Synchronization](#client-side-synchronization)
  - [Initiate Synchronization Process](#initiate-synchronization-process)
  - [Synchronization Progress Event](#synchronization-progress-event)
  - [Synchronization Result Explanation](#synchronization-result-explanation)
    - [Synchronization Errors](#synchronization-errors)
    - [Synchronization Logs](#synchronization-logs)

### Prerequisites

- The client side framework expects that a Flutter client project is already available and **working**, and it is already uses the [Moor](https://moor.simonbinder.eu/) package, and it has correctly implements the standard usage of Moor first, such as creating Dart table classes, and then generating the Moor's code, etc. Also the database operations should be tested first, make sure that the Flutter project can already insert / update / delete data into its SQLite database using Moor functions. The Moor's guide can be read [here](https://moor.simonbinder.eu/docs/). The following tasks will add the framework functionalities on top of this Flutter client project.
- The server side framework expects that a .NET 5.0 ASP .NET Core Web project is already available and **working**, and any choice of database should also be available and can be manipulated by the web project (the web project can insert / update / delete into the database). The following tasks assume that the web project uses the Entity Framework Core for its database API and will add the framework functionalities on top of this web project. Adapt accordingly for other database API.

### Dependencies Registration

#### Client Side Dependencies

The following shows the minimum dependendencies that are required for using `netcoresync_moor`, `netcoresync_moor_generator`, and `moor` (and its generator) in the client project's `pubspec.yaml`:

```dart
dependencies:
  moor: ^4.4.1
  sqlite3_flutter_libs: ^0.5.0
  netcoresync_moor: ^1.0.0

dev_dependencies:
  moor_generator: ^4.4.1
  build_runner: ^2.1.1
  netcoresync_moor_generator: ^1.0.0
```

For every dart files in the client project that requires to reference the `netcoresync_moor` package, add the `import` directive on top of the file:

```dart
import 'package:netcoresync_moor/netcoresync_moor.dart';
```

#### Server Side Dependencies

The following shows the required depencencies for using the `NETCoreSyncServer` middleware in the server project's `.csproj`:

```csharp
<ItemGroup>
  <PackageReference Include="NETCoreSyncServer" Version="1.0.0" />
</ItemGroup>
```

For every C# files in the server project that requires to reference the `NETCoreSync` classes, add the `using` directive on top of the file:

```csharp
using NETCoreSyncServer;
```

### Client Side Data Annotation

#### Moor Data Classes

For any Moor tables that needs to be synchronized, the data classes needs to be annotated with `@NetCoreSyncTable`. For example:

```dart
@NetCoreSyncTable
class Persons extends Table {
  // The primary key uses uuid package to generate unique key
  TextColumn get id => text().withLength(max: 36).clientDefault(() => Uuid().v4())();

  // ... other fields here ...

  // synchronization fields
  TextColumn get syncId => text().withLength(max: 36).withDefault(Constant(""))();
  TextColumn get knowledgeId => text().withLength(max: 36).withDefault(Constant(""))();
  BoolColumn get synced => boolean().withDefault(const Constant(false)();
  BoolColumn get deleted => boolean().withDefault(const Constant(false)();

  @override
  Set<Column> get primaryKey => { id };
}
```

The required synchronization fields that needs to be present on each table are:

- `id`: a primary key field that is unique.
- `syncId`: a unique value that identifies a single user.
- `knowledgeId`: a unique value that identifies a device.
- `synced`: an indicator to detect whether this particular row is already synchronized or not.
- `deleted`: an indicator to detect whether this particular row is already deleted or not.

These synchronization field values should not be changed in the client code manually, and will be handled by the framework during database operations and synchronization.

If some of the synchronization field names have conflict with the existing table column names, the names can be overriden in the `@NETCoreSyncTable`'s constructor like the following:

```dart
@NetCoreSyncTable(
  idFieldName: "pk",
  syncIdFieldName: "syncSyncId",
  knowledgeIdFieldName: "syncKnowledgeId",
  syncedFieldName: "syncSynced",
  deletedFieldName: "syncDeleted",
)
class Area extends Table {
  TextColumn get pk => text().withLength(max: 36).clientDefault(() => Uuid().v4())();

  // ... other fields here ...

  // synchronization fields
  TextColumn get syncSyncId => text().withLength(max: 36).withDefault(Constant(""))();
  TextColumn get syncKnowledgeId => text().withLength(max: 36).withDefault(Constant(""))();
  BoolColumn get syncSynced => boolean().withDefault(const Constant(false)();
  BoolColumn get syncDeleted => boolean().withDefault(const Constant(false)();

  @override
  Set<Column> get primaryKey => { id };
}
```

#### Moor Custom Row Classes

In case the client project uses Moor's `@UseRowClass`, the `@NETCoreSyncTable` annotation still should be applied:

```dart
@NetCoreSyncTable
@UseRowClass(CustomObject, constructor: "fromDb")
class CustomObjects extends Table {
  // other fields and synchronization fields are here
}
```

There are several restrictions for using Custom Row Class:
- The custom class fields should be made **mutable**, means that each of its field values can be assigned independently during run-time by the framework.
- The custom class should implement a factory method called `fromJson()` and an instance method called `toJson()`  that serialize and deserialize JSON objects. For example:

  ```dart
  factory CustomObject.fromJson(Map<String, dynamic> json) {
    CustomObject customObject = CustomObject();
    // Write the implementation here
    return customObject;
  }
  
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
    // Write implementation here
    };
  }
  ```

- The custom class must also implement an instance method called `toCompanion()` which returns its Moor's `Companion` class. This is required by the framework for its internal implementation later during updates. This should be implemented exactly like Moor does, by returning an instance of its Companion version, where it is constructed by passing all of your Row Class fields values, and each of those fields values is wrapped with the `Value()` class. Take a look on how Moor implement it for your tables that `extends DataClass` in the generated `*.g.dart` file, especially when handling the `nullToAbsent` argument, where it is expected to use `Value.absent()` for your nullable fields if the `nullToAbsent` parameter is set to `true`. For example:
  ```dart
  CustomObjectsCompanion toCompanion(bool nullToAbsent) {
    return CustomObjectsCompanion(
      id: Value(id),
      fieldStringNullable: nullToAbsent && fieldStringNullable == null
        ? Value.absent() : Value(fieldStringNullable),
      fieldIntNullable: nullToAbsent && fieldIntNullable == null
        ? Value.absent() : Value(fieldIntNullable),
      syncId: Value(syncId),
      knowledgeId: Value(knowledgeId),
      synced: Value(synced),
      deleted: Value(deleted),
    );
  }
  ```

> If your data classes are generated by Moor (not using `@UseRowClass`), it is expected that they already have these functions (`toJson()`, `fromJson()`, and `toCompanion()`), so modification is not necessary for the standard Moor data classes.

### Server Side Data Annotation

#### SyncTable Annotation

Every synchronized client table must have its counterpart in the server project. The following shows an example of the client's `Person` counterpart called `SyncPerson` class on the server:

```csharp
[SyncTable("Person", order: 2)]
public class SyncPerson
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.None)]
    [SyncProperty(SyncPropertyAttribute.PropertyIndicatorEnum.ID)]
    public Guid ID { get; set; }
    
    // ... other fields here ...

    // synchronization fields
    [SyncProperty(SyncPropertyAttribute.PropertyIndicatorEnum.SyncID)]
    public string SyncID { get; set; } = null!;
    [SyncProperty(SyncPropertyAttribute.PropertyIndicatorEnum.KnowledgeID)]
    public string KnowledgeID { get; set; } = null!;
    [SyncProperty(SyncPropertyAttribute.PropertyIndicatorEnum.TimeStamp)]
    public long TimeStamp { get; set; }
    [SyncProperty(SyncPropertyAttribute.PropertyIndicatorEnum.Deleted)]
    public bool Deleted { get; set; }
}
```

The `SyncPerson` class in the example above is the counterpart of the client's `Person` class. The `SyncPerson` class is an Entity Framework Core model class. To indicate such relationship, the `SyncPerson` class is annotated with the `SyncTable` annotation with the following constructor parameters:

- `ClientClassName`: parameter that indicates the class name on the client project for this particular table (which is "Person" on the client).

- `Order`: parameter that indicates the processing order for all synchronized tables. The order specified here should follow the relational table foreign key relationship, ordered from the most independent table to the most dependent table. This is to ensure that the referenced foreign key value that points to some master table is already processed earlier, so missing foreign key violation can be avoided during synchronization. For example, the following model classes have these relationships:
  ```csharp
  [SyncTable(clientClassName: "Product", order: 1)]
  public class Product
  {
      [Key]
      [DatabaseGenerated(DatabaseGeneratedOption.None)]
      [SyncProperty(SyncPropertyAttribute.PropertyIndicatorEnum.ID)]
      public Guid ID { get; set; }
  
      public string Name { get; set; } = null!;
  
      [JsonIgnore]
      [ForeignKey("ProductID")]
      public ICollection<Order> Orders { get; set; } = null!;
      
      // ... synchronization fields here ...
  }
  
  [SyncTable(clientClassName: "Order", order: 2)]
  public class Order
  {
      [Key]
      [DatabaseGenerated(DatabaseGeneratedOption.None)]
      [SyncProperty(SyncPropertyAttribute.PropertyIndicatorEnum.ID)]
      public Guid ID { get; set; }
  
      public DateTime? OrderDate { get; set; } = null!;
      public decimal TotalPrice { get; set; } = 0;
  
      public Guid? ProductID { get; set; }
          
      [JsonIgnore]
      public Product? Product { get; set; }
      
      // ... synchronization fields here ...
  }
  ```
  In the example above, the most independent table is the `Product` class, and the `Order` class is dependent on the `Product` class. Therefore, the `SyncTable`'s `Order` is set to `1` for `Product`, and `2` for `Order`.
  
  > Notice that in the example above, the `Product` navigation property: `Orders`, and the `Order` navigation property: `Product`, are marked with `[JsonIgnore]`. This is necessary to avoid those navigation property values to be serialized to the client which can lead to unpredictable results during synchronization. These navigation properties are only useful for usage within the server project itself.

#### SyncProperty Annotation

Each server model class requires synchronization fields to be present, which are:

- `ID`: a primary key field that is unique. This field correlates with the client's `id`.
- `SyncID`: a unique value that identifies a single user. This field correlates with the client's `syncId`.
- `KnowledgeId`: a unique value that identifies a device. This field correlates with the client's `knowledgeId`.
- `TimeStamp`: the framework will increase this numeric value whenever this particular row is modified.
- `deleted`: an indicator to detect whether this particular row is already deleted or not. This field correlates with the client's `deleted`.

Use the `SyncProperty` annotation to indicate which class properties belongs to which type of synchronization fields. In the example above, the `ID` property is marked with `[SyncProperty(SyncPropertyAttribute.PropertyIndicatorEnum.ID)]` annotation to indicate that this field is a unique primary key for synchronization. Also the `SyncID` property is marked with `[SyncProperty(SyncPropertyAttribute.PropertyIndicatorEnum.SyncID)]` to indicate that this field is the field to hold synchronization ID values, and so on. These synchronization field values should not be changed in the server code manually, and will be handled by the framework during database operations and synchronization. 

### Client Side Code Generation

To generate the code for this framework, these steps should be performed first:

- On the Moor's database class (the class with `@UseMoor` annotation), add the `NetCoreSyncClient` and the `NetCoreSyncClientUser` mixin into the class. For example:

  ```dart
  @UseMoor(
    tables: [
      Areas,
      Persons,
      NetCoreSyncKnowledges,
    ],
  )
  class Database extends _$Database with NetCoreSyncClient, NetCoreSyncClientUser {
    Database(QueryExecutor queryExecutor) : super(queryExecutor);
  
    @override
    int get schemaVersion => 1;
  }
  ```
  
- Notice in the example above, aside from the registered `Areas` and `Persons` data classes in the Moor's `tables`,  the built-in `NetCoreSyncKnowledges` data class table from the client framework should also be included in the `tables` list property of the `@UseMoor` annotation.

- Before starting the code generation, the `moor_generator` have builder options as specified [here](https://moor.simonbinder.eu/docs/advanced-features/builder_options/). This framework expect that the Moor code generation should use the **standard** Moor builder options. The following is the restriction of how the Moor builder options should be to correctly work with this framework (where most of the options are standard):

  - `use_data_class_name_for_companions` should be `false` (default).

  - `data_class_to_companions` should be `true` (default).

- Run the code generator (on the project's root folder in terminal):
  ```sh
  flutter packages pub run build_runner build
  ```
  The `netcoresync_moor` code will be generated along with Moor's generated code inside the Moor's standard generated file, the `[yourdatabasefile].g.dart`.
  > To generate builder code from a clean state:
  > ```sh
  > flutter packages pub run build_runner clean
  > flutter clean
  > flutter pub get
  > flutter packages pub run build_runner build --delete-conflicting-outputs
  > ```

### Client Side Initialization

- The framework should be initialized once during startup, and the required initialization function is already generated during client side code generation. After the Moor's database class has been instantiated, it should followed with the framework initialization call. The following shows example of initializing the framework:

  ```dart
  void main() async {
    // This line instantiated the Moor's database class (the constructDatabase method
    // is only an example, you may have different method to instantiate the Moor's database)
    Database database = await constructDatabase(logStatements: false);
  
    // This line initialized the framework
    await database.netCoreSyncInitialize();
    
    runApp(MyApp());
  }
  ```
  
- After it has been initialized, before doing any database operations, the framework should be activated with an active `syncId` first. This usually happens whenever a user is logged into the application:

  ```dart
    void userHasLoggedIn(String username) {
      // Get the database instance here, probably from a state management
      final database = getDatabaseInstance();
    
      database.netCoreSyncSetSyncIdInfo(SyncIdInfo(
          syncId: userName,
          linkedSyncIds: [],
      ));
    }
  ```

  The `netCoreSetSyncIdInfo` method call uses a class called `SyncIdInfo` for its parameter. The `SyncIdInfo` class purpose is to hold the active `syncId` information, along with the `linkedSyncIds` (an array of other user's `syncId`s). In the example above, the application uses the passed-in `username` parameter as the `syncId` value for the logged-in user. The `syncId` can be anything, as long as its uniqueness among users of the application can be guaranteed. The `linkedSyncIds` in the example above is specified with an empty array, means that the logged-in user does not associate with other user's `syncId`s.

- If the application supports the `linkedSyncIds` feature, then the logged in user can switch between `syncId`s. For example:
  
  ```dart
    // In this example, a specific user with syncId = ABC has already logged-in, 
    // and the user ABC is associated with the DEF and GHI accounts.
    // The netCoreSyncSetSyncIdInfo has already been called with parameter:
    // SyncIdInfo(syncId: 'ABC', linkedSyncIds: ['DEF', 'GHI'])
  
    void switchActiveSyncId(String selectedSyncId) {
      // Get the database instance here, probably from a state management
      final database = getDatabaseInstance();
    
      // The parameter selectedSyncId has already been checked, with the possibility
      // of only between DEF or GHI for this particular user.
      database.netCoreSyncSetActiveSyncId(selectedSyncId);
    }
  ```
  
  By switching to any of the `linkedSyncIds` using the `netCoreSyncSetActiveSyncId` method call, the current logged-in `syncId` can read and modify the other user's data.
  
### Client Side Moor Code Adaptation

The existing Moor functions called by the application needs to be altered. Instead of calling the Moor standard functions to read and modify data, use the `netcoresync_moor` functions to ensure the synchronization works correctly later. The following lists the changes that needs to be applied for each supported Moor function calls.

|Category|Moor's Method|Framework's Method|Example|
|:---:|:---:|:---:|:---|
|Generated Table Variable|`persons`|`syncPersons`|For a `Persons` data class, Moor will generate its corresponding table variable called `persons`. The framework will also generate its _synchronized_ version called `syncPersons` (the variable name always begins with _sync_ and camel-cased). Use the framework version instead. The framework version has already filtered the data with correct `syncId` and its related `linkedSyncIds`.|
|Read Data|`select(persons)`|`syncSelect(syncPersons)`|Moor:<br>`await select(persons).get();`<br><br>Framework:<br>`await syncSelect(syncPersons).get();`|
|Read Data|`selectOnly(persons)`|`syncSelectOnly(syncPersons)`|Moor:<br>`await (selectOnly(persons)..addColumns([persons.name])).get();`<br><br>Framework:<br>`await (syncSelectOnly(syncPersons)..addColumns([syncPersons.name])).get();`|
|Read Data|`join(others)`|`syncJoin(syncOthers)`|Moor:<br>`await (select(persons).join([leftOuterJoin(others, others.id.equalsExp(persons.otherId))]).get();`<br><br>Framework:<br>`await (syncSelect(syncPersons).syncJoin([leftOuterJoin(syncOthers, syncOthers.id.equalsExp(syncPersons.otherId))]).get();`|
|Insert Data|`into(persons).insert(data)`|`syncInto(syncPersons).syncInsert(data)`|Moor:<br>`await into(persons).insert(data);`<br><br>Framework:<br>`await syncInto(syncPersons).syncInsert(data);`|
|Insert Data|`into(persons).insertOnConflictUpdate(data)`|`syncInto(syncPersons).syncInsertOnConflictUpdate(data)`|Moor:<br>`await into(persons).insertOnConflictUpdate(data);`<br><br>Framework:<br>`await syncInto(syncPersons).syncInsertOnConflictUpdate(data);`|
|Insert Data|Insert onConflict: `DoUpdate(updateFunc)` |Insert onConflict: `SyncDoUpdate(updateFunc)`|Moor:<br>`await into(persons).insert(data, onConflict: DoUpdate(updateFunc));`<br><br>Framework:<br>`await syncInto(syncPersons).syncInsert(data, onConflict: SyncDoUpdate(updateFunc));`|
|Insert Data|Insert onConflict: `UpsertMultiple(func)` |Insert onConflict: `SyncUpsertMultiple(func)`|Moor:<br>`await into(persons).insert(data, onConflict: UpsertMultiple(func));`<br><br>Framework:<br>`await syncInto(syncPersons).syncInsert(data, onConflict: SyncUpsertMultiple(func));`|
|Insert Data|`into(persons).insertReturning(data)`|`syncInto(syncPersons).syncInsertReturning(data)`|Moor:<br>`await into(persons).insertReturning(data);`<br><br>Framework:<br>`await syncInto(syncPersons).syncInsertReturning(data);`|
|Update Data|`update(persons).replace(data)`|`syncUpdate(syncPersons).syncReplace(data)`|Moor:<br>`await update(persons).replace(data);`<br><br>Framework:<br>`await syncUpdate(syncPersons).syncReplace(data);`|
|Update Data|`update(persons).write(data)`|`syncUpdate(syncPersons).syncWrite(data)`|Moor:<br>`await (update(persons)..whereSamePrimaryKey(data)).write(value);`<br><br>Framework:<br>`await (syncUpdate(syncPersons)..whereSamePrimaryKey(data)).syncWrite(value);`|
|Delete Data|`delete(persons).go()`|`syncDelete(syncPersons).go()`|Moor:<br>`await (delete(persons)..whereSamePrimaryKey(data)).go();`<br><br>Framework:<br>`await (syncDelete(syncPersons)..whereSamePrimaryKey(data)).go();`|
|Transactions|`await database.transaction(() async {}`|No Change||

For other Moor's method calls that is not mentioned above, at the moment, they are not supported, such as (and perhaps not limited to):
- The [batch](https://moor.simonbinder.eu/api/moor/databaseconnectionuser/batch) method
- The [InsertMode](https://moor.simonbinder.eu/api/moor/insertmode-class): `replace` and `insertOrReplace`, because they may physically delete an existing already-synchronized row.

### Server Side SyncEngine Implementation

The server side component (`NETCoreSyncServer`) needs to have a custom class that is derived from its abstract `SyncEngine` class. This way, the framework can be directed to communicate with any kind of database. The following shows an example of subclassing the `SyncEngine` class (the `databaseContext` variable is using the Entity Framework Core framework):

```csharp
public class CustomSyncEngine : SyncEngine
{
    private readonly DatabaseContext databaseContext;

    public CustomSyncEngine(DatabaseContext databaseContext)
    {
        this.databaseContext = databaseContext;
    }

    override public long GetNextTimeStamp()
    {
        return databaseContext.GetNextTimeStamp();
    }

    override public IQueryable GetQueryable(Type type)
    {
        if (type == typeof(SyncArea)) return databaseContext.Areas.AsQueryable();
        if (type == typeof(SyncPerson)) return databaseContext.Persons.AsQueryable();
        throw new NotImplementedException();
    }

    override public Dictionary<string, string> ClientPropertyNameToServerPropertyName(Type type)
    {
        if (type == typeof(SyncPerson))
        {
            return new Dictionary<string, string>() { ["clientAreaId"] = "ServerAreaID" };
        }
        return base.ClientPropertyNameToServerPropertyName(type);
    }

    override public void Insert(Type type, dynamic serverData)
    {
        if (type == typeof(SyncArea)) databaseContext.Areas.Add(serverData);
        else if (type == typeof(SyncPerson)) databaseContext.Persons.Add(serverData);
        else throw new NotImplementedException();
        databaseContext.SaveChanges();
    }

    override public void Update(Type type, dynamic serverData)
    {
        if (type == typeof(SyncArea)) databaseContext.Areas.Update(serverData);
        else if (type == typeof(SyncPerson)) databaseContext.Persons.Update(serverData);
        else throw new NotImplementedException();
        databaseContext.SaveChanges();
    }
}
```

 The following lists all of the abstract ``SyncEngine` methods that needs to be implemented (and also `virtual` methods that can be overriden) in the custom class:

- `abstract public long GetNextTimeStamp()`: should return an increasing `long` value that should be consistent and never reset. Usually this is obtained from the server's clock, or a database query that returns the server's epoch millisecond.
- `abstract public IQueryable GetQueryable(Type type)`: should return a LINQ `IQueryable` for the specified `type` parameter. The  `type` parameter value will be one of the model class types that is annotated with  `SyncTable` annotation.
- `abstract public void Insert(Type type, dynamic serverData)`: should perform a database insert here. The `type` parameter value will be one of the model class types that is annotated with  `SyncTable` annotation. The `serverData` will be the object with the type: `type` that needs to be inserted into the database. 
- `abstract public void Update(Type type, dynamic serverData)`: same explanation as the `Insert` method above, but this is for database update operations.
- `virtual public Dictionary<string, string> ClientPropertyNameToServerPropertyName(Type type)`: this is an optional (`virtual`) method that can be used to specify mapping between client field names and their corresponding server field names. If the specified `type` parameter needs to have field name conversion between client and server, then this method should return a `Dictionary` with the client field names that wants to be mapped in the dictionary keys, and the mapped server field names in the dictionary values. By default, this method will return an empty dictionary (no conversion).
- `virtual public dynamic PopulateServerData(Type type, Dictionary<string, object?> clientData, dynamic? serverData)`: this is an optional method to be overriden, and for most cases, this should not be overriden at all. This method populates the `serverData` object with the `clientData` dictionary values. If incoming data is a new data, (where the `serverData` is also null), then the framework will use the .NET Reflection's `Activator.CreateInstance()` with empty constructor (some ORM does not support creating data object with empty constructor, so this will be a good cause to override this method). Also, the default Moor's serialization for `DateTime` value is into epoch millisecond (a number) which is already handled by this default implementation. After the `serverData` is populated, it will be returned at the end of this method.
- `virtual public void ModifySerializedServerData(Dictionary<string, object?> serializedServerData)`: this is an optional method to be overriden. When the server finished serializing its data into a `Dictionary` as specified in the `serializedServerData` parameter, then this is the chance to change the serialization result before transmitted to the clients (if necessary) through the server's response. 

Aside from the implementation of `abstract` and `virtual` methods, The `SyncEngine` also provides a property called `CustomInfo`, implemented as  `Dictionary<string, object?>`, which is the custom information that is passed in during the client `netCoreSyncSynchronize()` method call. This property can then be inspected inside each implementation method, if necessary.

### Server Side Middleware Configuration

Middleware configuration takes place in the web project's `Startup.cs` class. 

#### Intercept Synchronization Request

To intercept synchronization request, use the `SyncEvent` class to register a callback handler that is invoked whenever a client tries to perform synchronization. For example, this can force your users to upgrade their application first before continuing the synchronization process. Application features shall evolve over time along with its database, so the schema may also be changed. The server's database will always likely to represent the latest version, so forcing users to upgrade first is the correct move to do. User upgrades (using Moor's [Migration](https://moor.simonbinder.eu/docs/advanced-features/migrations/) techniques) should bring existing client databases to the latest changes, therefore it will be safe to continue the synchronization process with the server's database.
> Scenarios for supporting backward-compatibility (support older database schemas) seems too complicated, and will likely require `NETCoreSyncServer` component to do complex work and deeper integration, so this is not supported for now.

To use the `SyncEvent` class, the following illustrates its usage:

```csharp
public void ConfigureServices(IServiceCollection services)
{
    // ... some other code here ...
    
    var moorMinimumSchemaVersion = Configuration.GetValue<int>("moorMinimumSchemaVersion");
    SyncEvent syncEvent = new SyncEvent();
    syncEvent.OnHandshake = (request) => 
    {
        if (request.SchemaVersion <= testMinimumSchemaVersion)
        {
            return "Please update your application first before performing synchronization";
        }
        return null;
    };
    
    // ... some other code here ...
}
```

The `SyncEvent.OnHandshake` callback has to return either a `null` value (to indicate that the connected client is allowed to proceed), or a `string` value that explain the reason why the client is not allowed. This returned `string` value will be treated as an `errorMessage` which will be explained in the [Synchronization Result Explanation](#synchronization-result-explanation) section below.

The `SyncEvent.OnHandshake` callback has the `request` parameter, and the `request` parameter carries these information:

- `SchemaVersion`: the Moor client database's `schemaVersion` of the connected client.
- `SyncIdInfo`: the `syncId` and its `linkedSyncIds` of the connected client.
-  `CustomInfo`: a `Dictionary<string, object?>` that can contain custom information which can be passed from the client. This can be used to provide more information to the server that is not provided by the framework. Read about `customInfo` usage in the [Client Side Execute Synchronization](#client-side-execute-synchronization) section.

#### Register SyncEngine Implementation Class Service

After the custom class (the `SyncEngine` implementation class) is ready, it needs to be registered as one of the ServiceCollection using the ASP .NET Core Dependency Injection method. The following shows an example of registering the `CustomSyncEngine` class (which is the implementation class from `SyncEngine`) inside the `Startup`'s `ConfigureServices()` method:

```csharp
public void ConfigureServices(IServiceCollection services)
{
    // ... some other code here ...

    services.AddScoped<SyncEngine, CustomSyncEngine>();

    // ... some other code here ...
}
```

> If using Entity Framework Core, your subclass of `SyncEngine`'s service lifetime is supposed to follow your EF Core `AddDbContext()`'s lifetime, therefore whenever `SyncEngine` subclass is instantiated inside the middleware, it will always have the same lifetime as the database. In the example above, the registration uses `AddScoped()`, because the EF Core `AddDbContext()` by default also uses `AddScoped()`. Also notice that the service type is registered as `SyncEngine` abstract class type, while the implementation uses the subclass (`CustomSyncEngine`) type. 

#### Register NETCoreSyncServer Service

The following shows an example to register the `NETCoreSyncServer` using the ASP .NET Core Dependency Injection method:

> The `SyncEngine` implementation registration above must take place before the `services.AddNETCoreSyncServer()` below.

```csharp
public void ConfigureServices(IServiceCollection services)
{
    // ... some other code here ...

    services.AddNETCoreSyncServer(syncEvent: syncEvent);

    // ... some other code here ...
}
```

#### Register NETCoreSyncServer Middleware Pipeline

The following example shows how to activate the middleware in the pipeline:

> The method call below should take place after the `app.UseRouting()` and before the `app.UseEndpoints()`.

```csharp
public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
{
    // ... some other code here ...

    app.UseNETCoreSyncServer();

    // ... some other code here ...
}
```

By default, the method call above will open a WebSocket listener on: `/netcoresyncserver` path. So, if the web project is configured with https, run on `localhost`, and listening on port 5001, the full url for the WebSocket will be: `wss://localhost:5001/netcoresyncserver`. There is a `NetCoreSyncServerOptions` class that can be instantiated to configure several parameters such as:

- `Path`: by default, the listening path for the WebSocket is `/netcoresyncserver`
- `KeepAliveIntervalInSeconds`: Increase the keep-alive interval if the network connection is not stable. The default value is `120` seconds.
- `SendReceiveBufferSizeInBytes`: The WebSocket buffer size in bytes for processing requests from clients and send responses. The default value is `4096` bytes.

Then the `NetCoreSyncOptions` instance can be passed as an argument for the `app.UseNETCoreSyncServer()` to adjust its WebSocket endpoint behaviors.

### Client Side Synchronization

#### Initiate Synchronization Process

Synchronization process is always initiated by the clients. The following shows an example of client starts a synchronization process:

```dart
  // SyncEvent can be used to show synchronization progress to users
  SyncEvent syncEvent =
      SyncEvent(progressEvent: (eventMessage, indeterminate, value) {
    // Update visual indicators here using the provided parameters
  });

  // Get the database instance here, probably from a state management
  final database = getDatabaseInstance();

  final syncResult = await database.netCoreSyncSynchronize(
    url: "wss://localhost:5001/netcoresyncserver",
    syncEvent: syncEvent,
    syncResultLogLevel: SyncResultLogLevel.fullData,
  );

  if (syncResult.errorMessage != null) {
    // if there's an error happened, the errorMessage contains the String text of the error.
  } else if (syncResult.error != null) {
    // if there's an error happened, the error contains the Object (usually an Exception) of the error.
  } else {
    // The synchronization is finished and successfully executed without errors.
  }
```

The `netCoreSyncSynchronize()` method is the method to initiate synchronization process. The arguments are:
- `url` is the `NETCoreSyncServer` WebSocket url, as explained in the [Register NETCoreSyncServer Middleware Pipeline](#register-netcoresyncserver-middleware-pipeline) section.
- `syncEvent`is the `SyncEvent` object for monitoring the synchronization progress (optional). The `SyncEvent` class will be explained in the following sections.
- `syncResultLogLevel` is an `enum` to indicate the verbosity level of the logs inside the synchronization result. The verbosity levels are: `countsOnly`, `syncFieldsOnly`, and `fullData` (this is the default). The verbosity level will be explained in the following sections.

#### Synchronization Progress Event

The `SyncEvent` class provides information that can be used to display visual indicators for the synchronization progress:
- `eventMessage` is a default text message provided by the framework of each stages that happens in the synchronization. 
- `indeterminate` is a `bool` value that indicates whether the stage can determine a progress value or not. If it is `true`, then the `value` parameter will contain a progress value, and a non-deterministic visual indicator such as `CircleProgressIndicator` can be used. If it is `false`, then a visual indicator such as `LinearProgressIndicator` can be presented with the `value` parameter as its current progression value. 
- `value` is a `double` value that indicates the current stage progression. The `value` parameter is always ranged from `0.0` to `1.0`, so it is already compatible to be used directly with common visual indicators. In the case of non-deterministic (`indeterminate` is false), this value will always be zero.
- To know the exact details of what the `eventMessage` will be, read the [Synchronization Logs](#synchronization-logs) section.

#### Synchronization Result Explanation

The resulted value from the `netCoreSyncSynchronize()` method call is a `SyncResult` type, which has properties to indicate:

- Errors that happens during synchronization process (if any).
- The detailed process steps of the synchronization process.

##### Synchronization Errors

The `SyncResult` type has the following properties to indicate errors:

- `errorMessage`: if an error happens during synchronization, this will be the text value of the error message.
- `error`: if an error happens during synchronization, this will be the `Object` (usually an `Exception`) of the error.

The `errorMessage` and the `error` have these relationships:

- `errorMessage` will always have the `String` representation (using `.toString()`) of the `error`. For any type of `error`, the framework always try to use a "safe and generic" `errorMessage` text, such as: *"Error while connecting to server. Please check your network connection, or try again later."*. This way, the `errorMessage` itself can be directly presented to the end-users. Nevertheless, in production, the `error` object should be checked thoroughly to detect whether it carries sensitive information to be presented to the end-users or not.
- There's a possibility that the `error` object is `null` while the `errorMessage` still contains the error message text. This can be caused by the `syncEvent.OnHandshake()` handler in the server side (as explained in [Intercept Synchronization Request](#intercept-synchronization-request)) returns an error message.

For the `error` object types, the following lists the class type possibilities provided by the framework to indicate various errors:

- `NetCoreSyncNotInitializedException`: The client code hasn't initialized (call the `netCoreSyncInitialize()`) yet.
- `NetCoreSyncSyncIdInfoNotSetException`: The client code tries to do database operations without setting the `SyncIdInfo` first.
- `NetCoreSyncMustNotInsideTransactionException`: This exception is raised if the client code tries to do synchronization inside a Moor's database transaction. Running synchronization inside a transaction is not supported.
- `NetCoreSyncTypeNotRegisteredException`: The framework detects a database operation performed by the client code that uses unregistered table types (the class type is not annotated with `@NetCoreSyncTable`).
- `NetCoreSyncSocketException`: This exception type will be raised for all errors related to WebSockets. For example, an error with this type is raised when the client code tries to perform `netCoreSyncSynchronize()` repeatedly without `await` the results (which make the last active WebSocket still trying to connect to server).
- `NetCoreSyncServerSyncIdInfoOverlappedException`: The `NETCoreSyncServer` server side framework regulates the client synchronization requests. It inspects the `SyncIdInfo` client request, and deny the request with this exception type if the `SyncIdInfo` information (the `syncId` and also its `linkedSyncIds`) overlaps with currently synchronizing clients. This is to ensure that database conflicts can be avoided for clients that have the same `syncId` (or overlapping `linkedSyncIds`).
- `NetCoreSyncException`: the generic type of exception that is generated by the client framework that is not covered in the above explanation.
- `NetCoreSyncServerException`: the generic type of exception that is generated by the server framework that is not covered in the above explanation.

##### Synchronization Logs

The `SyncResult` type has a property called `logs`, which is a list of structured log data (implemented as `List<Map<String, dynamic>>`) that contains full information of the synchronization process steps from start to finish. The ordered stages of synchronization process that is reflected in the log list are:

- `connectRequest`: connection request initiated by the client.
  ```json
  {
    "action":"connectRequest",
    "data":{
      "url":"wss://localhost:5001/netcoresyncserver"
    }
  }
  ```
  - The `data.url` value is the `NETCoreSyncServer` WebSocket url that is specified in the `netCoreSyncSynchronize()` call method.
  - If the `SyncEvent`'s `progressEvent` is configured, its `eventMessage` will be _"Connecting..."_ message.
- `connectResponse`: connection response from server.
  ```json
  {
    "action":"connectResponse",
    "data":{
      "connectionId":"08e63daa-ae3f-44ab-b033-1c102d74cd45"
    }
  }
  ```
  - The `data.connectionId` value is a unique value obtained from the server middleware, which is generated for every client connection. In most cases this information is not necessary, it is only useful for debugging both client and server where this value correlates between them.
- `handshakeRequest`: client is requesting to start the synchronization with the server.
  ```json
  {
    "action":"handshakeRequest",
    "data":{
      "schemaVersion":1,
      "syncIdInfo":{
        "syncId":"aaa",
        "linkedSyncIds":[]
      },
      "customInfo":{
        "a":"abc",
        "b":1000
      }
    }
  }
  ```
  - The `data` properties are the information that is sent by the client, and will be available on the server during the server's `SyncEvent.OnHandshake()` callback handler (the `request` parameter) as explained in the [Intercept Synchronization Request](#intercept-synchronization-request). 
  - If the `SyncEvent`'s `progressEvent` is configured, its `eventMessage` will be _"Acquiring access..."_ message.
- `handshakeResponse`: response from server that allows client to continue the synchronization.
  ```json
  {
    "action":"handshakeResponse",
    "data":{
      "orderedClassNames":[
        "AreaData",
        "Person"
      ]
    }
  }
  ```
  - The `data.orderedClassNames` are the client Moor's data class types that participate in the synchronization process, and ordered as dictated by the server's `SyncTable.order` annotation on each corresponding models.
- `syncTableRequest`: client start sending data that is not synchronized yet to the server for each `orderedClassNames`. So according to the  `handshakeResponse` example above, the `syncTableRequest` will be logged twice (one for the `AreaData` class, and followed by `Person` class). The following shows an example for `AreaData`'s `syncTableRequest`:  
  ```json
  {
    "action":"syncTableRequest",
    "data":{
      "className":"AreaData",
      "annotations":{
        "idFieldName":"pk",
        "syncIdFieldName":"syncSyncId",
        "knowledgeIdFieldName":"syncKnowledgeId",
        "syncedFieldName":"syncSynced",
        "deletedFieldName":"syncDeleted",
        "columnFieldNames":[
          "pk",
          "city",
          "district",
          "syncSyncId",
          "syncKnowledgeId",
          "syncSynced",
          "syncDeleted"
        ]
      },
      "unsyncedRows":[
        {
          "pk":"b13a0305-091e-4160-bf31-127f0edfb124",
          "city":"Tokyo",
          "district":"Shibuya",
          "syncSyncId":"aaa",
          "syncKnowledgeId":"1347ecf8-47f6-496f-a1c3-ed376b959044",
          "syncSynced":false,
          "syncDeleted":false
        }
      ],
      "knowledges":[
        {
          "id":"1347ecf8-47f6-496f-a1c3-ed376b959044",
          "syncId":"aaa",
          "local":true,
          "lastTimeStamp":0,
          "meta":""
        }
      ],
      "customInfo":{
        "a":"abc",
        "b":1000
      }
    }
  }
  ```
  - The `data.annotations` contains the synchronization field names (along with other field names) from the client that is useful in server processing.
  - The `data.unsyncedRows` contains a list of rows for the particular table that is not synchronized yet with the server. The `syncResultLogLevel` enumeration that is passed in as argument in the `netCoreSyncSynchronize()` method call will determine how verbose this list will be:
    - `fullData` (default): the rows will be logged as it is without stripping any information, which can result in large data if the number of unsynchronized rows is high.
    - `syncFieldsOnly`: the rows will be logged with its synchronization fields only, other fields will be stripped (omitted).
    - `countsOnly`: the rows list will be replaced by a single number that indicates the number of the actual rows.
  - The `data.knowledges` is an internal information sent by the client framework to indicate the current knowledge of the client data. For more information about `knowledges`, read the detailed explanation in the [How It Works](#how-it-works) section.
  - The `data.customInfo` is the same as the custom information that is passed in the `netCoreSyncSynchronize()` method call.
  - If the `SyncEvent`'s `progressEvent` is configured, its `eventMessage` will be _"Synchronizing..."_ message, with `indeterminate` is set to `false`, and the `value` contains a `double` value ranged from `0.0` to `1.0` that tells the progression value, starting from the first table to the last table.
- `syncTableResponse`: the server respond back to the client's last `syncTableRequest`, which means that for each `syncTableRequest` there will be a corresponding `syncTableResponse`. The following shows an example of `syncTableResponse` for the last `AreaData`'s `syncTableRequest`:  
  
  ```json
  {
    "action":"syncTableResponse",
    "data":{
      "className":"AreaData",
      "annotations":{
        "timeStampFieldName":"timeStamp",
        "idFieldName":"id",
        "syncIdFieldName":"syncID",
        "knowledgeIdFieldName":"knowledgeID",
        "deletedFieldName":"deleted"
      },
      "unsyncedRows":[],
      "knowledges":[
        {
          "id":"1347ecf8-47f6-496f-a1c3-ed376b959044",
          "syncId":"aaa",
          "local":true,
          "lastTimeStamp":1629955542602,
          "meta":""
        }
      ],
      "deletedIds":[],
      "logs":{
        "inserts":[
          {
            "id":"b13a0305-091e-4160-bf31-127f0edfb124",
            "city":"Tokyo",
            "district":"Shibuya",
            "syncID":"aaa",
            "knowledgeID":"1347ecf8-47f6-496f-a1c3-ed376b959044",
            "deleted":false,
            "timeStamp":1629955542602
          }
        ],
        "updates":[],
        "deletes":[],
        "ignores":[]
      }
    }
  }
  ```
  - The `data.annotations` contains the synchronization field names (along with other field names) from the server that is useful in client processing.
  - The `data.unsyncedRows` contains a list of rows for the particular table that the server knows, but they are not known by the client (for example, the data was created by the user on other devices, or created by other user that is allowed to modify the user's data through `linkedSyncIds`), based on the last `knowledges` that the client sent earlier in the `syncTableRequest`. The verbosity level of these rows are also affected by the `syncResultLogLevel` enumeration, as explained in the `syncTableRequest`'s `data.unsyncedRows` explanation.
  - The `data.knowledges` is an internal information that the server replied back (based on the last `syncTableRequest`'s `data.knowledges`) to the client. Esentially the rows are the same with the request, but their `lastTimeStamp` values are already up-to-date from the server. For more information about `knowledges`, read the detailed explanation in the [How It Works](#how-it-works) section.
  - The `data.deletedIds` is an internal information that contains which rows that have been deleted in the server, so the client framework can adjust its data accordingly. For more info about this, read the detailed explanation in the [How It Works](#how-it-works) section.
  - The `data.logs` object is the result of server data modification for the rows that was sent in the `syncTableRequest`'s `data.unsyncedRows` earlier. It contains different lists for each different database operations, such as `inserts`, `updates`, and `deletes` (The `ignores` list is used to handle an already deleted row is synchronized to the client. For more info about this, read the detailed explanation in the [How It Works](#how-it-works) section). Each data inside each list is also affected by the `syncResultLogLevel` enumeration, as explained in the `syncTableRequest`'s `data.unsyncedRows` explanation.
- `responseApplyRows`: This is the result of client data modification for the rows that was sent by the server in the `syncTableResponse`'s `data.unsyncedRows` earlier. The following shows an example of `responseApplyRows` for the last `AreaData`'s `syncTableResponse`:  
  
  ```json
  {
    "action":"responseApplyRows",
    "data":{
      "className":"AreaData",
      "logs":{
        "inserts":[],
        "updates":[],
        "deletes":[],
        "ignores":[],
        "deletedIds":[]
      }
    }
  }
  ```
  - The `data.logs` object explanation is the same as the `syncTableResponse`'s `data.logs` object. The difference is, it contains the `deletedIds` list, which has the same explanation as the `syncTableResponse`'s `data.deletedIds`.
- `closeRequest`: close request initiated by the client.
  ```json
  {
     "action":"closeRequest",
     "data":{}
  }
  ```
  - If the `SyncEvent`'s `progressEvent` is configured, its `eventMessage` will be _"Disconnecting..."_ message.
- `closeResponse`: close response from server.
  
  ```json
  {
     "action":"closeResponse",
     "data":{}
  }
  ```
