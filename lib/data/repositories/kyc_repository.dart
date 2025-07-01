import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../models/kyc/kyc_model.dart';
import '../models/kyc/kyc_document.dart';
import '../models/common/api_response.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';

final kycRepositoryProvider = Provider<KYCRepository>((ref) {
  return KYCRepository(ref.read(apiServiceProvider));
});

class KYCRepository {
  final ApiService _apiService;
  static const String _kycCacheKey = 'kyc_data';

  KYCRepository(this._apiService);

  Future<ApiResponse<KYCModel>> getKYCStatus() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.kycStatus,
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<KYCModel>.fromJson(
          response.data!,
          (json) => KYCModel.fromJson(json as Map<String, dynamic>),
        );

        // Cache KYC data locally
        if (apiResponse.success && apiResponse.data != null) {
          await StorageService.setCachedData(
            _kycCacheKey,
            apiResponse.data!.toJson(),
          );
        }

        return apiResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      // Try to return cached data if network fails
      final cachedData = await StorageService.getCachedData(_kycCacheKey);
      if (cachedData != null) {
        return ApiResponse<KYCModel>(
          success: true,
          data: KYCModel.fromJson(cachedData),
          timestamp: DateTime.now(),
          message: 'Loaded from cache',
        );
      }
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<String>> uploadDocument({
    required File file,
    required String documentType,
    String? documentNumber,
    DateTime? expiryDate,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'documentType': documentType,
        if (documentNumber != null) 'documentNumber': documentNumber,
        if (expiryDate != null) 'expiryDate': expiryDate.toIso8601String(),
      });

      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.kycUpload,
        data: formData,
      );

      if (response.data != null) {
        return ApiResponse<String>.fromJson(
          response.data!,
          (json) => json.toString(),
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<KYCModel>> submitKYC(KYCSubmission submission) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.kycSubmit,
        data: submission.toJson(),
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<KYCModel>.fromJson(
          response.data!,
          (json) => KYCModel.fromJson(json as Map<String, dynamic>),
        );

        // Update cached KYC data
        if (apiResponse.success && apiResponse.data != null) {
          await StorageService.setCachedData(
            _kycCacheKey,
            apiResponse.data!.toJson(),
          );
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

  Future<ApiResponse<List<String>>> getRequiredDocuments() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/kyc/required-documents',
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

  Future<ApiResponse<List<String>>> getSupportedDocumentTypes() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/kyc/document-types',
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

  Future<ApiResponse<void>> deleteDocument(String documentId) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        '/api/users/kyc/documents/$documentId',
      );

      if (response.data != null) {
        // Refresh KYC status after deletion
        await getKYCStatus();

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<KYCDocument>> updateDocument({
    required String documentId,
    String? documentNumber,
    DateTime? expiryDate,
    DateTime? issueDate,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (documentNumber != null) data['documentNumber'] = documentNumber;
      if (expiryDate != null) data['expiryDate'] = expiryDate.toIso8601String();
      if (issueDate != null) data['issueDate'] = issueDate.toIso8601String();

      final response = await _apiService.put<Map<String, dynamic>>(
        '/api/users/kyc/documents/$documentId',
        data: data,
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<KYCDocument>.fromJson(
          response.data!,
          (json) => KYCDocument.fromJson(json as Map<String, dynamic>),
        );

        // Refresh KYC status after update
        await getKYCStatus();

        return apiResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> resubmitKYC() async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/users/kyc/resubmit',
      );

      if (response.data != null) {
        // Refresh KYC status after resubmission
        await getKYCStatus();

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getKYCProgress() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/users/kyc/progress',
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

  Future<ApiResponse<List<String>>> getKYCGuidelines() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/kyc/guidelines',
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

  Future<KYCModel?> getCachedKYCData() async {
    try {
      final cachedData = await StorageService.getCachedData(_kycCacheKey);
      if (cachedData != null) {
        return KYCModel.fromJson(cachedData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearKYCCache() async {
    await StorageService.removeCachedData(_kycCacheKey);
  }

  Future<bool> isKYCCompleted() async {
    try {
      final kycData = await getCachedKYCData();
      return kycData?.status.toLowerCase() == 'approved';
    } catch (e) {
      return false;
    }
  }

  Future<double> getKYCCompletionPercentage() async {
    try {
      final kycData = await getCachedKYCData();
      return kycData?.completionPercentage ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}
