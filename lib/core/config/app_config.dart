import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static Future<void> load({String fileName = '.env'}) async {
    try {
      if (await File(fileName).exists()) {
        await dotenv.load(fileName: fileName);
      } else {
        dotenv.test(Platform.environment);
      }
    } catch (_) {
      dotenv.test(Platform.environment);
    }
  }

  static String get(String key, {String defaultValue = ''}) {
    return dotenv.env[key] ?? defaultValue;
  }
}
