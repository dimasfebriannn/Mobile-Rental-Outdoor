import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../home/home_screen.dart';

class RegisterOtpScreen extends StatefulWidget {
  final String email;
  final String name;
  final String password;

  const RegisterOtpScreen({
    super.key,
    required this.email,
    required this.name,
    required this.password,
  });

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen>
    with SingleTickerProviderStateMixin {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  final Color creamBg = const Color(0xFFF5EFE6);
  final Color darkBrown = const Color(0xFF3E2723);
  final Color goldenYellow = const Color(0xFFE5A93D);

  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // --- LOGIC VERIFIKASI ---
  Future<void> _handleVerify() async {
    if (_otpController.text.length < 6) {
      _showError("Masukkan 6 digit kode OTP.");
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulasi API
    if (!mounted) return;
    setState(() => _isLoading = false);
    _showSuccessPopup();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700, behavior: SnackBarBehavior.floating),
    );
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.verified_user_rounded, color: Colors.green, size: 50),
              ),
              const SizedBox(height: 24),
              Text("EMAIL TERVERIFIKASI", style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
              const SizedBox(height: 12),
              Text("Selamat bergabung, ${widget.name}! Akun Anda telah aktif.", textAlign: TextAlign.center, style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 13, height: 1.5)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: darkBrown, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0),
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false),
                  child: const Text("MULAI PETUALANGAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
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
          // ── 1. GLASSMORPHISM BACKGROUND ACCENTS ──────────────────
          
          // Bulatan Emas di Kiri Atas
          _buildGlassCircle(top: -50, left: -50, size: 200, color: goldenYellow.withOpacity(0.15)),
          
          // Bulatan Coklat di Kanan Tengah
          _buildGlassCircle(top: size.height * 0.3, right: -80, size: 250, color: darkBrown.withOpacity(0.05)),

          // ── 2. HEADER SECTION ───────────────────────────────────
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
                          color: Colors.white.withOpacity(0.5), // Semi transparan
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: darkBrown.withOpacity(0.1)),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded, color: darkBrown, size: 18),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text('Verifikasi', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: darkBrown, letterSpacing: -1)),
                    Text('Email Anda.', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: goldenYellow, height: 1.0, letterSpacing: -1.5)),
                    const SizedBox(height: 12),
                    Text('Kami telah mengirimkan kode OTP ke:', style: TextStyle(fontSize: 13, color: darkBrown.withOpacity(0.5))),
                    Text(widget.email, style: TextStyle(fontSize: 14, color: darkBrown, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
          ),

          // ── 3. OTP FORM SHEET ────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: size.height * 0.55,
            child: FadeTransition(
              opacity: _fade,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9), // Glassy effect on sheet
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: [BoxShadow(color: darkBrown.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -5))],
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 40, 32, 24),
                      child: Column(
                        children: [
                          Container(width: 40, height: 4, decoration: BoxDecoration(color: darkBrown.withOpacity(0.05), borderRadius: BorderRadius.circular(10))),
                          const SizedBox(height: 32),
                          Text("MASUKKAN KODE OTP", style: TextStyle(color: darkBrown.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                          const SizedBox(height: 20),
                          _buildOTPField(),
                          const SizedBox(height: 40),
                          _buildVerifyButton(),
                          const Spacer(),
                          Text("Tidak menerima kode?", style: TextStyle(color: darkBrown.withOpacity(0.4), fontSize: 12)),
                          TextButton(
                            onPressed: () {}, 
                            child: Text("Kirim Ulang Kode", style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 13)),
                          ),
                        ],
                      ),
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

  // --- HELPER WIDGETS ---

  Widget _buildGlassCircle({double? top, double? left, double? right, double? bottom, required double size, required Color color}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }

  Widget _buildOTPField() {
    return TextField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      maxLength: 6,
      textAlign: TextAlign.center,
      style: TextStyle(color: darkBrown, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 15),
      decoration: InputDecoration(
        counterText: "",
        filled: true,
        fillColor: creamBg.withOpacity(0.4),
        hintText: "000000",
        hintStyle: TextStyle(color: darkBrown.withOpacity(0.1)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleVerify,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBrown, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
          elevation: 0
        ),
        child: _isLoading 
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text('VERIFIKASI SEKARANG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }
}