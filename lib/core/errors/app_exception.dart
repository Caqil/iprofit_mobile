import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Base exception class for the application
abstract class AppException implements Exception {
  const AppException(this.message);

  final String message;

  /// Create AppException from DioException
  factory AppException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(dioException.response);

      case DioExceptionType.cancel:
        return const RequestCancelledException('Request was cancelled');

      case DioExceptionType.connectionError:
        return const NetworkException(
          'Connection error. Please check your internet connection.',
        );

      case DioExceptionType.badCertificate:
        return const NetworkException(
          'SSL certificate error. Please try again.',
        );

      case DioExceptionType.unknown:
      if (dioException.message?.contains('SocketException') == true) {
          return const NetworkException('No internet connection available');
        }
        return UnknownException(
          dioException.message ?? 'An unexpected error occurred',
        );
    }
  }

  /// Create AppException from generic Exception
  factory AppException.fromException(Exception exception) {
    if (exception is AppException) {
      return exception;
    }

    final message = exception.toString();

    // Parse common exception types
    if (message.contains('SocketException') ||
        message.contains('NetworkException')) {
      return const NetworkException('Network connection failed');
    }

    if (message.contains('FormatException') || message.contains('TypeError')) {
      return ParseException('Data parsing failed: ${exception.toString()}');
    }

    if (message.contains('FileSystemException')) {
      return FileException('File operation failed: ${exception.toString()}');
    }

    return UnknownException(exception.toString());
  }

  /// Handle HTTP response errors
  static AppException _handleResponseError(Response? response) {
    if (response == null) {
      return const NetworkException('No response received from server');
    }

    final statusCode = response.statusCode;
    final data = response.data;

    String message = 'Something went wrong';
    Map<String, dynamic>? details;

    if (data is Map<String, dynamic>) {
      message =
          data['message']?.toString() ??
          data['error']?.toString() ??
          data['detail']?.toString() ??
          message;
      details = data['details'] as Map<String, dynamic>?;
    } else if (data is String) {
      message = data;
    }

    switch (statusCode) {
      case 400:
        return BadRequestException(message);
      case 401:
        if (message.toLowerCase().contains('token') &&
            (message.toLowerCase().contains('expired') ||
                message.toLowerCase().contains('invalid'))) {
          return TokenExpiredException(message);
        }
        return UnauthorizedException(message);
      case 403:
        return ForbiddenException(message);
      case 404:
        return NotFoundException(message);
      case 422:
        return ValidationException(message, details);
      case 429:
        return RateLimitedException(message);
      case 500:
        return ServerException(message);
      case 502:
        return const ServerException('Server temporarily unavailable');
      case 503:
        return MaintenanceException(
          message.isEmpty ? 'Service temporarily unavailable' : message,
        );
      default:
        if (statusCode != null && statusCode >= 400 && statusCode < 500) {
          return BadRequestException(message);
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException(message);
        }
        return UnknownException(message);
    }
  }

  /// Factory constructors for different error types
  const factory AppException.unknown([String? message]) = UnknownException;
  const factory AppException.network(String message) = NetworkException;
  const factory AppException.serverError(String message) = ServerException;
  const factory AppException.badRequest(String message) = BadRequestException;
  const factory AppException.unauthorized(String message) =
      UnauthorizedException;
  const factory AppException.forbidden(String message) = ForbiddenException;
  const factory AppException.notFound(String message) = NotFoundException;
  const factory AppException.validationError(
    String message, [
    Map<String, dynamic>? details,
  ]) = ValidationException;
  const factory AppException.rateLimited(String message) = RateLimitedException;
  const factory AppException.requestCancelled(String message) =
      RequestCancelledException;
  const factory AppException.tokenExpired(String message) =
      TokenExpiredException;
  const factory AppException.permissionDenied(String message) =
      PermissionDeniedException;
  const factory AppException.parseError(String message) = ParseException;
  const factory AppException.cacheError(String message) = CacheException;
  const factory AppException.fileError(String message) = FileException;
  const factory AppException.biometricError(String message) =
      BiometricException;
  const factory AppException.deviceError(String message) = DeviceException;
  const factory AppException.businessLogic(String message) =
      BusinessLogicException;
  const factory AppException.maintenance(String message) = MaintenanceException;
  const factory AppException.featureUnavailable(String message) =
      FeatureUnavailableException;

  @override
  String toString() => message;
}

