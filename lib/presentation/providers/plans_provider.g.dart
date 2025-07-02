// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plans_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedPlanHash() => r'7739eef41b3dbb2e2fca942943c48ce415ebf809';

/// Provider for current selected plan
///
/// Copied from [selectedPlan].
@ProviderFor(selectedPlan)
final selectedPlanProvider = AutoDisposeProvider<PlanModel?>.internal(
  selectedPlan,
  name: r'selectedPlanProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedPlanHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SelectedPlanRef = AutoDisposeProviderRef<PlanModel?>;
String _$freePlansHash() => r'a42b7984daa9040439db022add2ea769a2d44971';

/// Provider for free plans only
///
/// Copied from [freePlans].
@ProviderFor(freePlans)
final freePlansProvider = AutoDisposeProvider<List<PlanModel>>.internal(
  freePlans,
  name: r'freePlansProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$freePlansHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FreePlansRef = AutoDisposeProviderRef<List<PlanModel>>;
String _$paidPlansHash() => r'144c6ca7685aeea1f1d2915145ee455bdc03999d';

/// Provider for paid plans only
///
/// Copied from [paidPlans].
@ProviderFor(paidPlans)
final paidPlansProvider = AutoDisposeProvider<List<PlanModel>>.internal(
  paidPlans,
  name: r'paidPlansProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$paidPlansHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PaidPlansRef = AutoDisposeProviderRef<List<PlanModel>>;
String _$isPlansLoadingHash() => r'706b10da1359a3a6be150ae1693fc8b97d9774bf';

/// Provider for checking if plans are loading
///
/// Copied from [isPlansLoading].
@ProviderFor(isPlansLoading)
final isPlansLoadingProvider = AutoDisposeProvider<bool>.internal(
  isPlansLoading,
  name: r'isPlansLoadingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isPlansLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsPlansLoadingRef = AutoDisposeProviderRef<bool>;
String _$plansErrorHash() => r'b70ee4ca0c7982d4d0e44fd8c7c24a28a2085632';

/// Provider for plans error
///
/// Copied from [plansError].
@ProviderFor(plansError)
final plansErrorProvider = AutoDisposeProvider<String?>.internal(
  plansError,
  name: r'plansErrorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$plansErrorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlansErrorRef = AutoDisposeProviderRef<String?>;
String _$plansHash() => r'f7f0d7b33a45059d03a3485a06509eedfb637a58';

/// See also [Plans].
@ProviderFor(Plans)
final plansProvider = AutoDisposeNotifierProvider<Plans, PlansState>.internal(
  Plans.new,
  name: r'plansProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$plansHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Plans = AutoDisposeNotifier<PlansState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
