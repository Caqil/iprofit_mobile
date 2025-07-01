import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/auth/user_model.dart';
import '../../data/models/auth/login_request.dart';
import '../../data/models/auth/register_request.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/notification_service.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    _checkAuthStatus();
    return const AuthState();
  }

  Future<void> _checkAuthStatus() async {
    final token = await StorageService.getAccessToken();
    final user = await StorageService.getUser();

    if (token != null && user != null) {
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isAuthenticated: false,
        user: null,
        isLoading: false,
      );
    }
  }

  Future<bool> login(LoginRequest request) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final repository = ref.read(authRepositoryProvider);
      final response = await repository.login(request);

      if (response.success) {
        await StorageService.setAccessToken(response.data!.tokens.accessToken);
        await StorageService.setRefreshToken(
          response.data!.tokens.refreshToken,
        );
        await StorageService.setUser(response.data!.user);

        // Register FCM token
        await NotificationService.registerFCMToken();

        state = state.copyWith(
          isAuthenticated: true,
          user: response.data!.user,
          isLoading: false,
        );

        return true;
      } else {
        state = state.copyWith(error: response.message, isLoading: false);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  Future<bool> register(RegisterRequest request) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final repository = ref.read(authRepositoryProvider);
      final response = await repository.register(request);

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          message: 'Registration successful. Please verify your email.',
        );
        return true;
      } else {
        state = state.copyWith(error: response.message, isLoading: false);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
    } catch (e) {
      // Log error but continue with logout
    } finally {
      await StorageService.clearAuthData();
      await NotificationService.unregisterFCMToken();

      state = const AuthState(
        isAuthenticated: false,
        user: null,
        isLoading: false,
      );
    }
  }
}

class AuthState {
  final bool isAuthenticated;
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final String? message;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = true,
    this.error,
    this.message,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? user,
    bool? isLoading,
    String? error,
    String? message,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      message: message,
    );
  }
}
