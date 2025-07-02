import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/tasks/task_model.dart';
import '../models/tasks/task_submission.dart';
import '../models/tasks/task_category.dart';
import '../models/common/api_response.dart';
import '../models/common/pagination.dart';
import '../services/storage_service.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository(ref.read(apiClientProvider));
});

class TasksRepository {
  final ApiClient _apiClient;
  static const String _cacheKeyTasks = 'tasks';
  static const String _cacheKeySubmissions = 'task_submissions';
  static const String _cacheKeyCategories = 'task_categories';
  static const String _cacheKeyFilters = 'task_filters';
  static const String _cacheKeyStatistics = 'task_statistics';
  static const String _cacheKeyProgress = 'task_progress';
  static const String _cacheKeyTasksSummary = 'tasks_summary';
  static const Duration _cacheExpiry = Duration(minutes: 10);

  TasksRepository(this._apiClient);

  /// Get available tasks with filtering and pagination
  Future<PaginatedResponse<TaskModel>> getTasks({
    int page = 1,
    int limit = 20,
    String category = 'all',
    String difficulty = 'all',
    double? rewardMin,
    double? rewardMax,
    String sortBy = 'rewardAmount',
    String sortOrder = 'desc',
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey =
          '${_cacheKeyTasks}_${page}_${limit}_${category}_$difficulty';

      // Check cache first (only for first page)
      if (!forceRefresh && page == 1) {
        final cached = await _getCachedTasks(cacheKey);
        if (cached != null) {
          return cached;
        }
      }

      final queryParams = <String, dynamic>{
        ApiConstants.pageParam: page,
        ApiConstants.limitParam: limit,
        ApiConstants.sortByParam: sortBy,
        ApiConstants.sortOrderParam: sortOrder,
      };

      if (category != 'all') {
        queryParams[ApiConstants.categoryParam] = category;
      }

      if (difficulty != 'all') {
        queryParams['difficulty'] = difficulty;
      }

      if (rewardMin != null) {
        queryParams['rewardMin'] = rewardMin;
      }

      if (rewardMax != null) {
        queryParams['rewardMax'] = rewardMax;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEndpointWithQuery(ApiConstants.tasks, queryParams),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final paginatedResponse = PaginatedResponse<TaskModel>.fromJson(
          response.data!,
          (json) => TaskModel.fromJson(json as Map<String, dynamic>),
        );

        // Cache first page
        if (page == 1 && paginatedResponse.success) {
          await _cacheTasks(cacheKey, paginatedResponse);
        }

        return paginatedResponse;
      }

      throw AppException.serverError('Failed to fetch tasks');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get task details by ID
  Future<ApiResponse<TaskModel>> getTaskDetails(String taskId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.tasks}/$taskId',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<TaskModel>.fromJson(
          response.data!,
          (json) => TaskModel.fromJson(json as Map<String, dynamic>),
        );
      }

      throw AppException.serverError('Failed to fetch task details');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Submit a task
  Future<ApiResponse<TaskSubmissionResponse>> submitTask({
    required String taskId,
    required TaskSubmission submission,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.tasks}/$taskId/submit',
        data: submission.toJson(),
      );

      if (response.statusCode == ApiConstants.statusCreated) {
        final apiResponse = ApiResponse<TaskSubmissionResponse>.fromJson(
          response.data!,
          (json) =>
              TaskSubmissionResponse.fromJson(json as Map<String, dynamic>),
        );

        // Clear submissions cache after successful submission
        await _clearSubmissionsCache();

        return apiResponse;
      }

