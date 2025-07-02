// ============================================================================
// lib/presentation/providers/plans_provider.dart
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/errors/app_exception.dart';
import '../../data/models/plans/plan_model.dart';
import '../../data/repositories/plans_repository.dart';

part 'plans_provider.g.dart';

// ============================================================================
// PLANS STATE MODEL
// ============================================================================

/// Plans provider state model
class PlansState {
  final List<PlanModel> plans;
  final PlanModel? selectedPlan;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  const PlansState({
    this.plans = const [],
    this.selectedPlan,
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
  });

  PlansState copyWith({
    List<PlanModel>? plans,
    PlanModel? selectedPlan,
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) {
    return PlansState(
      plans: plans ?? this.plans,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  bool get hasError => error != null;
  bool get hasPlans => plans.isNotEmpty;
  bool get hasSelectedPlan => selectedPlan != null;

  /// Get free plans
  List<PlanModel> get freePlans => plans.where((plan) => plan.isFree).toList();

  /// Get paid plans
  List<PlanModel> get paidPlans => plans.where((plan) => !plan.isFree).toList();

  /// Get default plan
  PlanModel? get defaultPlan =>
      plans.where((plan) => plan.isDefault).firstOrNull;
}

// ============================================================================
// PLANS PROVIDER
// ============================================================================

@riverpod
class Plans extends _$Plans {
  @override
  PlansState build() {
    return const PlansState();
  }

  // ===== INITIALIZATION =====

  /// Initialize plans by fetching from API
  Future<void> initialize({bool forceRefresh = false}) async {
    if (state.isInitialized && !forceRefresh) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final plansRepository = ref.read(plansRepositoryProvider);
      final response = await plansRepository.getRegistrationPlans(
        forceRefresh: forceRefresh,
      );

      if (response.success && response.data != null) {
        final plans = response.data!;

        // Set default plan
        PlanModel? defaultPlan;
        if (plans.isNotEmpty) {
          // Find default plan or first free plan or first plan
          defaultPlan =
              plans.where((plan) => plan.isDefault).firstOrNull ??
              plans.where((plan) => plan.isFree).firstOrNull ??
              plans.first;
        }

        state = state.copyWith(
          plans: plans,
          selectedPlan: defaultPlan,
          isLoading: false,
          isInitialized: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to load plans',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e));
    }
  }

  // ===== PLAN SELECTION =====

  /// Select a plan
  void selectPlan(PlanModel plan) {
    state = state.copyWith(selectedPlan: plan);
  }

  /// Select plan by ID
  void selectPlanById(String planId) {
    final plan = state.plans.where((p) => p.id == planId).firstOrNull;
    if (plan != null) {
      selectPlan(plan);
    }
  }

  /// Clear selected plan
  void clearSelection() {
    state = state.copyWith(selectedPlan: null);
  }

  // ===== PLAN OPERATIONS =====

  /// Get plan details by ID
  Future<PlanModel?> getPlanDetails(String planId) async {
    try {
      // First check if plan is already in state
      final existingPlan = state.plans.where((p) => p.id == planId).firstOrNull;
      if (existingPlan != null) {
        return existingPlan;
      }

      // Fetch from API
      final plansRepository = ref.read(plansRepositoryProvider);
      final response = await plansRepository.getPlanDetails(planId);

      if (response.success && response.data != null) {
        return response.data;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Refresh plans
  Future<void> refresh() async {
    await initialize(forceRefresh: true);
  }

  /// Filter plans by criteria
  List<PlanModel> filterPlans({
    bool? isFree,
    bool? isActive,
    double? maxPrice,
    double? minPrice,
  }) {
    var filteredPlans = state.plans.toList();

    if (isFree != null) {
      filteredPlans = filteredPlans
          .where((plan) => plan.isFree == isFree)
          .toList();
    }

    if (isActive != null) {
      filteredPlans = filteredPlans
          .where((plan) => plan.isActive == isActive)
          .toList();
    }

    if (maxPrice != null) {
      filteredPlans = filteredPlans
          .where((plan) => plan.price <= maxPrice)
          .toList();
    }

    if (minPrice != null) {
      filteredPlans = filteredPlans
          .where((plan) => plan.price >= minPrice)
          .toList();
    }

    return filteredPlans;
  }

  /// Find suitable plans for amount
  List<PlanModel> getSuitablePlans(double amount) {
    return state.plans
        .where((plan) => plan.isSuitableForAmount(amount))
        .toList();
  }

  // ===== ERROR HANDLING =====

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.userMessage;
    }
    return 'Failed to load plans. Please try again.';
  }
}

// ============================================================================
// CONVENIENCE PROVIDERS
// ============================================================================

/// Provider for current selected plan
@riverpod
PlanModel? selectedPlan(Ref ref) {
  return ref.watch(plansProvider).selectedPlan;
}

/// Provider for free plans only
@riverpod
List<PlanModel> freePlans(Ref ref) {
  return ref.watch(plansProvider).freePlans;
}

/// Provider for paid plans only
@riverpod
List<PlanModel> paidPlans(Ref ref) {
  return ref.watch(plansProvider).paidPlans;
}

/// Provider for checking if plans are loading
@riverpod
bool isPlansLoading(Ref ref) {
  return ref.watch(plansProvider).isLoading;
}

/// Provider for plans error
@riverpod
String? plansError(Ref ref) {
  return ref.watch(plansProvider).error;
}
