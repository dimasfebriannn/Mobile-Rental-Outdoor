// lib/services/api_service.dart
//
// Singleton HTTP client yang dipakai oleh AuthService, ProfileService,
// dan RecommendationService.
//
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static const _tokenKey = 'auth_token';

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl:        ApiConfig.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConfig.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeout),
      headers:        {'Accept': 'application/json'},
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );

  // ── Token helpers ─────────────────────────────────────────────────────────
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<String?> _readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  void init() {}

  Future<bool> get isLoggedIn async => (await _readToken()) != null;

  // ── HTTP Methods ──────────────────────────────────────────────────────────

  Future<Response> get(String endpoint, {Map<String, dynamic>? params}) {
    return _dio.get(endpoint, queryParameters: params);
  }

  Future<Response> post(String endpoint, [dynamic data]) {
    return _dio.post(endpoint, data: data);
  }

  Future<Response> put(String endpoint, [dynamic data]) {
    return _dio.put(endpoint, data: data);
  }

  Future<Response> patch(String endpoint, [dynamic data]) {
    return _dio.patch(endpoint, data: data);
  }

  Future<Response> delete(String endpoint) {
    return _dio.delete(endpoint);
  }

  /// POST multipart/form-data — untuk upload gambar ke AI recommendation.
  Future<Response> postMultipart(String endpoint, FormData formData) {
    return _dio.post(
      endpoint,
      data:    formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Accept':       'application/json',
        },
        // Timeout lebih lama untuk proses AI
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
  }
}