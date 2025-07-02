// ============================================================================
// lib/presentation/screens/auth/register_screen.dart
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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    // Navigate to next step with form data
    context.push(
      '${RoutePaths.verifyOtp}?name=${_nameController.text}&email=${_emailController.text}',
    );
  }

  Future<void> _handleSocialRegister(String provider) async {
    // Implement social registration
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
          title: 'Registration Failed',
          message: current.error!,
        );
      }
    });

    return LoadingOverlay(
      isLoading: authState.isLoading,
      message: 'Creating your account...',
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A), // Dark background
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
                          'Step 1 of 4',
                          style: ShadTheme.of(
                            context,
                          ).textTheme.small.copyWith(color: Colors.grey[400]),
                        ),
                        const Spacer(),
                        Text(
                          'Account Details',
                          style: ShadTheme.of(
                            context,
                          ).textTheme.small.copyWith(color: Colors.grey[400]),
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
                        widthFactor: 0.25, // 1 of 4 steps
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
                      'Create Account',
                      style: ShadTheme.of(context).textTheme.h1?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your details to get started with your\ninvestment journey',
                      style: ShadTheme.of(
                        context,
                      ).textTheme.p?.copyWith(color: Colors.grey[400]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Registration Form
                ShadForm(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Full Name Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Full Name',
                            style: ShadTheme.of(context).textTheme.p?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ShadInputFormField(
                            controller: _nameController,
                            placeholder: Text('Enter your full name'),
                            validator: Validators.validateName,
                            leading: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                LucideIcons.user,
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

                      // Continue Button
                      ShadButton(
                        onPressed: _handleContinue,
                        width: double.infinity,
                        backgroundColor: Colors.blue,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue',
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

                      // Social Registration Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[700])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Or continue with',
                              style: ShadTheme.of(context).textTheme.small
                                  ?.copyWith(color: Colors.grey[400]),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[700])),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Social Registration Buttons
                      Row(
                        children: [
                          // Google Button
                          Expanded(
                            child: ShadButton.outline(
                              onPressed: () => _handleSocialRegister('google'),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.chrome,
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
                              onPressed: () =>
                                  _handleSocialRegister('facebook'),
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
                              onTap: () => context.push(RoutePaths.login),
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
