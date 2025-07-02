// lib/data/services/auth_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/errors/app_exception.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';
import '../models/auth/register_request.dart';
import '../models/auth/user_model.dart';
import '../models/common/api_response.dart';
import '../repositories/auth_repository.dart';
import 'storage_service.dart';
import 'device_service.dart';
import 'notification_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(authRepositoryProvider));
});

/// Authentication service that manages user authentication state,
/// token handling, and session management
class AuthService {
  final AuthRepository _authRepository;

  // Stream controllers for authentication state
  final _authStateController = StreamController<AuthState>.broadcast();
  final _userController = StreamController<UserModel?>.broadcast();

  // Current authentication state
  AuthState _currentState = AuthState.unauthenticated;
  UserModel? _currentUser;
  Timer? _tokenRefreshTimer;
  Timer? _sessionTimer;

  AuthService(this._authRepository) {
    _initialize();
  }

  // ===== GETTERS =====

  /// Current authentication state
  AuthState get currentState => _currentState;

  /// Current authenticated user
  UserModel? get currentUser => _currentUser;

  /// Stream of authentication state changes
  Stream<AuthState> get authStateStream => _authStateController.stream;

  /// Stream of user changes
  Stream<UserModel?> get userStream => _userController.stream;

  /// Check if user is currently authenticated
  bool get isAuthenticated => _currentState == AuthState.authenticated;

  /// Check if user session is valid
  bool get isSessionValid => _currentUser != null && isAuthenticated;

  // ===== AUTHENTICATION METHODS =====

  /// Login user with email and password
  Future<ApiResponse<LoginResponse>> login(LoginRequest request) async {
    try {
      _updateState(AuthState.loading);

      final response = await _authRepository.login(request);

      if (response.success && response.data != null) {
        await _handleSuccessfulAuth(response.data!);
        _updateState(AuthState.authenticated);

        // Start session management
        _startSessionManagement();

        // Send device registration
        await _registerDevice();

        return response;
      } else {
        _updateState(AuthState.unauthenticated);
        throw AppException.serverError(response.message ?? 'Login failed');
      }
    } catch (e) {
      _updateState(AuthState.unauthenticated);

      // Track failed login attempts
      await _trackFailedLogin();

      rethrow;
    }
  }

  /// Register new user
  Future<ApiResponse<LoginResponse>> register(RegisterRequest request) async {
    try {
      _updateState(AuthState.loading);

      final response = await _authRepository.register(request);

      if (response.success && response.data != null) {
        await _handleSuccessfulAuth(response.data!);
        _updateState(AuthState.authenticated);

        // Start session management
        _startSessionManagement();

        // Send device registration
        await _registerDevice();

        return response;
      } else {
        _updateState(AuthState.unauthenticated);
        throw AppException.serverError(
          response.message ?? 'Registration failed',
        );
      }
    } catch (e) {
      _updateState(AuthState.unauthenticated);
      rethrow;
    }
  }

  /// Logout current user
  Future<void> logout({bool revokeToken = true}) async {
    try {
      _updateState(AuthState.loading);

      if (revokeToken && isAuthenticated) {
        try {
          await _authRepository.logout();
        } catch (e) {
          // Continue with local logout even if server logout fails
          if (kDebugMode) {
            print('Server logout failed: $e');
          }
        }
      }

      await _performLocalLogout();
      _updateState(AuthState.unauthenticated);
    } catch (e) {
      // Ensure we still clear local data even if logout fails
      await _performLocalLogout();
      _updateState(AuthState.unauthenticated);
      rethrow;
    }
  }

