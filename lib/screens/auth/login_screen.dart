import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/custom_textfield.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _headerSlide;
  late Animation<Offset> _sheetSlide;

  final Color creamBg = const Color(0xFFF5EFE6);
  final Color darkBrown = const Color(0xFF3E2723);
  final Color goldenYellow = const Color(0xFFE5A93D);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _headerSlide = Tween<Offset>(begin: const Offset(-0.08, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic)),
    );

    _sheetSlide = Tween<Offset>(begin: const Offset(0, 1.0), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeOutExpo)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Fungsi Helper untuk Navigasi Fade (Biar Kode Bersih)
  void _navigateTo(Widget screen, {bool isReplacement = false}) {
    final route = PageRouteBuilder(
      pageBuilder: (context, anim1, anim2) => screen,
      transitionsBuilder: (context, anim1, anim2, child) => FadeTransition(opacity: anim1, child: child),
      transitionDuration: const Duration(milliseconds: 500),
    );

    if (isReplacement) {
      Navigator.pushReplacement(context, route);
    } else {
      Navigator.push(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: creamBg,
      body: SizedBox(
        height: size.height,
        child: Stack(
          children: [
            // ================= BACKGROUND DECORATION =================
            Positioned(
              top: -30, right: -30,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  color: goldenYellow.withOpacity(0.15)
                ),
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
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                    ),
                  ),
                ),
              ),
            ),

            // ================= HEADER SECTION =================
            Positioned(
              top: 0, left: 0, right: 0, height: size.height * 0.42,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) => Opacity(
                      opacity: _fade.value, 
                      child: SlideTransition(position: _headerSlide, child: child!)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BRANDING: MAJELIS ADVENTURE (Premium Look)
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22, 
                              backgroundColor: Colors.white,
                              // PERBAIKAN: Gunakan path standar assets/
                              backgroundImage: const AssetImage('lib/assets/img/majelis.png'),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("MAJELIS", 
                                  style: TextStyle(fontWeight: FontWeight.w900, color: darkBrown, fontSize: 18, letterSpacing: 0.5)),
                                Text("ADVENTURE", 
                                  style: TextStyle(fontWeight: FontWeight.w300, color: darkBrown.withOpacity(0.7), fontSize: 11, letterSpacing: 4.0)),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text("Mulai", 
                          style: TextStyle(fontSize: 38, fontWeight: FontWeight.w300, color: darkBrown, letterSpacing: -1.0)),
                        Text("Petualangan.", 
                          style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: goldenYellow, height: 1.0, letterSpacing: -1.5)),
                        const SizedBox(height: 10),
                        Text("Peralatan outdoor terbaik untuk\nsetiap pendakianmu.", 
                          style: TextStyle(fontSize: 14, color: darkBrown.withOpacity(0.5), fontWeight: FontWeight.w500, height: 1.4)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ================= FORM SHEET SECTION =================
            Positioned(
              bottom: 0, left: 0, right: 0, height: size.height * 0.58,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => SlideTransition(position: _sheetSlide, child: child!),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                    boxShadow: [
                      BoxShadow(color: darkBrown.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -5))
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
                    child: Column(
                      children: [
                        Container(
                          width: 36, height: 4, 
                          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10))
                        ),
                        const SizedBox(height: 28),

                        const CustomTextField(hintText: "Email", prefixIcon: Icons.alternate_email_rounded),
                        const SizedBox(height: 12),
                        const CustomTextField(hintText: "Kata Sandi", prefixIcon: Icons.lock_outline_rounded, isPassword: true),
                        
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {}, 
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 35)),
                            child: Text("Lupa Sandi?", 
                              style: TextStyle(color: darkBrown, fontWeight: FontWeight.w700, fontSize: 12))
                          ),
                        ),
                        
                        const SizedBox(height: 8),

                        // Login Button
                        SizedBox(
                          width: double.infinity, height: 52,
                          child: ElevatedButton(
                            onPressed: () => _navigateTo(const HomeScreen(), isReplacement: true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkBrown, 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0
                            ),
                            child: const Text("MASUK", 
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade200)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16), 
                              child: Text("ATAU", 
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1))
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade200)),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Google Button
                        SizedBox(
                          width: double.infinity, height: 52,
                          child: OutlinedButton(
                            onPressed: () => _navigateTo(const HomeScreen(), isReplacement: true),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300), 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.g_mobiledata_rounded, color: darkBrown, size: 30),
                                const SizedBox(width: 8),
                                Text("GOOGLE ACCOUNT", 
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: darkBrown)),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Belum punya akun? ", 
                              style: TextStyle(color: darkBrown.withOpacity(0.6), fontSize: 13)),
                            GestureDetector(
                              onTap: () => _navigateTo(const RegisterScreen()),
                              child: Text("Daftar Sekarang", 
                                style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 13))
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