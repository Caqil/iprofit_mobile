import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/tasks/task_model.dart';
import '../models/tasks/task_submission.dart';
import '../models/tasks/task_category.dart';
import '../models/common/api_response.dart';
import '../models/common/pagination.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository(ref.read(apiServiceProvider));
});

class TasksRepository {
  final ApiService _apiService;
  static const String _tasksCacheKey = 'tasks_data';
  static const String _submissionsCacheKey = 'task_submissions_data';
  static const String _categoriesCacheKey = 'task_categories_data';
  static const String _completedTasksCacheKey = 'completed_tasks_data';

  TasksRepository(this._apiService);

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
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'category': category,
        'difficulty': difficulty,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (rewardMin != null) queryParams['rewardMin'] = rewardMin.toString();
      if (rewardMax != null) queryParams['rewardMax'] = rewardMax.toString();

      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.tasks,
        queryParameters: queryParams,
      );

      if (response.data != null) {
        final paginatedResponse = PaginatedResponse<TaskModel>.fromJson(
          response.data!,
          (json) => TaskModel.fromJson(json as Map<String, dynamic>),
        );

        // Cache tasks data locally (first page only)
        if (paginatedResponse.success && page == 1) {
          await StorageService.setCachedData(
            _tasksCacheKey,
            paginatedResponse.data.map((task) => task.toJson()).toList(),
          );
        }

        return paginatedResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      // Try to return cached data if network fails and it's the first page
      if (page == 1) {
        final cachedData = await StorageService.getCachedData(_tasksCacheKey);
        if (cachedData != null) {
          final tasks = (cachedData as List)
              .map((json) => TaskModel.fromJson(json))
              .toList();

          return PaginatedResponse<TaskModel>(
            success: true,
            data: tasks,
            pagination: Pagination(
              currentPage: 1,
              totalPages: 1,
              totalItems: tasks.length,
              itemsPerPage: tasks.length,
              hasNextPage: false,
              hasPreviousPage: false,
            ),
            timestamp: DateTime.now(),
          );
        }
      }
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<TaskModel>> getTaskDetails(String taskId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConstants.tasks}/$taskId',
      );

      if (response.data != null) {
        return ApiResponse<TaskModel>.fromJson(
          response.data!,
          (json) => TaskModel.fromJson(json as Map<String, dynamic>),
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<TaskSubmissionResponse>> submitTask(
    String taskId,
    TaskSubmission submission,
  ) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '${ApiConstants.tasks}/$taskId/submit',
        data: submission.toJson(),
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<TaskSubmissionResponse>.fromJson(
          response.data!,
          (json) =>
              TaskSubmissionResponse.fromJson(json as Map<String, dynamic>),
        );

        // Refresh tasks and submissions cache after submission
        if (apiResponse.success) {
          await getTasks(forceRefresh: true);
          await getTaskSubmissions(forceRefresh: true);
        }

        return apiResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<PaginatedResponse<TaskSubmissionResponse>> getTaskSubmissions({
    int page = 1,
    int limit = 20,
    String status = 'all',
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    bool forceRefresh = false,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'status': status,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.taskSubmissions,
        queryParameters: queryParams,
      );

      if (response.data != null) {
        final paginatedResponse =
            PaginatedResponse<TaskSubmissionResponse>.fromJson(
              response.data!,
              (json) =>
                  TaskSubmissionResponse.fromJson(json as Map<String, dynamic>),
            );

        // Cache submissions data locally (first page only)
        if (paginatedResponse.success && page == 1) {
          await StorageService.setCachedData(
            _submissionsCacheKey,
            paginatedResponse.data
                .map((submission) => submission.toJson())
                .toList(),
          );
        }

        return paginatedResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      // Try to return cached data if network fails and it's the first page
      if (page == 1) {
        final cachedData = await StorageService.getCachedData(
          _submissionsCacheKey,
        );
        if (cachedData != null) {
          final submissions = (cachedData as List)
              .map((json) => TaskSubmissionResponse.fromJson(json))
              .toList();

          return PaginatedResponse<TaskSubmissionResponse>(
            success: true,
            data: submissions,
            pagination: Pagination(
              currentPage: 1,
              totalPages: 1,
              totalItems: submissions.length,
              itemsPerPage: submissions.length,
              hasNextPage: false,
              hasPreviousPage: false,
            ),
            timestamp: DateTime.now(),
          );
        }
      }
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<TaskSubmissionResponse>> getSubmissionDetails(
    String submissionId,
  ) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConstants.taskSubmissions}/$submissionId',
      );

      if (response.data != null) {
        return ApiResponse<TaskSubmissionResponse>.fromJson(
          response.data!,
          (json) =>
              TaskSubmissionResponse.fromJson(json as Map<String, dynamic>),
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<List<TaskCategory>>> getTaskCategories() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConstants.tasks}/categories',
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<List<TaskCategory>>.fromJson(
          response.data!,
          (json) => (json as List)
              .map((e) => TaskCategory.fromJson(e as Map<String, dynamic>))
              .toList(),
        );

        // Cache categories data locally
        if (apiResponse.success && apiResponse.data != null) {
          await StorageService.setCachedData(
            _categoriesCacheKey,
            apiResponse.data!.map((category) => category.toJson()).toList(),
          );
        }

        return apiResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      // Try to return cached data if network fails
      final cachedData = await StorageService.getCachedData(
        _categoriesCacheKey,
      );
      if (cachedData != null) {
        final categories = (cachedData as List)
            .map((json) => TaskCategory.fromJson(json))
            .toList();

        return ApiResponse<List<TaskCategory>>(
          success: true,
          data: categories,
          timestamp: DateTime.now(),
          message: 'Loaded from cache',
        );
      }
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getTaskStats() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConstants.tasks}/stats',
      );

      if (response.data != null) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getUserTaskHistory({
    String period = 'monthly',
    bool includeEarnings = true,
  }) async {
    try {
      final queryParams = {
        'period': period,
        'includeEarnings': includeEarnings.toString(),
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConstants.tasks}/history',
        queryParameters: queryParams,
      );

      if (response.data != null) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> resubmitTask({
    required String submissionId,
    required TaskSubmission newSubmission,
  }) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '${ApiConstants.taskSubmissions}/$submissionId/resubmit',
        data: newSubmission.toJson(),
      );

      if (response.data != null) {
        // Refresh submissions cache after resubmission
        await getTaskSubmissions(forceRefresh: true);

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> reportTask({
    required String taskId,
    required String reason,
    String? description,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '${ApiConstants.tasks}/$taskId/report',
        data: {
          'reason': reason,
          if (description != null) 'description': description,
        },
      );

      if (response.data != null) {
        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<List<String>>> getTaskGuidelines() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConstants.tasks}/guidelines',
      );

      if (response.data != null) {
        return ApiResponse<List<String>>.fromJson(
          response.data!,
          (json) => (json as List).map((e) => e.toString()).toList(),
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getTaskRequirements(
    String taskId,
  ) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConstants.tasks}/$taskId/requirements',
      );

      if (response.data != null) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getPopularTasks({
    int limit = 10,
  }) async {
    try {
      final queryParams = {'limit': limit.toString()};

      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConstants.tasks}/popular',
        queryParameters: queryParams,
      );

      if (response.data != null) {
        return ApiResponse<List<Map<String, dynamic>>>.fromJson(
          response.data!,
          (json) =>
              (json as List).map((e) => e as Map<String, dynamic>).toList(),
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getRecommendedTasks({
    int limit = 5,
  }) async {
    try {
      final queryParams = {'limit': limit.toString()};

      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConstants.tasks}/recommended',
        queryParameters: queryParams,
      );

      if (response.data != null) {
        return ApiResponse<List<Map<String, dynamic>>>.fromJson(
          response.data!,
          (json) =>
              (json as List).map((e) => e as Map<String, dynamic>).toList(),
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  // Cache management methods
  Future<List<TaskModel>?> getCachedTasks() async {
    try {
      final cachedData = await StorageService.getCachedData(_tasksCacheKey);
      if (cachedData != null) {
        return (cachedData as List)
            .map((json) => TaskModel.fromJson(json))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<TaskSubmissionResponse>?> getCachedSubmissions() async {
    try {
      final cachedData = await StorageService.getCachedData(
        _submissionsCacheKey,
      );
      if (cachedData != null) {
        return (cachedData as List)
            .map((json) => TaskSubmissionResponse.fromJson(json))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<TaskCategory>?> getCachedCategories() async {
    try {
      final cachedData = await StorageService.getCachedData(
        _categoriesCacheKey,
      );
      if (cachedData != null) {
        return (cachedData as List)
            .map((json) => TaskCategory.fromJson(json))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearTasksCache() async {
    await StorageService.removeCachedData(_tasksCacheKey);
    await StorageService.removeCachedData(_submissionsCacheKey);
    await StorageService.removeCachedData(_categoriesCacheKey);
    await StorageService.removeCachedData(_completedTasksCacheKey);
  }

  Future<Map<String, dynamic>> getTasksSummary() async {
    try {
      final tasks = await getCachedTasks();
      final submissions = await getCachedSubmissions();

      if (tasks == null || submissions == null) return {};

      final availableTasks = tasks
          .where((task) => task.userStatus.canSubmit)
          .length;
      final completedTasks = submissions
          .where((sub) => sub.status == 'approved')
          .length;
      final pendingTasks = submissions
          .where((sub) => sub.status == 'pending')
          .length;
      final totalEarnings = submissions
          .where((sub) => sub.status == 'approved')
          .fold<double>(0, (sum, sub) => sum + (sub.rewardAmount ?? 0));

      return {
        'totalTasks': tasks.length,
        'availableTasks': availableTasks,
        'completedTasks': completedTasks,
        'pendingTasks': pendingTasks,
        'totalSubmissions': submissions.length,
        'totalEarnings': totalEarnings,
        'successRate': submissions.isNotEmpty
            ? (completedTasks / submissions.length) * 100
            : 0.0,
      };
    } catch (e) {
      return {};
    }
  }

  Future<List<TaskModel>> getAvailableTasks() async {
    try {
      final tasks = await getCachedTasks();
      if (tasks == null) return [];

      return tasks.where((task) => task.userStatus.canSubmit).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<TaskModel>> getCompletedTasks() async {
    try {
      final tasks = await getCachedTasks();
      if (tasks == null) return [];

      return tasks.where((task) => task.userStatus.hasSubmitted).toList();
    } catch (e) {
      return [];
    }
  }
}
