# netcoresync_moor's Synchronization Logic

## Introduction

This page provides in-depth explanation about the synchronization logic used in the [netcoresync_moor](https://github.com/aldycool/NETCoreSync/tree/master/netcoresync_moor) client package and its server counterpart, the [NETCoreSyncServer](https://github.com/aldycool/NETCoreSync/tree/master/NETCoreSyncServer) package. The synchronization logic approach is called the **ServerTimeStamp** approach. Why this is named like this? because this is the latest evolution from previously existing logic approaches in the [NETCoreSync](https://github.com/aldycool/NETCoreSync) framework. Ordered from the oldest to the newest, the previous logic are:

- [GlobalTimeStamp](https://github.com/aldycool/NETCoreSync/blob/master/NetCoreSync/docs/global-timestamp-how-it-works.md), where synchronization between server and clients uses the world clock (the system's Date Time) when comparing a data that exist in both source and destination. This has a drawback that needs the time source to be stable and unchanged (which are not possible in mobile devices where users can change the device's date).
- [DatabaseTimeStamp](https://github.com/aldycool/NETCoreSync/blob/master/NetCoreSync/docs/database-timestamp-how-it-works.md), where synchronization between server and clients uses their own _internal time stamp_ (represented in `long` value) when comparing a data that exist in both source and destination. This also has a drawback, where this approach cannot support a needed feature called called "linkedSyncId", where a single user account can be linked with several different user accounts to allow them to share data among themselves (they can modify each other data), and those changes can still be synchronized back to each user account devices.
- ServerTimeStamp, the synchronization is slightly modified from DatabaseTimeStamp approach, where only the server component that keeps the time stamp, and client databases do not keep their own internal time stamp (just use boolean flags only). This allows the "linkedSyncId" feature to be implemented here.

Consider the following scenario about the drawback of the DatabaseTimeStamp approach (which is eliminated by using the ServerTimeStamp approach):

> The DatabaseTimeStamp have flaws, where it doesn't properly handle on how different syncIds (synchronization IDs in DatabaseTimeStamp's terminology) allow editing a same existing row. For example, a syncId ABC is allowed to sync data from another syncId DEF, where ABC is allowed to read, edit, delete, and add data on behalf of DEF. Because the DatabaseTimeStamp works by inserting a "timeStamp" value that is coming from internal device-wise "Knowledge" counter into the modified data, how can ABC edit a data that is coming from DEF? what "timeStamp" value that should be inserted by ABC into that data? this is because that data is coming from DEF, where its "timeStamp" is originally coming from the internal "Knowledge" counter that only resides in the DEF's device. This is the problem.

The GlobalTimeStamp and DatabaseTimeStamp only exists in previous version of NETCoreSync which is implemented under Xamarin. Moving forward, the ServerTimeStamp in Flutter version will be the primary development to have periodical updates and improvements, while the Xamarin version will remain as a backward-compatible solution only.

## Conflict Resolution

The ServerTimeStamp approach is automatically have these behaviors for conflict resolution:
- In the event of a single data insert, because of the required database design have stated that each data must have a unique primary key, there would be no conflict during insert operations.
- In the event of a single data update, the last synchronized data is always wins (means it will replace any previous data that was synchronized last time). This is actually follows what Google does to synchronize its online products (read more in detail [here](https://softwareengineering.stackexchange.com/questions/153806/conflict-resolution-for-two-way-sync).
- In the event of a single data delete, because of the required database design have stated that delete operations must use **Soft-Delete** approach (data is not physically deleted from table, only flagged as deleted), the missing foreign key conflict would never occur.

## Key Points

- We will classify the synchronization process into two activities: **Upload** and **Download**.
- To follow Google's behavior where the last synchronization wins, Upload should be performed first, and then the Download follows. This is to ensure whatever updates made in the client shall be saved on the server, this is to reflect whoever perform the sync last will win.
- Also, server's database should be treated as a single source repository. This means that even if we have a web client, it should not modify directly into the server's database, it should behave as just another client with the same synchronization mechanism.
- For upload purposes, tables in the client should have these special columns (known as **client synchronization fields**):
  - `id`: the primary key column which should be unique among all data. This is usually implemented using GUID or uuid.
  - `syncId`: a unique user identification value, which can have one or more databases on each separate devices on all platforms.
  - `knowledgeId`: a unique value that is generated by the framework. This value is unique among devices. In correlation with `syncId` means that, if there is a user with three separate devices, then the `syncId` for that user should be the same, but there will be three different `knowledgeId` that is owned by that `syncId` where each of the `knowledgeId` is generated by each devices.
  - `synced`: a flag to indicate whether this particular row has been synchronized or not. After every modification of any data in client's database, the `synced` value shall be marked as `false` to be picked up by the upload process during synchronization. After the synchronization has finished, the uploaded rows will have their `synced` values set to `true`.
  - `deleted`: a flag to indicate whether this particular row is already deleted or not.
- For download purposes, the framework will create one special table called `knowledge`, that contains these columns:
  - `id`: a unique value generated by the framework, and actually this is the `knowledgeId` value explained above that will be inserted by the framework into the synchronized tables.
  - `syncId`: the same as the `syncId` explanation above (unique user identification value).
  - `lastTimeStamp`: a number value to keep track of the server's last time stamp for this particular `knowledge`. This value is generated by the server.
  - `local`: a flag to indicate whether this `knowledge` row is the primary device identification for the logged-in user or not. At the start of the first insert of any data into a synchronized table, the framework will check the `knowledge` table to ensure it has exactly one row for the current active (logged-in) `syncId` with its `local` set to `true`,  and the `lastTimeStamp` value should be zero at first, and the `syncId` will be specified with the user's unique account. This row will be known as the local knowledge row for the current client's database for the current user. Next, if the user have different devices, there will be additional rows with `local` set to  `false` but with the same `syncId`. Also, there will be other rows with different `syncId`s to denote other users. These rows with different `syncId`s is actually called the *"linked syncIds"*, marked with their  `local` set to `false`. This means that the current active `syncId` is allowed to "link" to the other `syncId`, and able to add, edit, or delete on behalf of the other `syncId`'s data. But, if these rows have been marked with its `local` set to `true`, this means that this other `syncId` has been logged in to this device. So the `knowledge` table uniqueness shall be specified by unique `id` (known as `knowledgeId`) + `syncId`, and for each combination of `id` + `syncId`, there can be only one row that is marked with `local` = `true` (or only `local` = `false` if the `syncId` has never been logged into this device).
- On the server side, each corresponding synchronized tables should have these special columns (known as **server synchronization fields**): 
  - `id`: the primary key column which should be unique among all data. This is usually implemented using GUID or uuid.
  - `syncId`: the same as the `syncId` explanation above (unique user identification value).
  - `knowledgeId`: the same as the `knowledgeId` explanation above (unique device identification value).
  - `timeStamp`: a number value generated by the server component for this row.
  - `deleted`: the same as the `deleted` explanation above (to indicate if this row is already deleted or not).
  When the client starts the download, the client shall inform the server of the "knowledge" that it knew so far (from the `knowledge` table where the client shall send all of the `knowledge` for the logged-in `syncId`, or, if it has been linked to several other `syncId`s, then those `knowledge` rows shall also be sent), so the server will know what data to send back to the client. After all the downloaded data have been saved by the client (and updated with their `synced` value set to `true`), server also send back the client's `knowledge` information where each of the `knowledge` row has been updated with the latest Server's `timeStamp` value (or maybe along with some other new `knowledge` rows that the client has never knew about) of the downloaded data, so it can be persisted in the client's `knowledge` table.

## Synchronization Fields Behavior

The following lists the behavior of synchronization field values on different database operations (insert / update / delete) on client and on server.

### Client Sync Fields Behavior

- Inserts: 
  - `syncId` = taken from primary (logged in) `syncId`, unless there's a mode to act on behalf of other linked user, `syncId` should follow the other user's `syncId`.
  - `knowledgeId` = taken from `id` of the `knowledge` table where the `syncId` matched the logged in user and its `local` is `true`. If the operation is performed on behalf some other linked user's `syncId`, this value should also be the same (still using the `id` from the original `syncId` + `local` = `true` row). This will be fine, assuming that when the other user is synchronizing, this will be picked up and will be considered as the other user's data but on different device. But, if other `syncId` (other user) has logged into the device, then a new row with the other `syncId` + `local` = `true` should be generated first, and this value is taken from the id of this row (as explained above).
	- `synced` = `false`
	- `deleted` = `false`
- Updates:
  - `syncId` = ignored (no change)
  - `knowledgeId` = ignored (no change)
  - `synced` = `false`
  - `deleted` = ignored (no change)
- Deletes (_soft delete_ approach):
  - `syncId` = ignore
  - `knowledgeId` = ignore
  - `synced` = `false`
  - `deleted` = `true`
- When Upload completes: all uploaded data will have their `synced` values set to `true`.
- When Downloading and writing into local database, all `synced` values will be set to `true`. The rule for handling an incoming server data's `deleted` flag:
  - If incoming `deleted` is ` false`, then proceed as usual.
  - If incoming `deleted` is `true` and its `id` is found in the local table, then proceed as usual.
  - If incoming `deleted` is `true` and its `id` is not found in the local table, then ignore the write. 

### Server Sync Fields Behavior

_(Unless the column value is stated, the column values will follow the original values from client's incoming data)._

- Inserts:
  - `timeStamp` = Server will generate an increasing integer (known as _timestamp_) typically from the server's clock, and should not be reset at all.
- Updates:
  - `timeStamp` = same behavior as Inserts above.
  - `deleted` = The rule for handling an incoming client data's `deleted` flag:
    - If incoming `deleted` is `true` or `false` and the existing `deleted` in server is `false`, follow the incoming value.
    - If incoming `deleted` is `false` and the existing `deleted` in server is `true`, ignore the modification and take note of this row to be informed later in the server response that this row has been deleted
    - If incoming `deleted` is `true` and the existing `deleted` in server is `true`, ignore the modification _(theoretically this situation will never happen since deleted row can never be modified, therefore its synced value will never be false and never be picked up by upload process)_.
- Deletes:
  - By design, there will be no delete (physical delete) operation running on server.

## Simulation

The following simulate the above logic. "Server" is the server component that have its consolidated database for all users (or known as `syncId`), and "Client" can be considered as a user's device (computer / phone / web) that have its own local database. "Client1" and "Client2" means different devices for the same `syncId`.

> These simulation steps are also already made as a unit test in the `netcoresync_moor` package [here](https://github.com/aldycool/NETCoreSync/blob/master/netcoresync_moor/test/integration_tests/netcoresync_sync_test.dart) (in a `test` section called _SyncSession Synchronize_) to ensure the synchronization logic is always work as intended.

### Activity 1: Client1 Insert + Sync

- Client1 login with syncId=abc, Other allowed syncIds=None for now
- Client1 First Time Prepare Local Knowledge: id=k1, syncId=abc, local=true, lastTimeStamp=0
- Client1 Insert Person: id=guid1, syncId=abc, knowledgeId=k1, name=A, synced=false, deleted=false
- Client1 Sync Request: abc + k1 = 0 -> Query WHERE synced = false -> payload = guid1
- Server Insert Person: id=guid1, syncId=abc, knowledgeId=k1, name=A, timeStamp=100, deleted=false
- Server Query WHERE syncId IN (abc) AND id NOT IN (guid1) AND ( (knowledgeId=k1 And timeStamp > 0) OR (knowledgeId NOT IN (k1)) )
- Server Sync Response: abc + k1 = 100, payload = None
- Client1 saved Knowledge from Server + Update synced = true for: guid1

#### Post-Activity Data

- Client1 - Knowledge:
  - id=k1, syncId=abc, local=true, lastTimeStamp=100
- Client1 - Person:
  - id=guid1, syncId=abc, knowledgeId=k1, name=A, synced=true, deleted=false
- Server - Person:
  - id=guid1, syncId=abc, knowledgeId=k1, name=A, timeStamp=100, deleted=false

### Activity 2: On Client1 No Changes + Sync

- Client1 Sync Request: abc + k1 = 100 -> Query WHERE synced = false -> payload = None
- Server Query WHERE syncId IN (abc) AND ( (knowledgeId=k1 And timeStamp > 100) OR (knowledgeId NOT IN (k1)) )
- Server Sync Response: abc + k1 = 100, payload = None
- Client1 saved Knowledge from Server

#### Post-Activity Data

(Same as Previous Activity)

### Activity 3: Client1 Update + Sync

- Client1 Update Person: id=guid1, syncId=abc, knowledgeId=k1, name=B, synced=false, deleted=false
- Client1 Sync Request: abc + k1 = 100 -> Query WHERE synced = false -> payload = guid1
- Server Update Person: id=guid1, syncId=abc, knowledgeId=k1, name=B, timeStamp=101, deleted=false
- Server Query WHERE syncId IN (abc) AND id NOT IN (guid1) AND ( (knowledgeId=k1 And timeStamp > 100) OR (knowledgeId NOT IN (k1)) )
- Server Sync Response: abc + k1 = 101, payload = None
- Client1 saved Knowledge from Server + Update synced = true for: guid1

#### Post-Activity Data

- Client1 - Knowledge:
  - id=k1, syncId=abc, local=true, lastTimeStamp=101
- Client1 - Person:
  - id=guid1, syncId=abc, knowledgeId=k1, name=B, synced=true, deleted=false
- Server - Person:
  - id=guid1, syncId=abc, knowledgeId=k1, name=B, timeStamp=101, deleted=false

### Activity 4: Client2 Insert + Sync, Client1 Sync

- Client2 login with syncId=abc, Other allowed syncIds=None for now
- Client2 First Time Prepare Local Knowledge: id=k2, syncId=abc, local=true, lastTimeStamp=0
- Client2 Insert Person: id=guid2, syncId=abc, knowledgeId=k2, name=C, synced=false, deleted=false
- Client2 Sync Request: abc + k2 = 0 -> Query WHERE synced = false -> payload = guid2
- Server Insert Person: id=guid2, syncId=abc, knowledgeId=k2, name=C, timeStamp=102, deleted=false
- Server Query WHERE syncId IN (abc) AND id NOT IN (guid2) AND ( (knowledgeId=k2 And timeStamp > 0) OR (knowledgeId NOT IN (k2)) )
- Server Sync Response: abc + k2 = 102, abc + k1 = 101, payload = guid1
- Client2 Insert Person: id=guid1, syncId=abc, knowledgeId=k1, name=B, synced=true, deleted=false
- Client2 saved Knowledge from Server + Update synced = true for: guid2
- Client1 Sync Request: abc + k1 = 101 -> Query WHERE synced = false -> payload = None
- Server Query WHERE syncId IN (abc) AND ( (knowledgeId=k1 And timeStamp > 101) OR (knowledgeId NOT IN (k1)) )
- Server Sync Response: abc + k2 = 102, abc + k1 = 101, payload = guid2
- Client1 Insert Person: id=guid2, syncId=abc, knowledgeId=k2, name=C, synced=true, deleted=false
- Client1 saved Knowledge from Server

#### Post-Activity Data

- Client1 - Knowledge:
  - id=k1, syncId=abc, local=true, lastTimeStamp=101
  - id=k2, syncId=abc, local=false, lastTimeStamp=102
- Client1 - Person:
  - id=guid1, syncId=abc, knowledgeId=k1, name=B, synced=true, deleted=false
  - id=guid2, syncId=abc, knowledgeId=k2, name=C, synced=true, deleted=false
- Client2 - Knowledge:
  - id=k2, syncId=abc, local=true, lastTimeStamp=102
  - id=k1, syncId=abc, local=false, lastTimeStamp=101
- Client2 - Person:
  - id=guid2, syncId=abc, knowledgeId=k2, name=C, synced=true, deleted=false
  - id=guid1, syncId=abc, knowledgeId=k1, name=B, synced=true, deleted=false
- Server - Person:
  - id=guid1, syncId=abc, knowledgeId=k1, name=B, timeStamp=101, deleted=false
  - id=guid2, syncId=abc, knowledgeId=k2, name=C, timeStamp=102, deleted=false

### Activity 5: Client1 Insert + Update Client2, Client2 Insert + Update Client1, Client1 Sync, Client2 Sync, Client1 Sync

- Client1 Insert Person: id=guid3, syncId=abc, knowledgeId=k1, name=E, synced=false, deleted=false
- Client1 Update Person: id=guid2, syncId=abc, knowledgeId=k2, name=F, synced=false, deleted=false
- Client2 Insert Person: id=guid4, syncId=abc, knowledgeId=k2, name=G, synced=false, deleted=false
- Client2 Update Person: id=guid1, syncId=abc, knowledgeId=k1, name=H, synced=false, deleted=false
- Client1 Sync Request: abc + k1 = 101, abc + k2 = 102 -> Query WHERE synced = false -> payload = guid3, guid2
- Server Insert Person: id=guid3, syncId=abc, knowledgeId=k1, name=E, timeStamp=103, deleted=false
- Server Update Person: id=guid2, syncId=abc, knowledgeId=k2, name=F, timeStamp=104, deleted=false 
- Server Query WHERE syncId IN (abc) AND id NOT IN (guid3, guid2) AND ( (knowledgeId=k1 AND timeStamp > 101) OR (knowledgeId=k2 And timeStamp > 102) OR (knowledgeId NOT IN (k1, k2)) )
- Server Sync Response: abc + k1 = 103, abc + k2 = 104, payload = None
- Client1 saved Knowledge from Server + Update synced = true for: guid3, guid2
- Client2 Sync Request: abc + k2 = 102, abc + k1 = 101 -> Query WHERE synced = false -> payload = guid4, guid1
- Server Insert Person: id=guid4, syncId=abc, knowledgeId=k2, name=G, timeStamp=105, deleted=false
- Server Update Person: id=guid1, syncId=abc, knowledgeId=k1, name=H, timeStamp=106, deleted=false 
- Server Query WHERE syncId IN (abc) AND id NOT IN (guid4, guid1) AND ( (knowledgeId=k2 AND timeStamp > 102) OR (knowledgeId=k1 And timeStamp > 101) OR (knowledgeId NOT IN (k1, k2)) )
- Server Sync Response: abc + k2 = 105, abc + k1 = 106, payload = guid2, guid3
- Client2 Update Person: id=guid2, syncId=abc, knowledgeId=k2, name=F, synced=true, deleted=false
- Client2 Insert Person: id=guid3, syncId=abc, knowledgeId=k1, name=E, synced=true, deleted=false
- Client2 saved Knowledge from Server + Update synced = true for: guid4, guid1
- Client1 Sync Request: abc + k1 = 103, abc + k2 = 104 -> Query WHERE synced = false -> payload = None
- Server Query WHERE syncId IN (abc) AND ( (knowledgeId=k1 AND timeStamp > 103) OR (knowledgeId=k2 And timeStamp > 104) OR (knowledgeId NOT IN (k1, k2)) )
- Server Sync Response: abc + k2 = 105, abc + k1 = 106, payload = guid1, guid4
- Client1 Update Person: id=guid1, syncId=abc, knowledgeId=k1, name=H, synced=true, deleted=false
- Client1 Insert Person: id=guid4, syncId=abc, knowledgeId=k2, name=G, synced=true, deleted=false
- Client1 saved Knowledge from Server

#### Post-Activity Data

- Client1 - Knowledge:
  - id=k1, syncId=abc, local=true, lastTimeStamp=106
  - id=k2, syncId=abc, local=false, lastTimeStamp=105
- Client1 - Person:
  - id=guid1, syncId=abc, knowledgeId=k1, name=H, synced=true, deleted=false
  - id=guid2, syncId=abc, knowledgeId=k2, name=F, synced=true, deleted=false
  - id=guid3, syncId=abc, knowledgeId=k1, name=E, synced=true, deleted=false
  - id=guid4, syncId=abc, knowledgeId=k2, name=G, synced=true, deleted=false
- Client2 - Knowledge:
  - id=k2, syncId=abc, local=true, lastTimeStamp=105
  - id=k1, syncId=abc, local=false, lastTimeStamp=106
- Client2 - Person:
  - id=guid2, syncId=abc, knowledgeId=k2, name=F, synced=true, deleted=false
  - id=guid1, syncId=abc, knowledgeId=k1, name=H, synced=true, deleted=false
  - id=guid3, syncId=abc, knowledgeId=k1, name=E, synced=true, deleted=false
  - id=guid4, syncId=abc, knowledgeId=k2, name=G, synced=true, deleted=false
- Server - Person:
  - id=guid1, syncId=abc, knowledgeId=k1, name=H, timeStamp=106, deleted=false
  - id=guid2, syncId=abc, knowledgeId=k2, name=F, timeStamp=104, deleted=false
  - id=guid3, syncId=abc, knowledgeId=k1, name=E, timeStamp=103, deleted=false
  - id=guid4, syncId=abc, knowledgeId=k2, name=G, timeStamp=105, deleted=false

### Activity 6: Client1 Delete Client2, Client2 Update, Client1 Sync, Client2 Sync, Client1 Sync

- Client1 Delete Person: id=guid4, syncId=abc, knowledgeId=k2, name=G, synced=false, deleted=true
- Client2 Update Person: id=guid4, syncId=abc, knowledgeId=k2, name=I, synced=false, deleted=false
- Client1 Sync Request: abc + k1 = 106, abc + k2 = 105 -> Query WHERE synced = false -> payload = guid4
- Server Update Person: id=guid4, syncId=abc, knowledgeId=k2, name=G, timeStamp=107, deleted=true 
- Server Query WHERE syncId IN (abc) AND id NOT IN (guid4) AND ( (knowledgeId=k1 AND timeStamp > 106) OR (knowledgeId=k2 And timeStamp > 105) OR (knowledgeId NOT IN (k1, k2)) )
- Server Sync Response: abc + k1 = 106, abc + k2 = 107, payload = None
- Client1 saved Knowledge from Server + Update synced = true for: guid4
- Client2 Sync Request: abc + k1 = 106, abc + k2 = 105 -> Query WHERE synced = false -> payload = guid4
- Server Update Person: id=guid4, syncId=abc, knowledgeId=k2, name=I, timeStamp=108, deleted=true (inform deleted later)
- Server Query WHERE syncId IN (abc) AND id NOT IN (guid4) AND ( (knowledgeId=k1 AND timeStamp > 106) OR (knowledgeId=k2 And timeStamp > 105) OR (knowledgeId NOT IN (k1, k2)) )
- Server Sync Response: abc + k1 = 106, abc + k2 = 108, payload = None, deleted = guid4
- Client2 saved Knowledge from Server + Update synced = true for: guid4, deleted = true for: guid4
- Client1 Sync Request: abc + k1 = 106, abc + k2 = 107 -> Query WHERE synced = false -> payload = None
- Server Query WHERE syncId IN (abc) AND ( (knowledgeId=k1 AND timeStamp > 106) OR (knowledgeId=k2 And timeStamp > 107) OR (knowledgeId NOT IN (k1, k2)) )
- Server Sync Response: abc + k1 = 106, abc + k2 = 108, payload = guid4
- Client1 Update Person: id=guid4, syncId=abc, knowledgeId=k2, name=I, synced=true, deleted=true
- Client1 saved Knowledge from Server
- _=== Start Alternate Situation for Client2 (if Client2 doesn't update its data and just Sync only) ===_
  - Client2 Sync Request: abc + k1 = 106, abc + k2 = 105 -> Query WHERE synced = false -> payload = None
  - Server Query WHERE syncId IN (abc) AND ( (knowledgeId=k1 AND timeStamp > 106) OR (knowledgeId=k2 And timeStamp > 105) OR (knowledgeId NOT IN (k1, k2)) )
  - Server Sync Response: abc + k1 = 106, abc + k2 = 107, payload = guid4
  - Client2 Update Person: id=guid4, syncId=abc, knowledgeId=k2, name=G, synced=true, deleted=true
  - Client2 saved Knowledge from Server

  _=== End Alternate Situation for Client2 ===_

#### Post-Activity Data

- Client1 - Knowledge:
  - id=k1, syncId=abc, local=true, lastTimeStamp=106
  - id=k2, syncId=abc, local=false, lastTimeStamp=108
- Client1 - Person:
  - id=guid1, syncId=abc, knowledgeId=k1, name=H, synced=true, deleted=false
  - id=guid2, syncId=abc, knowledgeId=k2, name=F, synced=true, deleted=false
  - id=guid3, syncId=abc, knowledgeId=k1, name=E, synced=true, deleted=false
  - id=guid4, syncId=abc, knowledgeId=k2, name=I, synced=true, deleted=true
- Client2 - Knowledge:
  - id=k2, syncId=abc, local=true, lastTimeStamp=108
  - id=k1, syncId=abc, local=false, lastTimeStamp=106
- Client2 - Person:
  - id=guid2, syncId=abc, knowledgeId=k2, name=F, synced=true, deleted=false
  - id=guid1, syncId=abc, knowledgeId=k1, name=H, synced=true, deleted=false
  - id=guid3, syncId=abc, knowledgeId=k1, name=E, synced=true, deleted=false
  - id=guid4, syncId=abc, knowledgeId=k2, name=I, synced=true, deleted=true
- Server - Person:
  - id=guid1, syncId=abc, knowledgeId=k1, name=H, timeStamp=106, deleted=false
  - id=guid2, syncId=abc, knowledgeId=k2, name=F, timeStamp=104, deleted=false
  - id=guid3, syncId=abc, knowledgeId=k1, name=E, timeStamp=103, deleted=false
  - id=guid4, syncId=abc, knowledgeId=k2, name=I, timeStamp=108, deleted=true

### Activity 7: Other SyncId: DEF with Client3, allowed to access SyncId: ABC, Client3 Sync

- Client3 login with syncId=def, Other allowed syncIds=abc
- Client3 First Time Prepare Local Knowledge: id=k3, syncId=def, local=true, lastTimeStamp=0
- Client3 Sync Request: def + k3 = 0 -> Query WHERE synced = false -> payload = None
- Server Query WHERE syncId IN (abc, def) AND ( (knowledgeId=k3 And timeStamp > 0) OR (knowledgeId NOT IN (k3)) )
- Server Sync Response: abc + k1 = 106, abc + k2 = 108, def + k3 = 0, payload = guid1, guid2, guid3, guid4
- Client3 Insert Person: id=guid1, syncId=abc, knowledgeId=k1, name=H, synced=true, deleted=false
- Client3 Insert Person: id=guid2, syncId=abc, knowledgeId=k2, name=F, synced=true, deleted=false
- Client3 Insert Person: id=guid3, syncId=abc, knowledgeId=k1, name=E, synced=true, deleted=false
- Client3 Insert Person: id=guid4, syncId=abc, knowledgeId=k2, name=I, synced=true, deleted=true
- Client3 saved Knowledge from Server

#### Post-Activity Data

- Client1 - Knowledge:
  - id=k1, syncId=abc, local=true, lastTimeStamp=106
  - id=k2, syncId=abc, local=false, lastTimeStamp=108
- Client1 - Person:
  - id=guid1, syncId=abc, knowledgeId=k1, name=H, synced=true, deleted=false
  - id=guid2, syncId=abc, knowledgeId=k2, name=F, synced=true, deleted=false
  - id=guid3, syncId=abc, knowledgeId=k1, name=E, synced=true, deleted=false
  - id=guid4, syncId=abc, knowledgeId=k2, name=I, synced=true, deleted=true
- Client2 - Knowledge:
  - id=k2, syncId=abc, local=true, lastTimeStamp=108
  - id=k1, syncId=abc, local=false, lastTimeStamp=106
- Client2 - Person:
  - id=guid2, syncId=abc, knowledgeId=k2, name=F, synced=true, deleted=false
  - id=guid1, syncId=abc, knowledgeId=k1, name=H, synced=true, deleted=false
  - id=guid3, syncId=abc, knowledgeId=k1, name=E, synced=true, deleted=false
  - id=guid4, syncId=abc, knowledgeId=k2, name=I, synced=true, deleted=true
- Client3 - Knowledge:
  - id=k1, syncId=abc, local=false, lastTimeStamp=106
  - id=k2, syncId=abc, local=false, lastTimeStamp=108
  - id=k3, syncId=def, local=true, lastTimeStamp=0
- Client3 - Person:
  - id=guid1, syncId=abc, knowledgeId=k1, name=H, synced=true, deleted=false
  - id=guid2, syncId=abc, knowledgeId=k2, name=F, synced=true, deleted=false
  - id=guid3, syncId=abc, knowledgeId=k1, name=E, synced=true, deleted=false
  - id=guid4, syncId=abc, knowledgeId=k2, name=I, synced=true, deleted=true
- Server - Person:
  - id=guid1, syncId=abc, knowledgeId=k1, name=H, timeStamp=106, deleted=false
  - id=guid2, syncId=abc, knowledgeId=k2, name=F, timeStamp=104, deleted=false
  - id=guid3, syncId=abc, knowledgeId=k1, name=E, timeStamp=103, deleted=false
  - id=guid4, syncId=abc, knowledgeId=k2, name=I, timeStamp=108, deleted=true

### Activity 8: Client3 Insert + Insert Client1 + Update Client1 + Sync

- Client3 Insert Person: id=guid5, syncId=def, knowledgeId=k3, name=J, synced=false, deleted=false
- Client3 Insert Person: id=guid6, syncId=abc, knowledgeId=k3, name=K, synced=false, deleted=false
- Client3 Update Person: id=guid1, syncId=abc, knowledgeId=k1, name=L, synced=false, deleted=false
- Client2 Sync Request: abc + k1 = 106, abc + k2 = 108, def + k3 = 0 -> Query WHERE synced = false -> payload = guid5, guid6, guid1
- Server Insert Person: id=guid5, syncId=def, knowledgeId=k3, name=J, timeStamp=109, deleted=false
- Server Insert Person: id=guid6, syncId=abc, knowledgeId=k3, name=K, timeStamp=110, deleted=false
- Server Update Person: id=guid1, syncId=abc, knowledgeId=k1, name=L, timeStamp=111, deleted=false
- Server Query WHERE syncId IN (abc, def) AND id NOT IN (guid5, guid6, guid1) AND ( (knowledgeId=k1 And timeStamp > 106) OR (knowledgeId=k2 And timeStamp > 108) OR (knowledgeId=k3 And timeStamp > 0) OR (knowledgeId NOT IN (k1, k2, k3)) )
- Server Sync Response: abc + k1 = 111, abc + k2 = 108, abc + k3 = 110, def + k3 = 109, payload = None
- Client3 saved Knowledge from Server + Update synced = true for: guid5, guid6, guid1

#### Post-Activity Data

- Client1 - Knowledge:
  - id=k1, syncId=abc, local=true, lastTimeStamp=106
  - id=k2, syncId=abc, local=false, lastTimeStamp=108
- Client1 - Person:
  - id=guid1, syncId=abc, knowledgeId=k1, name=H, synced=true, deleted=false
  - id=guid2, syncId=abc, knowledgeId=k2, name=F, synced=true, deleted=false
  - id=guid3, syncId=abc, knowledgeId=k1, name=E, synced=true, deleted=false
  - id=guid4, syncId=abc, knowledgeId=k2, name=I, synced=true, deleted=true
- Client2 - Knowledge:
  - id=k2, syncId=abc, local=true, lastTimeStamp=108
  - id=k1, syncId=abc, local=false, lastTimeStamp=106
- Client2 - Person:
  - id=guid2, syncId=abc, knowledgeId=k2, name=F, synced=true, deleted=false
  - id=guid1, syncId=abc, knowledgeId=k1, name=H, synced=true, deleted=false
  - id=guid3, syncId=abc, knowledgeId=k1, name=E, synced=true, deleted=false
  - id=guid4, syncId=abc, knowledgeId=k2, name=I, synced=true, deleted=true
- Client3 - Knowledge:
  - id=k1, syncId=abc, local=false, lastTimeStamp=111
  - id=k2, syncId=abc, local=false, lastTimeStamp=108
  - id=k3, syncId=abc, local=false, lastTimeStamp=110
  - id=k3, syncId=def, local=true, lastTimeStamp=109
- Client3 - Person:
  - id=guid1, syncId=abc, knowledgeId=k1, name=L, synced=true, deleted=false
  - id=guid2, syncId=abc, knowledgeId=k2, name=F, synced=true, deleted=false
  - id=guid3, syncId=abc, knowledgeId=k1, name=E, synced=true, deleted=false
  - id=guid4, syncId=abc, knowledgeId=k2, name=I, synced=true, deleted=true
  - id=guid5, syncId=def, knowledgeId=k3, name=J, synced=true, deleted=false
  - id=guid6, syncId=abc, knowledgeId=k3, name=K, synced=true, deleted=false
- Server - Person:
  - id=guid1, syncId=abc, knowledgeId=k1, name=L, timeStamp=111, deleted=false
  - id=guid2, syncId=abc, knowledgeId=k2, name=F, timeStamp=104, deleted=false
  - id=guid3, syncId=abc, knowledgeId=k1, name=E, timeStamp=103, deleted=false
  - id=guid4, syncId=abc, knowledgeId=k2, name=I, timeStamp=108, deleted=true
  - id=guid5, syncId=def, knowledgeId=k3, name=J, timeStamp=109, deleted=false
  - id=guid6, syncId=abc, knowledgeId=k3, name=K, timeStamp=110, deleted=false

### Activity 9: Client1 Sync

- Client1 Sync Request: abc + k1 = 106, abc + k2 = 108 -> Query WHERE synced = false -> payload = None
- Server Query WHERE syncId IN (abc) AND ( (knowledgeId=k1 And timeStamp > 106) OR (knowledgeId=k2 And timeStamp > 108) OR (knowledgeId NOT IN (k1, k2)) )
- Server Sync Response: abc + k1 = 111, abc + k2 = 108, abc + k3 = 110, payload = guid1, guid6
- Client1 Update Person: id=guid1, syncId=abc, knowledgeId=k1, name=L, synced=true, deleted=false
- Client1 Insert Person: id=guid6, syncId=abc, knowledgeId=k3, name=K, synced=true, deleted=false
- Client1 saved Knowledge from Server

#### Post-Activity Data

- Client1 - Knowledge:
  - id=k1, syncId=abc, local=true, lastTimeStamp=111
  - id=k2, syncId=abc, local=false, lastTimeStamp=108
  - id=k3, syncId=abc, local=false, lastTimeStamp=110
- Client1 - Person:
  - id=guid1, syncId=abc, knowledgeId=k1, name=L, synced=true, deleted=false
  - id=guid2, syncId=abc, knowledgeId=k2, name=F, synced=true, deleted=false
  - id=guid3, syncId=abc, knowledgeId=k1, name=E, synced=true, deleted=false
  - id=guid4, syncId=abc, knowledgeId=k2, name=I, synced=true, deleted=true
  - id=guid6, syncId=abc, knowledgeId=k3, name=K, synced=true, deleted=false
- Client2 - Knowledge:
  - id=k2, syncId=abc, local=true, lastTimeStamp=108
  - id=k1, syncId=abc, local=false, lastTimeStamp=106
- Client2 - Person:
  - id=guid2, syncId=abc, knowledgeId=k2, name=F, synced=true, deleted=false
  - id=guid1, syncId=abc, knowledgeId=k1, name=H, synced=true, deleted=false
  - id=guid3, syncId=abc, knowledgeId=k1, name=E, synced=true, deleted=false
  - id=guid4, syncId=abc, knowledgeId=k2, name=I, synced=true, deleted=true
- Client3 - Knowledge:
  - id=k1, syncId=abc, local=false, lastTimeStamp=111
  - id=k2, syncId=abc, local=false, lastTimeStamp=108
  - id=k3, syncId=abc, local=false, lastTimeStamp=110
  - id=k3, syncId=def, local=true, lastTimeStamp=109
- Client3 - Person:
  - id=guid1, syncId=abc, knowledgeId=k1, name=L, synced=true, deleted=false
  - id=guid2, syncId=abc, knowledgeId=k2, name=F, synced=true, deleted=false
  - id=guid3, syncId=abc, knowledgeId=k1, name=E, synced=true, deleted=false
  - id=guid4, syncId=abc, knowledgeId=k2, name=I, synced=true, deleted=true
  - id=guid5, syncId=def, knowledgeId=k3, name=J, synced=true, deleted=false
  - id=guid6, syncId=abc, knowledgeId=k3, name=K, synced=true, deleted=false
- Server - Person:
  - id=guid1, syncId=abc, knowledgeId=k1, name=L, timeStamp=111, deleted=false
  - id=guid2, syncId=abc, knowledgeId=k2, name=F, timeStamp=104, deleted=false
  - id=guid3, syncId=abc, knowledgeId=k1, name=E, timeStamp=103, deleted=false
  - id=guid4, syncId=abc, knowledgeId=k2, name=I, timeStamp=108, deleted=true
  - id=guid5, syncId=def, knowledgeId=k3, name=J, timeStamp=109, deleted=false
  - id=guid6, syncId=abc, knowledgeId=k3, name=K, timeStamp=110, deleted=false

## Conclusion

In this synchronization design, there are still some issues that needs to be sorted out:

- The _soft-delete_ strategy may resulted in "wasted" rows where they won't be touched again forever, therefore it will take up space sooner or later. Consider working on a "Purge" feature, where all soft-deleted rows are really physically deleted from the tables. This will need all synchronized devices + users to acknowledge the purge, or think about forcing all devices to log out and re-download the purged version from server database (where the data is already cleaned). As for the cleanliness of database in server and client, actually the client databases will be free of these deleted rows because when encountering data with the `deleted` flag set to `true` during downloading and its `id` is not found in client database, the data will be ignored. As for the server database, the "Retention" approach (where the `deleted` data set to true is automatically and physically deleted after a certain period) is still having a risk of a device's data not deleted (if retention period is already happened before the client perform synchronization). Therefore, the "forcing" logout method is still considered as the best approach (users with old database that have exceeded retention period are forced to log out to retrieve fresh copy of the data from the server).

