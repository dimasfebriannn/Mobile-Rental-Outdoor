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
  static const String _ngrokUrl = 'https://9dfb-103-105-57-88.ngrok-free.app/api';
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
  static const String recommendationImage   = '/recommendation/image';
  static const String recommendationHistory = '/recommendation/history';

  // ── AI Chat Assistant Endpoints ───────────────────────────────────────────
  /// POST /api/chat          → kirim pesan ke AI
  static const String chat        = '/chat';

  /// GET  /api/chat/history  → ambil riwayat chat
  static const String chatHistory = '/chat/history';

  /// DELETE /api/chat/clear  → hapus riwayat chat
  static const String chatClear   = '/chat/clear';

  // ── Dio settings ──────────────────────────────────────────────────────────
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 60000;
}