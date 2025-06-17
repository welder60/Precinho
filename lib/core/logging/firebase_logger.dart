import 'package:flutter/foundation.dart';

/// Simple logger for Firebase operations.
class FirebaseLogger {
  /// Logs [message] with optional [data] in debug mode.
  static void log(String message, [Map<String, dynamic>? data]) {
    if (kDebugMode) {
      final buffer = StringBuffer('[Firebase] $message');
      if (data != null) buffer.write(' | Data: $data');
      // ignore: avoid_print
      print(buffer.toString());
    }
  }
}
