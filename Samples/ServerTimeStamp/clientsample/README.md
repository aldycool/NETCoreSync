# clientsample

This is the client-side Flutter example project for the Flutter version (that runs in all platforms: android, ios, web, macos, windows, linux) of [NETCoreSync](https://github.com/aldycool/NETCoreSync). This client-side example works in conjunction with its server-side example [here](https://github.com/aldycool/NETCoreSync/tree/master/Samples/ServerTimeStamp/WebSample). Read more about the Flutter version of NETCoreSync in the `netcoresync_moor`'s [README](https://github.com/aldycool/NETCoreSync/blob/master/netcoresync_moor/README.md).

## Getting Started

- Ensure the latest [Flutter SDK](https://flutter.dev/docs/get-started/install) is installed.
- This example uses the `netcoresync_moor` package, which is built on top of [Moor](https://github.com/simolus3/moor) package, so it is required to be able to run with Moor requirements first. All platforms in this project are already compliant with what Moor requires (full documentation in [here](https://moor.simonbinder.eu/docs/platforms/)). The following are additional notes for the platform that you're going to run this project with:
  - `macos`, `android`, `ios`, `web`: no further configuration is neccesary.
  - `windows`: As stated in the Moor's windows documentation [here](https://moor.simonbinder.eu/docs/platforms/#windows), your `windows` platform needs to have the `sqlite3.dll` file to work correctly. Please read the documentation link for further information.
  - `linux`: As stated in the Moor's linux documentation [here](https://moor.simonbinder.eu/docs/platforms/#linux), your `linux` platform needs to have the `libsqlite3.so` file to work correctly. Please read the documentation link for further information.
- Clone this project to your local machine: `git clone https://github.com/aldycool/NETCoreSync.git`.
- Navigate to the `clientsample` folder and run the app:
  ```sh
  cd NETCoreSync/Samples/ServerTimeStamp/clientsample
  flutter pub get
  flutter run # Flutter will present options here if you have multiple devices
  ```
- When the application has launched, we can try inserting data and other database operations here. But, before proceeding with the synchronization function inside the application, ensure that the its server-side example [here](https://github.com/aldycool/NETCoreSync/tree/master/Samples/ServerTimeStamp/WebSample) is successfully launched first. Take note of the server's listening URL as this URL is going to be used as the Sync Url parameter inside the client application. For example, if the server's listening URL is: https://localhost:5001, then the Sync Url would be: `wss://localhost:5001/netcoresyncserver` (assuming the WebSocket path is not changed and still in default).
> For more details on the client-side and server-side configuration, read the Flutter version of NETCoreSync in the `netcoresync_moor`'s [README](https://github.com/aldycool/NETCoreSync/blob/master/netcoresync_moor/README.md).
