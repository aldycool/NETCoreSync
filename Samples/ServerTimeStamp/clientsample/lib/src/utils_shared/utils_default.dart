import 'dart:io';

void bypassHttpCertificateVerifyFailed() {
  HttpOverrides.global = _CustomHttpOverrides();
}

class _CustomHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
