// ============================================================================
// lib/data/repositories/plans_repository.dart
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iprofit_mobile/data/models/plans/plan_model.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/common/api_response.dart';
import '../services/storage_service.dart';

final plansRepositoryProvider = Provider<PlansRepository>((ref) {
  return PlansRepository(ref.read(apiClientProvider));
});

class PlansRepository {
  final ApiClient _apiClient;
  static const String _cacheKeyPlans = 'available_plans';
  static const Duration _cacheExpiry = Duration(
    hours: 6,
  ); // Plans don't change often

  PlansRepository(this._apiClient);

  /// Get all available plans
  Future<ApiResponse<List<PlanModel>>> getPlans({
    bool activeOnly = true,
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedPlans();
        if (cached != null && cached.isNotEmpty) {
          return ApiResponse<List<PlanModel>>(
            success: true,
            data: cached,
            message: 'Plans loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final queryParams = <String, dynamic>{};
      if (activeOnly) {
        queryParams['active'] = 'true';
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.plans,
        queryParameters: queryParams,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final responseData = response.data!;

        // Handle nested response structure: data.data contains the plans array
        final plansData = responseData['data']?['data'] as List?;

        if (plansData == null) {
          throw AppException.parseError('Invalid plans response structure');
        }

        final plans = plansData
            .map((item) => PlanModel.fromJson(item as Map<String, dynamic>))
            .toList();

        // Sort plans by priority
        plans.sort((a, b) => a.priority.compareTo(b.priority));

        // Cache the result
        await _cachePlans(plans);

        return ApiResponse<List<PlanModel>>(
          success: true,
          data: plans,
          message: 'Plans loaded successfully',
          timestamp: DateTime.now(),
        );
      }

      throw AppException.serverError('Failed to fetch plans');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get plan details by ID
  Future<ApiResponse<PlanModel>> getPlanDetails(String planId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.plans}/$planId',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final responseData = response.data!;

        // Handle nested response structure
        final planData = responseData['data'];

        if (planData == null) {
          throw AppException.parseError('Invalid plan response structure');
        }

        final plan = PlanModel.fromJson(planData as Map<String, dynamic>);

        return ApiResponse<PlanModel>(
          success: true,
          data: plan,
          message: 'Plan details loaded successfully',
          timestamp: DateTime.now(),
        );
      }

      throw AppException.serverError('Failed to fetch plan details');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get plans suitable for registration (usually includes free plans)
  Future<ApiResponse<List<PlanModel>>> getRegistrationPlans({
    bool forceRefresh = false,
  }) async {
    try {
      final plansResponse = await getPlans(
        activeOnly: true,
        forceRefresh: forceRefresh,
      );

      if (plansResponse.success && plansResponse.data != null) {
        final plans = plansResponse.data!;

        // Filter only active plans and sort appropriately for registration
        final registrationPlans = plans.where((plan) => plan.isActive).toList();

        // Sort: Default plan first, then by priority
        registrationPlans.sort((a, b) {
          if (a.isDefault && !b.isDefault) return -1;
          if (!a.isDefault && b.isDefault) return 1;
          return a.priority.compareTo(b.priority);
        });

        return ApiResponse<List<PlanModel>>(
          success: true,
          data: registrationPlans,
          message: 'Registration plans loaded',
          timestamp: DateTime.now(),
        );
      }

      return plansResponse;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get default plan (the plan marked as isDefault or first free plan)
  Future<ApiResponse<PlanModel?>> getDefaultPlan() async {
    try {
      final plansResponse = await getRegistrationPlans();

      if (plansResponse.success && plansResponse.data != null) {
        final plans = plansResponse.data!;

        // Find default plan
        final defaultPlan = plans.where((plan) => plan.isDefault).firstOrNull;
        if (defaultPlan != null) {
          return ApiResponse<PlanModel?>(
            success: true,
            data: defaultPlan,
            message: 'Default plan found',
            timestamp: DateTime.now(),
          );
        }

        // Find first free plan
        final freePlan = plans.where((plan) => plan.isFree).firstOrNull;
        if (freePlan != null) {
          return ApiResponse<PlanModel?>(
            success: true,
            data: freePlan,
            message: 'Free plan found as default',
            timestamp: DateTime.now(),
          );
        }

        // If no free plan, get the first plan (lowest priority)
        if (plans.isNotEmpty) {
          return ApiResponse<PlanModel?>(
            success: true,
            data: plans.first,
            message: 'First available plan selected as default',
            timestamp: DateTime.now(),
          );
        }
      }

      return ApiResponse<PlanModel?>(
        success: true,
        data: null,
        message: 'No default plan available',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Compare plans for selection
  Future<ApiResponse<List<PlanModel>>> getComparisonPlans({
    List<String>? planIds,
  }) async {
    try {
      if (planIds == null || planIds.isEmpty) {
        // Get all active plans for comparison
        return await getPlans(activeOnly: true);
      }

      // Get specific plans
      final List<PlanModel> plans = [];
      for (final planId in planIds) {
        final planResponse = await getPlanDetails(planId);
        if (planResponse.success && planResponse.data != null) {
          plans.add(planResponse.data!);
        }
      }

      return ApiResponse<List<PlanModel>>(
        success: true,
        data: plans,
        message: 'Comparison plans loaded',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  // ===== CACHE METHODS =====

  /// Cache plans to local storage
  Future<void> _cachePlans(List<PlanModel> plans) async {
    try {
      final cacheData = {
        'plans': plans.map((plan) => plan.toJson()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await StorageService.setString(_cacheKeyPlans, cacheData.toString());
    } catch (e) {
      // Silent fail for cache operations
    }
  }

  /// Get cached plans
  Future<List<PlanModel>?> _getCachedPlans() async {
    try {
      final cachedString = await StorageService.getString(_cacheKeyPlans);
      if (cachedString == null) return null;

      final cacheData = cachedString as Map<String, dynamic>?;
      if (cacheData == null) return null;

      final timestamp = cacheData['timestamp'] as int?;
      if (timestamp == null) return null;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
        return null; // Cache expired
      }

      final plansJson = cacheData['plans'] as List?;
      if (plansJson == null) return null;

      return plansJson
          .map((item) => PlanModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null; // Return null on any cache error
    }
  }

  /// Clear plans cache
  Future<void> clearCache() async {
    try {
      await StorageService.removeCachedData(_cacheKeyPlans);
    } catch (e) {
      // Silent fail for cache operations
    }
  }
}
