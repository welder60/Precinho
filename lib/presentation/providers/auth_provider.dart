import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_service.dart';
import '../../data/models/user_model.dart';
import '../../core/errors/failures.dart';
import '../../core/constants/enums.dart';

// Provider do serviço de autenticação
final authServiceProvider = Provider<AuthService>((ref) {
  return FirebaseAuthService();
});

// Estado da autenticação
class AuthState {
  final UserModel? user;
  final LoadingState loadingState;
  final Failure? failure;

  const AuthState({
    this.user,
    this.loadingState = LoadingState.initial,
    this.failure,
  });

  AuthState copyWith({
    UserModel? user,
    LoadingState? loadingState,
    Failure? failure,
  }) {
    return AuthState(
      user: user ?? this.user,
      loadingState: loadingState ?? this.loadingState,
      failure: failure,
    );
  }

  bool get isAuthenticated => user != null;
  bool get isLoading => loadingState == LoadingState.loading;
  bool get hasError => failure != null;
}

// Notifier para gerenciar o estado da autenticação
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _init();
  }

  void _init() {
    // Escutar mudanças no estado de autenticação
    _authService.authStateChanges.listen((user) {
      state = state.copyWith(
        user: user,
        loadingState: LoadingState.success,
        failure: null,
      );
    });

    // Verificar usuário atual
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    try {
      state = state.copyWith(loadingState: LoadingState.loading);
      final user = await _authService.getCurrentUser();
      state = state.copyWith(
        user: user,
        loadingState: LoadingState.success,
        failure: null,
      );
    } catch (e) {
      final failure = FailureHandler.handleException(e);
      state = state.copyWith(
        loadingState: LoadingState.error,
        failure: failure,
      );
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      state = state.copyWith(loadingState: LoadingState.loading);
      final user = await _authService.signInWithEmail(email, password);
      state = state.copyWith(
        user: user,
        loadingState: LoadingState.success,
        failure: null,
      );
    } catch (e) {
      final failure = FailureHandler.handleException(e);
      state = state.copyWith(
        loadingState: LoadingState.error,
        failure: failure,
      );
    }
  }

  Future<void> signUpWithEmail(String email, String password, String name) async {
    try {
      state = state.copyWith(loadingState: LoadingState.loading);
      final user = await _authService.signUpWithEmail(email, password, name);
      state = state.copyWith(
        user: user,
        loadingState: LoadingState.success,
        failure: null,
      );
    } catch (e) {
      final failure = FailureHandler.handleException(e);
      state = state.copyWith(
        loadingState: LoadingState.error,
        failure: failure,
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(loadingState: LoadingState.loading);
      final user = await _authService.signInWithGoogle();
      state = state.copyWith(
        user: user,
        loadingState: LoadingState.success,
        failure: null,
      );
    } catch (e) {
      final failure = FailureHandler.handleException(e);
      state = state.copyWith(
        loadingState: LoadingState.error,
        failure: failure,
      );
    }
  }

  Future<void> signOut() async {
    try {
      state = state.copyWith(loadingState: LoadingState.loading);
      await _authService.signOut();
      state = state.copyWith(
        user: null,
        loadingState: LoadingState.success,
        failure: null,
      );
    } catch (e) {
      final failure = FailureHandler.handleException(e);
      state = state.copyWith(
        loadingState: LoadingState.error,
        failure: failure,
      );
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      state = state.copyWith(loadingState: LoadingState.loading);
      await _authService.resetPassword(email);
      state = state.copyWith(
        loadingState: LoadingState.success,
        failure: null,
      );
    } catch (e) {
      final failure = FailureHandler.handleException(e);
      state = state.copyWith(
        loadingState: LoadingState.error,
        failure: failure,
      );
    }
  }

  Future<void> updateProfile(String name, String? photoUrl) async {
    try {
      state = state.copyWith(loadingState: LoadingState.loading);
      await _authService.updateProfile(name, photoUrl);
      
      // Atualizar o usuário local
      if (state.user != null) {
        final updatedUser = state.user!.copyWith(
          name: name,
          photoUrl: photoUrl,
          updatedAt: DateTime.now(),
        );
        state = state.copyWith(
          user: updatedUser,
          loadingState: LoadingState.success,
          failure: null,
        );
      }
    } catch (e) {
      final failure = FailureHandler.handleException(e);
      state = state.copyWith(
        loadingState: LoadingState.error,
        failure: failure,
      );
    }
  }

  void clearError() {
    state = state.copyWith(failure: null);
  }
}

// Provider do notifier de autenticação
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Provider para verificar se o usuário está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isAuthenticated;
});

// Provider para obter o usuário atual
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user;
});

// Provider para verificar se está carregando
final isLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isLoading;
});

// Provider para obter erro de autenticação
final authErrorProvider = Provider<Failure?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.failure;
});

