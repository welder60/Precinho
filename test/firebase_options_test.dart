import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:precinho_app/firebase_options.dart';

void main() {
  group('DefaultFirebaseOptions', () {
    test('returns android options when platform is android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(DefaultFirebaseOptions.currentPlatform, DefaultFirebaseOptions.android);
      debugDefaultTargetPlatformOverride = null;
    });

    test('returns ios options when platform is ios', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(DefaultFirebaseOptions.currentPlatform, DefaultFirebaseOptions.ios);
      debugDefaultTargetPlatformOverride = null;
    });

    test('web options constant is accessible', () {
      expect(DefaultFirebaseOptions.web.apiKey.isNotEmpty, isTrue);
    });
  });
}
