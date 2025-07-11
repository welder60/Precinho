import 'package:flutter/foundation.dart';

/// Simple logger for Google Maps API requests.
class MapsLogger {
  /// Logs [message] with optional [data] in debug mode.
  static void log(String message, [Map<String, dynamic>? data]) {
    if (kDebugMode) {
      final buffer = StringBuffer('[MapsAPI] $message');
      if (data != null) buffer.write(' | Data: $data');
      // ignore: avoid_print
      print(buffer.toString());
    }
  }
}
