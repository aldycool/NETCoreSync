import 'package:flutter/material.dart';

class Utils {
  static Future<void> alert({
    required BuildContext buildContext,
    required String title,
    required String message,
  }) async {
    await showDialog(
        context: buildContext,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          );
        });
  }

  static Future<bool> confirm({
    required BuildContext buildContext,
    required String title,
    required String message,
  }) async {
    bool? result = await showDialog<bool>(
        context: buildContext,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("OK"),
              ),
            ],
          );
        });
    return result ?? false;
  }
}