      throw AppException.serverError('Task submission failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get user task submissions with pagination
  Future<PaginatedResponse<TaskSubmissionResponse>> getTaskSubmissions({
    int page = 1,
    int limit = 20,
    String status = 'all',
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = '${_cacheKeySubmissions}_${page}_${limit}_$status';

      // Check cache first (only for first page)
      if (!forceRefresh && page == 1) {
        final cached = await _getCachedSubmissions(cacheKey);
        if (cached != null) {
          return cached;
        }
      }

      final queryParams = <String, dynamic>{
        ApiConstants.pageParam: page,
        ApiConstants.limitParam: limit,
        ApiConstants.sortByParam: sortBy,
        ApiConstants.sortOrderParam: sortOrder,
      };

      if (status != 'all') {
        queryParams[ApiConstants.statusParam] = status;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEndpointWithQuery(
          ApiConstants.taskSubmissions,
          queryParams,
        ),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final paginatedResponse =
            PaginatedResponse<TaskSubmissionResponse>.fromJson(
              response.data!,
              (json) =>
                  TaskSubmissionResponse.fromJson(json as Map<String, dynamic>),
            );

        // Cache first page
        if (page == 1 && paginatedResponse.success) {
          await _cacheSubmissions(cacheKey, paginatedResponse);
        }

        return paginatedResponse;
      }

      throw AppException.serverError('Failed to fetch task submissions');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get task categories
  Future<ApiResponse<List<TaskCategory>>> getTaskCategories({
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedCategories();
        if (cached != null) {
          return ApiResponse<List<TaskCategory>>(
            success: true,
            data: cached,
            message: 'Task categories loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.taskCategories,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<List<TaskCategory>>.fromJson(
          response.data!,
          (json) => (json as List)
              .map(
                (item) => TaskCategory.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
        );

        // Cache the result
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheCategories(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch task categories');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get task filters configuration
  Future<ApiResponse<Map<String, dynamic>>> getTaskFilters({
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedFilters();
        if (cached != null) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            data: cached,
            message: 'Task filters loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.taskFilters,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );

        // Cache the result
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheFilters(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch task filters');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get task submission details
  Future<ApiResponse<TaskSubmissionResponse>> getSubmissionDetails(
    String submissionId,
  ) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.taskSubmissions}/$submissionId',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<TaskSubmissionResponse>.fromJson(
          response.data!,
          (json) =>
              TaskSubmissionResponse.fromJson(json as Map<String, dynamic>),
        );
      }

      throw AppException.serverError('Failed to fetch submission details');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Update task submission (for resubmission)
  Future<ApiResponse<TaskSubmissionResponse>> updateTaskSubmission({
    required String submissionId,
    required TaskSubmission updatedSubmission,
  }) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '${ApiConstants.taskSubmissions}/$submissionId',
        data: updatedSubmission.toJson(),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<TaskSubmissionResponse>.fromJson(
          response.data!,
          (json) =>
              TaskSubmissionResponse.fromJson(json as Map<String, dynamic>),
        );

        // Clear submissions cache after update
        await _clearSubmissionsCache();

        return apiResponse;
      }

      throw AppException.serverError('Task submission update failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get user task statistics
  Future<ApiResponse<Map<String, dynamic>>> getTaskStatistics({
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedStatistics();
        if (cached != null) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            data: cached,
            message: 'Task statistics loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.tasks}/statistics',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );

        // Cache the result
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheStatistics(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch task statistics');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get user task progress/achievements
  Future<ApiResponse<Map<String, dynamic>>> getTaskProgress({
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedProgress();
        if (cached != null) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            data: cached,
            message: 'Task progress loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.tasks}/progress',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );

        // Cache the result
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheProgress(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch task progress');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Report task issue
  Future<ApiResponse<void>> reportTaskIssue({
    required String taskId,
    required String issue,
    String? description,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.tasks}/$taskId/report',
        data: {
          'issue': issue,
          if (description != null) 'description': description,
        },
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw AppException.serverError('Failed to report task issue');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get recommended tasks for user
  Future<ApiResponse<List<TaskModel>>> getRecommendedTasks({
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEndpointWithQuery('${ApiConstants.tasks}/recommended', {
          'limit': limit,
        }),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<List<TaskModel>>.fromJson(
          response.data!,
          (json) => (json as List)
              .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
              .toList(),
        );
      }

      throw AppException.serverError('Failed to fetch recommended tasks');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Start a task (mark as in progress)
  Future<ApiResponse<void>> startTask(String taskId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.tasks}/$taskId/start',
        data: {},
      );

      if (response.statusCode == ApiConstants.statusOk) {
        // Clear tasks cache after starting task
        await _clearTasksCache();
        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw AppException.serverError('Failed to start task');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Cancel a task (if allowed)
  Future<ApiResponse<void>> cancelTask(String taskId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.tasks}/$taskId/cancel',
        data: {},
      );

      if (response.statusCode == ApiConstants.statusOk) {
        // Clear tasks cache after canceling task
        await _clearTasksCache();
        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw AppException.serverError('Failed to cancel task');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get featured/highlighted tasks
  Future<ApiResponse<List<TaskModel>>> getFeaturedTasks({int limit = 5}) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEndpointWithQuery('${ApiConstants.tasks}/featured', {
          'limit': limit,
        }),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<List<TaskModel>>.fromJson(
          response.data!,
          (json) => (json as List)
              .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
              .toList(),
        );
      }

      throw AppException.serverError('Failed to fetch featured tasks');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Cache management methods
  Future<void> _cacheTasks(
    String key,
    PaginatedResponse<TaskModel> tasks,
  ) async {
    await StorageService.setCachedData(key, {
      'data': tasks.toJson((task) => task.toJson()),
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<PaginatedResponse<TaskModel>?> _getCachedTasks(String key) async {
    try {
      final cached = await StorageService.getCachedData(
        key,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return PaginatedResponse<TaskModel>.fromJson(
          cached['data'] as Map<String, dynamic>,
          (json) => TaskModel.fromJson(json as Map<String, dynamic>),
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheSubmissions(
    String key,
    PaginatedResponse<TaskSubmissionResponse> submissions,
  ) async {
    await StorageService.setCachedData(key, {
      'data': submissions.toJson((submission) => submission.toJson()),
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<PaginatedResponse<TaskSubmissionResponse>?> _getCachedSubmissions(
    String key,
  ) async {
    try {
      final cached = await StorageService.getCachedData(
        key,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return PaginatedResponse<TaskSubmissionResponse>.fromJson(
          cached['data'] as Map<String, dynamic>,
          (json) =>
              TaskSubmissionResponse.fromJson(json as Map<String, dynamic>),
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getTasksSummary({
    bool forceRefresh = false,
    String period = 'monthly', // 'daily', 'weekly', 'monthly', 'yearly'
  }) async {
    try {
      final cacheKey = '${_cacheKeyTasksSummary}_$period';

      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedTasksSummary(cacheKey);
        if (cached != null) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            data: cached,
            message: 'Tasks summary loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final queryParams = <String, dynamic>{'period': period};

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEndpointWithQuery(
          '${ApiConstants.tasks}/summary',
          queryParams,
        ),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );

        // Cache the result
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheTasksSummary(cacheKey, apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch tasks summary');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  Future<void> _cacheTasksSummary(
    String key,
    Map<String, dynamic> summary,
  ) async {
    await StorageService.setCachedData(key, {
      'data': summary,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<Map<String, dynamic>?> _getCachedTasksSummary(String key) async {
    try {
      final cached = await StorageService.getCachedData(
        key,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return cached['data'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearTasksCache() async {
    try {
      // Clear direct cache keys
      await Future.wait([
        StorageService.removeCachedData(_cacheKeyCategories),
        StorageService.removeCachedData(_cacheKeyFilters),
        StorageService.removeCachedData(_cacheKeyStatistics),
        StorageService.removeCachedData(_cacheKeyProgress),
      ]);

      // Clear pattern-based cache
      final cacheInfo = await StorageService.getCacheInfo();
      final tasksKeys = (cacheInfo['keys'] as List).where((key) {
        final keyStr = key.toString();
        return keyStr.startsWith(_cacheKeyTasks) ||
            keyStr.startsWith(_cacheKeySubmissions) ||
            keyStr.startsWith(_cacheKeyTasksSummary);
      }).toList();

      for (final key in tasksKeys) {
        await StorageService.removeCachedData(key.toString());
      }
    } catch (e) {
      // Handle cache clearing error silently
    }
  }

  Future<void> _cacheCategories(List<TaskCategory> categories) async {
    await StorageService.setCachedData(_cacheKeyCategories, {
      'data': categories.map((category) => category.toJson()).toList(),
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<TaskCategory>?> _getCachedCategories() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKeyCategories,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return (cached['data'] as List)
            .map((item) => TaskCategory.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheFilters(Map<String, dynamic> filters) async {
    await StorageService.setCachedData(_cacheKeyFilters, {
      'data': filters,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<Map<String, dynamic>?> _getCachedFilters() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKeyFilters,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return cached['data'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheStatistics(Map<String, dynamic> statistics) async {
    await StorageService.setCachedData(_cacheKeyStatistics, {
      'data': statistics,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<Map<String, dynamic>?> _getCachedStatistics() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKeyStatistics,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return cached['data'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheProgress(Map<String, dynamic> progress) async {
    await StorageService.setCachedData(_cacheKeyProgress, {
      'data': progress,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<Map<String, dynamic>?> _getCachedProgress() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKeyProgress,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return cached['data'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Clear all task-related cache
  Future<void> _clearTasksCache() async {
    await StorageService.removeCachedData('tasks');
  }

  /// Clear task submissions cache
  Future<void> _clearSubmissionsCache() async {
    await StorageService.removeCachedData('task_submissions');
  }
}
