import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class Formatters {
  // Date formatters
  static final DateFormat _readableDateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _readableDateTimeFormat = DateFormat(
    'MMM dd, yyyy hh:mm a',
  );
  static final DateFormat _shortDateFormat = DateFormat('MM/dd/yyyy');
  static final DateFormat _timeOnlyFormat = DateFormat('hh:mm a');
  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _monthYearFormat = DateFormat('MMM yyyy');
  static final DateFormat _dayMonthFormat = DateFormat('dd MMM');

  // Currency formatters
  static final NumberFormat _usdFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
    locale: 'en_US',
  );

  static final NumberFormat _bdtFormatter = NumberFormat.currency(
    symbol: '৳',
    decimalDigits: 2,
    locale: 'bn_BD',
  );

  static final NumberFormat _percentageFormatter =
      NumberFormat.percentPattern();
  static final NumberFormat _decimalFormatter = NumberFormat('#,##0.00');
  static final NumberFormat _integerFormatter = NumberFormat('#,##0');

  /// Format currency based on currency code
  static String formatCurrency(double amount, {String currency = 'USD'}) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return _usdFormatter.format(amount);
      case 'BDT':
        return _bdtFormatter.format(amount);
      default:
        return '$currency ${_decimalFormatter.format(amount)}';
    }
  }

  /// Format USD currency
  static String formatUSD(double amount) {
    return _usdFormatter.format(amount);
  }

  /// Format BDT currency
  static String formatBDT(double amount) {
    return _bdtFormatter.format(amount);
  }

  /// Format compact currency (with K, M, B suffixes)
  static String formatCompactCurrency(
    double amount, {
    String currency = 'USD',
  }) {
    String symbol;
    switch (currency.toUpperCase()) {
      case 'USD':
        symbol = '\$';
        break;
      case 'BDT':
        symbol = '৳';
        break;
      default:
        symbol = currency;
    }

    if (amount >= 1000000000) {
      return '$symbol${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '$symbol${amount.toStringAsFixed(2)}';
    }
  }

  /// Format percentage
  static String formatPercentage(double value, {int decimalPlaces = 1}) {
    return '${(value * 100).toStringAsFixed(decimalPlaces)}%';
  }

  /// Format decimal number
  static String formatDecimal(double value, {int decimalPlaces = 2}) {
    return value.toStringAsFixed(decimalPlaces);
  }

  /// Format integer with thousands separator
  static String formatInteger(int value) {
    return _integerFormatter.format(value);
  }

  /// Format phone number
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digits
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (digits.length == 10) {
      // US format: (123) 456-7890
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (digits.length == 11 && digits.startsWith('1')) {
      // US format with country code: +1 (123) 456-7890
      return '+1 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
    } else if (digits.length >= 10) {
      // International format: +XX XXX XXX XXXX
      final countryCode = digits.substring(0, digits.length - 10);
      final localNumber = digits.substring(digits.length - 10);
      return '+$countryCode ${localNumber.substring(0, 3)} ${localNumber.substring(3, 6)} ${localNumber.substring(6)}';
    }

    // Return original if can't format
    return phoneNumber;
  }

  /// Format transaction ID (make it more readable)
  static String formatTransactionId(String transactionId) {
    if (transactionId.length > 12) {
      return '${transactionId.substring(0, 4)}-${transactionId.substring(4, 8)}-${transactionId.substring(8, 12)}...';
    }
    return transactionId;
  }

  /// Format account number (mask all but last 4 digits)
  static String formatAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;

    final lastFour = accountNumber.substring(accountNumber.length - 4);
    final masked = '*' * (accountNumber.length - 4);
    return '$masked$lastFour';
  }

  /// Format card number (mask all but last 4 digits)
  static String formatCardNumber(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 4) return digits;

    final lastFour = digits.substring(digits.length - 4);
    final masked = '*' * (digits.length - 4);
    return '$masked$lastFour';
  }

  /// Format date for display
  static String formatDate(DateTime date) {
    return _readableDateFormat.format(date);
  }

  /// Format date and time for display
  static String formatDateTime(DateTime dateTime) {
    return _readableDateTimeFormat.format(dateTime);
  }

  /// Format time only
  static String formatTime(DateTime dateTime) {
    return _timeOnlyFormat.format(dateTime);
  }

  /// Format date for API
  static String formatDateForApi(DateTime date) {
    return _apiDateFormat.format(date);
  }

  /// Format month and year
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Format day and month
  static String formatDayMonth(DateTime date) {
    return _dayMonthFormat.format(date);
  }

  /// Format relative time
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Format transaction status
  static String formatTransactionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'processing':
        return 'Processing';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.titleCase;
    }
  }

  /// Format transaction type
  static String formatTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'deposit':
        return 'Deposit';
      case 'withdrawal':
        return 'Withdrawal';
      case 'bonus':
        return 'Bonus';
      case 'profit':
        return 'Profit';
      case 'penalty':
        return 'Penalty';
      case 'referral_bonus':
        return 'Referral Bonus';
      case 'task_reward':
        return 'Task Reward';
      default:
        return type.titleCase;
    }
  }

  /// Format KYC status
  static String formatKYCStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending Verification';
      case 'approved':
        return 'Verified';
      case 'rejected':
        return 'Verification Failed';
      case 'incomplete':
        return 'Incomplete';
      default:
        return status.titleCase;
    }
  }

  /// Format loan status
  static String formatLoanStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Under Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'defaulted':
        return 'Defaulted';
      default:
        return status.titleCase;
    }
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Format duration
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    } else {
      return '${duration.inSeconds} second${duration.inSeconds > 1 ? 's' : ''}';
    }
  }
}

/// Input formatters for TextFields
class InputFormatters {
  /// Currency input formatter
  static TextInputFormatter currency({int decimalPlaces = 2}) {
    return FilteringTextInputFormatter.allow(
      RegExp(r'^\d+\.?\d{0,' + decimalPlaces.toString() + '}'),
    );
  }

  /// Phone number formatter
  static TextInputFormatter phoneNumber() {
    return FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]'));
  }

  /// Digits only formatter
  static TextInputFormatter digitsOnly() {
    return FilteringTextInputFormatter.digitsOnly;
  }

  /// Letters only formatter
  static TextInputFormatter lettersOnly() {
    return FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'));
  }

  /// Email formatter (allow email characters)
  static TextInputFormatter email() {
    return FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]'));
  }

  /// Password formatter (no spaces)
  static TextInputFormatter password() {
    return FilteringTextInputFormatter.deny(RegExp(r'\s'));
  }

  /// Decimal number formatter
  static TextInputFormatter decimal({int decimalPlaces = 2}) {
    return FilteringTextInputFormatter.allow(
      RegExp(r'^\d+\.?\d{0,' + decimalPlaces.toString() + '}'),
    );
  }

  /// Uppercase formatter
  static TextInputFormatter upperCase() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      return newValue.copyWith(text: newValue.text.toUpperCase());
    });
  }

  /// Lowercase formatter
  static TextInputFormatter lowerCase() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      return newValue.copyWith(text: newValue.text.toLowerCase());
    });
  }
}
