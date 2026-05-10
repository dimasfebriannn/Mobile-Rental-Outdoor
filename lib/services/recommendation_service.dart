// lib/services/recommendation_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/recommendation.dart';
import 'api_service.dart';

class RecommendationService {
  RecommendationService._();
  static final RecommendationService instance = RecommendationService._();

  /// Upload gambar ke Laravel dan terima hasil rekomendasi AI.
  ///
  /// [imageFile] : File gambar dari image_picker.
  ///
  /// Throw [RecommendationException] jika terjadi error.
  Future<RecommendationResult> analyzeImage(File imageFile) async {
    final fileName  = imageFile.path.split('/').last;
    final mimeType  = _detectMimeType(fileName);

    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: DioMediaType.parse(mimeType),
      ),
    });

    try {
      final response = await ApiService.instance.postMultipart(
        ApiConfig.recommendationImage,
        formData,
      );

      final body = response.data as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        return RecommendationResult.fromJson(body);
      }

      throw RecommendationException(
        body['message'] as String? ?? 'Terjadi kesalahan.',
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] as String?;
      throw RecommendationException(
        msg ?? _dioErrorMessage(e),
      );
    }
  }

  String _detectMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png'           => 'image/png',
      'webp'          => 'image/webp',
      'heic'          => 'image/heic',
      _               => 'image/jpeg',
    };
  }

  String _dioErrorMessage(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout => 'Koneksi timeout. Coba lagi.',
      DioExceptionType.receiveTimeout    => 'AI sedang sibuk. Coba lagi.',
      DioExceptionType.connectionError   => 'Tidak ada koneksi internet.',
      _                                  => 'Terjadi kesalahan jaringan.',
    };
  }
}

class RecommendationException implements Exception {
  final String message;
  const RecommendationException(this.message);

  @override
  String toString() => message;
}