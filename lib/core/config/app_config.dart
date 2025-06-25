import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static Future<void> load({String fileName = '.env'}) async {
    if (await File(fileName).exists()) {
      await dotenv.load(fileName: fileName);
    }
  }

  static String get(String key, {String defaultValue = ''}) {
    if (dotenv.isInitialized && dotenv.env.containsKey(key)) {
      return dotenv.env[key]!;
    }
    return Platform.environment[key] ?? defaultValue;
  }
}
