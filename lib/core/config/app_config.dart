import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static Future<void> load({String fileName = '.env'}) async {
    if (kIsWeb) {
      try {
        await dotenv.load(fileName: fileName);
      } catch (_) {
        // In web builds the file may not be available, ignore errors
      }
      return;
    }

    if (await File(fileName).exists()) {
      await dotenv.load(fileName: fileName);
    }
  }

  static String get(String key, {String defaultValue = ''}) {
    if (dotenv.isInitialized && dotenv.env.containsKey(key)) {
      return dotenv.env[key]!;
    }
    if (!kIsWeb) {
      return Platform.environment[key] ?? defaultValue;
    }
    return defaultValue;
  }
}
