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
  static const String _ngrokUrl = 'https://405f-103-105-57-88.ngrok-free.app/api';
  static const String _prodUrl = 'https://api.yourdomain.com/api';

  static String get baseUrl {
    switch (_env) {
      case 'ngrok':
        return _ngrokUrl;
      case 'prod':
        return _prodUrl;
      default:
        return _localUrl;
    }
  }

  // ── Auth Endpoints ────────────────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String googleAuth = '/auth/google';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String setPassword = '/auth/set-password';

  // ── Reset Password Endpoints (3 langkah) ─────────────────────────────────
  /// Langkah 1: Kirim OTP ke email
  /// POST body: { email }
  static const String forgotPassword = '/auth/forgot-password';

  /// Langkah 2: Verifikasi OTP → dapat reset_token
  /// POST body: { email, otp }
  static const String verifyResetOtp = '/auth/verify-reset-otp';

  /// Langkah 3: Buat password baru pakai reset_token
  /// POST body: { reset_token, password, password_confirmation }
  static const String resetPassword = '/auth/reset-password';

  // ── Barang / Katalog Endpoints ────────────────────────────────────────────
  static const String barang = '/barang';
  static String barangDetail(int id) => '/barang/$id';
  static const String kategori = '/kategori';

  // ── Profile Endpoints ─────────────────────────────────────────────────────
  static const String profile = '/profile';
  static const String changePassword = '/profile/change-password';

  // ── AI Recommendation Endpoints ───────────────────────────────────────────
  static const String recommendationImage = '/recommendation/image';
  static const String recommendationHistory = '/recommendation/history';

  // ── AI Chat Assistant Endpoints ───────────────────────────────────────────
  static const String chat = '/chat';
  static const String chatHistory = '/chat/history';
  static const String chatClear = '/chat/clear';

  // ── Checkout ──────────────────────────────────────────────────────────────
  static const String checkout = '/checkout';
  static const String checkoutValidasiIdentitas =
      '/checkout/validasi-identitas';
  static const String checkoutHistory = '/checkout/history';
  static String checkoutDetail(int id) => '/checkout/$id';

  static String checkoutReopenPayment(int id) => '/checkout/$id/reopen-payment';

  static String checkoutBayarDenda(int id) => '/checkout/$id/bayar-denda';

  static String checkoutDetailLengkap(int id) => '/checkout/$id/detail-lengkap';
  // ── Dio settings ──────────────────────────────────────────────────────────
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 60000;
}
