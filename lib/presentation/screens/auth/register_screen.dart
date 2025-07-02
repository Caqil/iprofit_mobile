// ============================================================================
// lib/presentation/screens/auth/register_screen.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iprofit_mobile/presentation/providers/plans_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/device_service.dart';
import '../../../router/route_paths.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/success_dialog.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // Form keys for each step
  final _step1FormKey = GlobalKey<ShadFormState>();
  final _step2FormKey = GlobalKey<ShadFormState>();
  final _step3FormKey = GlobalKey<ShadFormState>();

  // Controllers for all form fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _referralCodeController = TextEditingController();

  // State variables
  int _currentStep = 0;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _acceptPrivacy = false;
  String? _deviceId;
  String? _selectedPlan;

  // Step configuration
  final List<StepInfo> _steps = [
    StepInfo(
      title: 'Basic Information',
      description: 'Enter your personal details',
      icon: LucideIcons.user,
    ),
    StepInfo(
      title: 'Security',
      description: 'Create a secure password',
      icon: LucideIcons.lock,
    ),
    StepInfo(
      title: 'Investment',
      description: 'Choose your plan',
      icon: LucideIcons.trendingUp,
    ),
    StepInfo(
      title: 'Confirmation',
      description: 'Review and confirm',
      icon: LucideIcons.circleCheck,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeDeviceId();
    // Initialize plans after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlans();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  /// Initialize plans from API (called after widget tree is built)
  Future<void> _initializePlans() async {
    try {
      // Use Future.microtask to ensure we're outside the build phase
      await Future.microtask(() async {
        await ref.read(plansProvider.notifier).initialize();
      });

      // Set default selected plan
      if (mounted) {
        final plansState = ref.read(plansProvider);
        if (plansState.hasSelectedPlan) {
          setState(() => _selectedPlan = plansState.selectedPlan!.id);
        } else if (plansState.hasPlans) {
          // If no selected plan but has plans, select first one
          setState(() => _selectedPlan = plansState.plans.first.id);
        }
      }
    } catch (e) {
      // Don't show error dialog immediately - let user proceed without plans
      debugPrint('Plans initialization failed: $e');
    }
  }

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

  /// Validate current step and move to next
  Future<void> _nextStep() async {
    bool isValid = false;

    switch (_currentStep) {
      case 0:
        isValid = _step1FormKey.currentState?.validate() ?? false;
        break;
      case 1:
        isValid = _step2FormKey.currentState?.validate() ?? false;
        if (isValid &&
            _passwordController.text != _confirmPasswordController.text) {
          await showErrorDialog(
            context,
            title: 'Password Mismatch',
            message: 'Passwords do not match. Please check and try again.',
          );
          isValid = false;
        }
        break;
      case 2:
        isValid = _step3FormKey.currentState?.validate() ?? false;
        break;
      case 3:
        // Final step - submit registration
        await _handleRegister();
        return;
    }

    if (isValid) {
      setState(() {
        _currentStep = (_currentStep + 1).clamp(0, _steps.length - 1);
      });
    }
  }

  /// Go to previous step
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  /// Handle registration with real API integration
  Future<void> _handleRegister() async {
    if (_deviceId == null) return;

    // Validate terms acceptance
    if (!_acceptTerms || !_acceptPrivacy) {
      await showErrorDialog(
        context,
        title: 'Terms Required',
        message:
            'Please accept both Terms of Service and Privacy Policy to continue.',
      );
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          deviceId: _deviceId!,
          planId: _selectedPlan, // Can be null if no plans available
          referralCode: _referralCodeController.text.trim().isNotEmpty
              ? _referralCodeController.text.trim()
              : null,
          acceptTerms: _acceptTerms,
          acceptPrivacy: _acceptPrivacy,
        );

    if (success && mounted) {
      await showSuccessDialog(
        context,
        title: 'Registration Successful!',
        message: 'Welcome to iProfit! Please verify your email to get started.',
        autoClose: true,
        autoCloseDuration: const Duration(seconds: 2),
      );

      // Navigate to OTP verification with user data
      if (mounted) {
        context.push(
          '${RoutePaths.verifyOtp}?email=${_emailController.text.trim()}&name=${_nameController.text.trim()}',
        );
      }
    }
  }

  /// Handle social registration
  Future<void> _handleSocialRegister(String provider) async {
    await showErrorDialog(
      context,
      title: 'Coming Soon',
      message: '$provider registration will be available soon.',
    );
  }

  /// Get step progress as percentage
  double get _stepProgress => (_currentStep + 1) / _steps.length;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen for auth state changes and errors
    ref.listen<AuthenticationState>(authProvider, (previous, current) {
      if (current.hasError && mounted) {
        showErrorDialog(
          context,
          title: 'Registration Failed',
          message: current.error ?? 'An unexpected error occurred',
        );
      }
    });

    return LoadingOverlay(
      isLoading: authState.isLoading,
      message: 'Creating your account...',
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: SafeArea(
          child: Column(
            children: [
              // Header with progress
              _buildHeader(),

              // Step content
              Expanded(
                child: SingleChildScrollView(
                  padding: AppConstants.paddingHorizontalMD,
                  child: _buildCurrentStepContent(),
                ),
              ),

              // Navigation buttons
              _buildNavigationButtons(authState),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header with logo and progress indicator
  Widget _buildHeader() {
    return Container(
      padding: AppConstants.paddingHorizontalMD,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Column(
        children: [
          // Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.trendingUp,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'iProfit',
                style: ShadTheme.of(context).textTheme.h3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Progress Indicator
          Row(
            children: [
              Text(
                'Step ${_currentStep + 1} of ${_steps.length}',
                style: ShadTheme.of(
                  context,
                ).textTheme.small.copyWith(color: Colors.grey[400]),
              ),
              const Spacer(),
              Text(
                _steps[_currentStep].title,
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
              widthFactor: _stepProgress,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Step icon and description
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _steps[_currentStep].icon,
                  size: 18,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _steps[_currentStep].description,
                  style: ShadTheme.of(
                    context,
                  ).textTheme.p.copyWith(color: Colors.grey[300]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build content for current step
  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1BasicInfo();
      case 1:
        return _buildStep2Security();
      case 2:
        return _buildStep3Investment();
      case 3:
        return _buildStep4Confirmation();
      default:
        return Container();
    }
  }

  /// Step 1: Basic Information
  Widget _buildStep1BasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        Text(
          'Basic Information',
          style: ShadTheme.of(context).textTheme.h2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Let\'s start with your basic details',
          style: ShadTheme.of(
            context,
          ).textTheme.p.copyWith(color: Colors.grey[400]),
        ),

        const SizedBox(height: 32),

        ShadForm(
          key: _step1FormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Full Name Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full Name',
                    style: ShadTheme.of(context).textTheme.p.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ShadInputFormField(
                    controller: _nameController,
                    placeholder: const Text('Enter your full name'),
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) =>
                        Validators.validateRequired(value, 'Full name'),
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
                      border: ShadBorder.all(color: Colors.grey[700]!),
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
                      border: ShadBorder.all(color: Colors.grey[700]!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Phone Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phone Number',
                    style: ShadTheme.of(context).textTheme.p.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ShadInputFormField(
                    controller: _phoneController,
                    placeholder: const Text('Enter your phone number'),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    validator: Validators.validatePhoneNumber,
                    leading: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        LucideIcons.phone,
                        size: 18,
                        color: Colors.grey[400],
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    decoration: ShadDecoration(
                      border: ShadBorder.all(color: Colors.grey[700]!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Step 2: Security (Password)
  Widget _buildStep2Security() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        Text(
          'Security',
          style: ShadTheme.of(context).textTheme.h2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create a strong password to secure your account',
          style: ShadTheme.of(
            context,
          ).textTheme.p.copyWith(color: Colors.grey[400]),
        ),

        const SizedBox(height: 32),

        ShadForm(
          key: _step2FormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                    placeholder: const Text('Create a strong password'),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    validator: Validators.validatePassword,
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
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        child: Icon(
                          _obscurePassword
                              ? LucideIcons.eyeOff
                              : LucideIcons.eye,
                          size: 18,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    decoration: ShadDecoration(
                      border: ShadBorder.all(color: Colors.grey[700]!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Confirm Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm Password',
                    style: ShadTheme.of(context).textTheme.p.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ShadInputFormField(
                    controller: _confirmPasswordController,
                    placeholder: const Text('Confirm your password'),
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    validator: (value) =>
                        Validators.validateRequired(value, 'Confirm password'),
                    leading: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        LucideIcons.lockKeyhole,
                        size: 18,
                        color: Colors.grey[400],
                      ),
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.all(12),
                      child: GestureDetector(
                        onTap: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                        child: Icon(
                          _obscureConfirmPassword
                              ? LucideIcons.eyeOff
                              : LucideIcons.eye,
                          size: 18,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    decoration: ShadDecoration(
                      border: ShadBorder.all(color: Colors.grey[700]!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Password requirements
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password Requirements:',
                      style: ShadTheme.of(context).textTheme.small.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• At least 8 characters long\n'
                      '• Contains uppercase and lowercase letters\n'
                      '• Contains at least one number\n'
                      '• Contains at least one special character',
                      style: ShadTheme.of(
                        context,
                      ).textTheme.small.copyWith(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Step 3: Investment Plan
  Widget _buildStep3Investment() {
    final plansState = ref.watch(plansProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        Text(
          'Investment Plan',
          style: ShadTheme.of(context).textTheme.h2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the plan that best fits your investment goals',
          style: ShadTheme.of(
            context,
          ).textTheme.p.copyWith(color: Colors.grey[400]),
        ),

        const SizedBox(height: 32),

        ShadForm(
          key: _step3FormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Loading state
              if (plansState.isLoading)
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Loading investment plans...',
                        style: ShadTheme.of(
                          context,
                        ).textTheme.p.copyWith(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                )
              // Error state
              else if (plansState.hasError)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        LucideIcons.circleAlert,
                        color: Colors.red,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load plans',
                        style: ShadTheme.of(context).textTheme.p.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        plansState.error ?? 'Unknown error occurred',
                        style: ShadTheme.of(
                          context,
                        ).textTheme.small.copyWith(color: Colors.grey[400]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ShadButton.outline(
                        onPressed: () =>
                            ref.read(plansProvider.notifier).refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              // Plans list
              else if (plansState.hasPlans)
                ...List.generate(plansState.plans.length, (index) {
                  final plan = plansState.plans[index];
                  final isSelected = _selectedPlan == plan.id;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedPlan = plan.id);
                        ref.read(plansProvider.notifier).selectPlan(plan);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey[700]!,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.grey[600]!,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          LucideIcons.check,
                                          size: 12,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        plan.name,
                                        style: ShadTheme.of(context).textTheme.p
                                            .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      if (plan.badgeText != null) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: plan.isFree
                                                ? Colors.green
                                                : Colors.orange,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            plan.badgeText!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      plan.dailyReturnEstimate,
                                      style: ShadTheme.of(context).textTheme.p
                                          .copyWith(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      'daily',
                                      style: ShadTheme.of(context)
                                          .textTheme
                                          .small
                                          .copyWith(
                                            color: Colors.grey[400],
                                            fontSize: 10,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              plan.description,
                              style: ShadTheme.of(context).textTheme.small
                                  .copyWith(color: Colors.grey[400]),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Price: ',
                                  style: ShadTheme.of(context).textTheme.small
                                      .copyWith(color: Colors.grey[400]),
                                ),
                                Text(
                                  plan.formattedPrice,
                                  style: ShadTheme.of(context).textTheme.small
                                      .copyWith(
                                        color: plan.isFree
                                            ? Colors.green
                                            : Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Min Deposit: ',
                                  style: ShadTheme.of(context).textTheme.small
                                      .copyWith(color: Colors.grey[400]),
                                ),
                                Text(
                                  '${plan.currency} ${plan.limits.formattedMinDeposit}',
                                  style: ShadTheme.of(context).textTheme.small
                                      .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                            if (plan.features.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: plan.features.take(4).map((feature) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.blue.withOpacity(0.2)
                                          : Colors.grey[800],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      feature,
                                      style: ShadTheme.of(context)
                                          .textTheme
                                          .small
                                          .copyWith(
                                            color: isSelected
                                                ? Colors.blue[200]
                                                : Colors.grey[400],
                                            fontSize: 11,
                                          ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              if (plan.features.length > 4)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '+${plan.features.length - 4} more features',
                                    style: ShadTheme.of(context).textTheme.small
                                        .copyWith(
                                          color: Colors.grey[500],
                                          fontSize: 10,
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                })
              // No plans available
              else
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(LucideIcons.package, color: Colors.orange, size: 40),
                      const SizedBox(height: 16),
                      Text(
                        'Plans temporarily unavailable',
                        style: ShadTheme.of(context).textTheme.p.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You can still create your account and choose a plan later from your dashboard.',
                        style: ShadTheme.of(
                          context,
                        ).textTheme.small.copyWith(color: Colors.grey[400]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ShadButton.outline(
                        onPressed: () {
                          // Set to null to skip plan selection
                          setState(() => _selectedPlan = null);
                          ref.read(plansProvider.notifier).refresh();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.refreshCw, size: 16),
                            const SizedBox(width: 8),
                            const Text('Retry Loading Plans'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Referral Code Field (Optional)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Referral Code (Optional)',
                    style: ShadTheme.of(context).textTheme.p.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ShadInputFormField(
                    controller: _referralCodeController,
                    placeholder: const Text('Enter referral code for bonus'),
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.characters,
                    validator: Validators.validateReferralCode,
                    leading: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        LucideIcons.gift,
                        size: 18,
                        color: Colors.grey[400],
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    decoration: ShadDecoration(
                      border: ShadBorder.all(color: Colors.grey[700]!),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get bonus rewards when you use a referral code',
                    style: ShadTheme.of(
                      context,
                    ).textTheme.small.copyWith(color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Step 4: Confirmation
  Widget _buildStep4Confirmation() {
    final plansState = ref.watch(plansProvider);
    final selectedPlan = plansState.plans
        .where((plan) => plan.id == _selectedPlan)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        Text(
          'Confirmation',
          style: ShadTheme.of(context).textTheme.h2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Review your information before creating your account',
          style: ShadTheme.of(
            context,
          ).textTheme.p.copyWith(color: Colors.grey[400]),
        ),

        const SizedBox(height: 32),

        // Review Information
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Information',
                style: ShadTheme.of(context).textTheme.p.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Name', _nameController.text),
              _buildInfoRow('Email', _emailController.text),
              _buildInfoRow('Phone', _phoneController.text),
              _buildInfoRow('Plan', selectedPlan?.name ?? 'Unknown Plan'),
              if (selectedPlan != null)
                _buildInfoRow('Plan Price', selectedPlan.formattedPrice),
              if (_referralCodeController.text.isNotEmpty)
                _buildInfoRow('Referral Code', _referralCodeController.text),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Terms and Privacy Checkboxes
        Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _acceptTerms ? Colors.blue : Colors.transparent,
                      border: Border.all(
                        color: _acceptTerms ? Colors.blue : Colors.grey[600]!,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _acceptTerms
                        ? const Icon(
                            LucideIcons.check,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    children: [
                      Text(
                        'I accept the ',
                        style: ShadTheme.of(
                          context,
                        ).textTheme.small.copyWith(color: Colors.grey[300]),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.grey[900],
                              title: const Text(
                                'Terms of Service',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'Terms of Service content would be displayed here.',
                                style: TextStyle(color: Colors.grey),
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
                        child: Text(
                          'Terms of Service',
                          style: ShadTheme.of(context).textTheme.small.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _acceptPrivacy = !_acceptPrivacy),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _acceptPrivacy ? Colors.blue : Colors.transparent,
                      border: Border.all(
                        color: _acceptPrivacy ? Colors.blue : Colors.grey[600]!,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _acceptPrivacy
                        ? const Icon(
                            LucideIcons.check,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    children: [
                      Text(
                        'I accept the ',
                        style: ShadTheme.of(
                          context,
                        ).textTheme.small.copyWith(color: Colors.grey[300]),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.grey[900],
                              title: const Text(
                                'Privacy Policy',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'Privacy Policy content would be displayed here.',
                                style: TextStyle(color: Colors.grey),
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
                        child: Text(
                          'Privacy Policy',
                          style: ShadTheme.of(context).textTheme.small.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Social Registration Option
        Column(
          children: [
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[700])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Or register with',
                    style: ShadTheme.of(
                      context,
                    ).textTheme.small.copyWith(color: Colors.grey[400]),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[700])),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google Registration
                GestureDetector(
                  onTap: () => _handleSocialRegister('Google'),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[700]!),
                    ),
                    child: const Icon(
                      LucideIcons.chrome,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Apple Registration
                GestureDetector(
                  onTap: () => _handleSocialRegister('Apple'),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[700]!),
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
      ],
    );
  }

  /// Build info row for review section
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: ShadTheme.of(
                context,
              ).textTheme.small.copyWith(color: Colors.grey[400]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: ShadTheme.of(context).textTheme.small.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build navigation buttons
  Widget _buildNavigationButtons(AuthenticationState authState) {
    return Container(
      padding: AppConstants.paddingHorizontalMD,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(top: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Column(
        children: [
          // Main action button
          ShadButton(
            onPressed: (_deviceId != null && !authState.isLoading)
                ? _nextStep
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentStep == _steps.length - 1
                      ? 'Create Account'
                      : 'Continue',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _currentStep == _steps.length - 1
                      ? LucideIcons.userPlus
                      : LucideIcons.arrowRight,
                  size: 18,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Navigation row
          Row(
            children: [
              // Back button
              if (_currentStep > 0)
                ShadButton.outline(
                  onPressed: _previousStep,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.arrowLeft, size: 16),
                      const SizedBox(width: 8),
                      const Text('Back'),
                    ],
                  ),
                )
              else
                const SizedBox(),

              const Spacer(),

              // Login link
              GestureDetector(
                onTap: () => context.push(RoutePaths.login),
                child: Text(
                  'Already have an account? Sign in',
                  style: ShadTheme.of(context).textTheme.small.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Step information model
class StepInfo {
  final String title;
  final String description;
  final IconData icon;

  StepInfo({
    required this.title,
    required this.description,
    required this.icon,
  });
}
