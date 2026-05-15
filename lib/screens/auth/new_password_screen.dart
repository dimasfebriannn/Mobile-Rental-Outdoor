// lib/screens/auth/new_password_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/custom_textfield.dart';
import '../../services/auth_service.dart';

class NewPasswordScreen extends StatefulWidget {
  /// Token dari OtpVerificationScreen — hasil verifyResetOtp()
  final String resetToken;

  const NewPasswordScreen({super.key, required this.resetToken});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _passController    = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  // ── Warna signature ───────────────────────────────────────────────────────
  final Color creamBg      = const Color(0xFFF5EFE6);
  final Color darkBrown    = const Color(0xFF3E2723);
  final Color goldenYellow = const Color(0xFFE5A93D);

  @override
  void dispose() {
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ── Reset password (hit API nyata) ────────────────────────────────────────
  Future<void> _handleReset() async {
    final password     = _passController.text;
    final confirmation = _confirmController.text;

    if (password.isEmpty) {
      _showSnackBar('Masukkan password baru.', Colors.red.shade700);
      return;
    }
    if (password.length < 8) {
      _showSnackBar('Password minimal 8 karakter.', Colors.red.shade700);
      return;
    }
    if (password != confirmation) {
      _showSnackBar('Konfirmasi password tidak cocok.', Colors.red.shade700);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.instance.resetPassword(
        resetToken:   widget.resetToken,
        password:     password,
        confirmation: confirmation,
      );

      if (!mounted) return;
      _showSuccessPopup();
    } catch (errorMessage) {
      if (!mounted) return;
      _showSnackBar(errorMessage.toString(), Colors.red.shade700);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Popup sukses → kembali ke login ──────────────────────────────────────
  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: goldenYellow.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.verified_user_rounded,
                        color: goldenYellow, size: 50),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'SANDI DIPERBARUI',
                    style: TextStyle(
                      color: darkBrown,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Password Anda berhasil diperbarui. Silakan login menggunakan password baru.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: darkBrown.withOpacity(0.6),
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBrown,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Kembali ke halaman pertama (login)
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      child: const Text(
                        'LOGIN SEKARANG',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // Dekorasi blob
          Positioned(
            top: size.height * 0.1,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [goldenYellow.withOpacity(0.3), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            top: -30,
            left: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: darkBrown.withOpacity(0.05),
              ),
            ),
          ),

          // Header
          _buildHeader(size),

          // Glassmorphism sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.62,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(45)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(45)),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4), width: 1.5),
                  ),
                  padding: const EdgeInsets.fromLTRB(32, 48, 32, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('KATA SANDI BARU'),
                      const SizedBox(height: 18),
                      CustomTextField(
                        hintText: 'Sandi Baru (min. 8 karakter)',
                        prefixIcon: Icons.lock_open_rounded,
                        isPassword: true,
                        controller: _passController,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        hintText: 'Konfirmasi Sandi',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        controller: _confirmController,
                      ),
                      const SizedBox(height: 40),
                      _buildButton(),
                      const Spacer(),
                      Center(
                        child: Text(
                          'MAJELIS RENTAL SECURITY',
                          style: TextStyle(
                            color: darkBrown.withOpacity(0.2),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Tombol back melayang
          Positioned(
            top: 50,
            left: 24,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: darkBrown, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: size.height * 0.4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Buat',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                color: darkBrown,
                letterSpacing: -1,
              ),
            ),
            Text(
              'Sandi Baru.',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: goldenYellow,
                height: 1.0,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Gunakan kombinasi karakter unik untuk memastikan keamanan akun Anda tetap terjaga.',
              style: TextStyle(
                fontSize: 14,
                color: darkBrown.withOpacity(0.6),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleReset,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBrown,
          disabledBackgroundColor: darkBrown.withOpacity(0.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'PERBARUI SEKARANG',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  fontSize: 13,
                ),
              ),
      ),
    );
  }

  Widget _sectionLabel(String l) => Text(
        l,
        style: TextStyle(
          color: darkBrown.withOpacity(0.4),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      );
}