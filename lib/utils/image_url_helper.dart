// lib/utils/image_url_helper.dart
//
// Utility untuk memperbaiki URL gambar yang masih menggunakan
// 127.0.0.1 atau localhost (hasil dari asset() PHP saat APP_URL lokal).
// Ganti base URL ke ApiConfig.baseUrl agar bisa diakses dari device/emulator.

import '../config/api_config.dart';

class ImageUrlHelper {
  ImageUrlHelper._();

  /// Ganti http://127.0.0.1:PORT atau http://localhost:PORT
  /// dengan base URL aktif dari ApiConfig (ngrok / produksi).
  static String fix(String? raw) {
    if (raw == null || raw.isEmpty) return '';

    // Hilangkan trailing '/api' dari baseUrl agar dapat base domain saja
    // Contoh: 'https://abc.ngrok-free.app/api' → 'https://abc.ngrok-free.app'
    final appBase = ApiConfig.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');

    return raw.replaceFirst(
      RegExp(r'https?://(127\.0\.0\.1|localhost)(:\d+)?'),
      appBase,
    );
  }
}