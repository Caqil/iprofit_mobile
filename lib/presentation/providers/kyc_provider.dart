// lib/presentation/providers/kyc_provider.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/errors/app_exception.dart';
import '../../data/repositories/kyc_repository.dart';
import '../../data/models/kyc/kyc_model.dart';
import '../../data/models/kyc/kyc_document.dart';
import '../../data/models/common/api_response.dart';

part 'kyc_provider.g.dart';

// ============================================================================
// KYC STATE MODEL
// ============================================================================

/// KYC provider state model
class KYCState {
  final KYCModel? kycData;
  final List<KYCDocument> documents;
  final bool isLoading;
  final String? error;
  final bool isSubmitting;
  final bool isUploading;
  final Map<String, double> uploadProgress;
  final String? lastUpdated;

  const KYCState({
    this.kycData,
    this.documents = const [],
    this.isLoading = false,
    this.error,
    this.isSubmitting = false,
    this.isUploading = false,
    this.uploadProgress = const {},
    this.lastUpdated,
  });

  KYCState copyWith({
    KYCModel? kycData,
    List<KYCDocument>? documents,
    bool? isLoading,
    String? error,
    bool? isSubmitting,
    bool? isUploading,
    Map<String, double>? uploadProgress,
    String? lastUpdated,
  }) {
    return KYCState(
      kycData: kycData ?? this.kycData,
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Convenience getters
  bool get hasError => error != null;
  bool get hasKYCData => kycData != null;
  String get kycStatus => kycData?.status ?? 'pending';
  bool get isKYCPending => kycStatus == 'pending';
  bool get isKYCSubmitted => kycStatus == 'submitted' || kycStatus == 'review';
  bool get isKYCVerified => kycStatus == 'verified';
  bool get isKYCRejected => kycStatus == 'rejected';
  double get completionPercentage => kycData?.completionPercentage ?? 0.0;
  bool get canSubmitKYC => completionPercentage >= 100.0 && !isKYCSubmitted;
  List<String> get missingDocuments => kycData?.missingDocuments ?? [];
  String? get rejectionReason => kycData?.rejectionReason;
}

// ============================================================================
// KYC PROVIDER
// ============================================================================

@riverpod
class KYC extends _$KYC {
  @override
  KYCState build() {
    // Initialize KYC data on provider creation
    _initializeKYC();
    return const KYCState();
  }

  // ===== INITIALIZATION =====

  /// Initialize KYC data
  Future<void> _initializeKYC() async {
    await loadKYCStatus();
  }

  // ===== KYC STATUS MANAGEMENT =====

  /// Load KYC status
  Future<void> loadKYCStatus({bool forceRefresh = false}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final kycRepository = ref.read(kycRepositoryProvider);
      final response = await kycRepository.getKYCStatus(
        forceRefresh: forceRefresh,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(
          kycData: response.data!,
          documents: response.data!.documents,
          isLoading: false,
          lastUpdated: DateTime.now().toIso8601String(),
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to load KYC status',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e));
    }
  }

  /// Refresh KYC status
  Future<void> refreshKYCStatus() async {
    await loadKYCStatus(forceRefresh: true);
  }

  // ===== DOCUMENT MANAGEMENT =====

  /// Upload KYC document
  Future<bool> uploadDocument({
    required String documentType,
    required String filePath,
    String? documentNumber,
    DateTime? expiryDate,
    DateTime? issueDate,
  }) async {
    try {
      state = state.copyWith(
        isUploading: true,
        error: null,
        uploadProgress: {...state.uploadProgress, documentType: 0.0},
      );

      final kycRepository = ref.read(kycRepositoryProvider);

      // Simulate progress updates (you might want to implement actual progress tracking)
      _updateUploadProgress(documentType, 0.3);

      final response = await kycRepository.uploadDocument(
        documentType: documentType,
        filePath: filePath,
        documentNumber: documentNumber,
        expiryDate: expiryDate,
        issueDate: issueDate,
      );

      _updateUploadProgress(documentType, 1.0);

      if (response.success && response.data != null) {
        // Update documents list
        final updatedDocuments = [...state.documents];
        final existingIndex = updatedDocuments.indexWhere(
          (doc) => doc.type == documentType,
        );

        if (existingIndex != -1) {
          updatedDocuments[existingIndex] = response.data!;
        } else {
          updatedDocuments.add(response.data!);
        }

        state = state.copyWith(documents: updatedDocuments, isUploading: false);

        // Refresh KYC status to get updated completion percentage
        await loadKYCStatus(forceRefresh: true);

        return true;
      } else {
        state = state.copyWith(
          isUploading: false,
          error: response.message ?? 'Failed to upload document',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isUploading: false, error: _getErrorMessage(e));
      return false;
    } finally {
      // Clear upload progress
      final updatedProgress = Map<String, double>.from(state.uploadProgress);
      updatedProgress.remove(documentType);
      state = state.copyWith(uploadProgress: updatedProgress);
    }
  }

  /// Update upload progress
  void _updateUploadProgress(String documentType, double progress) {
    state = state.copyWith(
      uploadProgress: {...state.uploadProgress, documentType: progress},
    );
  }

  /// Delete KYC document
  Future<bool> deleteDocument(String documentId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final kycRepository = ref.read(kycRepositoryProvider);
      final response = await kycRepository.deleteDocument(documentId);

      if (response.success) {
        // Remove document from list
        final updatedDocuments = state.documents
            .where((doc) => doc.number != documentId)
            .toList();

        state = state.copyWith(documents: updatedDocuments, isLoading: false);

        // Refresh KYC status
        await loadKYCStatus(forceRefresh: true);

        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to delete document',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e));
      return false;
    }
  }

  // ===== KYC SUBMISSION =====

  /// Submit KYC for verification
  Future<bool> submitKYC() async {
    try {
      if (!state.canSubmitKYC) {
        state = state.copyWith(
          error:
              'KYC is not ready for submission. Please complete all required documents.',
        );
        return false;
      }

      state = state.copyWith(isSubmitting: true, error: null);

      // Create KYC submission from current state
      final submission = _createKYCSubmission();
      if (submission == null) {
        state = state.copyWith(
          isSubmitting: false,
          error:
              'Unable to prepare KYC submission. Please ensure all required information is complete.',
        );
        return false;
      }

      final kycRepository = ref.read(kycRepositoryProvider);
      final response = await kycRepository.submitKYC(submission);

      if (response.success) {
        // Refresh KYC status to get updated submission status
        await loadKYCStatus(forceRefresh: true);

        state = state.copyWith(isSubmitting: false);
        return true;
      } else {
        state = state.copyWith(
          isSubmitting: false,
          error: response.message ?? 'Failed to submit KYC',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: _getErrorMessage(e));
      return false;
    }
  }

  /// Create KYC submission object from current state
  KYCSubmission? _createKYCSubmission() {
    try {
      final kycData = state.kycData;
      if (kycData == null) return null;

      return KYCSubmission(
        personalInfo: kycData.personalInfo,
        documents: state.documents,
        address: kycData.address,
      );
    } catch (e) {
      return null;
    }
  }

  // ===== KYC HISTORY =====

  /// Get KYC history
  Future<List<Map<String, dynamic>>> getKYCHistory() async {
    try {
      final kycRepository = ref.read(kycRepositoryProvider);
      final response = await kycRepository.getKYCHistory();

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw AppException.serverError(
          response.message ?? 'Failed to load KYC history',
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

  /// Check if document type is uploaded
  bool isDocumentUploaded(String documentType) {
    return state.documents.any((doc) => doc.type == documentType);
  }

  /// Get document by type
  KYCDocument? getDocumentByType(String documentType) {
    try {
      return state.documents.firstWhere((doc) => doc.type == documentType);
    } catch (e) {
      return null;
    }
  }

  /// Get upload progress for document type
  double getUploadProgress(String documentType) {
    return state.uploadProgress[documentType] ?? 0.0;
  }

  /// Force refresh all KYC data
  Future<void> refresh() async {
    await loadKYCStatus(forceRefresh: true);
  }
}

// ============================================================================
// ADDITIONAL PROVIDERS
// ============================================================================

/// Provider for KYC status
@riverpod
String kycStatus(Ref ref) {
  return ref.watch(kYCProvider.select((state) => state.kycStatus));
}

/// Provider for KYC verification status
@riverpod
bool isKYCVerified(Ref ref) {
  return ref.watch(kYCProvider.select((state) => state.isKYCVerified));
}

/// Provider for KYC completion percentage
@riverpod
double kycCompletionPercentage(Ref ref) {
  return ref.watch(kYCProvider.select((state) => state.completionPercentage));
}

/// Provider for KYC loading state
@riverpod
bool isKYCLoading(Ref ref) {
  return ref.watch(kYCProvider.select((state) => state.isLoading));
}

/// Provider for KYC error
@riverpod
String? kycError(Ref ref) {
  return ref.watch(kYCProvider.select((state) => state.error));
}

/// Provider for KYC documents
@riverpod
List<KYCDocument> kycDocuments(Ref ref) {
  return ref.watch(kYCProvider.select((state) => state.documents));
}

/// Provider for missing documents
@riverpod
List<String> missingKYCDocuments(Ref ref) {
  return ref.watch(kYCProvider.select((state) => state.missingDocuments));
}

/// Provider for checking if KYC can be submitted
@riverpod
bool canSubmitKYC(Ref ref) {
  return ref.watch(kYCProvider.select((state) => state.canSubmitKYC));
}
