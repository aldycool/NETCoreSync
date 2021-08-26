## How It Works - Database TimeStamp
The **DatabaseTimeStamp** approach supports two kinds of mechanism, _PushThenPull_, and _PullThenPush_.

For the _PushThenPull_ mechanism, the client will act as the _local_, and the server will act as the _remote_. Basically, the _local_ will push its changes to the _remote_, and then the _local_ will pull the changes from the _remote_.

For the _PullThenPush_ mechanism, the reversed role will be applied, now the server will act as the _local_, and the client will act as the _remote_. Which means, the _remote_ will pull the changes from the _local_, and then the _remote_ will push the changes to the _local_.

Whatever the mechanism is, the synchronization process will always have four phases that will happen sequentially as listed below:

### 1. Getting the _Local Knowledge_
The _Knowledge_ information from the _local_ will be acquired during this phase. _Local Knowledge_ is actually a set of records that indicates what the _local_ knows about the state of its records. Each record from a _Knowledge_ will contain the following information:
* **DatabaseInstanceId**: This is a unique Database Instance Id (expressed as `Guid` but stored as `string`) of some database participant that have been synchronized successfully with the _local_ database (if its `IsLocal` property is `false`), or it's actually the unique Database Instance Id of the _local_ database itself (if its `IsLocal` property is `true`).
* **IsLocal**: This is the indicator (stored as `bool`) whether the particular record belongs to some other database participant (if `false`), or it belongs to the _local_ database itself (if `true`).
* **MaxTimeStamp**: This is the latest (maximum) `time stamp` for the particular record.

For example, if a _local_ database table, let's say `Employee`, have the following records:
* Row 1 -> Name: AAA, DatabaseInstanceId: `null`, LastUpdate: 1000
* Row 2 -> Name: BBB, DatabaseInstanceId: `null`, LastUpdate: 2000
* Row 3 -> Name: CCC, DatabaseInstanceId: DBA, LastUpdate: 3,
* Row 4 -> Name: DDD, DatabaseInstanceId: DBA, LastUpdate: 6,
* Row 5 -> Name: EEE, DatabaseInstanceId: DBB, LastUpdate: 12

And then, some other _local_ database table, let's say `Department`, have the following records:
* Row 1 -> Name: DEPT01, DatabaseInstanceId: `null`, LastUpdate: 1500
* Row 2 -> Name: DEPT02, DatabaseInstanceId: DBB, LastUpdate: 14

Then, the _Local Knowledge_ records will be:
* Row 1 -> DatabaseInstanceId: SERVER, IsLocal: `true`, MaxTimeStamp: 2000
* Row 2 -> DatabaseInstanceId: DBA, IsLocal: `false`, MaxTimeStamp: 6
* Row 3 -> DatabaseInstanceId: DBB, IsLocal: `false`, MaxTimeStamp: 14

So, the characteristics of a _Knowledge_ are:
* A _Knowledge_ records will always have a single record that have its `IsLocal` equals to `true`.
* Other records in a _Knowledge_ records that have `IsLocal` equals to `false` means that there have been successful synchronization process made by those DatabaseInstanceIds into the _local_ database.
* Each of the _Knowledge_ record's `MaxTimeStamp` indicates the latest `time stamp` value for that particular DatabaseInstanceId in ALL the tables in the _local_ database.
* If the _local_ database make some changes like inserts, updates, and deletes in its _local_ database, the _Knowledge_ record with `IsLocal` equals to `true` (its own DatabaseInstanceId) will also automatically update its `MaxTimeStamp` value accordingly. Also, even though the DatabaseInstanceId for it is recorded as SERVER (as shown in the _Local Knowledge_ records example), the system will automatically write `null` as the DatabaseInstanceId in all the tables to save space (later on, the system still can recognize `null` as the local DatabaseInstanceId).

Now, for the _time stamp_ (as recorded in _Knowledge_'s `MaxTimeStamp` or table's `LastUpdated`), this depends on your implementation of getting an _always-move-forward-long-value_ that is NOT DEPENDENT on world clock. This is calculated in the `GetNextTimeStamp()` method subclass, which have to return the said value. In the **DatabaseTimeStamp** example, the server is (confidently) using a world clock actually (`SELECT CAST((EXTRACT(EPOCH FROM NOW() AT TIME ZONE 'UTC') * 1000)`) which is executed as a PostgreSQL query. I say this confidently because server (very) rarely change its Date Time. But, in the client side, due to using a Realm Database, the `GetNextTimeStamp()` is implemented using a helper table (`TimeStamp`) which always increment its row's `Counter` column whenever the `GetNextTimeStamp()` method is executed. As for other database technologies, like SQL Server for example, you can use its `@@DBTS`. Or for MySQL, you can use the query: `SELECT MAX(UPDATE_TIME) FROM TABLES WHERE UPDATE_TIME < NOW()` in its `INFORMATION_SCHEMA` table. 

### 2. Getting the _Remote Knowledge_
The _Knowledge_ information from the _remote_ will be acquired during this phase. _Remote Knowledge_ is basically have the same explanation as the _Local Knowledge_ above, but this is acquired from the _remote_.

### 3. _Local_ Getting Its Changes Based on _Remote Knowledge_
After acquiring the _Remote Knowledge_, now _local_ basically knows what the _remote_ knows up until this point. For efficiency, _local_ only gathered its records that have the same `DatabaseInstanceId` as the `_Remote Knowledge`'s `DatabaseInstanceId`, and `LastUpdated` value greater than the _Remote Knowledge_'s `MaxTimeStamp`. OR, if _local_ database knows records with `DatabaseInstanceId` that is not known by the _Remote Knowledge_, whatever its `LastUpdated` value is, _local_ will also gathered them. The gathered records will be sent to the _remote_ to be applied there. 

### 4. _Remote_ Applying the Changes sent by the _Local_
The sent changes by the _local_ is applied in the _remote_ database. While doing so, _remote_ will inspect every applied records, and update its _Knowledge_ records as necessary (update its `MaxTimeStamp` for each `DatabaseInstanceId`, OR, creating new record of _Knowledge_ for unknown `DatabaseInstanceId`).
***
So, these four phases, for any mechanism (_PushThenPull_ or _PullThenPush_) will be executed twice, the first (phase 1, 2, 3 and 4) is for the _Push_ in _PushThenPull_ (or the _Pull_ in _PullThenPush_), and the second (phase 1, 2, 3 and 4 again) is for the _Pull_ in _PushThenPull_ (or the _Push_ in _PullThenPush_), which brings us to the total of 8 phases executed sequentially.
## Things to Note
* By using this kind of mechanism (_Knowledge_), it opens up a possibility to do a _peer-to-peer_ synchronization, where the _Knowledge_ itself is already sufficient to hold information from any other databases. But this is not implemented yet (as of now), maybe later when it is required to do so.
