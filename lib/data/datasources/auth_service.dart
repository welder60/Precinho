import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../core/errors/failures.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/firebase_logger.dart';

abstract class AuthService {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String email, String password, String name);
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<void> updateProfile(String name, String? photoUrl);
  Stream<UserModel?> get authStateChanges;
}

class FirebaseAuthService implements AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      FirebaseLogger.log('Get current user');
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      FirebaseLogger.log('Current user', {'uid': firebaseUser.uid});
      return _mapFirebaseUserToUserModel(firebaseUser);
    } catch (e) {
      FirebaseLogger.log('Get current user error', {'error': e.toString()});
      throw AuthenticationFailure(message: 'Erro ao obter usuário atual: $e');
    }
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      FirebaseLogger.log('Sign in with email', {'email': email});
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthenticationFailure(message: 'Falha na autenticação');
      }

      FirebaseLogger.log('Sign in success', {'uid': credential.user!.uid});
      return _mapFirebaseUserToUserModel(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      FirebaseLogger.log('Sign in firebase error', {'code': e.code});
      throw AuthenticationFailure(
        message: _getAuthErrorMessage(e.code),
        code: e.hashCode,
      );
    } catch (e) {
      FirebaseLogger.log('Sign in error', {'error': e.toString()});
      throw AuthenticationFailure(message: 'Erro inesperado: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmail(String email, String password, String name) async {
    try {
      FirebaseLogger.log('Sign up with email', {'email': email});
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthenticationFailure(message: 'Falha no cadastro');
      }

      // Atualizar o nome do usuário
      await credential.user!.updateDisplayName(name);
      await credential.user!.reload();

      final userModel = _mapFirebaseUserToUserModel(credential.user!);

      FirebaseLogger.log('Creating user record', userModel.toJson());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userModel.id)
          .set(userModel.toJson());

      FirebaseLogger.log('Sign up success', {'uid': userModel.id});
      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      FirebaseLogger.log('Sign up firebase error', {'code': e.code});
      throw AuthenticationFailure(
        message: _getAuthErrorMessage(e.code),
        code: e.hashCode,
      );
    } catch (e) {
      FirebaseLogger.log('Sign up error', {'error': e.toString()});
      throw AuthenticationFailure(message: 'Erro inesperado: $e');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      FirebaseLogger.log('Sign in with Google');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthenticationFailure(message: 'Login cancelado pelo usuário');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const AuthenticationFailure(message: 'Falha na autenticação com Google');
      }
      FirebaseLogger.log('Google sign in success', {'uid': userCredential.user!.uid});
      return _mapFirebaseUserToUserModel(userCredential.user!);
    } catch (e) {
      if (e is AuthenticationFailure) rethrow;
      FirebaseLogger.log('Google sign in error', {'error': e.toString()});
      throw AuthenticationFailure(message: 'Erro no login com Google: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      FirebaseLogger.log('Sign out');
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
      FirebaseLogger.log('Sign out success');
    } catch (e) {
      FirebaseLogger.log('Sign out error', {'error': e.toString()});
      throw AuthenticationFailure(message: 'Erro ao fazer logout: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      FirebaseLogger.log('Reset password', {'email': email});
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      FirebaseLogger.log('Reset password email sent');
    } on firebase_auth.FirebaseAuthException catch (e) {
      FirebaseLogger.log('Reset password firebase error', {'code': e.code});
      throw AuthenticationFailure(
        message: _getAuthErrorMessage(e.code),
        code: e.hashCode,
      );
    } catch (e) {
      FirebaseLogger.log('Reset password error', {'error': e.toString()});
      throw AuthenticationFailure(message: 'Erro ao enviar email de recuperação: $e');
    }
  }

  @override
  Future<void> updateProfile(String name, String? photoUrl) async {
    try {
      FirebaseLogger.log('Update profile', {'name': name, 'photo': photoUrl});
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationFailure(message: 'Usuário não autenticado');
      }

      await user.updateDisplayName(name);
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }
      await user.reload();
      FirebaseLogger.log('Profile updated', {'uid': user.uid});
    } catch (e) {
      FirebaseLogger.log('Update profile error', {'error': e.toString()});
      throw AuthenticationFailure(message: 'Erro ao atualizar perfil: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      FirebaseLogger.log('Auth state change', {'uid': firebaseUser?.uid});
      if (firebaseUser == null) return null;
      return _mapFirebaseUserToUserModel(firebaseUser);
    });
  }

  UserModel _mapFirebaseUserToUserModel(firebase_auth.User firebaseUser) {
    final email = firebaseUser.email;
    final role = email != null && AppConstants.adminEmails.contains(email)
        ? UserRole.admin
        : UserRole.user;

    return UserModel(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'Usuário',
      email: email ?? '',
      photoUrl: firebaseUser.photoURL,
      points: 0, // Será obtido do Firestore
      role: role,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
      phoneNumber: firebaseUser.phoneNumber,
      lastLoginAt: firebaseUser.metadata.lastSignInTime,
    );
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'Email já está em uso';
      case 'weak-password':
        return 'Senha muito fraca';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Usuário desabilitado';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde';
      case 'operation-not-allowed':
        return 'Operação não permitida';
      default:
        return 'Erro de autenticação';
    }
  }
}

