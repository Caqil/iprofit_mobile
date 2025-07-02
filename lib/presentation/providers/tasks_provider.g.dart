// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availableTasksHash() => r'f79ff33cb12c360cc011b68c8633f0bf404149b2';

/// Provider for available tasks
///
/// Copied from [availableTasks].
@ProviderFor(availableTasks)
final availableTasksProvider = AutoDisposeProvider<List<TaskModel>>.internal(
  availableTasks,
  name: r'availableTasksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableTasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailableTasksRef = AutoDisposeProviderRef<List<TaskModel>>;
String _$completedTasksCountHash() =>
    r'17b30e726c32983aea7e487a3aedeea861904cf1';

/// Provider for completed tasks count
///
/// Copied from [completedTasksCount].
@ProviderFor(completedTasksCount)
final completedTasksCountProvider = AutoDisposeProvider<int>.internal(
  completedTasksCount,
  name: r'completedTasksCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$completedTasksCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CompletedTasksCountRef = AutoDisposeProviderRef<int>;
String _$totalTasksEarnedHash() => r'4cded8d7c7fa876ab988ee9ed77bffccb67cb24d';

/// Provider for total earned amount
///
/// Copied from [totalTasksEarned].
@ProviderFor(totalTasksEarned)
final totalTasksEarnedProvider = AutoDisposeProvider<double>.internal(
  totalTasksEarned,
  name: r'totalTasksEarnedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalTasksEarnedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalTasksEarnedRef = AutoDisposeProviderRef<double>;
String _$pendingTaskSubmissionsHash() =>
    r'3d48037185e8a0b90e9f760cd3ef5c63181f53b6';

/// Provider for pending submissions
///
/// Copied from [pendingTaskSubmissions].
@ProviderFor(pendingTaskSubmissions)
final pendingTaskSubmissionsProvider =
    AutoDisposeProvider<List<TaskSubmissionResponse>>.internal(
      pendingTaskSubmissions,
      name: r'pendingTaskSubmissionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingTaskSubmissionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingTaskSubmissionsRef =
    AutoDisposeProviderRef<List<TaskSubmissionResponse>>;
String _$isTasksLoadingHash() => r'c40c4ddd5e69f04bb3c9fe09d46e18b1def1703d';

/// Provider for tasks loading state
///
/// Copied from [isTasksLoading].
@ProviderFor(isTasksLoading)
final isTasksLoadingProvider = AutoDisposeProvider<bool>.internal(
  isTasksLoading,
  name: r'isTasksLoadingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isTasksLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsTasksLoadingRef = AutoDisposeProviderRef<bool>;
String _$tasksErrorHash() => r'4c0c7aec96fbac390ec29a3752799f2c80f3591f';

/// Provider for tasks error
///
/// Copied from [tasksError].
@ProviderFor(tasksError)
final tasksErrorProvider = AutoDisposeProvider<String?>.internal(
  tasksError,
  name: r'tasksErrorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tasksErrorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TasksErrorRef = AutoDisposeProviderRef<String?>;
String _$taskCategoriesHash() => r'fccf18bf60ed6b62b874c223f09822a2273109fe';

/// Provider for task categories
///
/// Copied from [taskCategories].
@ProviderFor(taskCategories)
final taskCategoriesProvider = AutoDisposeProvider<List<TaskCategory>>.internal(
  taskCategories,
  name: r'taskCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskCategoriesRef = AutoDisposeProviderRef<List<TaskCategory>>;
String _$taskCompletionRateHash() =>
    r'8ca1de731384dc0ff1472ef4d34271e0607d7a9a';

/// Provider for completion rate
///
/// Copied from [taskCompletionRate].
@ProviderFor(taskCompletionRate)
final taskCompletionRateProvider = AutoDisposeProvider<double>.internal(
  taskCompletionRate,
  name: r'taskCompletionRateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskCompletionRateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskCompletionRateRef = AutoDisposeProviderRef<double>;
String _$taskApprovalRateHash() => r'0ee11caf2da563b5f14b9b8bee30c8d6a0ff929f';

/// Provider for approval rate
///
/// Copied from [taskApprovalRate].
@ProviderFor(taskApprovalRate)
final taskApprovalRateProvider = AutoDisposeProvider<double>.internal(
  taskApprovalRate,
  name: r'taskApprovalRateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskApprovalRateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskApprovalRateRef = AutoDisposeProviderRef<double>;
String _$potentialTaskEarningsHash() =>
    r'8ba7e5a9d1707aabc3f8b468ea003d55f020a061';

/// Provider for potential earnings
///
/// Copied from [potentialTaskEarnings].
@ProviderFor(potentialTaskEarnings)
final potentialTaskEarningsProvider = AutoDisposeProvider<double>.internal(
  potentialTaskEarnings,
  name: r'potentialTaskEarningsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$potentialTaskEarningsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PotentialTaskEarningsRef = AutoDisposeProviderRef<double>;
String _$tasksHash() => r'007cb406fa59ac233951086412d4c0a27df5c96e';

/// See also [Tasks].
@ProviderFor(Tasks)
final tasksProvider = AutoDisposeNotifierProvider<Tasks, TasksState>.internal(
  Tasks.new,
  name: r'tasksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Tasks = AutoDisposeNotifier<TasksState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
