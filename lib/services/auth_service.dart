// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'api_service.dart';

// ─── Model untuk response auth ────────────────────────────────────────────────
class AuthResult {
  final bool success;
  final String? message;
  final Map<String, dynamic>? user;

  /// Diisi oleh server ketika user mencoba login dengan metode yang salah.
  /// Nilai: 'google' → harus pakai Google, 'email' → harus pakai email.
  final String? authProvider;

  AuthResult({
    required this.success,
    this.message,
    this.user,
    this.authProvider,
  });
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ApiService _api = ApiService.instance;

  // ───────────────────────────────────────────────────────────────────────────
  // REGISTER dengan Email & Password
  // Flow: Firebase register → Laravel API register → simpan token
  // ───────────────────────────────────────────────────────────────────────────
  Future<AuthResult> registerWithEmail({
    required String name,
    required String email,
    required String password, required String phone, required String address,
  }) async {
    try {
      // 1. Buat akun di Firebase
      final firebaseCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      await firebaseCredential.user?.updateDisplayName(name);

      // 2. Daftarkan ke Laravel MySQL
      final response = await _api.post(ApiConfig.register, {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'firebase_uid': firebaseCredential.user?.uid,
      });

      if (response.statusCode == 201) {
        final token = response.data['token'] as String;
        await _api.saveToken(token);

        return AuthResult(
          success: true,
          message: 'Registrasi berhasil!',
          user: response.data['user'] as Map<String, dynamic>?,
        );
      }

      await firebaseCredential.user?.delete();
      return AuthResult(success: false, message: 'Gagal mendaftar ke server.');
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _firebaseErrorMessage(e.code));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Koneksi ke server gagal.';
      await _firebaseAuth.currentUser?.delete();
      return AuthResult(success: false, message: msg);
    } catch (e) {
      return AuthResult(success: false, message: 'Terjadi kesalahan: $e');
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // LOGIN dengan Email & Password
  //
  // Firebase TIDAK digunakan di sini — cukup Laravel Sanctum.
  // Jika server mengembalikan auth_provider: 'google', berarti
  // akun ini harus login via Google.
  // ───────────────────────────────────────────────────────────────────────────
  Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(ApiConfig.login, {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'] as String;
        await _api.saveToken(token);

        return AuthResult(
          success: true,
          message: 'Login berhasil!',
          user: response.data['user'] as Map<String, dynamic>?,
        );
      }

      return AuthResult(success: false, message: 'Login ke server gagal.');
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data?['message'] ?? 'Koneksi ke server gagal.';
      // auth_provider: 'google' → akun ini terdaftar via Google
      final provider = data?['auth_provider'] as String?;
      return AuthResult(success: false, message: msg, authProvider: provider);
    } catch (e) {
      return AuthResult(success: false, message: 'Terjadi kesalahan: $e');
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // LOGIN dengan Google
  // Flow: Google Sign-In → Firebase → Laravel API → simpan token
  //
  // Jika server mengembalikan auth_provider: 'email', berarti
  // akun ini harus login via email & password.
  // ───────────────────────────────────────────────────────────────────────────
  Future<AuthResult> loginWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult(success: false, message: 'Login Google dibatalkan.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebaseCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = firebaseCredential.user!;

      final methods =
          await _firebaseAuth.fetchSignInMethodsForEmail(user.email!);
      final hasPasswordProvider = methods.contains('password');

      final response = await _api.post(ApiConfig.googleAuth, {
        'google_id': user.uid,
        'name': user.displayName ?? googleUser.displayName ?? '',
        'email': user.email ?? googleUser.email,
        'avatar': user.photoURL ?? googleUser.photoUrl,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'] as String;
        await _api.saveToken(token);

        final userData =
            response.data['user'] as Map<String, dynamic>? ?? {};
        userData['has_password'] = hasPasswordProvider;

        return AuthResult(
          success: true,
          message: 'Login Google berhasil!',
          user: userData,
        );
      }

      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      return AuthResult(
        success: false,
        message: 'Login Google ke server gagal.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _firebaseErrorMessage(e.code));
    } on DioException catch (e) {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      final data = e.response?.data;
      final msg = data?['message'] ?? 'Koneksi ke server gagal.';
      // auth_provider: 'email' → akun ini terdaftar via email
      final provider = data?['auth_provider'] as String?;
      return AuthResult(success: false, message: msg, authProvider: provider);
    } catch (e) {
      return AuthResult(success: false, message: 'Terjadi kesalahan: $e');
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // SET PASSWORD untuk akun Google
  // ───────────────────────────────────────────────────────────────────────────
  Future<AuthResult> setPasswordForGoogleAccount({
    required String email,
    required String password,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        return AuthResult(success: false, message: 'User belum login.');
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.linkWithCredential(credential);

      await _api.post(ApiConfig.setPassword, {
        'email': email,
        'password': password,
        'password_confirmation': password,
      });

      return AuthResult(success: true, message: 'Password berhasil dibuat.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        return AuthResult(
          success: false,
          message: 'Password sudah pernah dibuat.',
        );
      }
      if (e.code == 'credential-already-in-use') {
        return AuthResult(
          success: false,
          message: 'Password sudah digunakan.',
        );
      }
      return AuthResult(success: false, message: _firebaseErrorMessage(e.code));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Server gagal.';
      return AuthResult(success: false, message: msg);
    } catch (e) {
      return AuthResult(success: false, message: 'Terjadi kesalahan: $e');
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // LOGOUT
  // ───────────────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _api.delete(ApiConfig.logout);
    } catch (_) {}
    await _api.clearToken();
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RESET PASSWORD — 3 Langkah
  // ═══════════════════════════════════════════════════════════════════════════

  // ── Langkah 1: Kirim OTP ke email ─────────────────────────────────────────
  ///
  /// Lempar [String] pesan error jika email tidak terdaftar atau koneksi gagal.
  Future<void> forgotPassword(String email) async {
    try {
      await _api.post(ApiConfig.forgotPassword, {'email': email});
    } on DioException catch (e) {
      throw _parseDioError(e);
    }
  }

  // ── Langkah 2: Verifikasi OTP ─────────────────────────────────────────────
  ///
  /// Mengembalikan [resetToken] yang dipakai di langkah 3.
  /// Lempar [String] pesan error jika OTP salah / kedaluwarsa.
  Future<String> verifyResetOtp(String email, String otp) async {
    try {
      final response = await _api.post(ApiConfig.verifyResetOtp, {
        'email': email,
        'otp': otp,
      });

      final data = response.data as Map<String, dynamic>;
      final token = data['reset_token'] as String?;

      if (token == null || token.isEmpty) {
        throw 'Server tidak mengembalikan token. Coba lagi.';
      }

      return token;
    } on DioException catch (e) {
      throw _parseDioError(e);
    }
  }

  // ── Langkah 3: Reset Password ─────────────────────────────────────────────
  ///
  /// [resetToken]   → dari verifyResetOtp()
  /// [password]     → password baru (min. 8 karakter)
  /// [confirmation] → harus sama dengan [password]
  Future<void> resetPassword({
    required String resetToken,
    required String password,
    required String confirmation,
  }) async {
    try {
      await _api.post(ApiConfig.resetPassword, {
        'reset_token': resetToken,
        'password': password,
        'password_confirmation': confirmation,
      });
    } on DioException catch (e) {
      throw _parseDioError(e);
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Helper: parse DioException → pesan error dalam Bahasa Indonesia
  // Dipakai khusus oleh metode reset password (yang melempar String error).
  // ───────────────────────────────────────────────────────────────────────────
  String _parseDioError(DioException e) {
    final data = e.response?.data;

    if (data is Map) {
      // Laravel validation errors → ambil pesan pertama dari errors map
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) {
          return first.first.toString();
        }
      }
      // Pesan langsung dari server
      if (data['message'] != null) {
        return data['message'].toString();
      }
    }

    // Fallback berdasarkan status HTTP
    switch (e.response?.statusCode) {
      case 401:
        return 'Sesi habis. Silakan login kembali.';
      case 403:
        return 'Anda tidak memiliki akses.';
      case 404:
        return 'Data tidak ditemukan.';
      case 422:
        return 'Data yang dikirim tidak valid.';
      case 500:
        return 'Terjadi kesalahan pada server. Coba beberapa saat lagi.';
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          return 'Koneksi timeout. Periksa jaringan Anda.';
        }
        if (e.type == DioExceptionType.connectionError) {
          return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
        }
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Helper: terjemahkan kode error Firebase ke Bahasa Indonesia
  // ───────────────────────────────────────────────────────────────────────────
  String _firebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak terdaftar.';
      case 'wrong-password':
        return 'Kata sandi salah.';
      case 'email-already-in-use':
        return 'Email sudah digunakan. Silakan login.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah (min. 6 karakter).';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'invalid-credential':
        return 'Email atau kata sandi salah.';
      default:
        return 'Terjadi kesalahan autentikasi ($code).';
    }
  }
}