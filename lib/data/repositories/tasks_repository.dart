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
        '${ApiConstants.taskDetails}/$taskId',
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

  /// Submit task completion
  Future<ApiResponse<TaskSubmissionResponse>> submitTask({
    required String taskId,
    required TaskSubmission submission,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.taskSubmit}/$taskId/submit',
        data: submission.toJson(),
      );

      if (response.statusCode == ApiConstants.statusCreated) {
        final apiResponse = ApiResponse<TaskSubmissionResponse>.fromJson(
          response.data!,
          (json) =>
              TaskSubmissionResponse.fromJson(json as Map<String, dynamic>),
        );

        // Clear tasks cache after submission to refresh user status
        await _clearTasksCache();

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
  Future<ApiResponse<Map<String, dynamic>>> getTaskFilters() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.taskFilters,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
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
  Future<ApiResponse<Map<String, dynamic>>> getTaskStatistics() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.tasks}/statistics',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw AppException.serverError('Failed to fetch task statistics');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get user task progress/achievements
  Future<ApiResponse<Map<String, dynamic>>> getTaskProgress() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.tasks}/progress',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
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

  Future<void> _clearTasksCache() async {
    final keys = await StorageService.getCacheInfo();
    final taskKeys = (keys['keys'] as List)
        .where((key) => key.toString().startsWith(_cacheKeyTasks))
        .toList();

    for (final key in taskKeys) {
      await StorageService.removeCachedData(key.toString());
    }
  }

  Future<void> _clearSubmissionsCache() async {
    final keys = await StorageService.getCacheInfo();
    final submissionKeys = (keys['keys'] as List)
        .where((key) => key.toString().startsWith(_cacheKeySubmissions))
        .toList();

    for (final key in submissionKeys) {
      await StorageService.removeCachedData(key.toString());
    }
  }

  /// Clear all tasks cache
  Future<void> clearTasksCache() async {
    await _clearTasksCache();
    await _clearSubmissionsCache();
    await StorageService.removeCachedData(_cacheKeyCategories);
  }

  /// Get tasks summary for offline mode
  Future<Map<String, dynamic>?> getTasksSummary() async {
    try {
      final cached = await _getCachedTasks('${_cacheKeyTasks}_1_20_all_all');
      if (cached?.data != null) {
        final tasks = cached!.data;
        return {
          'totalTasks': tasks.length,
          'availableTasks': tasks
              .where((task) => task.userStatus.canSubmit)
              .length,
          'completedTasks': tasks
              .where((task) => task.userStatus.hasSubmitted)
              .length,
          'totalReward': tasks.fold<double>(
            0,
            (sum, task) => sum + task.rewardAmount,
          ),
          'lastUpdated': DateTime.now().toIso8601String(),
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get cached tasks (for offline mode)
  Future<List<TaskModel>?> getCachedTasks() async {
    try {
      final cached = await _getCachedTasks('${_cacheKeyTasks}_1_20_all_all');
      return cached?.data;
    } catch (e) {
      return null;
    }
  }

  /// Utility methods
  bool canUserSubmitTask(TaskModel task) {
    return task.userStatus.canSubmit;
  }

  bool hasUserSubmittedTask(TaskModel task) {
    return task.userStatus.hasSubmitted;
  }

  bool isTaskExpired(TaskModel task) {
    if (task.expiresAt == null) return false;
    return DateTime.now().isAfter(task.expiresAt!);
  }

  bool isTaskAvailable(TaskModel task) {
    return !isTaskExpired(task) &&
        task.currentSubmissions < task.maxSubmissions &&
        canUserSubmitTask(task);
  }

  String getTaskDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return '#4CAF50'; // Green
      case 'medium':
        return '#FF9800'; // Orange
      case 'hard':
        return '#F44336'; // Red
      default:
        return '#757575'; // Grey
    }
  }

  String getTaskCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'social media':
        return 'share';
      case 'app installation':
        return 'download';
      case 'survey':
        return 'poll';
      case 'review':
        return 'star';
      case 'referral':
        return 'people';
      case 'video watch':
        return 'play_circle';
      case 'article read':
        return 'article';
      case 'registration':
        return 'person_add';
      default:
        return 'task_alt';
    }
  }

  String getSubmissionStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return '#4CAF50'; // Green
      case 'pending':
        return '#FF9800'; // Orange
      case 'rejected':
        return '#F44336'; // Red
      case 'under_review':
        return '#2196F3'; // Blue
      default:
        return '#757575'; // Grey
    }
  }

  String getSubmissionStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Pending Review';
      case 'rejected':
        return 'Rejected';
      case 'under_review':
        return 'Under Review';
      default:
        return 'Unknown';
    }
  }

  /// Calculate estimated completion time in minutes
  int getEstimatedCompletionMinutes(String timeEstimate) {
    final timeStr = timeEstimate.toLowerCase();

    if (timeStr.contains('minute')) {
      final match = RegExp(r'(\d+)').firstMatch(timeStr);
      return int.tryParse(match?.group(1) ?? '5') ?? 5;
    } else if (timeStr.contains('hour')) {
      final match = RegExp(r'(\d+)').firstMatch(timeStr);
      final hours = int.tryParse(match?.group(1) ?? '1') ?? 1;
      return hours * 60;
    } else if (timeStr.contains('day')) {
      final match = RegExp(r'(\d+)').firstMatch(timeStr);
      final days = int.tryParse(match?.group(1) ?? '1') ?? 1;
      return days * 24 * 60;
    }

    return 5; // Default 5 minutes
  }

  /// Format reward amount
  String formatRewardAmount(double amount, String currency) {
    if (currency.toUpperCase() == 'USD') {
      return '\$${amount.toStringAsFixed(2)}';
    } else if (currency.toUpperCase() == 'BDT') {
      return '৳${amount.toStringAsFixed(2)}';
    }
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  /// Check if task is popular
  bool isTaskPopular(TaskModel task) {
    return task.taskInfo.isPopular;
  }

  /// Get task urgency level
  String getTaskUrgency(TaskModel task) {
    return task.taskInfo.urgency;
  }

  /// Calculate task completion rate percentage
  double getTaskCompletionRate(TaskModel task) {
    return task.taskInfo.completionRate * 100;
  }
}
