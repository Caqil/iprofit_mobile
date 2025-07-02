// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$kycStatusHash() => r'a674b0028ef233bc75e68d70f8a6e6cc5023db6b';

/// Provider for KYC status
///
/// Copied from [kycStatus].
@ProviderFor(kycStatus)
final kycStatusProvider = AutoDisposeProvider<String>.internal(
  kycStatus,
  name: r'kycStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$kycStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef KycStatusRef = AutoDisposeProviderRef<String>;
String _$isKYCVerifiedHash() => r'7d637cca545e7976a0585f04267d19d19b46000a';

/// Provider for KYC verification status
///
/// Copied from [isKYCVerified].
@ProviderFor(isKYCVerified)
final isKYCVerifiedProvider = AutoDisposeProvider<bool>.internal(
  isKYCVerified,
  name: r'isKYCVerifiedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isKYCVerifiedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsKYCVerifiedRef = AutoDisposeProviderRef<bool>;
String _$kycCompletionPercentageHash() =>
    r'9c26cf2800080f5952971635a23899aa16d8930a';

/// Provider for KYC completion percentage
///
/// Copied from [kycCompletionPercentage].
@ProviderFor(kycCompletionPercentage)
final kycCompletionPercentageProvider = AutoDisposeProvider<double>.internal(
  kycCompletionPercentage,
  name: r'kycCompletionPercentageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$kycCompletionPercentageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef KycCompletionPercentageRef = AutoDisposeProviderRef<double>;
String _$isKYCLoadingHash() => r'8893a90ab652d655632d3f51ceca8e7d121d4fc7';

/// Provider for KYC loading state
///
/// Copied from [isKYCLoading].
@ProviderFor(isKYCLoading)
final isKYCLoadingProvider = AutoDisposeProvider<bool>.internal(
  isKYCLoading,
  name: r'isKYCLoadingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isKYCLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsKYCLoadingRef = AutoDisposeProviderRef<bool>;
String _$kycErrorHash() => r'9574eb7a43b98ac5ad276fc91a78008107399130';

/// Provider for KYC error
///
/// Copied from [kycError].
@ProviderFor(kycError)
final kycErrorProvider = AutoDisposeProvider<String?>.internal(
  kycError,
  name: r'kycErrorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$kycErrorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef KycErrorRef = AutoDisposeProviderRef<String?>;
String _$kycDocumentsHash() => r'e712a0acb512a3eeaccd41baf581f6d49f78d2ee';

/// Provider for KYC documents
///
/// Copied from [kycDocuments].
@ProviderFor(kycDocuments)
final kycDocumentsProvider = AutoDisposeProvider<List<KYCDocument>>.internal(
  kycDocuments,
  name: r'kycDocumentsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$kycDocumentsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef KycDocumentsRef = AutoDisposeProviderRef<List<KYCDocument>>;
String _$missingKYCDocumentsHash() =>
    r'56e8be5cccedca73a7b761a163ba69dc1177ce44';

/// Provider for missing documents
///
/// Copied from [missingKYCDocuments].
@ProviderFor(missingKYCDocuments)
final missingKYCDocumentsProvider = AutoDisposeProvider<List<String>>.internal(
  missingKYCDocuments,
  name: r'missingKYCDocumentsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$missingKYCDocumentsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MissingKYCDocumentsRef = AutoDisposeProviderRef<List<String>>;
String _$canSubmitKYCHash() => r'1b58c14fc02d09e2a393b3c4770f169518a5da90';

/// Provider for checking if KYC can be submitted
///
/// Copied from [canSubmitKYC].
@ProviderFor(canSubmitKYC)
final canSubmitKYCProvider = AutoDisposeProvider<bool>.internal(
  canSubmitKYC,
  name: r'canSubmitKYCProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$canSubmitKYCHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CanSubmitKYCRef = AutoDisposeProviderRef<bool>;
String _$kYCHash() => r'e2932191345c4942af5fc456a1d6c4b8ed49a75f';

/// See also [KYC].
@ProviderFor(KYC)
final kYCProvider = AutoDisposeNotifierProvider<KYC, KYCState>.internal(
  KYC.new,
  name: r'kYCProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$kYCHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$KYC = AutoDisposeNotifier<KYCState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
