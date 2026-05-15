// lib/screens/auth/register_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:majelis_adventure/screens/auth/register_otp_screen.dart';
import '../../widgets/custom_textfield.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────
  final _nameController            = TextEditingController();
  final _emailController           = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ── State ─────────────────────────────────────────────
  bool _isLoading       = false;
  bool _isGoogleLoading = false;

  // ── Animations ────────────────────────────────────────
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _headerSlide;
  late Animation<Offset> _sheetSlide;

  // ── Colors ────────────────────────────────────────────
  final Color creamBg      = const Color(0xFFF5EFE6);
  final Color darkBrown    = const Color(0xFF3E2723);
  final Color goldenYellow = const Color(0xFFE5A93D);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.6, curve: Curves.easeIn)));
    _headerSlide =
        Tween<Offset>(begin: const Offset(-0.08, 0), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic)));
    _sheetSlide =
        Tween<Offset>(begin: const Offset(0, 1.0), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _controller,
                curve:
                    const Interval(0.3, 1.0, curve: Curves.easeOutExpo)));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────
  void _backToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const LoginScreen(),
        transitionsBuilder: (context, anim1, anim2, child) =>
            FadeTransition(opacity: anim1, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const HomeScreen(),
        transitionsBuilder: (context, anim1, anim2, child) =>
            FadeTransition(opacity: anim1, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  // ── Snackbar Helper ───────────────────────────────────
  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // VALIDASI & REGISTER
  // ─────────────────────────────────────────────────────
  Future<void> _handleRegister() async {
    final name     = _nameController.text.trim();
    final email    = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm  = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showMessage('Semua kolom wajib diisi.');
      return;
    }
    if (password != confirm) {
      _showMessage('Konfirmasi kata sandi tidak cocok.');
      return;
    }

    setState(() => _isLoading = true);

    // REVISI LOGIC: Hit API Register 
    final result = await AuthService.instance.registerWithEmail(
      name: name,
      email: email,
      password: password, phone: '', address: '',
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      // PINDAH KE HALAMAN OTP (Bukan ke Home)
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) => RegisterOtpScreen(
            email: email,
            name: name,
            password: password,
          ),
          transitionsBuilder: (context, anim1, anim2, child) =>
              FadeTransition(opacity: anim1, child: child),
        ),
      );
    } else {
      _showMessage(result.message ?? 'Registrasi gagal.');
    }
  }

  Future<void> _handleGoogleRegister() async {
    setState(() => _isGoogleLoading = true);

    final result = await AuthService.instance.loginWithGoogle();

    if (!mounted) return;
    setState(() => _isGoogleLoading = false);

    if (result.success) {
      _goToHome();
    } else {
      _showMessage(result.message ?? 'Login Google gagal.');
    }
  }

  // ─────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: creamBg,
      body: SizedBox(
        height: size.height,
        child: Stack(
          children: [
            // ── Background Decoration ──────────────────
            Positioned(
              top: -30, right: -30,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: goldenYellow.withOpacity(0.15)),
              ),
            ),
            Positioned(
              top: 20, right: -50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    width: 180, height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 1.5),
                    ),
                  ),
                ),
              ),
            ),

            // ── Header ────────────────────────────────
            Positioned(
              top: 0, left: 0, right: 0,
              height: size.height * 0.35,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 20.0),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) => Opacity(
                        opacity: _fade.value,
                        child: SlideTransition(
                            position: _headerSlide, child: child!)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 45, height: 45,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image:
                                      AssetImage('lib/assets/img/majelis.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('MAJELIS',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: darkBrown,
                                        fontSize: 18,
                                        letterSpacing: 0.5)),
                                Text('ADVENTURE',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        color: darkBrown.withOpacity(0.7),
                                        fontSize: 12,
                                        letterSpacing: 4.0)),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text('Daftar Akun',
                            style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w300,
                                color: darkBrown,
                                letterSpacing: -1.0)),
                        Text('Baru.',
                            style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                color: goldenYellow,
                                height: 1.0,
                                letterSpacing: -1.5)),
                        const SizedBox(height: 8),
                        Text('Bergabunglah dalam ekosistem MDPL.',
                            style: TextStyle(
                                fontSize: 14,
                                color: darkBrown.withOpacity(0.5),
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Form Sheet ────────────────────────────
            Positioned(
              bottom: 0, left: 0, right: 0,
              height: size.height * 0.65,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) =>
                    SlideTransition(position: _sheetSlide, child: child!),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(40)),
                    boxShadow: [
                      BoxShadow(
                          color: darkBrown.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, -5))
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 36, height: 4,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10)),
                        ),

                        // ── Input Fields ──────────────
                        CustomTextField(
                          hintText: 'Nama Lengkap',
                          prefixIcon: Icons.person_outline_rounded,
                          controller: _nameController,
                        ),
                        CustomTextField(
                          hintText: 'Email',
                          prefixIcon: Icons.alternate_email_rounded,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        CustomTextField(
                          hintText: 'Kata Sandi',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          controller: _passwordController,
                        ),
                        CustomTextField(
                          hintText: 'Konfirmasi Sandi',
                          prefixIcon: Icons.lock_reset_rounded,
                          isPassword: true,
                          controller: _confirmPasswordController,
                        ),

                        // ── Register Button ───────────
                        SizedBox(
                          width: double.infinity, height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkBrown,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22, height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('DAFTAR',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2)),
                          ),
                        ),

                        Row(
                          children: [
                            Expanded(
                                child: Divider(color: Colors.grey.shade200)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('ATAU',
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800)),
                            ),
                            Expanded(
                                child: Divider(color: Colors.grey.shade200)),
                          ],
                        ),

                        // ── Google Button ─────────────
                        SizedBox(
                          width: double.infinity, height: 50,
                          child: OutlinedButton(
                            onPressed: _isGoogleLoading
                                ? null
                                : _handleGoogleRegister,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isGoogleLoading
                                ? SizedBox(
                                    width: 22, height: 22,
                                    child: CircularProgressIndicator(
                                        color: darkBrown, strokeWidth: 2),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.g_mobiledata_rounded,
                                          color: darkBrown, size: 28),
                                      const SizedBox(width: 8),
                                      Text('GOOGLE ACCOUNT',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: darkBrown)),
                                    ],
                                  ),
                          ),
                        ),

                        // ── Footer ────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Sudah punya akun? ',
                                style: TextStyle(
                                    color: darkBrown.withOpacity(0.6),
                                    fontSize: 13)),
                            GestureDetector(
                              onTap: _backToLogin,
                              child: Text('Masuk Saja',
                                  style: TextStyle(
                                      color: darkBrown,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}