// Concrete exception classes
class UnknownException extends AppException {
  const UnknownException([String? message])
    : super(message ?? 'An unexpected error occurred');
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class ServerException extends AppException {
  const ServerException(super.message);
}

class BadRequestException extends AppException {
  const BadRequestException(super.message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}

class ForbiddenException extends AppException {
  const ForbiddenException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message, [this.details]);
  final Map<String, dynamic>? details;
}

class RateLimitedException extends AppException {
  const RateLimitedException(super.message);
}

class RequestCancelledException extends AppException {
  const RequestCancelledException(super.message);
}

class TokenExpiredException extends AppException {
  const TokenExpiredException(super.message);
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException(super.message);
}

class ParseException extends AppException {
  const ParseException(super.message);
}

class CacheException extends AppException {
  const CacheException(super.message);
}

class FileException extends AppException {
  const FileException(super.message);
}

class BiometricException extends AppException {
  const BiometricException(super.message);
}

class DeviceException extends AppException {
  const DeviceException(super.message);
}

class BusinessLogicException extends AppException {
  const BusinessLogicException(super.message);
}

class MaintenanceException extends AppException {
  const MaintenanceException(super.message);
}

class FeatureUnavailableException extends AppException {
  const FeatureUnavailableException(super.message);
}

/// Extension methods for AppException
extension AppExceptionExtension on AppException {
  /// Get user-friendly error message
  String get userMessage {
    if (this is NetworkException) {
      return message;
    } else if (this is ServerException) {
      return 'Server error. Please try again later.';
    } else if (this is BadRequestException) {
      return message;
    } else if (this is UnauthorizedException) {
      return 'Please log in again to continue';
    } else if (this is ForbiddenException) {
      return 'You don\'t have permission to perform this action';
    } else if (this is NotFoundException) {
      return 'The requested resource was not found';
    } else if (this is ValidationException) {
      return message;
    } else if (this is RateLimitedException) {
      return 'Too many requests. Please try again later.';
    } else if (this is RequestCancelledException) {
      return 'Request was cancelled';
    } else if (this is TokenExpiredException) {
      return 'Your session has expired. Please log in again.';
    } else if (this is PermissionDeniedException) {
      return 'Permission denied. Please check your access rights.';
    } else if (this is ParseException) {
      return 'Data processing error. Please try again.';
    } else if (this is CacheException) {
      return 'Cache error. Please clear app data or reinstall.';
    } else if (this is FileException) {
      return 'File operation failed. Please check storage permissions.';
    } else if (this is BiometricException) {
      return 'Biometric authentication failed. Please try again.';
    } else if (this is DeviceException) {
      return 'Device error. Please restart the app.';
    } else if (this is BusinessLogicException) {
      return message;
    } else if (this is MaintenanceException) {
      return 'Service is under maintenance. Please try again later.';
    } else if (this is FeatureUnavailableException) {
      return 'This feature is currently unavailable';
    } else {
      return message;
    }
  }

  /// Get error severity level
  ErrorSeverity get severity {
    if (this is UnknownException) {
      return ErrorSeverity.high;
    } else if (this is NetworkException) {
      return ErrorSeverity.medium;
    } else if (this is ServerException) {
      return ErrorSeverity.high;
    } else if (this is BadRequestException) {
      return ErrorSeverity.low;
    } else if (this is UnauthorizedException) {
      return ErrorSeverity.high;
    } else if (this is ForbiddenException) {
      return ErrorSeverity.medium;
    } else if (this is NotFoundException) {
      return ErrorSeverity.low;
    } else if (this is ValidationException) {
      return ErrorSeverity.low;
    } else if (this is RateLimitedException) {
      return ErrorSeverity.medium;
    } else if (this is RequestCancelledException) {
      return ErrorSeverity.low;
    } else if (this is TokenExpiredException) {
      return ErrorSeverity.high;
    } else if (this is PermissionDeniedException) {
      return ErrorSeverity.medium;
    } else if (this is ParseException) {
      return ErrorSeverity.medium;
    } else if (this is CacheException) {
      return ErrorSeverity.medium;
    } else if (this is FileException) {
      return ErrorSeverity.medium;
    } else if (this is BiometricException) {
      return ErrorSeverity.low;
    } else if (this is DeviceException) {
      return ErrorSeverity.medium;
    } else if (this is BusinessLogicException) {
      return ErrorSeverity.low;
    } else if (this is MaintenanceException) {
      return ErrorSeverity.high;
    } else if (this is FeatureUnavailableException) {
      return ErrorSeverity.low;
    } else {
      return ErrorSeverity.medium;
    }
  }

  /// Check if error should trigger logout
  bool get shouldLogout {
    return this is UnauthorizedException || this is TokenExpiredException;
  }

  /// Check if error allows retry
  bool get canRetry {
    if (this is NetworkException ||
        this is ServerException ||
        this is RateLimitedException ||
        this is RequestCancelledException ||
        this is ParseException ||
        this is FileException ||
        this is BiometricException ||
        this is DeviceException ||
        this is MaintenanceException ||
        this is UnknownException) {
      return true;
    }
    return false;
  }

