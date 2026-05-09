// lib/services/profile_service.dart
//
// PENTING: Service ini sengaja menggunakan ApiService.instance (bukan Dio baru)
// supaya token yang dipakai selalu sama dengan yang disimpan saat login.
// Jika ApiService menggunakan key 'token', 'sanctum_token', dsb,
// ProfileService otomatis ikut — tidak perlu tahu key-nya.
//
import '../config/api_config.dart';
import 'api_service.dart'; // <── pakai instance yang sama dengan AuthService

// ─────────────────────────────────────────────────────────────────
// Model data profil user (kolom tabel `users`)
// ─────────────────────────────────────────────────────────────────
class UserProfile {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? alamat;
  final String? avatar;
  final String? googleId;
  final String? emailVerifiedAt;
  final bool hasPassword;
  final String role;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.alamat,
    this.avatar,
    this.googleId,
    this.emailVerifiedAt,
    required this.hasPassword,
    required this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id:              json['id'] as int,
      name:            json['name'] as String,
      email:           json['email'] as String,
      phone:           json['phone'] as String?,
      alamat:          json['alamat'] as String?,
      avatar:          json['avatar'] as String?,
      googleId:        json['google_id'] as String?,
      emailVerifiedAt: json['email_verified_at'] as String?,
      hasPassword:     json['has_password'] as bool? ?? true,
      role:            json['role'] as String? ?? 'user',
    );
  }

  bool get isEmailVerified => emailVerifiedAt != null;
  bool get isGoogleLinked  => googleId != null && googleId!.isNotEmpty;
}

// ─────────────────────────────────────────────────────────────────
// Service profil — semua request melalui ApiService.instance
// sehingga token selalu konsisten dengan sesi login aktif
// ─────────────────────────────────────────────────────────────────
class ProfileService {
  ProfileService._();

  // Gunakan instance yang SAMA dengan AuthService
  static final _api = ApiService.instance;

  // ── GET /api/profile ─────────────────────────────────
  static Future<UserProfile> getProfile() async {
    try {
      final response = await _api.get(ApiConfig.profile);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return UserProfile.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['message'] ?? 'Gagal memuat profil');
    } catch (e) {
      throw _toException(e);
    }
  }

  // ── PUT /api/profile ─────────────────────────────────
  static Future<UserProfile> updateProfile({
    required String name,
    String? phone,
    String? alamat,
  }) async {
    try {
      final response = await _api.put(ApiConfig.profile, {
        'name':   name,
        'phone':  phone,
        'alamat': alamat,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        return UserProfile.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['message'] ?? 'Gagal memperbarui profil');
    } catch (e) {
      throw _toException(e);
    }
  }

  // ── POST /api/profile/change-password ────────────────
  static Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _api.post(ApiConfig.changePassword, {
        'current_password':          currentPassword,
        'new_password':              newPassword,
        'new_password_confirmation': confirmPassword,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['message'] as String;
      }
      throw Exception(
        response.data['message'] ?? 'Gagal mengubah kata sandi',
      );
    } catch (e) {
      throw _toException(e);
    }
  }

  // ── Error normalizer ─────────────────────────────────
  static Exception _toException(Object e) {
    if (e is Exception) return e;
    try {
      // ignore: avoid_dynamic_calls
      final data = (e as dynamic).response?.data;
      if (data is Map) {
        if (data['message'] != null) return Exception(data['message']);
        if (data['errors'] != null) {
          final errors = data['errors'] as Map;
          final firstMsg = (errors.values.first as List).first;
          return Exception(firstMsg);
        }
      }
    } catch (_) {}
    return Exception('Terjadi kesalahan. Periksa koneksi Anda.');
  }
}