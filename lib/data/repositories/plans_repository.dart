// ============================================================================
// lib/data/repositories/plans_repository.dart - FIXED VERSION
// ============================================================================

import 'dart:convert';
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
  static const Duration _cacheExpiry = Duration(hours: 6);

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
          print('✅ Plans loaded from cache: ${cached.length} plans');
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

      print('🌐 Fetching plans from API: ${ApiConstants.plans}');
      print('📋 Query params: $queryParams');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.plans,
        queryParameters: queryParams,
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response data type: ${response.data.runtimeType}');

      if (response.statusCode == ApiConstants.statusOk) {
        final responseData = response.data!;
        print('🔍 Full response structure: ${responseData.keys}');

        // Handle multiple possible response structures
        List<dynamic>? plansData;

        // Try nested structure first: data.data
        if (responseData['data'] is Map<String, dynamic>) {
          final dataMap = responseData['data'] as Map<String, dynamic>;
          if (dataMap['data'] is List) {
            plansData = dataMap['data'] as List;
            print('✅ Found plans in nested structure: data.data');
          }
        }

        // Try direct data structure: data
        if (plansData == null && responseData['data'] is List) {
          plansData = responseData['data'] as List;
          print('✅ Found plans in direct structure: data');
        }

        // Try root level structure (direct array)
        if (plansData == null && responseData is List) {
          plansData = responseData as List<dynamic>;
          print('✅ Found plans in root level structure');
        }

        if (plansData == null) {
          print('❌ Could not find plans array in response');
          print('📄 Available keys: ${responseData.keys}');
          throw AppException.parseError(
            'Invalid plans response structure: no plans array found',
          );
        }

        print('📊 Converting ${plansData.length} plans from JSON');

        final plans = <PlanModel>[];
        for (int i = 0; i < plansData.length; i++) {
          try {
            final item = plansData[i];
            if (item is Map<String, dynamic>) {
              final plan = PlanModel.fromJson(item);
              plans.add(plan);
            } else {
              print('⚠️ Skipping plan at index $i: not a Map<String, dynamic>');
            }
          } catch (e) {
            print('⚠️ Error parsing plan at index $i: $e');
            // Continue with other plans instead of failing entirely
          }
        }

        if (plans.isEmpty) {
          print('❌ No valid plans found after parsing');
          throw AppException.parseError('No valid plans found in response');
        }

        // Sort plans by priority
        plans.sort((a, b) => a.priority.compareTo(b.priority));
        print('✅ Successfully parsed ${plans.length} plans');

        // Cache the result
        await _cachePlans(plans);

        return ApiResponse<List<PlanModel>>(
          success: true,
          data: plans,
          message: 'Plans loaded successfully',
          timestamp: DateTime.now(),
        );
      }

      throw AppException.serverError(
        'Failed to fetch plans: ${response.statusCode}',
      );
    } catch (e) {
      print('❌ Error in getPlans: $e');
      print('📍 Error type: ${e.runtimeType}');

      if (e is AppException) rethrow;

      // Handle specific Dio errors
      if (e.toString().contains('Instance of \'Future\'')) {
        throw AppException.parseError(
          'Async operation error. Please try again.',
        );
      }

      throw AppException.fromException(e as Exception);
    }
  }

  /// Get plan details by ID
  Future<ApiResponse<PlanModel>> getPlanDetails(String planId) async {
    try {
      print('🔍 Fetching plan details for ID: $planId');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.plans}/$planId',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final responseData = response.data!;
        print('📄 Plan details response keys: ${responseData.keys}');

        // Handle nested response structure
        Map<String, dynamic>? planData;

        if (responseData['data'] is Map<String, dynamic>) {
          planData = responseData['data'] as Map<String, dynamic>;
        } else {
          planData = responseData;
        }

        if (planData == null) {
          throw AppException.parseError('Invalid plan response structure');
        }

        final plan = PlanModel.fromJson(planData);
        print('✅ Successfully parsed plan details: ${plan.name}');

        return ApiResponse<PlanModel>(
          success: true,
          data: plan,
          message: 'Plan details loaded successfully',
          timestamp: DateTime.now(),
        );
      }

      throw AppException.serverError(
        'Failed to fetch plan details: ${response.statusCode}',
      );
    } catch (e) {
      print('❌ Error in getPlanDetails: $e');

      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get plans suitable for registration
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

        print('📋 Registration plans: ${registrationPlans.length} available');

        return ApiResponse<List<PlanModel>>(
          success: true,
          data: registrationPlans,
          message: 'Registration plans loaded',
          timestamp: DateTime.now(),
        );
      }

      return plansResponse;
    } catch (e) {
      print('❌ Error in getRegistrationPlans: $e');

      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get default plan
  Future<ApiResponse<PlanModel?>> getDefaultPlan() async {
    try {
      final plansResponse = await getRegistrationPlans();

      if (plansResponse.success && plansResponse.data != null) {
        final plans = plansResponse.data!;

        // Find default plan
        final defaultPlan = plans.where((plan) => plan.isDefault).firstOrNull;
        if (defaultPlan != null) {
          print('✅ Found default plan: ${defaultPlan.name}');
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
          print('✅ Found free plan as default: ${freePlan.name}');
          return ApiResponse<PlanModel?>(
            success: true,
            data: freePlan,
            message: 'Free plan found as default',
            timestamp: DateTime.now(),
          );
        }

        // If no free plan, get the first plan
        if (plans.isNotEmpty) {
          print('✅ Using first available plan as default: ${plans.first.name}');
          return ApiResponse<PlanModel?>(
            success: true,
            data: plans.first,
            message: 'First available plan selected as default',
            timestamp: DateTime.now(),
          );
        }
      }

      print('⚠️ No default plan available');
      return ApiResponse<PlanModel?>(
        success: true,
        data: null,
        message: 'No default plan available',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('❌ Error in getDefaultPlan: $e');

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
        return await getPlans(activeOnly: true);
      }

      final List<PlanModel> plans = [];
      for (final planId in planIds) {
        try {
          final planResponse = await getPlanDetails(planId);
          if (planResponse.success && planResponse.data != null) {
            plans.add(planResponse.data!);
          }
        } catch (e) {
          print('⚠️ Failed to fetch plan $planId: $e');
          // Continue with other plans
        }
      }

      return ApiResponse<List<PlanModel>>(
        success: true,
        data: plans,
        message: 'Comparison plans loaded',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('❌ Error in getComparisonPlans: $e');

      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  // ===== FIXED CACHE METHODS =====

  /// Cache plans to local storage - FIXED
  Future<void> _cachePlans(List<PlanModel> plans) async {
    try {
      final cacheData = {
        'plans': plans.map((plan) => plan.toJson()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Properly encode as JSON string
      final cacheString = jsonEncode(cacheData);
      await StorageService.setString(_cacheKeyPlans, cacheString);

      print('💾 Cached ${plans.length} plans');
    } catch (e) {
      print('⚠️ Cache save failed: $e');
      // Silent fail for cache operations
    }
  }

  /// Get cached plans - FIXED
  Future<List<PlanModel>?> _getCachedPlans() async {
    try {
      final cachedString = await StorageService.getString(_cacheKeyPlans);
      if (cachedString == null || cachedString.isEmpty) {
        print('📭 No cached plans found');
        return null;
      }

      // Properly decode JSON string
      final Map<String, dynamic> cacheData = jsonDecode(cachedString);

      final timestamp = cacheData['timestamp'] as int?;
      if (timestamp == null) {
        print('⚠️ Cache missing timestamp');
        return null;
      }

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
        print('⏰ Cache expired');
        return null;
      }

      final plansJson = cacheData['plans'] as List?;
      if (plansJson == null) {
        print('⚠️ Cache missing plans data');
        return null;
      }

      final plans = plansJson
          .map((item) => PlanModel.fromJson(item as Map<String, dynamic>))
          .toList();

      print('📁 Loaded ${plans.length} plans from cache');
      return plans;
    } catch (e) {
      print('⚠️ Cache load failed: $e');
      return null;
    }
  }

  /// Clear plans cache
  Future<void> clearCache() async {
    try {
      await StorageService.removeCachedData(_cacheKeyPlans);
      print('🗑️ Plans cache cleared');
    } catch (e) {
      print('⚠️ Cache clear failed: $e');
    }
  }
}
