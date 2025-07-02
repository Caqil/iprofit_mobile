// lib/presentation/providers/auth_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iprofit_mobile/data/services/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/errors/app_exception.dart';
import '../../data/services/auth_service.dart' as auth_service;
import '../../data/models/auth/login_request.dart';
import '../../data/models/auth/register_request.dart';
import '../../data/models/auth/user_model.dart';

part 'auth_provider.g.dart';

// ============================================================================
// AUTH STATE MODEL
// ============================================================================

/// Authentication provider state model
class AuthenticationState {
  final bool isAuthenticated;
  final bool isLoading;
  final UserModel? user;
  final String? error;
  final bool isInitialized;

  const AuthenticationState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.error,
    this.isInitialized = false,
  });

  AuthenticationState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    UserModel? user,
    String? error,
    bool? isInitialized,
  }) {
    return AuthenticationState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  bool get hasError => error != null;
  bool get hasUser => user != null;
  String get userName => user?.name ?? 'User';
  String get userEmail => user?.email ?? '';
  bool get isEmailVerified => user?.emailVerified ?? false;
  bool get isPhoneVerified => user?.phoneVerified ?? false;
  bool get isTwoFactorEnabled => user?.twoFactorEnabled ?? false;
  String get kycStatus => user?.kycStatus ?? 'pending';
  bool get isKycVerified => kycStatus == 'verified';
  double get balance => user?.balance ?? 0.0;
}

// ============================================================================
// AUTH PROVIDER
// ============================================================================

@riverpod
class Auth extends _$Auth {
  StreamSubscription? _authSubscription;
  StreamSubscription? _userSubscription;

  @override
  AuthenticationState build() {
    _initialize();
    return const AuthenticationState();
  }

  // ===== INITIALIZATION =====

  /// Initialize the auth provider
  void _initialize() {
    _checkInitialAuthState();
    _setupListeners();
  }

  /// Check initial authentication state
  Future<void> _checkInitialAuthState() async {
    try {
      state = state.copyWith(isLoading: true);

      final authService = ref.read(authServiceProvider);
      final isAuthenticated = await authService.checkAuthStatus();

      state = state.copyWith(
        isAuthenticated: isAuthenticated,
        user: authService.currentUser,
        isLoading: false,
        isInitialized: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        isInitialized: true,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Set up listeners for auth state changes
  void _setupListeners() {
    final authService = ref.read(authServiceProvider);

    // Listen to authentication state changes
    _authSubscription = authService.authStateStream.listen((authState) {
      switch (authState) {
        case auth_service.AuthState.authenticated:
          state = state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            error: null,
          );
          break;
        case auth_service.AuthState.unauthenticated:
          state = state.copyWith(
            isAuthenticated: false,
            user: null,
            isLoading: false,
            error: null,
          );
          break;
        case auth_service.AuthState.loading:
          state = state.copyWith(isLoading: true, error: null);
          break;
        case auth_service.AuthState.error:
          state = state.copyWith(
            isLoading: false,
            error: 'Authentication error occurred',
          );
          break;
      }
    });

    // Listen to user changes
    _userSubscription = authService.userStream.listen((user) {
      state = state.copyWith(user: user);
    });

    // Clean up on dispose
    ref.onDispose(() {
      _authSubscription?.cancel();
      _userSubscription?.cancel();
    });
  }

  // ===== AUTHENTICATION METHODS =====

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
    required String deviceId,

    bool rememberMe = true,
    String? twoFactorToken,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final authService = ref.read(authServiceProvider);

      // Check if account is locked out
      if (await authService.isAccountLockedOut()) {
        throw AppException.forbidden(
          'Account is temporarily locked due to too many failed login attempts. Please try again later.',
        );
      }

      final loginRequest = LoginRequest(
        email: email,
        password: password,
        rememberMe: rememberMe,
        twoFactorToken: twoFactorToken,
        deviceId: deviceId,
      );

      final response = await authService.login(loginRequest);

      if (response.success) {
        state = state.copyWith(
          isAuthenticated: true,
          user: response.data?.user,
          isLoading: false,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Login failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e));
      return false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    String? planId,
    String? referralCode,
    String? dateOfBirth,
    Map<String, dynamic>? address,
    required String deviceId,
    bool acceptTerms = true,
    bool acceptPrivacy = true,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final authService = ref.read(authServiceProvider);

      final registerRequest = RegisterRequest(
        name: name,
        email: email,
        phone: phone,
        password: password,
        confirmPassword: confirmPassword,
        planId: planId,
        referralCode: referralCode,
        dateOfBirth: dateOfBirth,
        address: address != null ? Address.fromJson(address) : null,
        deviceId: deviceId,
        acceptTerms: acceptTerms,
        acceptPrivacy: acceptPrivacy,
      );

      final response = await authService.register(registerRequest);

      if (response.success) {
        state = state.copyWith(
          isAuthenticated: true,
          user: response.data?.user,
          isLoading: false,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Registration failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e));
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final authService = ref.read(authServiceProvider);
      await authService.logout();

      state = state.copyWith(
        isAuthenticated: false,
        user: null,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      // Even if logout fails, clear local state
      state = state.copyWith(
        isAuthenticated: false,
        user: null,
        isLoading: false,
        error: null,
      );
    }
  }

  // ===== PASSWORD MANAGEMENT =====

  /// Request password reset
  Future<bool> forgotPassword(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final authService = ref.read(authServiceProvider);
      final response = await authService.forgotPassword(email);

      state = state.copyWith(isLoading: false);

      if (response.success) {
        return true;
      } else {
        state = state.copyWith(
          error: response.message ?? 'Failed to send reset email',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e));
      return false;
    }
  }

