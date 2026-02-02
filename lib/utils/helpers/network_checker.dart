import 'dart:async';
import 'dart:io';

Future<bool> hasNetwork() async {
  try {
    final result = await InternetAddress.lookup('google.com')
        .timeout(const Duration(seconds: 3));
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  } on TimeoutException catch (_) {
    return false;
  }
}

// import 'dart:async';
// import 'dart:io' show InternetAddress, SocketException;
// import 'package:flutter/foundation.dart';
// import 'dart:html' as html; // Only for web

// Future<bool> hasNetwork() async {
//   if (kIsWeb) {
//     // 🌐 Web-safe check using browser navigator, coerce null to false
//     return html.window.navigator.onLine ?? false;
//   } else {
//     // 📱 Mobile check using InternetAddress.lookup
//     try {
//       final result = await InternetAddress.lookup('google.com')
//           .timeout(const Duration(seconds: 3));
//       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } on SocketException catch (_) {
//       return false;
//     } on TimeoutException catch (_) {
//       return false;
//     }
//   }
// }
