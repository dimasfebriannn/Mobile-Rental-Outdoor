import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/custom_textfield.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  // ── Colors ────────────────────────────────────────────
  final Color creamBg = const Color(0xFFF5EFE6);
  final Color darkBrown = const Color(0xFF3E2723);
  final Color goldenYellow = const Color(0xFFE5A93D);

  // ── Animations ────────────────────────────────────────
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _sheetSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _sheetSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Logic ─────────────────────────────────────────────
  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Masukkan email Anda terlebih dahulu.');
      return;
    }

    setState(() => _isLoading = true);

    // Simulasi hit API (sesuaikan dengan AuthService Anda nanti)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    _showSuccessPopup();
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: goldenYellow.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mark_email_read_rounded, color: goldenYellow, size: 50),
              ),
              const SizedBox(height: 24),
              Text(
                "EMAIL TERKIRIM",
                style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5),
              ),
              const SizedBox(height: 16),
              Text(
                "Kami telah mengirimkan instruksi pengaturan ulang kata sandi ke email Anda.",
                textAlign: TextAlign.center,
                style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBrown,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Tutup dialog
                    Navigator.pop(context); // Kembali ke Login
                  },
                  child: const Text("KEMBALI KE LOGIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                ),
              ),
            ],
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
          // ── Background Decor ──────────────────
          Positioned(
            top: -30, left: -30,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle, color: goldenYellow.withOpacity(0.1)),
            ),
          ),

          // ── Header ────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: size.height * 0.4,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: darkBrown.withOpacity(0.1)),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded, color: darkBrown, size: 18),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Lupa',
                      style: TextStyle(fontSize: 38, fontWeight: FontWeight.w300, color: darkBrown, letterSpacing: -1),
                    ),
                    Text(
                      'Kata Sandi.',
                      style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: goldenYellow, height: 1.0, letterSpacing: -1.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Jangan khawatir, masukkan email Anda untuk mengatur ulang sandi.',
                      style: TextStyle(fontSize: 14, color: darkBrown.withOpacity(0.5), fontWeight: FontWeight.w500, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Form Sheet ────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: size.height * 0.5,
            child: SlideTransition(
              position: _sheetSlide,
              child: FadeTransition(
                opacity: _fade,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                    boxShadow: [BoxShadow(color: darkBrown.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -5))],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 40, 32, 24),
                    child: Column(
                      children: [
                        CustomTextField(
                          hintText: 'Masukkan Email Terdaftar',
                          prefixIcon: Icons.alternate_email_rounded,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleResetPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkBrown,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text(
                                    'KIRIM KODE OTP',
                                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                                  ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Ingat kata sandi?',
                          style: TextStyle(color: darkBrown.withOpacity(0.4), fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Kembali ke Login',
                            style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}