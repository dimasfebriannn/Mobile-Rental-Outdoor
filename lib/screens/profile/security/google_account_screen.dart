// lib/screens/profile/security/google_account_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:majelis_adventure/services/profile_service.dart';

class GoogleAccountScreen extends StatefulWidget {
  const GoogleAccountScreen({super.key});

  @override
  State<GoogleAccountScreen> createState() => _GoogleAccountScreenState();
}

class _GoogleAccountScreenState extends State<GoogleAccountScreen> {
  static const Color darkBrown = Color(0xFF3E2723);
  static const Color creamBg   = Color(0xFFF5EFE6);

  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final profile = await ProfileService.getProfile();
      if (mounted) setState(() { _profile = profile; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 130, 24, 40),
              child: Column(
                children: [
                  _isLoading ? _buildLoadingCard() : _buildGoogleCard(),
                  const SizedBox(height: 32),
                  _buildInfoText(),
                ],
              ),
            ),
          ),
          _buildGlassTopBar(context, "GOOGLE SYNC"),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: darkBrown.withOpacity(0.08), width: 1.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.g_mobiledata_rounded, size: 60, color: Colors.blue),
          const SizedBox(height: 16),
          _skeleton(width: 160, height: 18),
          const SizedBox(height: 8),
          _skeleton(width: 200, height: 14),
        ],
      ),
    );
  }

  Widget _buildGoogleCard() {
    final isLinked = _profile?.isGoogleLinked ?? false;
    final name  = _profile?.name  ?? '-';
    final email = _profile?.email ?? '-';

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: darkBrown.withOpacity(0.08), width: 1.5),
        boxShadow: [BoxShadow(color: darkBrown.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Icon(
            Icons.g_mobiledata_rounded,
            size: 60,
            color: isLinked ? Colors.blue : darkBrown.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            name.toUpperCase(),
            style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          Text(
            email,
            style: TextStyle(color: darkBrown.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          // Status terhubung berdasarkan data google_id dari DB
          Text(
            isLinked
                ? "TERHUBUNG SEBAGAI METODE LOGIN"
                : "TIDAK TERHUBUNG KE GOOGLE",
            style: TextStyle(
              color: isLinked ? Colors.green : Colors.orange,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeleton({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: darkBrown.withOpacity(0.07),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildInfoText() {
    return Text(
      _profile?.isGoogleLinked == true
          ? "Akun Google Anda digunakan untuk mempermudah proses autentikasi tanpa perlu memasukkan kata sandi manual."
          : "Akun Anda tidak terhubung ke Google. Anda menggunakan email dan kata sandi untuk masuk.",
      textAlign: TextAlign.center,
      style: TextStyle(color: darkBrown.withOpacity(0.3), fontSize: 12, fontWeight: FontWeight.w600, height: 1.5),
    );
  }

  Widget _buildGlassTopBar(BuildContext context, String title) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              border: Border(bottom: BorderSide(color: darkBrown.withOpacity(0.05), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: darkBrown.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: darkBrown, size: 18),
                  ),
                ),
                Text(title, style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2.5)),
                const SizedBox(width: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}