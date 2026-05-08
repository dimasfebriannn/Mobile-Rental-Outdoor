// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'api_service.dart';

// ─── Model untuk response auth ────────────────────────
class AuthResult {
  final bool success;
  final String? message;
  final Map<String, dynamic>? user;

  AuthResult({required this.success, this.message, this.user});
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ApiService _api = ApiService.instance;

  // ─────────────────────────────────────────────────────
  // REGISTER dengan Email & Password
  // Flow: Firebase register → Laravel API register → simpan token
  // ─────────────────────────────────────────────────────
  Future<AuthResult> registerWithEmail({
    required String name,
    required String email,
    required String password,
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
        // 3. Simpan Sanctum token
        final token = response.data['token'] as String;
        await _api.saveToken(token);

        return AuthResult(
          success: true,
          message: 'Registrasi berhasil!',
          user: response.data['user'] as Map<String, dynamic>?,
        );
      }

      // Jika Laravel gagal, hapus akun Firebase yang terlanjur dibuat
      await firebaseCredential.user?.delete();
      return AuthResult(success: false, message: 'Gagal mendaftar ke server.');
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _firebaseErrorMessage(e.code));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Koneksi ke server gagal.';
      // Hapus akun Firebase jika API Laravel gagal
      await _firebaseAuth.currentUser?.delete();
      return AuthResult(success: false, message: msg);
    } catch (e) {
      return AuthResult(success: false, message: 'Terjadi kesalahan: $e');
    }
  }

  // ─────────────────────────────────────────────────────
  // LOGIN dengan Email & Password
  // Flow: Firebase login → Laravel API login → simpan token
  // ─────────────────────────────────────────────────────
  Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('LOGIN START');

      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('REQUEST TO API');

      final response = await _api.post(ApiConfig.login, {
        'email': email,
        'password': password,
      });

      print(response.data);

      if (response.statusCode == 200) {
        final token = response.data['token'] as String;
        await _api.saveToken(token);

        return AuthResult(
          success: true,
          message: 'Login berhasil!',
          user: response.data['user'] as Map<String, dynamic>?,
        );
      }

      await _firebaseAuth.signOut();
      return AuthResult(success: false, message: 'Login ke server gagal.');
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _firebaseErrorMessage(e.code));
    } on DioException catch (e) {
      await _firebaseAuth.signOut();
      final msg = e.response?.data?['message'] ?? 'Koneksi ke server gagal.';
      return AuthResult(success: false, message: msg);
    } catch (e) {
      print('========================');
      print('GOOGLE LOGIN ERROR');
      print(e);
      print('========================');

      return AuthResult(success: false, message: 'Terjadi kesalahan: $e');
    }
  }

  // ─────────────────────────────────────────────────────
  // LOGIN dengan Google
  // Flow: Google Sign-In → Firebase → Laravel API → simpan token
  // ─────────────────────────────────────────────────────
  Future<AuthResult> loginWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      // 1. Trigger Google Sign-In popup
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult(success: false, message: 'Login Google dibatalkan.');
      }

      // 2. Dapatkan auth tokens Google
      final googleAuth = await googleUser.authentication;

      // 3. Buat Firebase credential dari token Google
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in ke Firebase dengan credential Google
      final firebaseCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = firebaseCredential.user!;

      // Cek apakah akun Google sudah punya provider password
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(
        user.email!,
      );

      final hasPasswordProvider = methods.contains('password');

      // 5. Kirim data Google user ke Laravel untuk disimpan/diperbarui di MySQL
      final response = await _api.post(ApiConfig.googleAuth, {
        'google_id': user.uid, // Firebase UID (juga Google UID)
        'name': user.displayName ?? googleUser.displayName ?? '',
        'email': user.email ?? googleUser.email,
        'avatar': user.photoURL ?? googleUser.photoUrl,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'] as String;
        await _api.saveToken(token);

        final userData = response.data['user'] as Map<String, dynamic>? ?? {};

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
      final msg = e.response?.data?['message'] ?? 'Koneksi ke server gagal.';
      return AuthResult(success: false, message: msg);
    } catch (e) {
      return AuthResult(success: false, message: 'Terjadi kesalahan: $e');
    }
  }

  // ─────────────────────────────────────────────────────
  // SET PASSWORD untuk akun Google
  // ─────────────────────────────────────────────────────
  Future<AuthResult> setPasswordForGoogleAccount({
    required String email,
    required String password,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        return AuthResult(success: false, message: 'User belum login.');
      }

      // Tambahkan provider password ke akun Firebase
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.linkWithCredential(credential);

      // Simpan password ke Laravel
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
        return AuthResult(success: false, message: 'Password sudah digunakan.');
      }

      return AuthResult(success: false, message: _firebaseErrorMessage(e.code));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Server gagal.';
      return AuthResult(success: false, message: msg);
    } catch (e) {
      return AuthResult(success: false, message: 'Terjadi kesalahan: $e');
    }
  }

  // ─────────────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _api.delete(ApiConfig.logout); // revoke token di Laravel
    } catch (_) {}
    await _api.clearToken();
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  // ─────────────────────────────────────────────────────
  // Helper: terjemahkan kode error Firebase ke Bahasa Indonesia
  // ─────────────────────────────────────────────────────
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
