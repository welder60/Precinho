import 'package:equatable/equatable.dart';
import '../constants/enums.dart';

abstract class Failure extends Equatable {
  final String message;
  final ErrorType type;
  final int? code;

  const Failure({
    required this.message,
    required this.type,
    this.code,
  });

  @override
  List<Object?> get props => [message, type, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'Erro de conexão com a internet',
    int? code,
  }) : super(
          message: message,
          type: ErrorType.network,
          code: code,
        );
}

class ServerFailure extends Failure {
  const ServerFailure({
    String message = 'Erro interno do servidor',
    int? code,
  }) : super(
          message: message,
          type: ErrorType.server,
          code: code,
        );
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    String message = 'Dados inválidos',
    int? code,
  }) : super(
          message: message,
          type: ErrorType.validation,
          code: code,
        );
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    String message = 'Erro de autenticação',
    int? code,
  }) : super(
          message: message,
          type: ErrorType.authentication,
          code: code,
        );
}

class PermissionFailure extends Failure {
  const PermissionFailure({
    String message = 'Permissão negada',
    int? code,
  }) : super(
          message: message,
          type: ErrorType.permission,
          code: code,
        );
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    String message = 'Erro desconhecido',
    int? code,
  }) : super(
          message: message,
          type: ErrorType.unknown,
          code: code,
        );
}

// Exceções personalizadas
class PrecinhException implements Exception {
  final String message;
  final ErrorType type;
  final int? code;
  final dynamic originalError;

  const PrecinhException({
    required this.message,
    required this.type,
    this.code,
    this.originalError,
  });

  @override
  String toString() {
    return 'PrecinhException: $message (Type: ${type.displayName}, Code: $code)';
  }
}

class LocationException extends PrecinhException {
  const LocationException({
    String message = 'Erro ao obter localização',
    int? code,
    dynamic originalError,
  }) : super(
          message: message,
          type: ErrorType.permission,
          code: code,
          originalError: originalError,
        );
}

class CameraException extends PrecinhException {
  const CameraException({
    String message = 'Erro ao acessar câmera',
    int? code,
    dynamic originalError,
  }) : super(
          message: message,
          type: ErrorType.permission,
          code: code,
          originalError: originalError,
        );
}

class ImageProcessingException extends PrecinhException {
  const ImageProcessingException({
    String message = 'Erro ao processar imagem',
    int? code,
    dynamic originalError,
  }) : super(
          message: message,
          type: ErrorType.unknown,
          code: code,
          originalError: originalError,
        );
}

class DatabaseException extends PrecinhException {
  const DatabaseException({
    String message = 'Erro no banco de dados',
    int? code,
    dynamic originalError,
  }) : super(
          message: message,
          type: ErrorType.server,
          code: code,
          originalError: originalError,
        );
}

// Utilitário para converter exceções em failures
class FailureHandler {
  static Failure handleException(dynamic exception) {
    if (exception is PrecinhException) {
      switch (exception.type) {
        case ErrorType.network:
          return NetworkFailure(message: exception.message, code: exception.code);
        case ErrorType.server:
          return ServerFailure(message: exception.message, code: exception.code);
        case ErrorType.validation:
          return ValidationFailure(message: exception.message, code: exception.code);
        case ErrorType.authentication:
          return AuthenticationFailure(message: exception.message, code: exception.code);
        case ErrorType.permission:
          return PermissionFailure(message: exception.message, code: exception.code);
        default:
          return UnknownFailure(message: exception.message, code: exception.code);
      }
    }
    
    // Tratamento de exceções comuns
    if (exception.toString().contains('SocketException') ||
        exception.toString().contains('TimeoutException')) {
      return const NetworkFailure();
    }
    
    if (exception.toString().contains('FormatException') ||
        exception.toString().contains('ArgumentError')) {
      return const ValidationFailure();
    }
    
    return UnknownFailure(message: exception.toString());
  }
}