  /// Reset password with token
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final authService = ref.read(authServiceProvider);
      final response = await authService.resetPassword(
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      state = state.copyWith(isLoading: false);

      if (response.success) {
        return true;
      } else {
        state = state.copyWith(
          error: response.message ?? 'Password reset failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e));
      return false;
    }
  }

  /// Change password for authenticated user
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final authService = ref.read(authServiceProvider);
      final response = await authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      state = state.copyWith(isLoading: false);

      if (response.success) {
        return true;
      } else {
        state = state.copyWith(
          error: response.message ?? 'Password change failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e));
      return false;
    }
  }

  // ===== EMAIL VERIFICATION =====

  /// Verify email with token
  Future<bool> verifyEmail(String token) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final authService = ref.read(authServiceProvider);
      final response = await authService.verifyEmail(token);

      state = state.copyWith(isLoading: false);

      if (response.success) {
        // User will be updated via the stream listener
        return true;
      } else {
        state = state.copyWith(
          error: response.message ?? 'Email verification failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e));
      return false;
    }
  }

  /// Resend email verification
  Future<bool> resendEmailVerification() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final authService = ref.read(authServiceProvider);
      final response = await authService.resendEmailVerification();

      state = state.copyWith(isLoading: false);

      if (response.success) {
        return true;
      } else {
        state = state.copyWith(
          error: response.message ?? 'Failed to resend verification email',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e));
      return false;
    }
  }

  // ===== USER MANAGEMENT =====

  /// Update user information
  Future<void> updateUser(UserModel user) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.updateUser(user);

      // User will be updated via the stream listener
    } catch (e) {
      state = state.copyWith(error: _getErrorMessage(e));
    }
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    try {
      final authService = ref.read(authServiceProvider);
      if (authService.isAuthenticated) {
        // Trigger a refresh of user data
        await authService.checkAuthStatus();
      }
    } catch (e) {
      state = state.copyWith(error: _getErrorMessage(e));
    }
  }

  // ===== ERROR HANDLING =====

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.userMessage;
    }
    return error.toString();
  }

  /// Get authentication headers
  Future<Map<String, String>> getAuthHeaders() async {
    final authService = ref.read(authServiceProvider);
    return await authService.getAuthHeaders();
  }

  /// Reset session timeout
  void resetSessionTimeout() {
    final authService = ref.read(authServiceProvider);
    authService.resetSessionTimeout();
  }
}

/// Provider for checking if user is authenticated
@riverpod
bool isAuthenticated(Ref ref) {
  return ref.watch(authProvider.select((state) => state.isAuthenticated));
}

/// Provider for current user
@riverpod
UserModel? currentUser(Ref ref) {
  return ref.watch(authProvider.select((state) => state.user));
}

/// Provider for auth loading state
@riverpod
bool isAuthLoading(Ref ref) {
  return ref.watch(authProvider.select((state) => state.isLoading));
}

/// Provider for auth error
@riverpod
String? authError(Ref ref) {
  return ref.watch(authProvider.select((state) => state.error));
}

/// Provider for user balance
@riverpod
double userBalance(Ref ref) {
  return ref.watch(authProvider.select((state) => state.balance));
}

/// Provider for KYC status
@riverpod
String kycStatus(Ref ref) {
  return ref.watch(authProvider.select((state) => state.kycStatus));
}

/// Provider for email verification status
@riverpod
bool isEmailVerified(Ref ref) {
  return ref.watch(authProvider.select((state) => state.isEmailVerified));
}
