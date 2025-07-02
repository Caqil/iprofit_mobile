// ============================================================================
// lib/presentation/screens/auth/login_screen.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/device_service.dart';
import '../../../router/route_paths.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/success_dialog.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _twoFactorController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = true;
  bool _showTwoFactor = false;
  String? _deviceId;

  @override
  void initState() {
    super.initState();
    _initializeDeviceId();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _twoFactorController.dispose();
    super.dispose();
  }

  /// Initialize device ID for security
  Future<void> _initializeDeviceId() async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      setState(() => _deviceId = deviceId);
    } catch (e) {
      if (mounted) {
        await showErrorDialog(
          context,
          title: 'Device Error',
          message: 'Unable to identify device. Please restart the app.',
        );
      }
    }
  }

  /// Handle login with real API integration
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate() || _deviceId == null) return;

    final success = await ref
        .read(authProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          deviceId: _deviceId!,
          rememberMe: _rememberMe,
          twoFactorToken: _showTwoFactor
              ? _twoFactorController.text.trim()
              : null,
        );

    if (success && mounted) {
      await showSuccessDialog(
        context,
        title: 'Welcome Back!',
        message: 'Login successful',
        autoClose: true,
        autoCloseDuration: const Duration(seconds: 1),
      );

      if (mounted) {
        context.go(RoutePaths.dashboard);
      }
    }
  }

  /// Handle biometric login
  Future<void> _handleBiometricLogin() async {
    await showErrorDialog(
      context,
      title: 'Coming Soon',
      message: 'Biometric login will be available in the next update.',
    );
  }

  /// Handle social login
  Future<void> _handleSocialLogin(String provider) async {
    await showErrorDialog(
      context,
      title: 'Coming Soon',
      message: '$provider login will be available soon.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen for auth state changes and errors
    ref.listen<AuthenticationState>(authProvider, (previous, current) {
      if (current.hasError && mounted) {
        // Handle 2FA requirement
        if (current.error?.contains('two-factor') == true ||
            current.error?.contains('2FA') == true) {
          setState(() => _showTwoFactor = true);
          return;
        }

        showErrorDialog(
          context,
          title: 'Login Failed',
          message: current.error ?? 'An unexpected error occurred',
        );
      }
    });

    return LoadingOverlay(
      isLoading: authState.isLoading,
      message: _showTwoFactor ? 'Verifying 2FA...' : 'Signing you in...',
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: AppConstants.paddingHorizontalLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Header
                Column(
                  children: [
                    // App Logo/Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.purple.shade600,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.dollarSign,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome back!',
                      style: ShadTheme.of(context).textTheme.h1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue your investment journey',
                      style: ShadTheme.of(
                        context,
                      ).textTheme.p.copyWith(color: Colors.grey[400]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // Login Form
                ShadForm(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email Address',
                            style: ShadTheme.of(context).textTheme.p.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ShadInputFormField(
                            controller: _emailController,
                            placeholder: const Text('Enter your email address'),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: Validators.validateEmail,
                            leading: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                LucideIcons.mail,
                                size: 18,
                                color: Colors.grey[400],
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            decoration: ShadDecoration(
                              border: ShadBorder.all(
                                color: Colors.grey[700]!,
                                width: 1,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Password Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password',
                            style: ShadTheme.of(context).textTheme.p.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ShadInputFormField(
                            controller: _passwordController,
                            placeholder: const Text('Enter your password'),
                            obscureText: !_isPasswordVisible,
                            textInputAction: _showTwoFactor
                                ? TextInputAction.next
                                : TextInputAction.done,
                            validator: Validators.validatePassword,
                            onSubmitted: (_) =>
                                _showTwoFactor ? null : _handleLogin(),
                            leading: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                LucideIcons.lock,
                                size: 18,
                                color: Colors.grey[400],
                              ),
                            ),
                            trailing: Padding(
                              padding: const EdgeInsets.all(12),
                              child: GestureDetector(
                                onTap: () => setState(
                                  () =>
                                      _isPasswordVisible = !_isPasswordVisible,
                                ),
                                child: Icon(
                                  _isPasswordVisible
                                      ? LucideIcons.eyeOff
                                      : LucideIcons.eye,
                                  size: 18,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            decoration: ShadDecoration(
                              border: ShadBorder.all(
                                color: Colors.grey[700]!,
                                width: 1,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Two-Factor Authentication Field (conditional)
                      if (_showTwoFactor) ...[
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '2FA Code',
                              style: ShadTheme.of(context).textTheme.p.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ShadInputFormField(
                              controller: _twoFactorController,
                              placeholder: const Text('Enter 6-digit code'),
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              maxLength: 6,
                              onSubmitted: (_) => _handleLogin(),
                              validator: (value) => Validators.validateRequired(
                                value,
                                '2FA Code',
                              ),
                              leading: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  LucideIcons.shield,
                                  size: 18,
                                  color: Colors.blue,
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                              decoration: ShadDecoration(
                                border: ShadBorder.all(
                                  color: Colors.blue,
                                  width: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please enter the 6-digit code from your authenticator app',
                              style: ShadTheme.of(context).textTheme.small
                                  .copyWith(color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Remember Me & Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _rememberMe = !_rememberMe),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: _rememberMe
                                            ? Colors.blue
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: _rememberMe
                                              ? Colors.blue
                                              : Colors.grey[600]!,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: _rememberMe
                                          ? const Icon(
                                              LucideIcons.check,
                                              size: 14,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Remember me',
                                      style: ShadTheme.of(context)
                                          .textTheme
                                          .small
                                          .copyWith(color: Colors.grey[300]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () =>
                                context.push(RoutePaths.forgotPassword),
                            child: Text(
                              'Forgot password?',
                              style: ShadTheme.of(context).textTheme.small
                                  .copyWith(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Login Button
                      ShadButton(
                        onPressed: (_deviceId != null && !authState.isLoading)
                            ? _handleLogin
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _showTwoFactor ? 'Verify & Sign In' : 'Sign In',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(LucideIcons.arrowRight, size: 18),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Social Login Section
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey[700])),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'Or sign in with',
                                  style: ShadTheme.of(context).textTheme.small
                                      .copyWith(color: Colors.grey[400]),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey[700])),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Biometric Login
                              GestureDetector(
                                onTap: _handleBiometricLogin,
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey[700]!,
                                    ),
                                  ),
                                  child: const Icon(
                                    LucideIcons.fingerprint,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Google Login
                              GestureDetector(
                                onTap: () => _handleSocialLogin('Google'),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey[700]!,
                                    ),
                                  ),
                                  child: const Icon(
                                    LucideIcons.chrome,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Apple Login
                              GestureDetector(
                                onTap: () => _handleSocialLogin('Apple'),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey[700]!,
                                    ),
                                  ),
                                  child: const Icon(
                                    LucideIcons.apple,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Register Link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account? ',
                              style: ShadTheme.of(
                                context,
                              ).textTheme.p.copyWith(color: Colors.grey[400]),
                            ),
                            GestureDetector(
                              onTap: () => context.push(RoutePaths.register),
                              child: Text(
                                'Sign up',
                                style: ShadTheme.of(context).textTheme.p
                                    .copyWith(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
