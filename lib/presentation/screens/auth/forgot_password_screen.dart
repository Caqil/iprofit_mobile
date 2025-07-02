// ============================================================================
// lib/presentation/screens/auth/forgot_password_screen.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iprofit_mobile/presentation/widgets/loading_overlay.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../router/route_paths.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/success_dialog.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authProvider.notifier)
        .forgotPassword(_emailController.text.trim());

    if (success && mounted) {
      await showSuccessDialog(
        context,
        title: 'Email Sent!',
        message: 'Check your email for password reset instructions',
        autoClose: false,
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen for auth errors
    ref.listen<AuthenticationState>(authProvider, (previous, current) {
      if (current.hasError && mounted) {
        showErrorDialog(
          context,
          title: 'Failed to Send Email',
          message: current.error!,
          showRetry: true,
          onRetry: _handleSendResetEmail,
        );
      }
    });

    return LoadingOverlay(
      isLoading: authState.isLoading,
      message: 'Sending reset email...',
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: AppConstants.paddingLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: ShadButton.ghost(
                    onPressed: () => context.pop(),
                    child: const Icon(
                      LucideIcons.arrowLeft,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Header Section
                Center(
                  child: Column(
                    children: [
                      // Logo
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
                            'Investment Pro',
                            style: ShadTheme.of(context).textTheme.h3?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 60),

                      // Title
                      Text(
                        'Forgot Password?',
                        style: ShadTheme.of(context).textTheme.h1?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your email address and we\'ll send you\ninstructions to reset your password',
                        style: ShadTheme.of(
                          context,
                        ).textTheme.p?.copyWith(color: Colors.grey[400]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Email Form
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
                            style: ShadTheme.of(context).textTheme.p?.copyWith(
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

                      const SizedBox(height: 32),

                      // Send Reset Email Button
                      ShadButton(
                        onPressed: _handleSendResetEmail,
                        width: double.infinity,
                        backgroundColor: Colors.blue,
                        child: Text(
                          'Send Reset Email',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Back to Login Link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Remember your password? ',
                              style: ShadTheme.of(
                                context,
                              ).textTheme.p?.copyWith(color: Colors.grey[400]),
                            ),
                            GestureDetector(
                              onTap: () => context.go(RoutePaths.login),
                              child: Text(
                                'Log in',
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
