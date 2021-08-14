import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:uuid/uuid.dart';

class NetCoreTestServer {
  static const String _defaultPrintPrefix =
      "\x1B[1;94mDotnetTestServer:\x1B[0m ";

  // _ansiPattern is courtesy (taken) from this awesome library:
  // https://github.com/frencojobs/tint
  static final RegExp _ansiPattern = RegExp([
    '[\\u001B\\u009B][[\\]()#;?]*(?:(?:(?:[a-zA-Z\\d]*(?:;[-a-zA-Z\\d\\/#&.:=?%@~_]*)*)?\\u0007)',
    '(?:(?:\\d{1,4}(?:;\\d{0,4})*)?[\\dA-PR-TZcf-ntqry=><~]))'
  ].join('|'));

  static Future<bool> build({
    required String dotnetExecutablePath,
    required String projectRootDirectory,
    String configuration = "Debug",
    bool printStdout = false,
    String printPrefix = _defaultPrintPrefix,
  }) async {
    final process = await Process.start(
      dotnetExecutablePath,
      [
        "build",
        "--configuration",
        configuration,
      ],
      workingDirectory: projectRootDirectory,
    );
    utf8.decoder
        .bind(process.stdout)
        .transform(const LineSplitter())
        .listen((line) {
      log(line, printStdout, printPrefix);
    });
    return await process.exitCode == 0;
  }

  static void log(Object? object, bool printStdout, String printPrefix) {
    if (printStdout) {
      String output = "$printPrefix${object.toString()}";
      print(output);
    }
  }

  String dotnetExecutablePath;
  String dllFileName;
  String dllDirectory;
  String aspNetCoreEnvironment;
  String aspNetCoreUrls;
  bool printStdout;
  String printPrefix;
  String printPrefixAdditionalText;

  NetCoreTestServer({
    required this.dotnetExecutablePath,
    required this.dllFileName,
    required this.dllDirectory,
    this.aspNetCoreEnvironment = "Development",
    this.aspNetCoreUrls = "http://localhost:5000;https://localhost:5001",
    this.printStdout = false,
    this.printPrefix = _defaultPrintPrefix,
    this.printPrefixAdditionalText = "",
  });

  late Process _serverProcess;
  final Map<String, CaptureOutputListener> _listeners = {};
  List<String> logs = [];

  Future<bool> start({List<String> args = const []}) async {
    log(
      "dotnet executable path: $dotnetExecutablePath",
      printStdout,
      printPrefix + printPrefixAdditionalText,
    );

    bool checkStartup = true;
    bool applicationStarted = false;
    Completer startupCompleter = Completer();

    _serverProcess = await Process.start(
      dotnetExecutablePath,
      [
        dllFileName,
        ...args,
      ],
      workingDirectory: dllDirectory,
      environment: {
        "ASPNETCORE_ENVIRONMENT": aspNetCoreEnvironment,
        "ASPNETCORE_URLS": aspNetCoreUrls,
      },
    );
    log(
      "dotnet pid: ${_serverProcess.pid}",
      printStdout,
      printPrefix + printPrefixAdditionalText,
    );
    _serverProcess.exitCode.whenComplete(() {
      if (checkStartup && !startupCompleter.isCompleted) {
        startupCompleter.complete();
      }
    });
    utf8.decoder
        .bind(_serverProcess.stdout)
        .transform(const LineSplitter())
        .listen((line) {
      log(
        line,
        printStdout,
        printPrefix + printPrefixAdditionalText,
      );
      if (checkStartup) {
        if (line.contains("Application started. Press Ctrl+C to shut down.")) {
          applicationStarted = true;
          checkStartup = false;
          if (!startupCompleter.isCompleted) {
            startupCompleter.complete();
          }
        }
        return;
      }
      String cleanedLine = line.replaceAll(_ansiPattern, "").trim();
      logs.add(cleanedLine);
      List<String> listenerKeys = _listeners.keys.toList();
      for (var i = 0; i < listenerKeys.length; i++) {
        String id = listenerKeys[i];
        _listeners[id]!.add(cleanedLine);
      }
    });
    await startupCompleter.future;
    return applicationStarted;
  }

  String startCaptureOutput({
    required int waitIdleInMs,
    String? onlyWithRegex,
  }) {
    String id = Uuid().v4();
    _listeners[id] = CaptureOutputListener(
      waitIdleInMs,
      onlyWithRegex,
    );
    return id;
  }

  Future<List<String>?> stopCaptureOutput(
    String id, {
    bool removeLogHeaderLines = true,
  }) async {
    if (!_listeners.containsKey(id)) {
      return null;
    }
    await _listeners[id]!._completerLinesNotEmpty.future;
    await _listeners[id]!._completerWaitIdle.future;
    List<String> result = List<String>.from(_listeners[id]!._lines);
    _listeners.remove(id);
    if (removeLogHeaderLines) {
      final logPrefixes = RegExp("crit:|fail:|warn:|info:|dbug:|trace:");
      result.removeWhere((line) => logPrefixes.matchAsPrefix(line) != null);
    }
    return result;
  }

  Future<void> stop() async {
    _serverProcess.kill();
    await _serverProcess.exitCode;
  }
}

class CaptureOutputListener {
  final int _waitIdleInMs;
  RegExp? _regExp;
  final List<String> _lines = [];
  final Completer _completerLinesNotEmpty = Completer();
  late CancelableOperation _cancelableOperation;
  final Completer _completerWaitIdle = Completer();

  CaptureOutputListener(
    this._waitIdleInMs,
    String? onlyWithRegex,
  ) {
    if (onlyWithRegex != null) {
      _regExp = RegExp(onlyWithRegex);
    }
  }

  void add(String line) {
    if (_completerWaitIdle.isCompleted) {
      return;
    }
    if (_regExp == null) {
      _lines.add(line);
    } else {
      if (_regExp!.hasMatch(line)) {
        _lines.add(line);
      }
    }
    if (!_completerLinesNotEmpty.isCompleted) {
      _completerLinesNotEmpty.complete();
    } else {
      _cancelableOperation.cancel();
    }
    _cancelableOperation = CancelableOperation.fromFuture(
      Future.delayed(
        Duration(milliseconds: _waitIdleInMs),
      ),
    ).then((_) {
      _completerWaitIdle.complete();
    });
  }
}
