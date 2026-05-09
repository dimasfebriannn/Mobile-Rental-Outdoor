// lib/screens/profile/profile_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:majelis_adventure/screens/profile/account_security_screen.dart';
import 'package:majelis_adventure/screens/profile/edit_profile_screen.dart';
import 'package:majelis_adventure/screens/profile/help_center_screen.dart';
import 'package:majelis_adventure/screens/profile/how_to_rent_screen.dart';
import 'package:majelis_adventure/screens/profile/notification_settings_screen.dart';
import 'package:majelis_adventure/screens/profile/service_complaint_screen.dart';
import 'package:majelis_adventure/screens/profile/terms_conditions_screen.dart';
import 'package:majelis_adventure/screens/profile/basecamp_location_screen.dart';
import 'package:majelis_adventure/services/profile_service.dart';

import 'package:majelis_adventure/screens/auth/login_screen.dart';
import 'package:majelis_adventure/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // TEMA WARNA MAJELIS ADVENTURE
  static const Color darkBrown = Color(0xFF3E2723);
  static const Color goldenYellow = Color(0xFFE5A93D);
  static const Color creamBg = Color(0xFFF5EFE6);
  static const Color dangerRed = Color(0xFFBE2B4A);

  UserProfile? _profile;
  bool _isLoading = true;
  bool _isLoggingOut = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final profile = await ProfileService.getProfile();
      if (mounted)
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _errorMsg = e.toString();
          _isLoading = false;
        });
    }
  }

  // ── LOGOUT LOGIC ────────────────────────────────────────────────
  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    try {
      await AuthService.instance.logout();

      if (!mounted) return;

      // Navigasi ke LoginScreen dan hapus semua route sebelumnya
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoggingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Gagal keluar. Coba lagi."),
          backgroundColor: dangerRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // ── DIALOG KONFIRMASI LOGOUT ─────────────────────────────────────
  Future<void> _showLogoutConfirmation() async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Tutup",
      barrierColor: darkBrown.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 320),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 28),
              decoration: BoxDecoration(
                color: creamBg,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: darkBrown.withOpacity(0.18),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── HEADER MERAH ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    decoration: BoxDecoration(
                      color: dangerRed,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "KELUAR AKUN",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── BODY PESAN ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 10),
                    child: Column(
                      children: [
                        Text(
                          "Yakin ingin keluar?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: darkBrown,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Kamu akan keluar dari sesi ini dan perlu login kembali untuk mengakses akun Majelis Adventure kamu.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: darkBrown.withOpacity(0.5),
                            fontSize: 13,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── TOMBOL KELUAR ──
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // tutup dialog
                              _handleLogout();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: dangerRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "YA, KELUAR SEKARANG",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ── TOMBOL BATAL ──
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              "Batal, Tetap di Sini",
                              style: TextStyle(
                                color: darkBrown.withOpacity(0.45),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // 1. BACKGROUND ACCENT
          Positioned(
            top: -40,
            right: -40,
            child: Icon(
              Icons.landscape,
              size: 280,
              color: goldenYellow.withOpacity(0.03),
            ),
          ),

          // 2. SCROLLABLE CONTENT
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: _fetchProfile,
              color: darkBrown,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                child: Column(
                  children: [
                    const SizedBox(height: 135),

                    // IDENTITY SECTION
                    _buildIdentitySection(),

                    const SizedBox(height: 35),

                    // GRUP 1: AKUN & KEAMANAN
                    _buildSectionLabel("AKUN & KEAMANAN", darkBrown),
                    _buildMenuGroup(darkBrown, [
                      _menuTile(
                        context,
                        Icons.person_outline_rounded,
                        "Ubah Informasi Profil",
                        const EditProfileScreen(),
                        darkBrown,
                      ),
                      _menuTile(
                        context,
                        Icons.security_rounded,
                        "Keamanan & Autentikasi",
                        const AccountSecurityScreen(),
                        darkBrown,
                      ),
                      _menuTile(
                        context,
                        Icons.notifications_none_rounded,
                        "Notifikasi",
                        const NotificationSettingsScreen(),
                        darkBrown,
                      ),
                    ]),

                    const SizedBox(height: 25),

                    // GRUP 2: EKSPLORASI MAJELIS
                    _buildSectionLabel("EKSPLORASI MAJELIS", darkBrown),
                    _buildMenuGroup(darkBrown, [
                      _menuTile(
                        context,
                        Icons.assignment_outlined,
                        "Cara Penyewaan",
                        const HowToRentScreen(),
                        darkBrown,
                      ),
                      _menuTile(
                        context,
                        Icons.gavel_outlined,
                        "Syarat & Ketentuan",
                        const TermsConditionsScreen(),
                        darkBrown,
                      ),
                      _menuTile(
                        context,
                        Icons.map_outlined,
                        "Lokasi Basecamp",
                        const BasecampLocationScreen(),
                        darkBrown,
                      ),
                    ]),

                    const SizedBox(height: 25),

                    // GRUP 3: DUKUNGAN
                    _buildSectionLabel("LAYANAN DUKUNGAN", darkBrown),
                    _buildMenuGroup(darkBrown, [
                      _menuTile(
                        context,
                        Icons.chat_bubble_outline_rounded,
                        "Komplain Layanan",
                        const ServiceComplaintScreen(),
                        darkBrown,
                      ),
                      _menuTile(
                        context,
                        Icons.help_outline_rounded,
                        "Pusat Bantuan & FAQ",
                        const HelpCenterScreen(),
                        darkBrown,
                      ),
                    ]),

                    const SizedBox(height: 45),

                    _buildLogoutButton(darkBrown),

                    const SizedBox(height: 20),
                    Text(
                      "MAJELIS ADVENTURE • BUILD V.3.41.7",
                      style: TextStyle(
                        color: darkBrown.withOpacity(0.2),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. GLASS TOP BAR
          _buildGlassTopBar(darkBrown, goldenYellow),

          // 4. LOADING OVERLAY saat proses logout
          if (_isLoggingOut)
            Positioned.fill(
              child: Container(
                color: darkBrown.withOpacity(0.35),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: creamBg,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: dangerRed,
                          strokeWidth: 2.5,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Sedang keluar...",
                          style: TextStyle(
                            color: darkBrown,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── IDENTITY SECTION ────────────────────────────────────────────
  Widget _buildIdentitySection() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: darkBrown.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: darkBrown.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: goldenYellow.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: const Color(0xFFF5EFE6),
              backgroundImage:
                  (_profile?.avatar != null && _profile!.avatar!.isNotEmpty)
                  ? NetworkImage(_profile!.avatar!) as ImageProvider
                  : const AssetImage('lib/assets/img/majelis.png'),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: _isLoading
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _skeleton(width: 140, height: 16),
                      const SizedBox(height: 8),
                      _skeleton(width: 200, height: 12),
                    ],
                  )
                : _errorMsg != null
                ? Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red.shade300,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Gagal memuat data",
                          style: TextStyle(
                            color: darkBrown.withOpacity(0.5),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profile!.name,
                        style: const TextStyle(
                          color: darkBrown,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        _profile!.email,
                        style: TextStyle(
                          color: darkBrown.withOpacity(0.4),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

  // ── WIDGET COMPONENTS ────────────────────────────────────────────
  Widget _buildGlassTopBar(Color db, Color gy) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              border: Border(
                bottom: BorderSide(color: db.withOpacity(0.05), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PENGATURAN",
                      style: TextStyle(
                        color: gy,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Profil Saya",
                      style: TextStyle(
                        color: db,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: db.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.manage_accounts_outlined,
                    color: db,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color db) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        label,
        style: TextStyle(
          color: db.withOpacity(0.3),
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildMenuGroup(Color db, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: db.withOpacity(0.06), width: 1.2),
      ),
      child: Column(children: items),
    );
  }

  Widget _menuTile(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
    Color db,
  ) {
    return ListTile(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        _fetchProfile();
      },
      leading: Icon(icon, color: db, size: 20),
      title: Text(
        title,
        style: TextStyle(color: db, fontSize: 14, fontWeight: FontWeight.w700),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: db.withOpacity(0.1),
        size: 18,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }

  // ── LOGOUT BUTTON (menggantikan _buildSimpleLogout) ──────────────
  Widget _buildLogoutButton(Color db) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isLoggingOut ? null : _showLogoutConfirmation,
        icon: const Icon(Icons.logout_rounded, size: 16, color: dangerRed),
        label: const Text(
          "KELUAR AKUN",
          style: TextStyle(
            color: dangerRed,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          side: BorderSide(color: dangerRed.withOpacity(0.2), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledForegroundColor: dangerRed.withOpacity(0.4),
        ),
      ),
    );
  }
}
