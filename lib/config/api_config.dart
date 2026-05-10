// lib/config/api_config.dart
// ─────────────────────────────────────────────────────────────────────────────
// Ganti _env sesuai kebutuhan:
//   'local'   → emulator Android (10.0.2.2) atau physical device (IP WiFi)
//   'ngrok'   → testing pakai ngrok tunnel
//   'prod'    → production / hosting
// ─────────────────────────────────────────────────────────────────────────────

class ApiConfig {
  ApiConfig._();

  static const String _env = 'ngrok'; // <── GANTI DI SINI

  // ── URL per environment ───────────────────────────────────────────────────
  static const String _localUrl = 'http://10.0.2.2:8000/api';
  static const String _ngrokUrl = 'https://fc53-103-105-57-88.ngrok-free.app/api';
  static const String _prodUrl  = 'https://api.yourdomain.com/api';

  static String get baseUrl {
    switch (_env) {
      case 'ngrok': return _ngrokUrl;
      case 'prod':  return _prodUrl;
      default:      return _localUrl;
    }
  }

  // ── Auth Endpoints ────────────────────────────────────────────────────────
  static const String register    = '/auth/register';
  static const String login       = '/auth/login';
  static const String googleAuth  = '/auth/google';
  static const String logout      = '/auth/logout';
  static const String me          = '/auth/me';
  static const String setPassword = '/auth/set-password';

  // ── Barang / Katalog Endpoints ────────────────────────────────────────────
  static const String barang         = '/barang';
  static String barangDetail(int id) => '/barang/$id';
  static const String kategori       = '/kategori';

  // ── Profile Endpoints ─────────────────────────────────────────────────────
  static const String profile        = '/profile';
  static const String changePassword = '/profile/change-password';

  // ── AI Recommendation Endpoints ───────────────────────────────────────────
  /// POST /api/recommendation/image  — upload gambar, terima rekomendasi
  static const String recommendationImage   = '/recommendation/image';

  /// GET  /api/recommendation/history — riwayat rekomendasi user login
  static const String recommendationHistory = '/recommendation/history';

  // ── Dio settings ──────────────────────────────────────────────────────────
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 60000; // Lebih lama untuk AI processing
}