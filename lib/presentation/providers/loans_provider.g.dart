// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loans_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeLoansHash() => r'afc6f7a95d5df27f158873739be3a83de410bfdd';

/// Provider for active loans
///
/// Copied from [activeLoans].
@ProviderFor(activeLoans)
final activeLoansProvider = AutoDisposeProvider<List<LoanModel>>.internal(
  activeLoans,
  name: r'activeLoansProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeLoansHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveLoansRef = AutoDisposeProviderRef<List<LoanModel>>;
String _$pendingLoansHash() => r'05a62daef21deea2429ebe1370a4a4f9e3349953';

/// Provider for pending loans
///
/// Copied from [pendingLoans].
@ProviderFor(pendingLoans)
final pendingLoansProvider = AutoDisposeProvider<List<LoanModel>>.internal(
  pendingLoans,
  name: r'pendingLoansProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingLoansHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingLoansRef = AutoDisposeProviderRef<List<LoanModel>>;
String _$totalLoanAmountHash() => r'69a6e6aeff14d5900ad3175fb63d56247837e781';

/// Provider for total loan amount
///
/// Copied from [totalLoanAmount].
@ProviderFor(totalLoanAmount)
final totalLoanAmountProvider = AutoDisposeProvider<double>.internal(
  totalLoanAmount,
  name: r'totalLoanAmountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalLoanAmountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalLoanAmountRef = AutoDisposeProviderRef<double>;
String _$totalOutstandingAmountHash() =>
    r'8b74236a5f4ac562464c53f638e946144717712b';

/// Provider for total outstanding amount
///
/// Copied from [totalOutstandingAmount].
@ProviderFor(totalOutstandingAmount)
final totalOutstandingAmountProvider = AutoDisposeProvider<double>.internal(
  totalOutstandingAmount,
  name: r'totalOutstandingAmountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalOutstandingAmountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalOutstandingAmountRef = AutoDisposeProviderRef<double>;
String _$totalEmiAmountHash() => r'a6063621d66a51b672087c57dc3fb5f5aa6120dc';

/// Provider for total EMI amount
///
/// Copied from [totalEmiAmount].
@ProviderFor(totalEmiAmount)
final totalEmiAmountProvider = AutoDisposeProvider<double>.internal(
  totalEmiAmount,
  name: r'totalEmiAmountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalEmiAmountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalEmiAmountRef = AutoDisposeProviderRef<double>;
String _$isEligibleForLoanHash() => r'e2bba9c58baf9f86f9e0e565232bdd548c729693';

/// Provider for loan eligibility
///
/// Copied from [isEligibleForLoan].
@ProviderFor(isEligibleForLoan)
final isEligibleForLoanProvider = AutoDisposeProvider<bool>.internal(
  isEligibleForLoan,
  name: r'isEligibleForLoanProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isEligibleForLoanHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsEligibleForLoanRef = AutoDisposeProviderRef<bool>;
String _$maxLoanAmountHash() => r'd5f15d5b8f693ee8d5e91f330cf6fc7f99058af9';

/// Provider for maximum loan amount
///
/// Copied from [maxLoanAmount].
@ProviderFor(maxLoanAmount)
final maxLoanAmountProvider = AutoDisposeProvider<double>.internal(
  maxLoanAmount,
  name: r'maxLoanAmountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$maxLoanAmountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MaxLoanAmountRef = AutoDisposeProviderRef<double>;
String _$isLoansLoadingHash() => r'b19ab9564123642cea399f34eb85f514f1558e30';

/// Provider for loans loading state
///
/// Copied from [isLoansLoading].
@ProviderFor(isLoansLoading)
final isLoansLoadingProvider = AutoDisposeProvider<bool>.internal(
  isLoansLoading,
  name: r'isLoansLoadingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isLoansLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsLoansLoadingRef = AutoDisposeProviderRef<bool>;
String _$loansErrorHash() => r'49fde3faca3953342622be959ecafe7f52fa8c1c';

/// Provider for loans error
///
/// Copied from [loansError].
@ProviderFor(loansError)
final loansErrorProvider = AutoDisposeProvider<String?>.internal(
  loansError,
  name: r'loansErrorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$loansErrorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LoansErrorRef = AutoDisposeProviderRef<String?>;
String _$lastEmiCalculationHash() =>
    r'72616d9f8e5c23c564b22a7c76b804f4d5f80dac';

/// Provider for last EMI calculation
///
/// Copied from [lastEmiCalculation].
@ProviderFor(lastEmiCalculation)
final lastEmiCalculationProvider =
    AutoDisposeProvider<EMICalculation?>.internal(
      lastEmiCalculation,
      name: r'lastEmiCalculationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lastEmiCalculationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LastEmiCalculationRef = AutoDisposeProviderRef<EMICalculation?>;
String _$nextEmiDueDateHash() => r'21ebb6b24bc13174d0f412db4e583fdbc83d7fb6';

/// Provider for next EMI due date
///
/// Copied from [nextEmiDueDate].
@ProviderFor(nextEmiDueDate)
final nextEmiDueDateProvider = AutoDisposeProvider<DateTime?>.internal(
  nextEmiDueDate,
  name: r'nextEmiDueDateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nextEmiDueDateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NextEmiDueDateRef = AutoDisposeProviderRef<DateTime?>;
String _$loansHash() => r'8064d93a4a96c0b3cbdc601f53d5d50886eebbd8';

/// See also [Loans].
@ProviderFor(Loans)
final loansProvider = AutoDisposeNotifierProvider<Loans, LoansState>.internal(
  Loans.new,
  name: r'loansProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$loansHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Loans = AutoDisposeNotifier<LoansState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
