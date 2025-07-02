// ============================================================================
// lib/presentation/screens/auth/forgot_password_screen.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../router/route_paths.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/loading_overlay.dart';
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

  bool _emailSent = false;
  int _resendCooldown = 0;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Handle sending password reset email with real API integration
  Future<void> _handleSendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authProvider.notifier)
        .forgotPassword(_emailController.text.trim());

    if (success && mounted) {
      setState(() {
        _emailSent = true;
        _resendCooldown = 60; // 60 seconds cooldown
      });

      // Start cooldown timer
      _startResendCooldown();

      await showSuccessDialog(
        context,
        title: 'Email Sent!',
        message:
            'We\'ve sent password reset instructions to ${_emailController.text.trim()}',
        autoClose: true,
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  /// Handle resending password reset email
  Future<void> _handleResendEmail() async {
    if (_resendCooldown > 0) return;

    final success = await ref
        .read(authProvider.notifier)
        .forgotPassword(_emailController.text.trim());

    if (success && mounted) {
      setState(() => _resendCooldown = 60);
      _startResendCooldown();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reset email sent again!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Start the resend cooldown timer
  void _startResendCooldown() {
    if (_resendCooldown <= 0) return;

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCooldown > 0) {
        setState(() => _resendCooldown--);
        _startResendCooldown();
      }
    });
  }

  /// Reset form to initial state
  void _resetForm() {
    setState(() {
      _emailSent = false;
      _resendCooldown = 0;
    });
    _emailController.clear();
  }

  /// Navigate to login with prefilled email
  void _goToLoginWithEmail() {
    context.push('${RoutePaths.login}?email=${_emailController.text.trim()}');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen for auth state changes and errors
    ref.listen<AuthenticationState>(authProvider, (previous, current) {
      if (current.hasError && mounted) {
        showErrorDialog(
          context,
          title: 'Reset Failed',
          message: current.error ?? 'An unexpected error occurred',
        );
      }
    });

    return LoadingOverlay(
      isLoading: authState.isLoading,
      message: _emailSent
          ? 'Sending reset email again...'
          : 'Sending reset email...',
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              LucideIcons.arrowLeft,
              color: Colors.white,
              size: 24,
            ),
          ),
          title: const Text(
            'Reset Password',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: AppConstants.paddingXS,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Header Section
                Column(
                  children: [
                    // Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _emailSent
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _emailSent
                            ? LucideIcons.mailCheck
                            : LucideIcons.keyRound,
                        size: 50,
                        color: _emailSent ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      _emailSent ? 'Check Your Email' : 'Forgot Password?',
                      style: ShadTheme.of(context).textTheme.h1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      _emailSent
                          ? 'We\'ve sent password reset instructions to your email address. Please check your inbox and follow the link to reset your password.'
                          : 'Don\'t worry! Enter your email address and we\'ll send you instructions to reset your password.',
                      style: ShadTheme.of(
                        context,
                      ).textTheme.p.copyWith(color: Colors.grey[400]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                if (!_emailSent) ...[
                  // Email Form (when email not sent yet)
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
                              placeholder: const Text(
                                'Enter your registered email',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              validator: Validators.validateEmail,
                              onSubmitted: (_) => _handleSendResetEmail(),
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
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Help Text
                        Text(
                          'We\'ll send a secure link to reset your password',
                          style: ShadTheme.of(
                            context,
                          ).textTheme.small.copyWith(color: Colors.grey[500]),
                        ),

                        const SizedBox(height: 32),

                        // Send Reset Email Button
                        ShadButton(
                          onPressed: !authState.isLoading
                              ? _handleSendResetEmail
                              : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Send Reset Link',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(LucideIcons.send, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Success State (when email sent)
                  Column(
                    children: [
                      // Email Display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              LucideIcons.mailCheck,
                              size: 40,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Email sent to:',
                              style: ShadTheme.of(context).textTheme.small
                                  .copyWith(color: Colors.grey[400]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _emailController.text.trim(),
                              style: ShadTheme.of(context).textTheme.p.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Action Buttons
                      Column(
                        children: [
                          // Check Email Button
                          ShadButton(
                            onPressed: _goToLoginWithEmail,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Go to Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(LucideIcons.logIn, size: 18),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Resend Button
                          ShadButton.outline(
                            onPressed:
                                (_resendCooldown == 0 && !authState.isLoading)
                                ? _handleResendEmail
                                : null,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _resendCooldown > 0
                                      ? 'Resend in ${_resendCooldown}s'
                                      : 'Resend Email',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _resendCooldown > 0
                                        ? Colors.grey[400]
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  LucideIcons.refreshCw,
                                  size: 18,
                                  color: _resendCooldown > 0
                                      ? Colors.grey[400]
                                      : null,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Try Different Email Button
                          ShadButton.outline(
                            onPressed: _resetForm,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Try Different Email',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(LucideIcons.pen, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 40),

                // Help Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        LucideIcons.handHelping,
                        size: 30,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Need Help?',
                        style: ShadTheme.of(context).textTheme.p.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'If you don\'t receive the email within a few minutes, check your spam folder or contact our support team.',
                        style: ShadTheme.of(
                          context,
                        ).textTheme.small.copyWith(color: Colors.grey[400]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ShadButton.outline(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.grey[900],
                              title: const Text(
                                'Contact Support',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Email: support@iprofit.com\nPhone: +1 (555) 123-4567',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.messageSquare, size: 16),
                            const SizedBox(width: 8),
                            const Text('Contact Support'),
                          ],
                        ),
                      ),
                    ],
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
                        ).textTheme.p.copyWith(color: Colors.grey[400]),
                      ),
                      GestureDetector(
                        onTap: () => context.push(RoutePaths.login),
                        child: Text(
                          'Sign in',
                          style: ShadTheme.of(context).textTheme.p.copyWith(
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
        ),
      ),
    );
  }
}
