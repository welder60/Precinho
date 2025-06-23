import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static Future<void> load({String fileName = '.env'}) async {
    if (await File(fileName).exists()) {
      await dotenv.load(fileName: fileName);
    }
  }

  static String get(String key, {String defaultValue = ''}) {
    return dotenv.env[key] ?? Platform.environment[key] ?? defaultValue;
  }
}
