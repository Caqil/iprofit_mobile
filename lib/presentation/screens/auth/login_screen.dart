// ============================================================================
// lib/presentation/screens/auth/login_screen.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iprofit_mobile/presentation/widgets/error_dialog.dart';
import 'package:iprofit_mobile/presentation/widgets/loading_overlay.dart';
import 'package:iprofit_mobile/presentation/widgets/success_dialog.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../router/route_paths.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  final bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          deviceId: 'device_id_placeholder',
          rememberMe: _rememberMe,
        );

    if (success && mounted) {
      await showSuccessDialog(
        context,
        title: 'Welcome Back!',
        message: 'Login successful',
        autoClose: true,
        autoCloseDuration: const Duration(seconds: 2),
      );
      context.go(RoutePaths.dashboard);
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    // Implement social login
    // await ref.read(authProvider.notifier).socialLogin(provider);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen for auth errors
    ref.listen<AuthenticationState>(authProvider, (previous, current) {
      if (current.hasError && mounted) {
        showErrorDialog(
          context,
          title: 'Login Failed',
          message: current.error!,
          showRetry: true,
          onRetry: _handleLogin,
        );
      }
    });

    return LoadingOverlay(
      isLoading: authState.isLoading,
      message: 'Signing you in...',
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A), // Dark background
        body: SafeArea(
          child: SingleChildScrollView(
            padding: AppConstants.paddingLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo Section
                Center(
                  child: Column(
                    children: [
                      // Logo with Investment Pro branding
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.trendingUp,
                            color: Colors.blue,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'IProfit',
                            style: ShadTheme.of(context).textTheme.h2.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),

                      // Welcome Text
                      Text(
                        'Log In',
                        style: ShadTheme.of(context).textTheme.h1?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Welcome back! Sign in to your account',
                        style: ShadTheme.of(
                          context,
                        ).textTheme.p?.copyWith(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

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
                            placeholder: Text('Enter your email address'),
                            keyboardType: TextInputType.emailAddress,
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
                            placeholder: Text('Enter your password'),
                            obscureText: !_isPasswordVisible,
                            validator: (value) =>
                                Validators.validateRequired(value, 'Password'),
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

                      const SizedBox(height: 16),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => context.push(RoutePaths.forgotPassword),
                          child: Text(
                            'Forgot password?',
                            style: ShadTheme.of(context).textTheme.p?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Login Button
                      ShadButton(
                        onPressed: _handleLogin,
                        width: double.infinity,
                        backgroundColor: Colors.blue,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Log In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              LucideIcons.arrowRight,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Social Login Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[700])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or continue with',
                              style: ShadTheme.of(context).textTheme.small
                                  ?.copyWith(color: Colors.grey[400]),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[700])),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Social Login Buttons
                      Row(
                        children: [
                          // Google Button
                          Expanded(
                            child: ShadButton.outline(
                              onPressed: () => _handleSocialLogin('google'),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons
                                        .chrome, // Using Chrome as Google substitute
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Google',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Facebook Button
                          Expanded(
                            child: ShadButton.outline(
                              onPressed: () => _handleSocialLogin('facebook'),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.facebook,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Facebook',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Register Link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: ShadTheme.of(
                                context,
                              ).textTheme.p?.copyWith(color: Colors.grey[400]),
                            ),
                            GestureDetector(
                              onTap: () => context.push(RoutePaths.register),
                              child: Text(
                                'Sign up',
                                style: ShadTheme.of(context).textTheme.p
                                    ?.copyWith(
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
