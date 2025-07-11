import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const List<String> _apiKeys = [
    'GOOGLE_MAPS_API_KEY_ANDROID',
    'GOOGLE_MAPS_API_KEY_IOS',
    'GOOGLE_MAPS_API_KEY_WEB',
    'GOOGLE_MAPS_API_KEY',
    'GOOGLE_SIGNIN_CLIENT_ID',
    'FIREBASE_WEB_API_KEY',
    'FIREBASE_WEB_APP_ID',
    'FIREBASE_WEB_MESSAGING_SENDER_ID',
    'FIREBASE_WEB_AUTH_DOMAIN',
    'FIREBASE_PROJECT_ID',
    'FIREBASE_STORAGE_BUCKET',
    'FIREBASE_MEASUREMENT_ID',
    'FIREBASE_ANDROID_API_KEY',
    'FIREBASE_ANDROID_APP_ID',
    'FIREBASE_IOS_API_KEY',
    'FIREBASE_IOS_APP_ID',
    'COSMOS_TOKEN',
  ];

  static Future<void> load({String fileName = '.env'}) async {
    if (kIsWeb) {
      try {
        await dotenv.load(fileName: fileName);
      } catch (_) {
        // In web builds the file may not be available, ignore errors
      }
      _logLoadedApiKeys();
      return;
    }

    if (await File(fileName).exists()) {
      await dotenv.load(fileName: fileName);
    }
    _logLoadedApiKeys();
  }

  static void _logLoadedApiKeys() {
    if (!dotenv.isInitialized) return;
    for (final key in _apiKeys) {
      final value = dotenv.env[key];
      if (value != null && value.isNotEmpty) {
        debugPrint('[CONFIG] $key: $value');
      } else {
        debugPrint('[CONFIG] $key not found or empty');
      }
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
