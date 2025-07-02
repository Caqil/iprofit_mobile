// ============================================================================
// lib/presentation/screens/auth/verify_otp_screen.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/constants/app_constants.dart';
import '../../../router/route_paths.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/success_dialog.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  final String? email;
  final String? name;

  const VerifyOtpScreen({super.key, this.email, this.name});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isResending = false;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  bool get _isComplete => _otpCode.length == 6;

  Future<void> _handleVerifyOtp() async {
    if (!_isComplete) {
      await showErrorDialog(
        context,
        title: 'Invalid Code',
        message: 'Please enter all 6 digits',
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).verifyEmail(_otpCode);

    if (success && mounted) {
      await showSuccessDialog(
        context,
        title: 'Email Verified!',
        message: 'Your email has been successfully verified',
        autoClose: true,
        autoCloseDuration: const Duration(seconds: 2),
      );
      context.go(RoutePaths.dashboard);
    }
  }

  Future<void> _handleResendOtp() async {
    setState(() => _isResending = true);

    final success = await ref
        .read(authProvider.notifier)
        .resendEmailVerification();

    setState(() => _isResending = false);

    if (success && mounted) {
      await showSuccessDialog(
        context,
        title: 'Code Resent!',
        message: 'A new verification code has been sent to your email',
        autoClose: true,
        autoCloseDuration: const Duration(seconds: 2),
      );
    }
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    if (_isComplete) {
      _handleVerifyOtp();
    }
  }

  void _onOtpBackspace(int index) {
    if (index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _clearOtp() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen for auth errors
    ref.listen<AuthenticationState>(authProvider, (previous, current) {
      if (current.hasError && mounted) {
        showErrorDialog(
          context,
          title: 'Verification Failed',
          message: current.error!,
          showRetry: true,
          onRetry: _handleVerifyOtp,
        );
      }
    });

    return LoadingOverlay(
      isLoading: authState.isLoading || _isResending,
      message: _isResending ? 'Resending code...' : 'Verifying email...',
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: AppConstants.paddingLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Header Section
                Column(
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

                    const SizedBox(height: 40),

                    // Progress Indicator
                    Row(
                      children: [
                        Text(
                          'Step 2 of 4',
                          style: ShadTheme.of(
                            context,
                          ).textTheme.small?.copyWith(color: Colors.grey[400]),
                        ),
                        const Spacer(),
                        Text(
                          'Verify Email',
                          style: ShadTheme.of(
                            context,
                          ).textTheme.small?.copyWith(color: Colors.grey[400]),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Progress Bar
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.5, // 2 of 4 steps
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Verify Your Email',
                      style: ShadTheme.of(context).textTheme.h1?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the 6-digit code sent to your email address.',
                      style: ShadTheme.of(
                        context,
                      ).textTheme.p?.copyWith(color: Colors.grey[400]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // Email Icon & Address
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.mail,
                          size: 40,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'We\'ve sent a verification code to',
                        style: ShadTheme.of(
                          context,
                        ).textTheme.p?.copyWith(color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.email ?? 'your@email.com',
                        style: ShadTheme.of(context).textTheme.p?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'Change Email',
                          style: ShadTheme.of(context).textTheme.small
                              ?.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 48,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        border: Border.all(
                          color: _controllers[index].text.isNotEmpty
                              ? Colors.blue
                              : Colors.grey[700]!,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: ShadTheme.of(context).textTheme.h4?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(0),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => _onOtpChanged(value, index),
                        onTap: () {
                          if (_controllers[index].text.isNotEmpty) {
                            _controllers[index].selection =
                                TextSelection.fromPosition(
                                  TextPosition(
                                    offset: _controllers[index].text.length,
                                  ),
                                );
                          }
                        },
                        onEditingComplete: () {
                          if (index < 5 &&
                              _controllers[index].text.isNotEmpty) {
                            _focusNodes[index + 1].requestFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // Clear Button
                Center(
                  child: ShadButton.ghost(
                    onPressed: _clearOtp,
                    child: Text(
                      'Clear',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Verify Button
                ShadButton(
                  onPressed: _isComplete ? _handleVerifyOtp : null,
                  width: double.infinity,
                  backgroundColor: _isComplete ? Colors.blue : Colors.grey[700],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Verify & Continue',
                        style: TextStyle(
                          color: _isComplete ? Colors.white : Colors.grey[400],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        LucideIcons.arrowRight,
                        size: 18,
                        color: _isComplete ? Colors.white : Colors.grey[400],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Resend OTP
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Didn't receive the code?",
                        style: ShadTheme.of(
                          context,
                        ).textTheme.p?.copyWith(color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _handleResendOtp,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.refreshCw,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Resend OTP',
                              style: ShadTheme.of(context).textTheme.p
                                  ?.copyWith(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Login Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: ShadTheme.of(
                          context,
                        ).textTheme.p?.copyWith(color: Colors.grey[400]),
                      ),
                      GestureDetector(
                        onTap: () => context.go(RoutePaths.login),
                        child: Text(
                          'Log in',
                          style: ShadTheme.of(context).textTheme.p?.copyWith(
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
        ),
      ),
    );
  }
}
