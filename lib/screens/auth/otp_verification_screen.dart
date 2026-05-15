// lib/screens/auth/otp_verification_screen.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import 'new_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  /// Email yang dikirim dari ForgotPasswordScreen
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  // ── Countdown kirim ulang (60 detik) ─────────────────────────────────────
  int _secondsLeft = 60;
  Timer? _resendTimer;

  // ── Warna signature ───────────────────────────────────────────────────────
  final Color creamBg      = const Color(0xFFF5EFE6);
  final Color darkBrown    = const Color(0xFF3E2723);
  final Color goldenYellow = const Color(0xFFE5A93D);

  late AnimationController _controller;
  late Animation<Offset> _sheetSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _sheetSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo),
    );
    _controller.forward();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otpController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // ── Countdown ─────────────────────────────────────────────────────────────
  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _secondsLeft = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  // ── Kirim ulang OTP ───────────────────────────────────────────────────────
  Future<void> _handleResend() async {
    if (_secondsLeft > 0 || _isResending) return;

    setState(() => _isResending = true);

    try {
      await AuthService.instance.forgotPassword(widget.email);
      if (!mounted) return;
      _showSnackBar('Kode OTP baru telah dikirim.', goldenYellow);
      _startResendCountdown();
      _otpController.clear();
    } catch (errorMessage) {
      if (!mounted) return;
      _showSnackBar(errorMessage.toString(), Colors.red.shade700);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  // ── Verifikasi OTP ────────────────────────────────────────────────────────
  Future<void> _handleVerify() async {
    final otp = _otpController.text.trim();

    if (otp.length < 6) {
      _showSnackBar('Masukkan 6 digit kode OTP.', Colors.red.shade700);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final resetToken =
          await AuthService.instance.verifyResetOtp(widget.email, otp);

      if (!mounted) return;

      // Navigasi ke halaman buat password baru
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NewPasswordScreen(resetToken: resetToken),
        ),
      );
    } catch (errorMessage) {
      if (!mounted) return;
      _showSnackBar(errorMessage.toString(), Colors.red.shade700);
      _otpController.clear();
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          _buildBackgroundDecor(),
          _buildHeader(size),

          // Glassmorphism sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.60,
            child: SlideTransition(
              position: _sheetSlide,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(45)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(32, 48, 32, 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(45)),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('KODE VERIFIKASI'),
                        const SizedBox(height: 6),
                        // Tampilkan email sebagai info
                        Text(
                          'Dikirim ke ${widget.email}',
                          style: TextStyle(
                            fontSize: 12,
                            color: darkBrown.withOpacity(0.4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildOTPField(),
                        const SizedBox(height: 40),
                        _buildButton(),
                        const Spacer(),
                        _buildResendOption(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecor() {
    return Stack(
      children: [
        Positioned(
          top: 150,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: goldenYellow.withOpacity(0.15),
            ),
          ),
        ),
        Positioned(
          top: 300,
          left: -30,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: darkBrown.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(Size size) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: size.height * 0.43,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Verifikasi',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: darkBrown,
                  letterSpacing: -1,
                ),
              ),
              Text(
                'Kode OTP.',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: goldenYellow,
                  height: 1.0,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Silakan periksa kotak masuk email Anda untuk mendapatkan kode 6 digit.',
                style: TextStyle(
                  fontSize: 13,
                  color: darkBrown.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPField() {
    return TextField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      maxLength: 6,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: darkBrown,
        fontSize: 26,
        fontWeight: FontWeight.w900,
        letterSpacing: 18,
      ),
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: darkBrown.withOpacity(0.03),
        hintText: '000000',
        hintStyle:
            TextStyle(color: darkBrown.withOpacity(0.1), letterSpacing: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
      ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleVerify,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBrown,
          disabledBackgroundColor: darkBrown.withOpacity(0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                'VERIFIKASI KODE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1.5,
                ),
              ),
      ),
    );
  }

  Widget _buildResendOption() {
    final canResend = _secondsLeft == 0 && !_isResending;

    return Center(
      child: _isResending
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : TextButton(
              onPressed: canResend ? _handleResend : null,
              child: RichText(
                text: TextSpan(
                  text: 'Tidak menerima kode? ',
                  style: TextStyle(
                    color: darkBrown.withOpacity(0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: canResend
                          ? 'Kirim Ulang'
                          : 'Kirim Ulang ($_secondsLeft)',
                      style: TextStyle(
                        color: canResend
                            ? darkBrown
                            : darkBrown.withOpacity(0.3),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionLabel(String l) => Text(
        l,
        style: TextStyle(
          color: darkBrown.withOpacity(0.3),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      );

  Widget _buildBackButton() => Positioned(
        top: 50,
        left: 24,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: darkBrown.withOpacity(0.05)),
            ),
            child:
                Icon(Icons.arrow_back_ios_new_rounded, color: darkBrown, size: 18),
          ),
        ),
      );
}