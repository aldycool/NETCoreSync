# client_app

The client-side Flutter sample project for synchronizing data with server-side .NET Core ServerApp.

## Getting Started

To run the examples:

- Windows: Download the SQLite binaries for windows here: https://www.sqlite.org/2021/sqlite-dll-win64-x64-3360000.zip, unzip and copy the sqlite3.dll into the same folder as the client_app.exe file.
- Linux: on Ubuntu Desktop 20.04: `apt-get install libsqlite3-dev`
- MacOS, Android, iOS, Web: No special instructions necessary, just run it.
- **As Per Writing: Flutter Sync Is Not Ready Yet, still in the works**

## netcoresync_client_flutter Notes

- To use the library, the package `build_runner` must also be specified in the `pubspec.yaml`'s `dev_dependencies` section. This library uses the `reflectable` package to generate reflections on your data classes. After including the `build_runner` package, to generate the `reflectable`'s file:
  ```sh
  flutter packages pub run build_runner clean
  flutter clean
  flutter pub get
  flutter packages pub run build_runner build --delete-conflicting-outputs  
  ```
  NOTE: this example is using Moor, where `build_runner` is already a requirement in Moor. You should still add the `build_runner` package yourself even if you are not using Moor.
