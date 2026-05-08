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
  static const String _ngrokUrl = 'https://943c-103-105-57-88.ngrok-free.app/api';
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
  /// GET /api/barang                       → semua barang aktif
  /// GET /api/barang?search=xxx            → filter nama
  /// GET /api/barang?kategori=Tenda        → filter kategori
  /// GET /api/barang?kategori=X&search=Y   → kombinasi
  static const String barang         = '/barang';

  /// GET /api/barang/{id}                  → detail 1 barang
  static String barangDetail(int id)  => '/barang/$id';

  /// GET /api/kategori                     → list kategori (untuk pill filter)
  static const String kategori        = '/kategori';

  // ── Dio settings ──────────────────────────────────────────────────────────
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}