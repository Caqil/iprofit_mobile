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
  final _step4FormKey = GlobalKey<ShadFormState>();

  // Controllers for all form fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateOfBirthController = TextEditingController();

  // Address controllers
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _zipCodeController = TextEditingController();

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
  DateTime? _selectedDate;

  // Step configuration
  final List<String> _stepTitles = [
    'Personal Info',
    'Address',
    'Security',
    'Investment',
    'Confirm',
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
    _dateOfBirthController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  /// Initialize plans from API
  Future<void> _initializePlans() async {
    try {
      await Future.microtask(() async {
        await ref.read(plansProvider.notifier).initialize();
      });

      if (mounted) {
        final plansState = ref.read(plansProvider);
        if (plansState.hasSelectedPlan) {
          setState(() => _selectedPlan = plansState.selectedPlan!.id);
        } else if (plansState.hasPlans) {
          setState(() => _selectedPlan = plansState.plans.first.id);
        }
      }
    } catch (e) {
      debugPrint('Plans initialization failed: $e');
    }
  }

  Future<void> _initializeDeviceId() async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      if (mounted) {
        setState(() => _deviceId = deviceId);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Device error: Unable to identify device', isError: true);
      }
    }
  }

  /// Show date picker for date of birth
  Future<void> _selectDateOfBirth() async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime(2000),
        firstDate: DateTime(1940),
        lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
        helpText: 'Select Date of Birth',
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Colors.blue,
                onPrimary: Colors.white,
                surface: Color(0xFF2A2A2A),
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null && mounted) {
        setState(() {
          _selectedDate = picked;
          _dateOfBirthController.text =
              '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error selecting date', isError: true);
      }
    }
  }

  /// Validate current step and move to next
  Future<void> _nextStep() async {
    bool isValid = false;

    switch (_currentStep) {
      case 0:
        isValid = _step1FormKey.currentState?.validate() ?? false;
        if (isValid && _selectedDate == null) {
          _showSnackBar('Please select your date of birth', isError: true);
          isValid = false;
        }
        break;
      case 1:
        isValid = _step2FormKey.currentState?.validate() ?? false;
        break;
      case 2:
        isValid = _step3FormKey.currentState?.validate() ?? false;
        if (isValid &&
            _passwordController.text != _confirmPasswordController.text) {
          _showSnackBar('Passwords do not match', isError: true);
          isValid = false;
        }
        break;
      case 3:
        isValid = _step4FormKey.currentState?.validate() ?? false;
        break;
      case 4:
        await _handleRegister();
        return;
    }

    if (isValid) {
      setState(() {
        _currentStep = (_currentStep + 1).clamp(0, _stepTitles.length - 1);
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

  /// Show snackbar message
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  /// Handle registration with API integration
  Future<void> _handleRegister() async {
    if (_deviceId == null) {
      _showSnackBar('Device ID not available', isError: true);
      return;
    }

    if (!_acceptTerms || !_acceptPrivacy) {
      _showSnackBar('Please accept Terms and Privacy Policy', isError: true);
      return;
    }

    if (_selectedDate == null) {
      _showSnackBar('Please select your date of birth', isError: true);
      return;
    }

    final formattedDateOfBirth =
        '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

    final address = {
      'street': _streetController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'country': _countryController.text.trim(),
      'zipCode': _zipCodeController.text.trim(),
    };

    final success = await ref
        .read(authProvider.notifier)
        .register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          dateOfBirth: formattedDateOfBirth,
          address: address,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          deviceId: _deviceId!,
          planId: _selectedPlan,
          referralCode: _referralCodeController.text.trim(),
          acceptTerms: _acceptTerms,
          acceptPrivacy: _acceptPrivacy,
        );

    if (success && mounted) {
      _showSnackBar('Registration successful! Please verify your email.');

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.push(
            '${RoutePaths.verifyOtp}?email=${_emailController.text.trim()}&name=${_nameController.text.trim()}',
          );
        }
      });
    }
  }

  /// Handle social registration
  Future<void> _handleSocialRegister(String provider) async {
    _showSnackBar('$provider registration coming soon');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthenticationState>(authProvider, (previous, current) {
      if (current.hasError && mounted) {
        _showSnackBar(current.error ?? 'Registration failed', isError: true);
      }
    });

    return LoadingOverlay(
      isLoading: authState.isLoading,
      message: 'Creating account...',
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildCurrentStepContent(),
              ),
            ),
            _buildBottomNavigation(authState),
          ],
        ),
      ),
    );
  }

  /// Build compact app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue, Colors.cyan]),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.trendingUp,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'iProfit',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.push(RoutePaths.login),
          child: const Text(
            'Sign In',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  /// Build compact progress indicator
  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentStep + 1} of ${_stepTitles.length}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                _stepTitles[_currentStep],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentStep + 1) / _stepTitles.length,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: 3,
          ),
        ],
      ),
    );
  }

  /// Build content for current step
  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1PersonalInfo();
      case 1:
        return _buildStep2Address();
      case 2:
        return _buildStep3Security();
      case 3:
        return _buildStep4Investment();
      case 4:
        return _buildStep5Confirmation();
      default:
        return Container();
    }
  }

  /// Compact input field widget
  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? trailing,
    VoidCallback? onTap,
    bool readOnly = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onTap,
            child: ShadInputFormField(
              controller: controller,
              placeholder: Text(
                hint,
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              validator: validator,
              obscureText: obscureText,
              readOnly: readOnly,
              textCapitalization: textCapitalization,
              leading: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(icon, size: 18, color: Colors.blue),
              ),
              trailing: trailing,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: ShadDecoration(
                border: ShadBorder.all(color: Colors.grey[700]!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Step 1: Personal Information
  Widget _buildStep1PersonalInfo() {
    return ShadForm(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Let\'s start with your basic details',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),

          _buildCompactTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: LucideIcons.user,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            validator: (value) =>
                Validators.validateRequired(value, 'Full name'),
          ),

          _buildCompactTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter your email address',
            icon: LucideIcons.mail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validators.validateEmail,
          ),

          _buildCompactTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: 'Enter your phone number',
            icon: LucideIcons.phone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: Validators.validatePhoneNumber,
          ),

          _buildCompactTextField(
            controller: _dateOfBirthController,
            label: 'Date of Birth',
            hint: 'Select your date of birth',
            icon: LucideIcons.calendar,
            readOnly: true,
            onTap: _selectDateOfBirth,
            validator: (value) =>
                Validators.validateRequired(value, 'Date of birth'),
            trailing: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(
                LucideIcons.chevronDown,
                size: 18,
                color: Colors.grey,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.info, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You must be 18 or older to register',
                    style: TextStyle(color: Colors.blue[200], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Step 2: Address Information
  Widget _buildStep2Address() {
    return ShadForm(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Address Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide your current address',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),

          _buildCompactTextField(
            controller: _streetController,
            label: 'Street Address',
            hint: 'Enter your street address',
            icon: LucideIcons.mapPin,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            validator: (value) =>
                Validators.validateRequired(value, 'Street address'),
          ),

          _buildCompactTextField(
            controller: _cityController,
            label: 'City',
            hint: 'Enter your city',
            icon: LucideIcons.building,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            validator: (value) => Validators.validateRequired(value, 'City'),
          ),

          Row(
            children: [
              Expanded(
                child: _buildCompactTextField(
                  controller: _stateController,
                  label: 'State/Province',
                  hint: 'State',
                  icon: LucideIcons.map,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) =>
                      Validators.validateRequired(value, 'State'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactTextField(
                  controller: _zipCodeController,
                  label: 'Zip Code',
                  hint: '12345',
                  icon: LucideIcons.hash,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      Validators.validateRequired(value, 'Zip code'),
                ),
              ),
            ],
          ),

          _buildCompactTextField(
            controller: _countryController,
            label: 'Country',
            hint: 'Enter your country',
            icon: LucideIcons.globe,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.words,
            validator: (value) => Validators.validateRequired(value, 'Country'),
          ),
        ],
      ),
    );
  }

  /// Step 3: Security
  Widget _buildStep3Security() {
    return ShadForm(
      key: _step3FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Security',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a secure password for your account',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),

          _buildCompactTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Create a strong password',
            icon: LucideIcons.lock,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            validator: Validators.validatePassword,
            trailing: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
            ),
          ),

          _buildCompactTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Confirm your password',
            icon: LucideIcons.lockKeyhole,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            validator: (value) =>
                Validators.validateRequired(value, 'Confirm password'),
            trailing: GestureDetector(
              onTap: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  _obscureConfirmPassword
                      ? LucideIcons.eyeOff
                      : LucideIcons.eye,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Password Requirements:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                ...[
                  '8+ characters',
                  'Upper & lowercase',
                  'Numbers',
                  'Special characters',
                ].map(
                  (req) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.check,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          req,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Step 4: Investment Plan
  Widget _buildStep4Investment() {
    final plansState = ref.watch(plansProvider);

    return ShadForm(
      key: _step4FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Investment Plan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your investment strategy',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),

          if (plansState.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (plansState.hasError)
            _buildErrorState(plansState.error!)
          else if (plansState.hasPlans)
            ...plansState.plans.map((plan) => _buildCompactPlanCard(plan))
          else
            _buildNoPlanState(),

          const SizedBox(height: 16),

          _buildCompactTextField(
            controller: _referralCodeController,
            label: 'Referral Code (Optional)',
            hint: 'Enter referral code',
            icon: LucideIcons.gift,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.characters,
            validator: Validators.validateReferralCode,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPlanCard(dynamic plan) {
    final isSelected = _selectedPlan == plan.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedPlan = plan.id);
          ref.read(plansProvider.notifier).selectPlan(plan);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey[700]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey[600]!,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: isSelected
                        ? const Icon(
                            LucideIcons.check,
                            size: 10,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      plan.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      plan.dailyReturnEstimate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                plan.description,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Price: ',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  Text(
                    plan.formattedPrice,
                    style: TextStyle(
                      color: plan.isFree ? Colors.green : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Min: ',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  Text(
                    '${plan.currency} ${plan.limits.formattedMinDeposit}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.circleAlert, color: Colors.red, size: 32),
          const SizedBox(height: 8),
          const Text(
            'Failed to load plans',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(error, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => ref.read(plansProvider.notifier).refresh(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPlanState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.package, color: Colors.orange, size: 32),
          const SizedBox(height: 8),
          const Text(
            'Plans Unavailable',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'You can choose a plan later',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              setState(() => _selectedPlan = null);
              ref.read(plansProvider.notifier).refresh();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Step 5: Confirmation
  Widget _buildStep5Confirmation() {
    final plansState = ref.watch(plansProvider);
    final selectedPlan = plansState.plans
        .where((plan) => plan.id == _selectedPlan)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review & Confirm',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please review your information',
          style: TextStyle(fontSize: 14, color: Colors.grey[400]),
        ),
        const SizedBox(height: 24),

        // Compact review sections
        _buildCompactReviewSection('Personal', [
          'Name: ${_nameController.text}',
          'Email: ${_emailController.text}',
          'Phone: ${_phoneController.text}',
          'DOB: ${_dateOfBirthController.text}',
        ]),

        const SizedBox(height: 16),

        _buildCompactReviewSection('Address', [
          'Street: ${_streetController.text}',
          'City: ${_cityController.text}',
          'State: ${_stateController.text}',
          'Country: ${_countryController.text}',
        ]),

        const SizedBox(height: 16),

        _buildCompactReviewSection('Investment', [
          'Plan: ${selectedPlan?.name ?? 'No plan selected'}',
          if (selectedPlan != null) 'Price: ${selectedPlan.formattedPrice}',
          if (_referralCodeController.text.isNotEmpty)
            'Referral: ${_referralCodeController.text}',
        ]),

        const SizedBox(height: 24),

        // Compact checkboxes
        _buildCompactCheckbox(
          value: _acceptTerms,
          onChanged: (value) => setState(() => _acceptTerms = value ?? false),
          title: 'I accept the Terms of Service',
        ),

        const SizedBox(height: 12),

        _buildCompactCheckbox(
          value: _acceptPrivacy,
          onChanged: (value) => setState(() => _acceptPrivacy = value ?? false),
          title: 'I accept the Privacy Policy',
        ),

        const SizedBox(height: 24),

        // Social options
        Center(
          child: Column(
            children: [
              Text(
                'Or register with',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(
                    LucideIcons.chrome,
                    'Google',
                    () => _handleSocialRegister('Google'),
                  ),
                  const SizedBox(width: 12),
                  _buildSocialButton(
                    LucideIcons.apple,
                    'Apple',
                    () => _handleSocialRegister('Apple'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactReviewSection(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                item,
                style: TextStyle(color: Colors.grey[300], fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String title,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: value ? Colors.blue : Colors.transparent,
              border: Border.all(
                color: value ? Colors.blue : Colors.grey[600]!,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: value
                ? const Icon(LucideIcons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: Colors.grey[300], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// Build compact bottom navigation
  Widget _buildBottomNavigation(AuthenticationState authState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: Row(
        children: [
          // Back button
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[600]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Back', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            const Expanded(child: SizedBox()),

          if (_currentStep > 0) const SizedBox(width: 12),

          // Continue/Create button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: (_deviceId != null && !authState.isLoading)
                  ? _nextStep
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _currentStep == _stepTitles.length - 1
                    ? 'Create Account'
                    : 'Continue',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
