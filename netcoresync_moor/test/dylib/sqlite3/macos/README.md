## CURRENT DYLIB VERSION: **3.36.0**

How to generate libsqlite3.dylib for macos (taken from [here](https://github.com/simolus3/moor/issues/1096)):

```sh
mkdir /tmp/sqlite
cd /tmp/sqlite
curl https://www.sqlite.org/2021/sqlite-amalgamation-3360000.zip --output sqlite.zip
unzip sqlite.zip
cd sqlite-amalgamation-3350500
cc -dynamiclib -o libsqlite3.dylib sqlite3.c -arch x86_64 -arch arm64 -O3
```

NOTE: the source url can be looked up here: https://www.sqlite.org/download.html
