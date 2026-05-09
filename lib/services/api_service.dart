// lib/services/api_service.dart
//
// Singleton HTTP client yang dipakai oleh AuthService DAN ProfileService.
// Token disimpan dan dibaca di satu tempat (SharedPreferences key: 'auth_token'),
// sehingga setiap login/logout otomatis dipakai oleh seluruh service.
//
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // ── Token key — harus konsisten di seluruh app ────────
  static const _tokenKey = 'auth_token';

  // ── Dio instance dengan interceptor otomatis ──────────
  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl:        ApiConfig.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
      headers:        {'Accept': 'application/json'},
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Sisipkan Bearer token ke setiap request secara otomatis
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

  // ─────────────────────────────────────────────────────
  // Token helpers
  // ─────────────────────────────────────────────────────
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

  // Dipanggil di main.dart — Dio sudah siap via lazy init, method ini
  // hanya untuk kompatibilitas agar tidak perlu ubah main.dart.
  void init() {
    // Dio sudah diinisialisasi secara lazy di deklarasi _dio di atas.
    // Tidak ada yang perlu dilakukan di sini.
  }

  // Cek apakah user sedang login (ada token tersimpan)
  Future<bool> get isLoggedIn async => (await _readToken()) != null;

  // ─────────────────────────────────────────────────────
  // HTTP Methods
  // ─────────────────────────────────────────────────────

  /// GET /api/[endpoint]
  Future<Response> get(String endpoint, {Map<String, dynamic>? params}) {
    return _dio.get(endpoint, queryParameters: params);
  }

  /// POST /api/[endpoint]
  Future<Response> post(String endpoint, [dynamic data]) {
    return _dio.post(endpoint, data: data);
  }

  /// PUT /api/[endpoint]
  Future<Response> put(String endpoint, [dynamic data]) {
    return _dio.put(endpoint, data: data);
  }

  /// PATCH /api/[endpoint]
  Future<Response> patch(String endpoint, [dynamic data]) {
    return _dio.patch(endpoint, data: data);
  }

  /// DELETE /api/[endpoint]
  Future<Response> delete(String endpoint) {
    return _dio.delete(endpoint);
  }
}