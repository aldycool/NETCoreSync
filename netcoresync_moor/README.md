# netcoresync_moor

Dart / Flutter Client (opinionated to Moor) for NETCoreSync (a data synchronization library / server component implemented using .NET Core).

## Usage Example

Please check the NETCoreSync's example that uses Flutter [here](https://github.com/aldycool/NETCoreSync/tree/master/Samples/Flutter). The server-side uses .NET Core 5.0 + EntityFramework Core + PostgreSQL, while the client-side uses Flutter + Moor as its offline database. The Flutter project supports all platforms, including Android, iOS, Windows, MacOS, Linux, and Web. Read the documentation on how to deploy the clients. **NOTE: FLUTTER SYNC IS STILL IN WORKS!**

## Notes

- Generate builds:
  ```sh
  flutter packages pub run build_runner clean
  flutter clean
  flutter pub get
  flutter packages pub run build_runner build --delete-conflicting-outputs
  ```

## Dev Notes

- Update 210707: After seeing latest efforts in testing the concepts, it seems that at this point which is only half the battle (doing getters and setters with `reflectable` on Moor's custom row classes), not to mention the rest of the way (making Moor's "queryables" to work with reflection, etc), most likely the pristine approach of NETCoreSync's "database-agnostic" will be dropped in favor of "Moor-opinionated", because if we keep moving forward, there will be a LOT of work when we try to subclassing the `SyncEngine` in Dart / Flutter environment (due to the lack of Reflection in Flutter). I feel that everybody is leaning towards "code-generation" approaches to overcome the lack of reflection support in Flutter. So the next move now, is to design a "builder" that works on top of the Moor's generated file, to make it very easy to work with Flutter-based NETCoreSync.
- SyncConfiguration does not support assemblies, and by default uses DatabaseTimeStamp strategy, so any non-related functions will be ommited. Also don't be opiniated to Moor, at the very least we only need what are the extended property names are (lastUpdated, deleted, databaseInstanceId) of every Type processed.
- Combination of synchronizationId + databaseInstanceId make up a unique User with its one device, so if he have two devices, he should have a single synchronizationId with two different databaseInstanceId.
- The HookPreInsertOrUpdateDatabaseTimeStamp + HookPreDeleteDatabaseTimeStamp is modifying the extended properties (lastUpdated, deleted, databaseInstanceId) for you, don't do it yourself
- On clients (not on server database where it should keep track all users data) the synchronizationId should not be persisted to Knowledge table because it is assumed the the client's database will only have one user data (TO BE INVESTIGATED, BECAUSE WE WILL NEED TO SUPPORT IMPORTING OTHER USER DATA LATER). UPDATE: I think now we have to change all approaches to be like Server-To-Server if we want our users to import and modify each other's data, still in thinking cap...
- Should rename HookPreInsertOrUpdateDatabaseTimeStamp => HookPreInsertOrUpdate 
- DART IN FLUTTER DOESN'T HAVE REFLECTION, read more below! Dart should be able to get/set value to an object based on string name
- OK - Dart should be able to pass by ref (modify the passed object properties) and have the modification on the next codes.
- Flutter doesn't support dart:mirrors (NO REFLECTION SUPPORT), and I know there's a package called `reflectable.dart`, but still.. read the next point.
- Avoid using too many package dependencies, in my experience, the more you use external dependencies, the higher the risk of something breaks in the future
- We may have to continue without reflection, just use interfaces (and more work on the implementation to assign `lastUpdated`, etc.)
- Also I'd like to stay with the current server-side .NET Core with no changes (if possible)
