import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precinho_app/main.dart';
import 'package:precinho_app/presentation/pages/auth/login_page.dart';
import 'package:precinho_app/presentation/providers/auth_provider.dart';
import 'package:precinho_app/data/datasources/auth_service.dart';
import 'package:precinho_app/data/models/user_model.dart';

void main() {
  testWidgets('renders login page when not authenticated', (tester) async {
    final authService = _FakeAuthService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authServiceProvider.overrideWithValue(authService)],
        child: const PrecinhApp(),
      ),
    );

    await tester.pump();
    expect(find.byType(LoginPage), findsOneWidget);
  });
}

class _FakeAuthService implements AuthService {
  @override
  Stream<UserModel?> get authStateChanges => const Stream.empty();

  @override
  Future<UserModel?> getCurrentUser() async => null;

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<UserModel> signInWithEmail(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> signUpWithEmail(String email, String password, String name) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateProfile(String name, String? photoUrl) async {}
}
