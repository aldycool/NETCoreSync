## Notes on SQLite libraries

- Windows: Download the SQLite binaries for windows here: https://www.sqlite.org/2021/sqlite-dll-win64-x64-3360000.zip, unzip and copy the sqlite3.dll into the same folder as the client_app.exe file.
- Linux: on Ubuntu Desktop 20.04: `apt-get install libsqlite3-dev`
- MacOS, Android, iOS, Web: No special instructions necessary, just run it.

## General Notes

- As per writing (2021-Jul-16), the tests and also the library functions supports `insertReturning` (and its sync equivalent: `syncInsertReturning`), but, neither android, ios, macos or maybe other platforms shipped with the required sqlite version (3.35), so manual installation (or packaging in the output) is necessary to install the sqlite 3.35 or newer. Read more about this issue [here](https://github.com/simolus3/moor/issues/1096).

- Clean Generate builds:

  ```sh
  flutter packages pub run build_runner clean
  flutter clean
  flutter pub get
  flutter packages pub run build_runner build --delete-conflicting-outputs
  ```

- Unit tests Code Coverage:

  - ensure the `lcov` application is installed: `brew install lcov` (this installs the `genhtml` application).
  - on the root folder: `flutter test --coverage`, this will create a folder `coverage` with a file `lcov.info` inside.
  - on the root folder: `genhtml -o coverage/genhtml coverage/lcov.info`, this will generate test reports in html files, the starting html index file is in `coverage/genhtml/index.html`.
  - NOTE: by default, the `coverage` folder is git-ignored.

## Dev Notes

- OK (using 'normalizedTable') - Put checks on syncInto + syncUpdate + syncDelete, the passed in table should NOT be in the sync form (this raise an error of malformed sql such as: INSERT INTO (SELECT * FROM ...))
- On the server side, circular reference errors could happen if the model classes contains navigation properties (child that has its parent property or parent that has its children property). Ideally, this should be handled by users by attributing those navigation properties with `[JsonIgnore]`. By design, NETCoreSyncServer is expecting that the models are properly annotated, and its SyncEngine.SerializeServerData() is implemented by this expectation (doing straight serialization), so it is the responsibility of the users to annotate the models properly, or just override the SyncEngine.SerializeServerData() to be implemented by their specific needs. To automatically ignore this circular reference, it can also be handled in NETCoreSyncServer by using the ReferenceHandler.IgnoreCycles, but, as per writing, this is only supported on .NET 6, which still in preview, so using the Preserve for now.
- Sometimes VSCode may throw an error when debugging dotnet, such as the dotnet executable cannot be found. Workaround that works was: disable and enable the C# extension, close VSCode, open it again and try loading a plain Web Api project and see if we can start debugging in it, and then back to the original project, the debugging should start normally again. So this weirdness in VSCode just has been found, and previously, the code in NetCoreTestServer failed to resolve "dotnet" executable using Dart's Process.Run (which was previously fine). This happens after I restarted my Mac. The code is already removed (and replaced by a hard-coded string gotten from "which dotnet"). Pay attention to this situation later to see why this is happening.
- As for database-level uniqueness, as per writing, the current client's SQLite + server's PostgreSQL are equipped with unique indexes on some tables to test the behavior of standard database-level constraint (on client moor's behavior test only). BUT, in real practice later, I don't think we can force uniqueness whatsoever, especially if we're going to use synchronization, for example: the Area table has the unique City name (users cannot input the same City name). Of course we can enforce it on a single device, but, if that user have other device with the same account, there's nothing that can prevent him (unless checking using sync, which we cannot always guarantee to be always performed) to enter the same City name on that other device. So for now, on production, do not enforce uniqueness.
- OK - Make effort later to reduce the generated code, remove stuffs that is not necessary.
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