import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/custom_textfield.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  final Color creamBg = const Color(0xFFF5EFE6);
  final Color darkBrown = const Color(0xFF3E2723);
  final Color goldenYellow = const Color(0xFFE5A93D);

  void _handleReset() async {
    if (_passController.text.isEmpty) return;
    if (_passController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kata sandi tidak cocok!")),
      );
      return;
    }

    setState(() => _isLoading = true);
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
                    child: Icon(Icons.verified_user_rounded, color: goldenYellow, size: 50),
                  ),
                  const SizedBox(height: 24),
                  Text("SANDI DIPERBARUI", 
                    style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  Text("Akses akun Anda telah pulih. Silakan gunakan kata sandi baru untuk masuk.", 
                    textAlign: TextAlign.center, 
                    style: TextStyle(color: darkBrown.withOpacity(0.6), fontSize: 13, height: 1.5, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity, 
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBrown, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), 
                        elevation: 0
                      ),
                      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      child: const Text("LOGIN SEKARANG", 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
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
          // 1. ELEMEN DEKORATIF UNTUK EFEK GLASS (BLOBS)
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

          // 2. HEADER AREA
          _buildHeader(size),

          // 3. GLASSMORPHISM SHEET
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: size.height * 0.62,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(45)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7), // Transparansi
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(45)),
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                  ),
                  padding: const EdgeInsets.fromLTRB(32, 48, 32, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel("KATA SANDI BARU"),
                      const SizedBox(height: 18),
                      CustomTextField(
                        hintText: 'Sandi Baru', 
                        prefixIcon: Icons.lock_open_rounded, 
                        isPassword: true, 
                        controller: _passController
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        hintText: 'Konfirmasi Sandi', 
                        prefixIcon: Icons.lock_outline_rounded, 
                        isPassword: true, 
                        controller: _confirmController
                      ),
                      const SizedBox(height: 40),
                      _buildButton(),
                      const Spacer(),
                      Center(
                        child: Text(
                          "MAJELIS ADVENTURE SECURITY",
                          style: TextStyle(color: darkBrown.withOpacity(0.2), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Tombol Back Melayang (Consistent with previous screens)
          Positioned(
            top: 50, left: 24,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded, color: darkBrown, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Positioned(
      top: 0, left: 0, right: 0,
      height: size.height * 0.4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Buat', 
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: darkBrown, letterSpacing: -1)),
            Text('Sandi Baru.', 
              style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: goldenYellow, height: 1.0, letterSpacing: -1.5)),
            const SizedBox(height: 12),
            Text('Gunakan kombinasi karakter unik untuk memastikan keamanan akun pendakian Anda tetap terjaga.', 
              style: TextStyle(fontSize: 14, color: darkBrown.withOpacity(0.6), fontWeight: FontWeight.w500, height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity, height: 58,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleReset,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBrown, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), 
          elevation: 0
        ),
        child: _isLoading 
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text('PERBARUI SEKARANG', 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
      ),
    );
  }

  Widget _sectionLabel(String l) => Text(l, 
    style: TextStyle(color: darkBrown.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2));
}