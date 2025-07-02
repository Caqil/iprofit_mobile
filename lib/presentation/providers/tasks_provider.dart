// lib/presentation/providers/tasks_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/errors/app_exception.dart';
import '../../data/repositories/tasks_repository.dart';
import '../../data/models/tasks/task_model.dart';
import '../../data/models/tasks/task_submission.dart';
import '../../data/models/tasks/task_category.dart';
import '../../data/models/common/pagination.dart';

part 'tasks_provider.g.dart';

// ============================================================================
// TASKS STATE MODEL
// ============================================================================

/// Tasks provider state model
class TasksState {
  final List<TaskModel> tasks;
  final Pagination? tasksPagination;
  final List<TaskSubmissionResponse> submissions;
  final Pagination? submissionsPagination;
  final List<TaskCategory> categories;
  final Map<String, dynamic>? statistics;
  final Map<String, dynamic>? progress;
  final bool isLoading;
  final bool isLoadingTasks;
  final bool isLoadingSubmissions;
  final bool isSubmitting;
  final String? error;
  final String currentCategory;
  final String currentDifficulty;
  final String currentSubmissionFilter;
  final double? rewardMin;
  final double? rewardMax;
  final String? lastUpdated;

  const TasksState({
    this.tasks = const [],
    this.tasksPagination,
    this.submissions = const [],
    this.submissionsPagination,
    this.categories = const [],
    this.statistics,
    this.progress,
    this.isLoading = false,
    this.isLoadingTasks = false,
    this.isLoadingSubmissions = false,
    this.isSubmitting = false,
    this.error,
    this.currentCategory = 'all',
    this.currentDifficulty = 'all',
    this.currentSubmissionFilter = 'all',
    this.rewardMin,
    this.rewardMax,
    this.lastUpdated,
  });

