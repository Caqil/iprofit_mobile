import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_exception.dart';
import '../../data/services/storage_service.dart';

final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  return ErrorHandler();
});

class ErrorHandler {
  /// Handle error with automatic categorization and response
  Future<ErrorHandlerResult> handleError(
    dynamic error, {
    String? context,
    StackTrace? stackTrace,
    bool showToUser = true,
    bool logError = true,
  }) async {
    AppException appException;

    // Convert various error types to AppException
    if (error is AppException) {
      appException = error;
    } else if (error is Exception) {
      appException = AppException.fromException(error);
    } else {
      appException = AppException.unknown(error.toString());
    }

    // Log the error if requested
    if (logError) {
      ErrorLogger.log(
        appException,
        context: context,
        additionalData: {
          if (stackTrace != null) 'stackTrace': stackTrace.toString(),
        },
      );
    }

    // Handle logout if needed
    if (appException.shouldLogout) {
      await _handleLogout();
    }

    return ErrorHandlerResult(
      exception: appException,
      shouldShowToUser: showToUser,
      userMessage: appException.userMessage,
      canRetry: appException.canRetry,
      shouldLogout: appException.shouldLogout,
    );
  }

  /// Handle network errors specifically
  Future<ErrorHandlerResult> handleNetworkError(
    dynamic error, {
    String? context,
    bool allowOfflineMode = true,
  }) async {
    final result = await handleError(error, context: context);

    // If it's a network error and offline mode is allowed,
    // suggest using cached data
    if (result.exception is NetworkException && allowOfflineMode) {
      return result.copyWith(
        suggestOfflineMode: true,
        userMessage:
            '${result.userMessage}\n\nYou can continue using cached data while offline.',
      );
    }

    return result;
  }

  /// Handle authentication errors
  Future<ErrorHandlerResult> handleAuthError(
    dynamic error, {
    String? context,
  }) async {
    final result = await handleError(error, context: context);

    // For auth errors, always suggest re-authentication
    if (result.exception is UnauthorizedException ||
        result.exception is TokenExpiredException) {
      return result.copyWith(
        suggestReauth: true,
        userMessage: 'Your session has expired. Please log in again.',
      );
    }

    return result;
  }

  /// Handle file operation errors
  Future<ErrorHandlerResult> handleFileError(
    dynamic error, {
    String? context,
    String? fileName,
  }) async {
    final result = await handleError(error, context: context);

    String message = result.userMessage;
    if (fileName != null) {
      message = 'Failed to process file "$fileName": $message';
    }

    return result.copyWith(
      userMessage: message,
      suggestAction: 'Please check file permissions and try again.',
    );
  }

  /// Handle validation errors with field-specific messages
  Future<ErrorHandlerResult> handleValidationError(
    dynamic error, {
    String? context,
    Map<String, String>? fieldErrors,
  }) async {
    final result = await handleError(error, context: context);

    if (result.exception is ValidationException && fieldErrors != null) {
      final formattedErrors = fieldErrors.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\n');

      return result.copyWith(
        userMessage: 'Please fix the following errors:\n$formattedErrors',
        fieldErrors: fieldErrors,
      );
    }

    return result;
  }

  /// Handle business logic errors
  Future<ErrorHandlerResult> handleBusinessError(
    String message, {
    String? context,
    String? action,
  }) async {
    final exception = AppException.businessLogic(message);

    return ErrorHandlerResult(
      exception: exception,
      shouldShowToUser: true,
      userMessage: message,
      canRetry: false,
      shouldLogout: false,
      suggestAction: action,
    );
  }

  /// Handle maintenance mode
  Future<ErrorHandlerResult> handleMaintenanceMode({
    String? estimatedTime,
    String? alternativeAction,
  }) async {
    String message = 'The app is currently under maintenance.';
    if (estimatedTime != null) {
      message += ' Expected to be back $estimatedTime.';
    }

    final exception = AppException.maintenance(message);

    return ErrorHandlerResult(
      exception: exception,
      shouldShowToUser: true,
      userMessage: message,
      canRetry: true,
      shouldLogout: false,
      suggestAction: alternativeAction ?? 'Please try again later.',
    );
  }

  /// Create a generic error with custom handling
  ErrorHandlerResult createError({
    required String message,
    ErrorSeverity severity = ErrorSeverity.medium,
    bool canRetry = true,
    bool shouldLogout = false,
    String? suggestAction,
  }) {
    AppException exception;

    switch (severity) {
      case ErrorSeverity.low:
        exception = AppException.businessLogic(message);
        break;
      case ErrorSeverity.medium:
        exception = AppException.unknown(message);
        break;
      case ErrorSeverity.high:
        exception = AppException.serverError(message);
        break;
    }

    return ErrorHandlerResult(
      exception: exception,
      shouldShowToUser: true,
      userMessage: message,
      canRetry: canRetry,
      shouldLogout: shouldLogout,
      suggestAction: suggestAction,
    );
  }

