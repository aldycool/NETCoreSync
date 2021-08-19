import 'package:flutter/material.dart';
import 'utils_shared.dart' as utils_shared;

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

  static void showToast(BuildContext context, String text) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.removeCurrentSnackBar();
    scaffold.showSnackBar(
      SnackBar(
        content: Text(text),
        duration: Duration(seconds: 3),
      ),
    );
  }

  static void bypassHttpCertificateVerifyFailed() {
    utils_shared.bypassHttpCertificateVerifyFailed();
  }
}