  /// Get appropriate icon for error type
  String get iconData {
    if (this is NetworkException) {
      return 'wifi_off';
    } else if (this is ServerException) {
      return 'cloud_off';
    } else if (this is UnauthorizedException) {
      return 'lock';
    } else if (this is ForbiddenException) {
      return 'block';
    } else if (this is NotFoundException) {
      return 'search_off';
    } else if (this is ValidationException) {
      return 'error';
    } else if (this is RateLimitedException) {
      return 'timer';
    } else if (this is TokenExpiredException) {
      return 'access_time';
    } else if (this is ParseException) {
      return 'data_usage';
    } else if (this is CacheException) {
      return 'storage';
    } else if (this is FileException) {
      return 'folder';
    } else if (this is BiometricException) {
      return 'fingerprint';
    } else if (this is DeviceException) {
      return 'phone_android';
    } else if (this is MaintenanceException) {
      return 'build';
    } else if (this is FeatureUnavailableException) {
      return 'disabled_by_default';
    } else if (this is BadRequestException) {
      return 'warning';
    } else if (this is RequestCancelledException) {
      return 'cancel';
    } else if (this is PermissionDeniedException) {
      return 'lock';
    } else if (this is BusinessLogicException) {
      return 'info';
    } else {
      return 'error_outline';
    }
  }

  /// Convert to Map for logging
  Map<String, dynamic> toMap() {
    return {
      'type': runtimeType.toString(),
      'message': userMessage,
      'severity': severity.name,
      'canRetry': canRetry,
      'shouldLogout': shouldLogout,
      'timestamp': DateTime.now().toIso8601String(),
      if (this is ValidationException)
        'details': (this as ValidationException).details,
    };
  }

  /// Pattern matching alternative to Freezed's when method
  T when<T>({
    required T Function(String?) unknown,
    required T Function(String) network,
    required T Function(String) serverError,
    required T Function(String) badRequest,
    required T Function(String) unauthorized,
    required T Function(String) forbidden,
    required T Function(String) notFound,
    required T Function(String, Map<String, dynamic>?) validationError,
    required T Function(String) rateLimited,
    required T Function(String) requestCancelled,
    required T Function(String) tokenExpired,
    required T Function(String) permissionDenied,
    required T Function(String) parseError,
    required T Function(String) cacheError,
    required T Function(String) fileError,
    required T Function(String) biometricError,
    required T Function(String) deviceError,
    required T Function(String) businessLogic,
    required T Function(String) maintenance,
    required T Function(String) featureUnavailable,
  }) {
    if (this is UnknownException) {
      return unknown(message);
    } else if (this is NetworkException) {
      return network(message);
    } else if (this is ServerException) {
      return serverError(message);
    } else if (this is BadRequestException) {
      return badRequest(message);
    } else if (this is UnauthorizedException) {
      return unauthorized(message);
    } else if (this is ForbiddenException) {
      return forbidden(message);
    } else if (this is NotFoundException) {
      return notFound(message);
    } else if (this is ValidationException) {
      return validationError(message, (this as ValidationException).details);
    } else if (this is RateLimitedException) {
      return rateLimited(message);
    } else if (this is RequestCancelledException) {
      return requestCancelled(message);
    } else if (this is TokenExpiredException) {
      return tokenExpired(message);
    } else if (this is PermissionDeniedException) {
      return permissionDenied(message);
    } else if (this is ParseException) {
      return parseError(message);
    } else if (this is CacheException) {
      return cacheError(message);
    } else if (this is FileException) {
      return fileError(message);
    } else if (this is BiometricException) {
      return biometricError(message);
    } else if (this is DeviceException) {
      return deviceError(message);
    } else if (this is BusinessLogicException) {
      return businessLogic(message);
    } else if (this is MaintenanceException) {
      return maintenance(message);
    } else if (this is FeatureUnavailableException) {
      return featureUnavailable(message);
    } else {
      return unknown(message);
    }
  }
}

/// Error severity levels
enum ErrorSeverity { low, medium, high }

/// Error logging utility
class ErrorLogger {
  static void log(
    AppException exception, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    final errorData = {
      ...exception.toMap(),
      if (context != null) 'context': context,
      if (additionalData != null) 'additionalData': additionalData,
    };

    // In production, you would send this to your analytics service
    // For now, we'll just print it in debug mode
    if (exception.severity == ErrorSeverity.high) {
      if (kDebugMode) {
        print('🔴 HIGH SEVERITY ERROR: $errorData');
      }
    } else if (exception.severity == ErrorSeverity.medium) {
      if (kDebugMode) {
        print('🟡 MEDIUM SEVERITY ERROR: $errorData');
      }
    } else {
      if (kDebugMode) {
        print('🟢 LOW SEVERITY ERROR: $errorData');
      }
    }

    // Send to crash reporting service (Firebase Crashlytics, Sentry, etc.)
    // _sendToCrashReporting(errorData);
  }

  static void logException(
    Exception exception, {
    String? context,
    StackTrace? stackTrace,
  }) {
    final appException = AppException.fromException(exception);
    log(
      appException,
      context: context,
      additionalData: {
        'originalException': exception.toString(),
        if (stackTrace != null) 'stackTrace': stackTrace.toString(),
      },
    );
  }
}