  /// Handle logout process
  Future<void> _handleLogout() async {
    try {
      // Clear authentication data
      await StorageService.clearAuthData();

      // You might want to navigate to login screen here
      // This would typically be handled by your auth provider

      if (kDebugMode) {
        print('User logged out due to authentication error');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: $e');
      }
    }
  }

  /// Get error recovery suggestions
  List<String> getRecoverySuggestions(AppException exception) {
    return exception.when(
      network: (_) => [
        'Check your internet connection',
        'Try switching between WiFi and mobile data',
        'Restart your router if using WiFi',
        'Try again in a few moments',
      ],
      serverError: (_) => [
        'The issue is on our end, please try again later',
        'Check our status page for updates',
        'Contact support if the problem persists',
      ],
      unauthorized: (_) => [
        'Log out and log back in',
        'Check if your account is still active',
        'Contact support if you need help',
      ],
      forbidden: (_) => [
        'You may not have permission for this action',
        'Contact your administrator',
        'Check if your account has the required access level',
      ],
      validationError: (_, __) => [
        'Check that all required fields are filled',
        'Ensure data is in the correct format',
        'Fix any highlighted errors and try again',
      ],
      rateLimited: (_) => [
        'Wait a moment before trying again',
        'You may have made too many requests',
        'Try again in a few minutes',
      ],
      fileError: (_) => [
        'Check if the file exists and is accessible',
        'Ensure you have permission to access the file',
        'Try selecting a different file',
        'Restart the app if the problem persists',
      ],
      biometricError: (_) => [
        'Make sure your fingerprint/face is registered',
        'Clean your device\'s biometric sensor',
        'Try using your PIN/password instead',
        'Restart the app and try again',
      ],
      parseError: (_) => [
        'The data format may be corrupted',
        'Try refreshing the data',
        'Clear app cache and try again',
        'Contact support if the issue persists',
      ],
      maintenance: (_) => [
        'The service is temporarily unavailable',
        'Check back in a few minutes',
        'Follow our social media for updates',
      ],
      unknown: (_) => [
        'Try closing and reopening the app',
        'Restart your device',
        'Check for app updates',
        'Contact support if the problem continues',
      ],
      badRequest: (_) => [
        'Check your input and try again',
        'Ensure all required information is provided',
      ],
      notFound: (_) => [
        'The requested item may have been removed',
        'Try refreshing the list',
        'Check if you have the correct permissions',
      ],
      requestCancelled: (_) => [
        'The request was cancelled',
        'Try the action again',
      ],
      tokenExpired: (_) => ['Your session has expired', 'Please log in again'],
      permissionDenied: (_) => [
        'You don\'t have permission for this action',
        'Contact your administrator',
        'Check your account settings',
      ],
      cacheError: (_) => [
        'Clear app cache in settings',
        'Restart the app',
        'Reinstall the app if necessary',
      ],
      deviceError: (_) => [
        'Restart the app',
        'Restart your device',
        'Check for system updates',
      ],
      businessLogic: (_) => [
        'Review the requirements',
        'Check your account status',
        'Contact support for assistance',
      ],
      featureUnavailable: (_) => [
        'This feature may not be available in your region',
        'Check for app updates',
        'Contact support for more information',
      ],
    );
  }
}

/// Result of error handling
class ErrorHandlerResult {
  final AppException exception;
  final bool shouldShowToUser;
  final String userMessage;
  final bool canRetry;
  final bool shouldLogout;
  final bool suggestOfflineMode;
  final bool suggestReauth;
  final String? suggestAction;
  final Map<String, String>? fieldErrors;

  const ErrorHandlerResult({
    required this.exception,
    required this.shouldShowToUser,
    required this.userMessage,
    required this.canRetry,
    required this.shouldLogout,
    this.suggestOfflineMode = false,
    this.suggestReauth = false,
    this.suggestAction,
    this.fieldErrors,
  });

  ErrorHandlerResult copyWith({
    AppException? exception,
    bool? shouldShowToUser,
    String? userMessage,
    bool? canRetry,
    bool? shouldLogout,
    bool? suggestOfflineMode,
    bool? suggestReauth,
    String? suggestAction,
    Map<String, String>? fieldErrors,
  }) {
    return ErrorHandlerResult(
      exception: exception ?? this.exception,
      shouldShowToUser: shouldShowToUser ?? this.shouldShowToUser,
      userMessage: userMessage ?? this.userMessage,
      canRetry: canRetry ?? this.canRetry,
      shouldLogout: shouldLogout ?? this.shouldLogout,
      suggestOfflineMode: suggestOfflineMode ?? this.suggestOfflineMode,
      suggestReauth: suggestReauth ?? this.suggestReauth,
      suggestAction: suggestAction ?? this.suggestAction,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  /// Convert to a map for serialization
  Map<String, dynamic> toMap() {
    return {
      'exception': exception.toMap(),
      'shouldShowToUser': shouldShowToUser,
      'userMessage': userMessage,
      'canRetry': canRetry,
      'shouldLogout': shouldLogout,
      'suggestOfflineMode': suggestOfflineMode,
      'suggestReauth': suggestReauth,
      'suggestAction': suggestAction,
      'fieldErrors': fieldErrors,
    };
  }
}
