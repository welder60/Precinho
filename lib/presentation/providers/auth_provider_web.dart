import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../../core/errors/failures.dart';

// Estado simplificado da autenticação para web
class AuthState {
  final String? userId;
  final String? email;
  final String? name;
  final LoadingState loadingState;
  final Failure? failure;

  const AuthState({
    this.userId,
    this.email,
    this.name,
    this.loadingState = LoadingState.initial,
    this.failure,
  });

  AuthState copyWith({
    String? userId,
    String? email,
    String? name,
    LoadingState? loadingState,
    Failure? failure,
  }) {
    return AuthState(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      loadingState: loadingState ?? this.loadingState,
      failure: failure,
    );
  }

  bool get isAuthenticated => userId != null;
  bool get isLoading => loadingState == LoadingState.loading;
  bool get hasError => failure != null;
}

// Notifier simplificado para web
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(loadingState: LoadingState.loading);
    
    try {
      // Simulação de login para demonstração
      await Future.delayed(const Duration(seconds: 2));
      
      state = state.copyWith(
        userId: 'demo_user_123',
        email: email,
        name: 'Usuário Demo',
        loadingState: LoadingState.success,
      );
    } catch (e) {
      state = state.copyWith(
        loadingState: LoadingState.error,
        failure: AuthFailure('Erro ao fazer login: ${e.toString()}'),
      );
    }
  }

  Future<void> signUpWithEmail(String email, String password, String name) async {
    state = state.copyWith(loadingState: LoadingState.loading);
    
    try {
      // Simulação de cadastro para demonstração
      await Future.delayed(const Duration(seconds: 2));
      
      state = state.copyWith(
        userId: 'demo_user_123',
        email: email,
        name: name,
        loadingState: LoadingState.success,
      );
    } catch (e) {
      state = state.copyWith(
        loadingState: LoadingState.error,
        failure: AuthFailure('Erro ao criar conta: ${e.toString()}'),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(loadingState: LoadingState.loading);
    
    try {
      // Simulação de login com Google para demonstração
      await Future.delayed(const Duration(seconds: 2));
      
      state = state.copyWith(
        userId: 'demo_google_user_123',
        email: 'usuario@gmail.com',
        name: 'Usuário Google',
        loadingState: LoadingState.success,
      );
    } catch (e) {
      state = state.copyWith(
        loadingState: LoadingState.error,
        failure: AuthFailure('Erro ao fazer login com Google: ${e.toString()}'),
      );
    }
  }

  void signOut() {
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(failure: null);
  }
}

// Providers
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final currentUserProvider = Provider<AuthState?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isAuthenticated ? authState : null;
});

// Classe de falha de autenticação
class AuthFailure extends Failure {
  const AuthFailure(String message) : super(
    message: message,
    type: ErrorType.authentication,
  );
}

