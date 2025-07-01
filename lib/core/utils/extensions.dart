import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// String extensions
extension StringExtensions on String {
  /// Check if string is valid email
  bool get isValidEmail {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(this);
  }

  /// Check if string is valid phone number
  bool get isValidPhone {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(this);
  }

  /// Check if string is strong password
  bool get isStrongPassword {
    return RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$',
    ).hasMatch(this);
  }

  /// Check if string is numeric
  bool get isNumeric {
    return double.tryParse(this) != null;
  }

  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Capitalize each word
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Remove all whitespace
  String get removeWhitespace {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Mask email (show only first 2 chars and domain)
  String get maskedEmail {
    if (!isValidEmail) return this;
    final parts = split('@');
    final localPart = parts[0];
    final domain = parts[1];

    if (localPart.length <= 2) return this;

    final masked = localPart.substring(0, 2) + '*' * (localPart.length - 2);
    return '$masked@$domain';
  }

  /// Mask phone number (show only last 4 digits)
  String get maskedPhone {
    if (length <= 4) return this;
    return '*' * (length - 4) + substring(length - 4);
  }

  /// Format as currency amount
  String formatAsCurrency({String symbol = '\$', int decimalPlaces = 2}) {
    final amount = double.tryParse(this) ?? 0.0;
    return '$symbol${amount.toStringAsFixed(decimalPlaces)}';
  }

  /// Parse to double safely
  double get toDoubleOrZero {
    return double.tryParse(this) ?? 0.0;
  }

  /// Parse to int safely
  int get toIntOrZero {
    return int.tryParse(this) ?? 0;
  }

  /// Check if string contains only digits
  bool get isDigitsOnly {
    return RegExp(r'^\d+$').hasMatch(this);
  }

  /// Truncate string with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Generate initials from name
  String get initials {
    if (isEmpty) return '';

    final words = trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }

    return words
        .take(2)
        .map((word) => word.substring(0, 1).toUpperCase())
        .join();
  }

  /// Convert to snake_case
  String get toSnakeCase {
    return toLowerCase().replaceAll(RegExp(r'\s+'), '_');
  }

  /// Convert snake_case to Title Case
  String get fromSnakeCase {
    return split('_').map((word) => word.capitalize).join(' ');
  }
}

/// Double extensions
extension DoubleExtensions on double {
  /// Format as currency
  String toCurrency({
    String symbol = '\$',
    int decimalPlaces = 2,
    String locale = 'en_US',
  }) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalPlaces,
      locale: locale,
    );
    return formatter.format(this);
  }

  /// Format as USD currency
  String get toUSD {
    return toCurrency(symbol: '\$', locale: 'en_US');
  }

  /// Format as BDT currency
  String get toBDT {
    return toCurrency(symbol: '৳', locale: 'bn_BD');
  }

  /// Format as percentage
  String toPercentage({int decimalPlaces = 1}) {
    return '${(this * 100).toStringAsFixed(decimalPlaces)}%';
  }

  /// Format with K, M, B suffixes
  String toCompactCurrency({String symbol = '\$'}) {
    if (this >= 1000000000) {
      return '$symbol${(this / 1000000000).toStringAsFixed(1)}B';
    } else if (this >= 1000000) {
      return '$symbol${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '$symbol${(this / 1000).toStringAsFixed(1)}K';
    } else {
      return '$symbol${toStringAsFixed(2)}';
    }
  }

  /// Check if amount is positive
  bool get isPositive => this > 0;

  /// Check if amount is negative
  bool get isNegative => this < 0;

  /// Get absolute value
  double get absolute => abs();

  /// Round to specific decimal places
  double roundToDecimal(int places) {
    final factor = pow(10, places);
    return (this * factor).round() / factor;
  }
}

/// DateTime extensions
extension DateTimeExtensions on DateTime {
  /// Format as readable date
  String get toReadableDate {
    return DateFormat('MMM dd, yyyy').format(this);
  }

  /// Format as readable date with time
  String get toReadableDateTime {
    return DateFormat('MMM dd, yyyy hh:mm a').format(this);
  }

  /// Format as short date
  String get toShortDate {
    return DateFormat('MM/dd/yyyy').format(this);
  }

  /// Format as time only
  String get toTimeOnly {
    return DateFormat('hh:mm a').format(this);
  }

  /// Get relative time (e.g., "2 hours ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

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

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if date is this month
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Get start of day
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Get end of day
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  /// Add business days (skip weekends)
  DateTime addBusinessDays(int days) {
    DateTime result = this;
    int addedDays = 0;

    while (addedDays < days) {
      result = result.add(const Duration(days: 1));
      if (result.weekday != DateTime.saturday &&
          result.weekday != DateTime.sunday) {
        addedDays++;
      }
    }

    return result;
  }

  /// Format for API (ISO 8601)
  String get toApiFormat {
    return toIso8601String();
  }
}

/// List extensions
extension ListExtensions<T> on List<T> {
  /// Safe get element at index
  T? safeGet(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Get first element or null
  T? get firstOrNull {
    return isEmpty ? null : first;
  }

  /// Get last element or null
  T? get lastOrNull {
    return isEmpty ? null : last;
  }

  /// Remove duplicates while preserving order
  List<T> get unique {
    final seen = <T>{};
    return where((element) => seen.add(element)).toList();
  }

  /// Chunk list into smaller lists
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (int i = 0; i < length; i += size) {
      final end = (i + size < length) ? i + size : length;
      chunks.add(sublist(i, end));
    }
    return chunks;
  }

  /// Get random element
  T? get random {
    if (isEmpty) return null;
    final random = DateTime.now().millisecondsSinceEpoch % length;
    return this[random];
  }
}

/// Widget extensions
extension WidgetExtensions on Widget {
  /// Add padding
  Widget padding(EdgeInsets padding) {
    return Padding(padding: padding, child: this);
  }

  /// Add symmetric padding
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  /// Add all-around padding
  Widget paddingAll(double padding) {
    return Padding(padding: EdgeInsets.all(padding), child: this);
  }

  /// Add only specific padding
  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }

  /// Add margin using Container
  Widget margin(EdgeInsets margin) {
    return Container(margin: margin, child: this);
  }

  /// Center widget
  Widget get center {
    return Center(child: this);
  }

  /// Make widget expanded
  Widget get expanded {
    return Expanded(child: this);
  }

  /// Make widget flexible
  Widget flexible({int flex = 1}) {
    return Flexible(flex: flex, child: this);
  }

  /// Add gesture detector
  Widget onTap(VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: this);
  }

  /// Add hero animation
  Widget hero(String tag) {
    return Hero(tag: tag, child: this);
  }

  /// Add opacity
  Widget opacity(double opacity) {
    return Opacity(opacity: opacity, child: this);
  }

  /// Add rotation
  Widget rotate(double angle) {
    return Transform.rotate(angle: angle, child: this);
  }

  /// Add scale
  Widget scale(double scale) {
    return Transform.scale(scale: scale, child: this);
  }

  /// Add visibility
  Widget visible(bool visible) {
    return Visibility(visible: visible, child: this);
  }

  /// Add conditional visibility
  Widget visibleIf(bool condition) {
    return condition ? this : const SizedBox.shrink();
  }

  /// Add safe area
  Widget get safeArea {
    return SafeArea(child: this);
  }

  /// Add single child scroll view
  Widget get scrollable {
    return SingleChildScrollView(child: this);
  }
}
