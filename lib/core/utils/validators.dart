class Validators {
  // Regular expressions for validation
  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
  static final RegExp _strongPasswordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$',
  );
  static final RegExp _nameRegex = RegExp(r'^[a-zA-Z\s]{2,50}$');
  static final RegExp _deviceIdRegex = RegExp(r'^[a-zA-Z0-9_-]{1,100}$');
  static final RegExp _referralCodeRegex = RegExp(r'^[A-Z0-9]{3,20}$');

  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    if (value.length > 254) {
      return 'Email is too long';
    }

    return null;
  }

  /// Validate password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (value.length > 128) {
      return 'Password is too long';
    }

    if (!_strongPasswordRegex.hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, number and special character';
    }

    // Check for common weak passwords
    final commonPasswords = [
      'password',
      '123456',
      '12345678',
      'qwerty',
      'abc123',
      'password123',
      'admin',
      'letmein',
      'welcome',
      '123456789',
    ];

    if (commonPasswords.contains(value.toLowerCase())) {
      return 'This password is too common, please choose a stronger one';
    }

    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove spaces, hyphens, and parentheses for validation
    final cleanedNumber = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (!_phoneRegex.hasMatch(cleanedNumber)) {
      return 'Please enter a valid phone number';
    }

    // Check for minimum length (international format)
    if (cleanedNumber.length < 7) {
      return 'Phone number is too short';
    }

    if (cleanedNumber.length > 15) {
      return 'Phone number is too long';
    }

    return null;
  }

  /// Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return 'Name must be at least 2 characters long';
    }

    if (trimmedValue.length > 50) {
      return 'Name is too long';
    }

    if (!_nameRegex.hasMatch(trimmedValue)) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }

  /// Validate amount
  static String? validateAmount(
    String? value, {
    double? minAmount,
    double? maxAmount,
    bool allowZero = false,
  }) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (!allowZero && amount <= 0) {
      return 'Amount must be greater than zero';
    }

    if (allowZero && amount < 0) {
      return 'Amount cannot be negative';
    }

    if (minAmount != null && amount < minAmount) {
      return 'Minimum amount is ${Formatters.formatCurrency(minAmount)}';
    }

    if (maxAmount != null && amount > maxAmount) {
      return 'Maximum amount is ${Formatters.formatCurrency(maxAmount)}';
    }

    // Check for too many decimal places
    if (value.contains('.')) {
      final decimalPart = value.split('.')[1];
      if (decimalPart.length > 2) {
        return 'Amount can have at most 2 decimal places';
      }
    }

    return null;
  }

  /// Validate deposit amount
  static String? validateDepositAmount(String? value) {
    return validateAmount(
      value,
      minAmount: 10.0, // From API constants
      maxAmount: 100000.0,
    );
  }

  /// Validate withdrawal amount
  static String? validateWithdrawalAmount(
    String? value, {
    double? availableBalance,
  }) {
    final amountValidation = validateAmount(
      value,
      minAmount: 100.0, // From API constants
      maxAmount: 100000.0, // Daily limit
    );

    if (amountValidation != null) return amountValidation;

    if (availableBalance != null) {
      final amount = double.parse(value!);
      if (amount > availableBalance) {
        return 'Insufficient balance';
      }
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate device ID
  static String? validateDeviceId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Device ID is required';
    }

    if (!_deviceIdRegex.hasMatch(value)) {
      return 'Invalid device ID format';
    }

    return null;
  }

  /// Validate referral code
  static String? validateReferralCode(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Referral code is optional
    }

    final upperValue = value.toUpperCase();

    if (!_referralCodeRegex.hasMatch(upperValue)) {
      return 'Invalid referral code format';
    }

    return null;
  }

  /// Validate date of birth
  static String? validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date of birth is required';
    }

    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();
      final age = now.year - date.year;

      if (date.isAfter(now)) {
        return 'Date of birth cannot be in the future';
      }

      if (age < 18) {
        return 'You must be at least 18 years old';
      }

      if (age > 120) {
        return 'Please enter a valid date of birth';
      }

      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  /// Validate loan amount
  static String? validateLoanAmount(String? value) {
    return validateAmount(value, minAmount: 100.0, maxAmount: 50000.0);
  }

  /// Validate loan tenure
  static String? validateLoanTenure(String? value) {
    if (value == null || value.isEmpty) {
      return 'Loan tenure is required';
    }

    final tenure = int.tryParse(value);
    if (tenure == null) {
      return 'Please enter a valid tenure';
    }

    if (tenure < 3) {
      return 'Minimum tenure is 3 months';
    }

    if (tenure > 60) {
      return 'Maximum tenure is 60 months';
    }

    return null;
  }

  /// Validate monthly income
  static String? validateMonthlyIncome(String? value) {
    return validateAmount(value, minAmount: 500.0, maxAmount: 1000000.0);
  }

  /// Validate account number
  static String? validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Account number is required';
    }

    final cleanedValue = value.replaceAll(RegExp(r'\D'), '');

    if (cleanedValue.length < 8) {
      return 'Account number is too short';
    }

    if (cleanedValue.length > 20) {
      return 'Account number is too long';
    }

    return null;
  }

  /// Validate routing number
  static String? validateRoutingNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Routing number is required';
    }

    final cleanedValue = value.replaceAll(RegExp(r'\D'), '');

    if (cleanedValue.length != 9) {
      return 'Routing number must be 9 digits';
    }

    return null;
  }

  /// Validate crypto wallet address
  static String? validateWalletAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Wallet address is required';
    }

    // Basic validation for common crypto addresses
    if (value.length < 25 || value.length > 62) {
      return 'Invalid wallet address format';
    }

    // Check for common prefixes
    final validPrefixes = ['1', '3', 'bc1', '0x', 'bnb', 'ltc'];
    final hasValidPrefix = validPrefixes.any(
      (prefix) => value.startsWith(prefix),
    );

    if (!hasValidPrefix) {
      return 'Invalid wallet address format';
    }

    return null;
  }

  /// Validate 2FA token
  static String? validate2FAToken(String? value) {
    if (value == null || value.isEmpty) {
      return '2FA token is required';
    }

    final cleanedValue = value.replaceAll(RegExp(r'\D'), '');

    if (cleanedValue.length != 6) {
      return '2FA token must be 6 digits';
    }

    return null;
  }

  /// Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional in most cases
    }

    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return 'Please enter a valid URL';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid URL';
    }
  }

  /// Validate file size
  static String? validateFileSize(int bytes, {int maxSizeInMB = 10}) {
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;

    if (bytes > maxSizeInBytes) {
      return 'File size cannot exceed ${maxSizeInMB}MB';
    }

    return null;
  }

  /// Validate file type
  static String? validateFileType(
    String fileName,
    List<String> allowedExtensions,
  ) {
    final extension = fileName.split('.').last.toLowerCase();

    if (!allowedExtensions.contains(extension)) {
      return 'Only ${allowedExtensions.join(', ')} files are allowed';
    }

    return null;
  }

  /// Combine multiple validators
  static String? combineValidators(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) return result;
    }
    return null;
  }
}

/// Form validation helper class
class FormValidators {
  /// Create a validator that combines multiple validation rules
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }

  /// Create a conditional validator
  static String? Function(String?) conditional(
    bool condition,
    String? Function(String?) validator,
  ) {
    return (value) {
      if (condition) {
        return validator(value);
      }
      return null;
    };
  }

  /// Create a validator that only runs if value is not empty
  static String? Function(String?) optional(
    String? Function(String?) validator,
  ) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return null;
      }
      return validator(value);
    };
  }
}
