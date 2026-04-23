import '../models/registered_user.dart';

class AuthService {
  AuthService._();

  static final Map<String, RegisteredUser> _users = {
    'demo@majelis.id': RegisteredUser(
      fullName: 'Demo User',
      email: 'demo@majelis.id',
      password: 'password123',
      phone: '+62 812 3456 7890',
      address: 'Jl. Demo No. 1, Bandung',
    ),
  };

  static RegisteredUser? login(String email, String password) {
    final user = _users[email.toLowerCase().trim()];
    if (user == null) return null;
    if (user.password != password) return null;
    return user;
  }

  static String? register(RegisteredUser newUser, String confirmPassword) {
    final email = newUser.email.toLowerCase().trim();
    if (newUser.fullName.trim().isEmpty) {
      return 'Nama lengkap harus diisi.';
    }
    if (email.isEmpty || !email.contains('@')) {
      return 'Email tidak valid.';
    }
    if (newUser.phone.trim().isEmpty) {
      return 'Nomor telepon harus diisi.';
    }
    if (newUser.address.trim().isEmpty) {
      return 'Alamat lengkap harus diisi.';
    }
    if (newUser.password.length < 6) {
      return 'Kata sandi minimal 6 karakter.';
    }
    if (newUser.password != confirmPassword) {
      return 'Konfirmasi kata sandi tidak cocok.';
    }
    if (_users.containsKey(email)) {
      return 'Email sudah terdaftar. Silakan login.';
    }
    _users[email] = RegisteredUser(
      fullName: newUser.fullName.trim(),
      email: email,
      password: newUser.password,
      phone: newUser.phone.trim(),
      address: newUser.address.trim(),
    );
    return null;
  }
}