  TasksState copyWith({
    List<TaskModel>? tasks,
    Pagination? tasksPagination,
    List<TaskSubmissionResponse>? submissions,
    Pagination? submissionsPagination,
    List<TaskCategory>? categories,
    Map<String, dynamic>? statistics,
    Map<String, dynamic>? progress,
    bool? isLoading,
    bool? isLoadingTasks,
    bool? isLoadingSubmissions,
    bool? isSubmitting,
    String? error,
    String? currentCategory,
    String? currentDifficulty,
    String? currentSubmissionFilter,
    double? rewardMin,
    double? rewardMax,
    String? lastUpdated,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      tasksPagination: tasksPagination ?? this.tasksPagination,
      submissions: submissions ?? this.submissions,
      submissionsPagination:
          submissionsPagination ?? this.submissionsPagination,
      categories: categories ?? this.categories,
      statistics: statistics ?? this.statistics,
      progress: progress ?? this.progress,
      isLoading: isLoading ?? this.isLoading,
      isLoadingTasks: isLoadingTasks ?? this.isLoadingTasks,
      isLoadingSubmissions: isLoadingSubmissions ?? this.isLoadingSubmissions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      currentCategory: currentCategory ?? this.currentCategory,
      currentDifficulty: currentDifficulty ?? this.currentDifficulty,
      currentSubmissionFilter:
          currentSubmissionFilter ?? this.currentSubmissionFilter,
      rewardMin: rewardMin ?? this.rewardMin,
      rewardMax: rewardMax ?? this.rewardMax,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Convenience getters
  bool get hasError => error != null;
  bool get hasTasks => tasks.isNotEmpty;
  bool get hasSubmissions => submissions.isNotEmpty;
  bool get hasCategories => categories.isNotEmpty;
  bool get hasMoreTasks => tasksPagination?.hasNextPage ?? false;
  bool get hasMoreSubmissions => submissionsPagination?.hasNextPage ?? false;
  bool get hasStatistics => statistics != null;
  bool get hasProgress => progress != null;

  // Task categories - FIXED: Using correct properties from TaskModel
  List<TaskModel> get availableTasks => tasks
      .where((t) => t.userStatus.canSubmit && !t.userStatus.hasSubmitted)
      .toList();

  List<TaskModel> get completedTasks =>
      tasks.where((t) => t.userStatus.hasSubmitted).toList();

  List<TaskModel> get highRewardTasks =>
      tasks.where((t) => t.rewardAmount >= 10.0).toList();

  List<TaskModel> get easyTasks =>
      tasks.where((t) => t.difficulty == 'easy').toList();

  List<TaskModel> get mediumTasks =>
      tasks.where((t) => t.difficulty == 'medium').toList();

  List<TaskModel> get hardTasks =>
      tasks.where((t) => t.difficulty == 'hard').toList();

  // Submission categories
  List<TaskSubmissionResponse> get pendingSubmissions =>
      submissions.where((s) => s.status == 'pending').toList();

  List<TaskSubmissionResponse> get approvedSubmissions =>
      submissions.where((s) => s.status == 'approved').toList();

  List<TaskSubmissionResponse> get rejectedSubmissions =>
      submissions.where((s) => s.status == 'rejected').toList();

  // Statistics
  int get totalTasksCompleted => completedTasks.length;

  double get totalEarned =>
      approvedSubmissions.fold(0.0, (sum, s) => sum + (s.rewardAmount ?? 0.0));

  double get potentialEarnings =>
      availableTasks.fold(0.0, (sum, t) => sum + t.rewardAmount);

  int get tasksInProgress => pendingSubmissions.length;

  // Progress metrics
  double get completionRate =>
      hasTasks ? (completedTasks.length / tasks.length) * 100 : 0.0;

  double get approvalRate => hasSubmissions
      ? (approvedSubmissions.length / submissions.length) * 100
      : 0.0;

  double get averageReward => approvedSubmissions.isNotEmpty
      ? totalEarned / approvedSubmissions.length
      : 0.0;
}

// ============================================================================
// TASKS PROVIDER
// ============================================================================

@riverpod
class Tasks extends _$Tasks {
  @override
  TasksState build() {
    // Initialize tasks data on provider creation
    _initializeTasks();
    return const TasksState();
  }

  // ===== INITIALIZATION =====

  /// Initialize tasks data
  Future<void> _initializeTasks() async {
    await Future.wait([
      loadTasks(),
      loadCategories(),
      loadSubmissions(),
      loadStatistics(),
    ]);
  }

  // ===== TASKS MANAGEMENT =====

  /// Load tasks with filtering and pagination
  Future<void> loadTasks({
    int page = 1,
    String category = 'all',
    String difficulty = 'all',
    double? rewardMin,
    double? rewardMax,
    String sortBy = 'rewardAmount',
    String sortOrder = 'desc',
    bool forceRefresh = false,
  }) async {
    try {
      // Set loading state
      if (page == 1) {
        state = state.copyWith(
          isLoadingTasks: true,
          error: null,
          currentCategory: category,
          currentDifficulty: difficulty,
          rewardMin: rewardMin,
          rewardMax: rewardMax,
        );
      } else {
        state = state.copyWith(isLoadingTasks: true, error: null);
      }

      final tasksRepository = ref.read(tasksRepositoryProvider);
      final response = await tasksRepository.getTasks(
        page: page,
        category: category,
        difficulty: difficulty,
        rewardMin: rewardMin,
        rewardMax: rewardMax,
        sortBy: sortBy,
        sortOrder: sortOrder,
        forceRefresh: forceRefresh,
      );

      if (response.success) {
        List<TaskModel> updatedTasks;

        if (page == 1) {
          updatedTasks = response.data;
        } else {
          updatedTasks = [...state.tasks, ...response.data];
        }

        state = state.copyWith(
          tasks: updatedTasks,
          tasksPagination: response.pagination,
          isLoadingTasks: false,
          lastUpdated: DateTime.now().toIso8601String(),
        );
      } else {
        state = state.copyWith(
          isLoadingTasks: false,
          error: response.data.toString(),
        );
      }
    } catch (e) {
      state = state.copyWith(isLoadingTasks: false, error: _getErrorMessage(e));
    }
  }

  /// Load more tasks (pagination)
  Future<void> loadMoreTasks() async {
    if (state.isLoadingTasks || !state.hasMoreTasks) return;

    final nextPage = (state.tasksPagination?.currentPage ?? 0) + 1;
    await loadTasks(
      page: nextPage,
      category: state.currentCategory,
      difficulty: state.currentDifficulty,
      rewardMin: state.rewardMin,
      rewardMax: state.rewardMax,
    );
  }

  /// Filter tasks by category
  Future<void> filterByCategory(String category) async {
    if (state.currentCategory == category) return;

    await loadTasks(
      category: category,
      difficulty: state.currentDifficulty,
      rewardMin: state.rewardMin,
      rewardMax: state.rewardMax,
    );
  }

  /// Filter tasks by difficulty
  Future<void> filterByDifficulty(String difficulty) async {
    if (state.currentDifficulty == difficulty) return;

    await loadTasks(
      category: state.currentCategory,
      difficulty: difficulty,
      rewardMin: state.rewardMin,
      rewardMax: state.rewardMax,
    );
  }

  /// Filter tasks by reward range
  Future<void> filterByRewardRange(double? min, double? max) async {
    await loadTasks(
      category: state.currentCategory,
      difficulty: state.currentDifficulty,
      rewardMin: min,
      rewardMax: max,
    );
  }

  /// Sort tasks
  Future<void> sortTasks(String sortBy, {String sortOrder = 'desc'}) async {
    await loadTasks(
      category: state.currentCategory,
      difficulty: state.currentDifficulty,
      rewardMin: state.rewardMin,
      rewardMax: state.rewardMax,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  /// Refresh tasks list
  Future<void> refreshTasks() async {
    await loadTasks(
      category: state.currentCategory,
      difficulty: state.currentDifficulty,
      rewardMin: state.rewardMin,
      rewardMax: state.rewardMax,
      forceRefresh: true,
    );
  }

  // ===== TASK SUBMISSIONS =====

  /// Load task submissions
  Future<void> loadSubmissions({
    int page = 1,
    String status = 'all',
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    bool forceRefresh = false,
  }) async {
    try {
      // Set loading state
      if (page == 1) {
        state = state.copyWith(
          isLoadingSubmissions: true,
          error: null,
          currentSubmissionFilter: status,
        );
      } else {
        state = state.copyWith(isLoadingSubmissions: true, error: null);
      }

      final tasksRepository = ref.read(tasksRepositoryProvider);
      final response = await tasksRepository.getTaskSubmissions(
        page: page,
        status: status,
        sortBy: sortBy,
        sortOrder: sortOrder,
        forceRefresh: forceRefresh,
      );

      if (response.success) {
        List<TaskSubmissionResponse> updatedSubmissions;

        if (page == 1) {
          updatedSubmissions = response.data;
        } else {
          updatedSubmissions = [...state.submissions, ...response.data];
        }

        state = state.copyWith(
          submissions: updatedSubmissions,
          submissionsPagination: response.pagination,
          isLoadingSubmissions: false,
        );
      } else {
        state = state.copyWith(
          isLoadingSubmissions: false,
          error: response.data.toString(),
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingSubmissions: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Load more submissions (pagination)
  Future<void> loadMoreSubmissions() async {
    if (state.isLoadingSubmissions || !state.hasMoreSubmissions) return;

    final nextPage = (state.submissionsPagination?.currentPage ?? 0) + 1;
    await loadSubmissions(
      page: nextPage,
      status: state.currentSubmissionFilter,
    );
  }

  /// Filter submissions by status
  Future<void> filterSubmissions(String status) async {
    if (state.currentSubmissionFilter == status) return;

    await loadSubmissions(status: status);
  }

  /// Refresh submissions list
  Future<void> refreshSubmissions() async {
    await loadSubmissions(
      status: state.currentSubmissionFilter,
      forceRefresh: true,
    );
  }

  /// Submit task - FIXED: Using correct TaskSubmission structure and repository call
  Future<bool> submitTask({
    required String taskId,
    required String content,
    List<String>? attachments,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      state = state.copyWith(isSubmitting: true, error: null);

      final tasksRepository = ref.read(tasksRepositoryProvider);

      // Create proof items from attachments/content
      final proofItems = <ProofItem>[];

      // Add content as text proof
      if (content.isNotEmpty) {
        proofItems.add(
          ProofItem(
            type: 'text',
            url: '', // Not applicable for text proof
            description: content,
          ),
        );
      }

      // Add attachments as file proofs
      if (attachments != null) {
        for (final attachment in attachments) {
          proofItems.add(
            ProofItem(type: 'file', url: attachment, description: 'Attachment'),
          );
        }
      }

      // Create TaskSubmission with correct structure
      final submission = TaskSubmission(
        taskId: taskId,
        proof: proofItems,
        completionNotes: content,
        completedAt: DateTime.now(),
      );

      // Call repository with both taskId and submission parameters
      final response = await tasksRepository.submitTask(
        taskId: taskId,
        submission: submission,
      );

      if (response.success) {
        state = state.copyWith(isSubmitting: false);

        // Refresh tasks and submissions to update status
        await Future.wait([refreshTasks(), refreshSubmissions()]);

        return true;
      } else {
        state = state.copyWith(
          isSubmitting: false,
          error: response.message ?? 'Failed to submit task',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: _getErrorMessage(e));
      return false;
    }
  }

  // ===== TASK CATEGORIES =====

  /// Load task categories
  Future<void> loadCategories({bool forceRefresh = false}) async {
    try {
      final tasksRepository = ref.read(tasksRepositoryProvider);
      final response = await tasksRepository.getTaskCategories(
        forceRefresh: forceRefresh,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(categories: response.data!);
      }
    } catch (e) {
      // Silent fail for categories
    }
  }

  // ===== STATISTICS AND PROGRESS =====

  /// Load task statistics
  Future<void> loadStatistics({
    String timeframe = '30d',
    bool forceRefresh = false,
  }) async {
    try {
      final tasksRepository = ref.read(tasksRepositoryProvider);
      final response = await tasksRepository.getTaskStatistics(
        forceRefresh: forceRefresh,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(statistics: response.data!);
      }
    } catch (e) {
      // Silent fail for statistics
    }
  }

  /// Load task progress
  Future<void> loadProgress({bool forceRefresh = false}) async {
    try {
      final tasksRepository = ref.read(tasksRepositoryProvider);
      final response = await tasksRepository.getTaskProgress(
        forceRefresh: forceRefresh,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(progress: response.data!);
      }
    } catch (e) {
      // Silent fail for progress
    }
  }

  // ===== TASK DETAILS =====

  /// Get task details
  Future<TaskModel?> getTaskDetails(String taskId) async {
    try {
      final tasksRepository = ref.read(tasksRepositoryProvider);
      final response = await tasksRepository.getTaskDetails(taskId);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw AppException.serverError(
          response.message ?? 'Failed to load task details',
        );
      }
    } catch (e) {
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get submission details
  Future<TaskSubmissionResponse?> getSubmissionDetails(
    String submissionId,
  ) async {
    try {
      final tasksRepository = ref.read(tasksRepositoryProvider);
      final response = await tasksRepository.getSubmissionDetails(submissionId);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw AppException.serverError(
          response.message ?? 'Failed to load submission details',
        );
      }
    } catch (e) {
      throw AppException.fromException(e as Exception);
    }
  }

  // ===== UTILITY METHODS =====

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.userMessage;
    }
    return error.toString();
  }

  /// Get task by ID
  TaskModel? getTaskById(String taskId) {
    try {
      return state.tasks.firstWhere((t) => t.id == taskId);
    } catch (e) {
      return null;
    }
  }

  /// Get submission by ID
  TaskSubmissionResponse? getSubmissionById(String submissionId) {
    try {
      return state.submissions.firstWhere((s) => s.id == submissionId);
    } catch (e) {
      return null;
    }
  }

  /// Check if task is completed - FIXED: Using correct property path
  bool isTaskCompleted(String taskId) {
    final task = getTaskById(taskId);
    return task?.userStatus.hasSubmitted ?? false;
  }

  /// Check if task has pending submission
  bool hasTaskPendingSubmission(String taskId) {
    return state.pendingSubmissions.any((s) => s.taskId == taskId);
  }

  /// Get tasks by category
  List<TaskModel> getTasksByCategory(String category) {
    return state.tasks.where((t) => t.category == category).toList();
  }

  /// Get earnings chart data - FIXED: Using correct property
  List<Map<String, dynamic>> getEarningsChartData({
    String timeframe = '30d',
    int maxPoints = 30,
  }) {
    final earnings = state.approvedSubmissions
        .take(maxPoints)
        .map(
          (s) => {
            'date':
                s.reviewedAt?.toIso8601String().split('T')[0] ??
                s.submittedAt.toIso8601String().split('T')[0],
            'amount': s.rewardAmount ?? 0.0,
          },
        )
        .toList();

    return earnings.reversed.toList(); // Reverse to show chronological order
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    await loadTasks();
  }

  /// Force refresh all tasks data
  Future<void> refresh() async {
    await Future.wait([
      refreshTasks(),
      refreshSubmissions(),
      loadCategories(forceRefresh: true),
      loadStatistics(forceRefresh: true),
      loadProgress(forceRefresh: true),
    ]);
  }
}

// ============================================================================
// ADDITIONAL PROVIDERS
// ============================================================================

/// Provider for available tasks
@riverpod
List<TaskModel> availableTasks(Ref ref) {
  return ref.watch(tasksProvider.select((state) => state.availableTasks));
}

/// Provider for completed tasks count
@riverpod
int completedTasksCount(Ref ref) {
  return ref.watch(tasksProvider.select((state) => state.totalTasksCompleted));
}

/// Provider for total earned amount
@riverpod
double totalTasksEarned(Ref ref) {
  return ref.watch(tasksProvider.select((state) => state.totalEarned));
}

/// Provider for pending submissions
@riverpod
List<TaskSubmissionResponse> pendingTaskSubmissions(Ref ref) {
  return ref.watch(tasksProvider.select((state) => state.pendingSubmissions));
}

/// Provider for tasks loading state
@riverpod
bool isTasksLoading(Ref ref) {
  return ref.watch(tasksProvider.select((state) => state.isLoadingTasks));
}

/// Provider for tasks error
@riverpod
String? tasksError(Ref ref) {
  return ref.watch(tasksProvider.select((state) => state.error));
}

/// Provider for task categories
@riverpod
List<TaskCategory> taskCategories(Ref ref) {
  return ref.watch(tasksProvider.select((state) => state.categories));
}

/// Provider for completion rate
@riverpod
double taskCompletionRate(Ref ref) {
  return ref.watch(tasksProvider.select((state) => state.completionRate));
}

/// Provider for approval rate
@riverpod
double taskApprovalRate(Ref ref) {
  return ref.watch(tasksProvider.select((state) => state.approvalRate));
}

/// Provider for potential earnings
@riverpod
double potentialTaskEarnings(Ref ref) {
  return ref.watch(tasksProvider.select((state) => state.potentialEarnings));
}
