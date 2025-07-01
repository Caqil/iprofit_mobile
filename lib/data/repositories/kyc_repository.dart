import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/kyc/kyc_model.dart';
import '../models/kyc/kyc_document.dart';
import '../models/common/api_response.dart';
import '../services/storage_service.dart';

final kycRepositoryProvider = Provider<KYCRepository>((ref) {
  return KYCRepository(ref.read(apiClientProvider));
});

class KYCRepository {
  final ApiClient _apiClient;
  static const String _cacheKey = 'kyc_status';
  static const Duration _cacheExpiry = Duration(minutes: 30);

  KYCRepository(this._apiClient);

  /// Get KYC status
  Future<ApiResponse<KYCModel>> getKYCStatus({
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedKYCData();
        if (cached != null) {
          return ApiResponse<KYCModel>(
            success: true,
            data: cached,
            message: 'KYC status loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.kycStatus,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<KYCModel>.fromJson(
          response.data!,
          (json) => KYCModel.fromJson(json as Map<String, dynamic>),
        );

        // Cache the result
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheKYCData(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch KYC status');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Upload KYC document
  Future<ApiResponse<KYCDocument>> uploadDocument({
    required String documentType,
    required String filePath,
    String? documentNumber,
    DateTime? expiryDate,
    DateTime? issueDate,
  }) async {
    try {
      final formData = FormData.fromMap({
        'documentType': documentType,
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
        if (documentNumber != null) 'documentNumber': documentNumber,
        if (expiryDate != null)
          'expiryDate': expiryDate.toIso8601String().split('T')[0],
        if (issueDate != null)
          'issueDate': issueDate.toIso8601String().split('T')[0],
      });

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.kycUpload,
        data: formData,
      );

      if (response.statusCode == ApiConstants.statusCreated) {
        final apiResponse = ApiResponse<KYCDocument>.fromJson(
          response.data!,
          (json) => KYCDocument.fromJson(json as Map<String, dynamic>),
        );

        // Invalidate cache after upload
        await _clearKYCCache();

        return apiResponse;
      }

      throw AppException.serverError('Document upload failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Submit KYC application
  Future<ApiResponse<KYCModel>> submitKYC(KYCSubmission submission) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.kycSubmit,
        data: submission.toJson(),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<KYCModel>.fromJson(
          response.data!,
          (json) => KYCModel.fromJson(json as Map<String, dynamic>),
        );

        // Update cache with new data
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheKYCData(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('KYC submission failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get KYC documents
  Future<ApiResponse<List<KYCDocument>>> getKYCDocuments({
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.kycDocuments,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<List<KYCDocument>>.fromJson(
          response.data!,
          (json) => (json as List)
              .map((item) => KYCDocument.fromJson(item as Map<String, dynamic>))
              .toList(),
        );
      }

      throw AppException.serverError('Failed to fetch KYC documents');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get KYC history
  Future<ApiResponse<List<Map<String, dynamic>>>> getKYCHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getPaginatedEndpoint(
          ApiConstants.kycHistory,
          page: page,
          limit: limit,
        ),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<List<Map<String, dynamic>>>.fromJson(
          response.data!,
          (json) => (json as List)
              .map((item) => item as Map<String, dynamic>)
              .toList(),
        );
      }

      throw AppException.serverError('Failed to fetch KYC history');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Delete KYC document
  Future<ApiResponse<void>> deleteDocument(String documentId) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '${ApiConstants.kycDocuments}/$documentId',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        // Invalidate cache after deletion
        await _clearKYCCache();

        return ApiResponse<void>.fromJson(response.data!, (json) {});
      }

      throw AppException.serverError('Failed to delete document');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get KYC requirements
  Future<ApiResponse<Map<String, dynamic>>> getKYCRequirements() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.kycStatus}/requirements',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw AppException.serverError('Failed to fetch KYC requirements');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Check document verification status
  Future<ApiResponse<Map<String, dynamic>>> checkDocumentStatus(
    String documentId,
  ) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.kycDocuments}/$documentId/status',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw AppException.serverError('Failed to check document status');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Resubmit rejected document
  Future<ApiResponse<KYCDocument>> resubmitDocument({
    required String documentId,
    required String filePath,
    String? documentNumber,
    DateTime? expiryDate,
    DateTime? issueDate,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
        if (documentNumber != null) 'documentNumber': documentNumber,
        if (expiryDate != null)
          'expiryDate': expiryDate.toIso8601String().split('T')[0],
        if (issueDate != null)
          'issueDate': issueDate.toIso8601String().split('T')[0],
      });

      final response = await _apiClient.put<Map<String, dynamic>>(
        '${ApiConstants.kycDocuments}/$documentId',
        data: formData,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<KYCDocument>.fromJson(
          response.data!,
          (json) => KYCDocument.fromJson(json as Map<String, dynamic>),
        );

        // Invalidate cache after resubmission
        await _clearKYCCache();

        return apiResponse;
      }

      throw AppException.serverError('Document resubmission failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Cache management methods
  Future<void> _cacheKYCData(KYCModel kycData) async {
    await StorageService.setCachedData(_cacheKey, {
      'data': kycData.toJson(),
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<KYCModel?> _getCachedKYCData() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKey,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return KYCModel.fromJson(cached['data'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _clearKYCCache() async {
    await StorageService.removeCachedData(_cacheKey);
  }

  /// Clear all KYC cache
  Future<void> clearKYCCache() async {
    await _clearKYCCache();
  }

  /// Get cached KYC data (for offline mode)
  Future<KYCModel?> getCachedKYC() async {
    return await _getCachedKYCData();
  }

  /// Validate document before upload
  bool validateDocument({
    required String filePath,
    required String documentType,
    int maxFileSize = 10 * 1024 * 1024, // 10MB
  }) {
    try {
      // Check file extension
      final extension = filePath.split('.').last.toLowerCase();
      final allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];

      if (!allowedExtensions.contains(extension)) {
        return false;
      }

      // Additional validation can be added here
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get KYC completion percentage
  double getCompletionPercentage(KYCModel kycData) {
    return kycData.completionPercentage;
  }

  /// Check if KYC is completed
  bool isKYCCompleted(KYCModel kycData) {
    return kycData.status.toLowerCase() == 'approved';
  }

  /// Get next KYC steps
  List<String> getNextSteps(KYCModel kycData) {
    return kycData.nextSteps;
  }

  /// Get missing documents
  List<String> getMissingDocuments(KYCModel kycData) {
    return kycData.missingDocuments;
  }
}
