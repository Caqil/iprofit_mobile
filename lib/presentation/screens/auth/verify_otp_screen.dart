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
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

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

  /// Start the resend cooldown timer (60 seconds initial)
  void _startResendCooldown() {
    setState(() => _resendCooldown = 60);
    _updateCooldown();
  }

  void _updateCooldown() {
    if (_resendCooldown <= 0) return;

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCooldown > 0) {
        setState(() => _resendCooldown--);
        _updateCooldown();
      }
    });
  }

  /// Handle OTP input changes
  void _onOtpChanged(String value, int index) {
    setState(() {
      _controllers[index].text = value;
    });

    if (value.isNotEmpty && index < 5) {
      // Move to next field
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Move to previous field
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-verify when complete
    if (_isComplete) {
      _handleVerifyOtp();
    }
  }

  /// Handle backspace key press
  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  /// Handle verify OTP with real API integration
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

      if (mounted) {
        context.go(RoutePaths.dashboard);
      }
    }
  }

  /// Handle resend OTP with real API integration
  Future<void> _handleResendOtp() async {
    if (_resendCooldown > 0) return;

    setState(() => _isResending = true);

    final success = await ref
        .read(authProvider.notifier)
        .resendEmailVerification();

    setState(() => _isResending = false);

    if (success && mounted) {
      _startResendCooldown();

      await showSuccessDialog(
        context,
        title: 'Code Resent!',
        message: 'A new verification code has been sent to your email',
        autoClose: true,
        autoCloseDuration: const Duration(seconds: 2),
      );

      // Clear current OTP inputs
      for (final controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen for auth state changes and errors
    ref.listen<AuthenticationState>(authProvider, (previous, current) {
      if (current.hasError && mounted) {
        showErrorDialog(
          context,
          title: 'Verification Failed',
          message: current.error ?? 'An unexpected error occurred',
        );
      }
    });

    return LoadingOverlay(
      isLoading: authState.isLoading || _isResending,
      message: _isResending ? 'Sending new code...' : 'Verifying code...',
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
            'Verify Email',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: AppConstants.paddingHorizontalLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Header Section
                Column(
                  children: [
                    // Email verification header
                    Text(
                      'Verify your email',
                      style: ShadTheme.of(context).textTheme.h1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enter the 6-digit code we sent to your email address to complete your registration',
                      style: ShadTheme.of(
                        context,
                      ).textTheme.p.copyWith(color: Colors.grey[400]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // Email Icon & Address
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
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
                      ).textTheme.p.copyWith(color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.email ?? 'your@email.com',
                      style: ShadTheme.of(context).textTheme.p.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        'Change Email',
                        style: ShadTheme.of(context).textTheme.small.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
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
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => _onOtpChanged(value, index),
                        onTap: () {
                          // Clear current field when tapped
                          _controllers[index].selection =
                              TextSelection.fromPosition(
                                TextPosition(
                                  offset: _controllers[index].text.length,
                                ),
                              );
                        },
                        onFieldSubmitted: (_) {
                          if (index < 5 &&
                              _controllers[index].text.isNotEmpty) {
                            _focusNodes[index + 1].requestFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 40),

                // Verify Button
                ShadButton(
                  onPressed: _isComplete ? _handleVerifyOtp : null,
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

                // Resend OTP Section
                Column(
                  children: [
                    Text(
                      "Didn't receive the code?",
                      style: ShadTheme.of(
                        context,
                      ).textTheme.p.copyWith(color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 8),
                    if (_resendCooldown > 0)
                      Text(
                        'Resend code in ${_resendCooldown}s',
                        style: ShadTheme.of(context).textTheme.p.copyWith(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _handleResendOtp,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              LucideIcons.refreshCw,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Resend OTP',
                              style: ShadTheme.of(context).textTheme.p.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

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
                        LucideIcons.info,
                        size: 24,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Verification Tips',
                        style: ShadTheme.of(context).textTheme.p.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Check your spam/junk folder\n'
                        '• Make sure you entered the correct email\n'
                        '• The code expires after 10 minutes\n'
                        '• Contact support if you need assistance',
                        style: ShadTheme.of(
                          context,
                        ).textTheme.small.copyWith(color: Colors.grey[400]),
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
                        ).textTheme.p.copyWith(color: Colors.grey[400]),
                      ),
                      GestureDetector(
                        onTap: () => context.go(RoutePaths.login),
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