  /// Refresh access token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await logout(revokeToken: false);
        return false;
      }

      final response = await _authRepository.refreshToken();

      if (response.success && response.data != null) {
        await _handleSuccessfulAuth(response.data!);
        _scheduleTokenRefresh();
        return true;
      } else {
        await logout(revokeToken: false);
        return false;
      }
    } catch (e) {
      await logout(revokeToken: false);
      return false;
    }
  }

  /// Check authentication status
  Future<bool> checkAuthStatus() async {
    try {
      _updateState(AuthState.loading);

      final accessToken = await StorageService.getAccessToken();
      final user = await StorageService.getUser();

      if (accessToken == null || user == null) {
        _updateState(AuthState.unauthenticated);
        return false;
      }

      // Check if session is valid using repository
      final isValid = await _authRepository.isSessionValid();
      if (!isValid) {
        // Try to refresh token
        final refreshed = await refreshToken();
        if (!refreshed) {
          return false;
        }
      }

      _currentUser = user;
      _updateState(AuthState.authenticated);
      _startSessionManagement();

      return true;
    } catch (e) {
      _updateState(AuthState.unauthenticated);
      return false;
    }
  }

  // ===== PASSWORD MANAGEMENT =====

  /// Request password reset
  Future<ApiResponse<void>> forgotPassword(String email) async {
    try {
      return await _authRepository.forgotPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password with token
  Future<ApiResponse<void>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      return await _authRepository.resetPassword(
        token: token,
        password: newPassword,
        confirmPassword: confirmPassword,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Change password for authenticated user
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (response.success) {
        // Update password changed timestamp
        await StorageService.setString(
          StorageKeys.passwordChangedAt,
          DateTime.now().toIso8601String(),
        );
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // ===== EMAIL VERIFICATION =====

  /// Verify email with token
  Future<ApiResponse<void>> verifyEmail(String token) async {
    try {
      final response = await _authRepository.verifyEmail(token);

      if (response.success && _currentUser != null) {
        // Create new UserModel with updated email verification status
        final updatedUser = UserModel(
          id: _currentUser!.id,
          name: _currentUser!.name,
          email: _currentUser!.email,
          phone: _currentUser!.phone,
          balance: _currentUser!.balance,
          status: _currentUser!.status,
          kycStatus: _currentUser!.kycStatus,
          referralCode: _currentUser!.referralCode,
          referredBy: _currentUser!.referredBy,
          profilePicture: _currentUser!.profilePicture,
          dateOfBirth: _currentUser!.dateOfBirth,
          address: _currentUser!.address,
          emailVerified: true, // Update this field
          phoneVerified: _currentUser!.phoneVerified,
          twoFactorEnabled: _currentUser!.twoFactorEnabled,
          lastLogin: _currentUser!.lastLogin,
          createdAt: _currentUser!.createdAt,
          updatedAt: _currentUser!.updatedAt,
          plan: _currentUser!.plan,
          preferences: _currentUser!.preferences,
        );

        _currentUser = updatedUser;
        await StorageService.setUser(_currentUser!);
        _userController.add(_currentUser);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Request email verification resend
  Future<ApiResponse<void>> resendEmailVerification() async {
    try {
      return await _authRepository.resendVerification();
    } catch (e) {
      rethrow;
    }
  }

  // ===== SESSION MANAGEMENT =====

  /// Start session management (auto logout, token refresh)
  void _startSessionManagement() {
    _scheduleTokenRefresh();
    _startSessionTimeout();
  }

  /// Schedule automatic token refresh
  void _scheduleTokenRefresh() {
    _tokenRefreshTimer?.cancel();

    // Refresh token 5 minutes before expiry (assuming 1 hour token)
    const refreshBuffer = Duration(minutes: 55);

    _tokenRefreshTimer = Timer(refreshBuffer, () {
      refreshToken();
    });
  }

  /// Start session timeout timer
  void _startSessionTimeout() {
    _sessionTimer?.cancel();

    // Auto logout after 30 minutes of inactivity
    _sessionTimer = Timer(const Duration(minutes: 30), () {
      logout();
    });
  }

  /// Reset session timeout
  void resetSessionTimeout() {
    if (isAuthenticated) {
      _startSessionTimeout();
    }
  }

  // ===== UTILITY METHODS =====

  /// Update current user information
  Future<void> updateUser(UserModel user) async {
    _currentUser = user;
    await StorageService.setUser(user);
    _userController.add(user);
  }

  /// Get authentication headers for API requests
  Future<Map<String, String>> getAuthHeaders() async {
    final headers = <String, String>{};

    final accessToken = await StorageService.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    return headers;
  }

  // ===== PRIVATE METHODS =====

  /// Initialize authentication service
  Future<void> _initialize() async {
    await checkAuthStatus();
  }

  /// Handle successful authentication
  Future<void> _handleSuccessfulAuth(LoginResponse loginResponse) async {
    // Store tokens
    await StorageService.setAccessToken(loginResponse.tokens.accessToken);
    await StorageService.setRefreshToken(loginResponse.tokens.refreshToken);

    // Store user data
    await StorageService.setUser(loginResponse.user);
    _currentUser = loginResponse.user;
    _userController.add(_currentUser);

    // Mark as logged in
    await StorageService.setString(
      StorageKeys.lastLoginTime,
      DateTime.now().toIso8601String(),
    );

    // Reset failed login attempts
    await StorageService.setInt(StorageKeys.loginAttempts, 0);
  }

  /// Perform local logout (clear stored data)
  Future<void> _performLocalLogout() async {
    // Cancel timers
    _tokenRefreshTimer?.cancel();
    _sessionTimer?.cancel();

    // Clear stored data using existing method
    await StorageService.clearAuthData();

    // Clear user data
    _currentUser = null;
    _userController.add(null);

    // Clear FCM token registration
    try {
      await NotificationService.unregisterFcmToken();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to unregister FCM token: $e');
      }
    }
  }

  /// Update authentication state
  void _updateState(AuthState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _authStateController.add(newState);
    }
  }

  /// Register device for push notifications
  Future<void> _registerDevice() async {
    try {
      await NotificationService.registerFcmToken();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to register device: $e');
      }
    }
  }

  /// Track failed login attempts for security
  Future<void> _trackFailedLogin() async {
    try {
      final attempts =
          await StorageService.getInt(StorageKeys.loginAttempts) ?? 0;
      await StorageService.setInt(StorageKeys.loginAttempts, attempts + 1);

      // Lock account after 5 failed attempts
      if (attempts >= 4) {
        final lockoutTime = DateTime.now().add(const Duration(minutes: 15));
        await StorageService.setString(
          StorageKeys.lockoutTime,
          lockoutTime.toIso8601String(),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to track login attempt: $e');
      }
    }
  }

  /// Check if account is locked out
  Future<bool> isAccountLockedOut() async {
    try {
      final lockoutTimeStr = await StorageService.getString(
        StorageKeys.lockoutTime,
      );
      if (lockoutTimeStr != null) {
        final lockoutTime = DateTime.parse(lockoutTimeStr);
        return DateTime.now().isBefore(lockoutTime);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _tokenRefreshTimer?.cancel();
    _sessionTimer?.cancel();
    _authStateController.close();
    _userController.close();
  }
}

/// Authentication state enumeration
enum AuthState {
  /// User is not authenticated
  unauthenticated,

  /// Authentication is in progress
  loading,

  /// User is authenticated
  authenticated,

  /// Authentication failed
  error,
}
