import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:majelis_adventure/screens/profile/account_security_screen.dart';
import 'package:majelis_adventure/screens/profile/edit_profile_screen.dart';
import 'package:majelis_adventure/screens/profile/notification_settings_screen.dart';
import 'package:majelis_adventure/screens/profile/how_to_rent_screen.dart';
import 'package:majelis_adventure/screens/profile/terms_conditions_screen.dart';
import 'package:majelis_adventure/screens/profile/basecamp_location_screen.dart';
import 'package:majelis_adventure/screens/profile/service_complaint_screen.dart';
import 'package:majelis_adventure/screens/profile/help_center_screen.dart';
import 'package:majelis_adventure/services/profile_service.dart';
import 'package:majelis_adventure/screens/auth/login_screen.dart';
import 'package:majelis_adventure/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color darkBrown = Color(0xFF3E2723);
  static const Color goldenYellow = Color(0xFFE5A93D);
  static const Color creamBg = Color(0xFFF5EFE6);
  static const Color dangerRed = Color(0xFFBE2B4A);

  UserProfile? _profile;
  bool _isLoading = true;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    try {
      final profile = await ProfileService.getProfile();
      if (mounted)
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // BACKGROUND ACCENT
          Positioned(
            top: -50,
            right: -50,
            child: Icon(
              Icons.terrain_rounded,
              size: 300,
              color: darkBrown.withOpacity(0.02),
            ),
          ),

          // KONTEN UTAMA
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _isLoading ? _buildShimmerLoading() : _buildContent(),
          ),

          // TOP BAR KONSISTEN
          _buildSlimTopBar(),

          if (_isLoggingOut) _buildLogoutOverlay(),
        ],
      ),
    );
  }

  // --- LOADING SKELETON ---
  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: darkBrown.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.5),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 140, 24, 0),
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            const SizedBox(height: 35),
            ...List.generate(
              3,
              (i) => Container(
                margin: const EdgeInsets.only(bottom: 25),
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CONTENT UTAMA ---
  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 140, 24, 120),
      child: Column(
        children: [
          _buildIdentityCard(),
          const SizedBox(height: 35),

          _buildSectionLabel("AKUN & KEAMANAN"),
          _buildDenseGroup([
            _menuTile(
              Icons.person_outline_rounded,
              "Informasi Profil",
              "Kelola nama, email, dan foto profil Anda",
              const EditProfileScreen(),
            ),
            _menuTile(
              Icons.shield_outlined,
              "Keamanan Akun",
              "Ubah password dan autentikasi akun",
              const AccountSecurityScreen(),
            ),
            _menuTile(
              Icons.notifications_none_rounded,
              "Notifikasi",
              "Atur preferensi pemberitahuan aplikasi",
              const NotificationSettingsScreen(),
            ),
          ]),

          const SizedBox(height: 25),
          _buildSectionLabel("EKSPLORASI MAJELIS"),
          _buildDenseGroup([
            _menuTile(
              Icons.auto_stories_outlined,
              "Panduan Sewa",
              "Tata cara menyewa alat",
              const HowToRentScreen(),
            ),
            _menuTile(
              Icons.gavel_rounded,
              "Legalitas",
              "Syarat, ketentuan, dan kebijakan privasi",
              const TermsConditionsScreen(),
            ),
            _menuTile(
              Icons.map_outlined,
              "Basecamp",
              "Cari lokasi pengambilan alat terdekat",
              const BasecampLocationScreen(),
            ),
          ]),

          const SizedBox(height: 25),
          _buildSectionLabel("LAYANAN DUKUNGAN"),
          _buildDenseGroup([
            _menuTile(
              Icons.chat_bubble_outline_rounded,
              "Komplain Layanan",
              "Sampaikan kendala atau kerusakan alat",
              const ServiceComplaintScreen(),
            ),
            _menuTile(
              Icons.help_outline_rounded,
              "Pusat Bantuan",
              "Jawaban cepat untuk pertanyaan Anda",
              const HelpCenterScreen(),
            ),
          ]),

          const SizedBox(height: 40),
          _buildLogoutCard(),
          const SizedBox(height: 20),
          Text(
            "MAJELIS ADVENTURE • V.3.41",
            style: TextStyle(
              color: darkBrown.withOpacity(0.15),
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlimTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              border: Border(
                bottom: BorderSide(color: darkBrown.withOpacity(0.05)),
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
                        color: goldenYellow,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const Text(
                      "Profil Saya",
                      style: TextStyle(
                        color: darkBrown,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: creamBg.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.manage_accounts_outlined,
                    color: darkBrown,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: darkBrown.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: darkBrown.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: creamBg,
            backgroundImage: (_profile?.avatar != null)
                ? NetworkImage(_profile!.avatar!)
                : const AssetImage('lib/assets/img/majelis.png')
                      as ImageProvider,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profile?.name ?? "Pendaki",
                  style: const TextStyle(
                    color: darkBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  _profile?.email ?? "...",
                  style: TextStyle(
                    color: darkBrown.withOpacity(0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.verified_user_rounded, color: goldenYellow, size: 20),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 12),
        child: Text(
          label,
          style: TextStyle(
            color: darkBrown.withOpacity(0.3),
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDenseGroup(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkBrown.withOpacity(0.06)),
      ),
      child: Column(children: tiles),
    );
  }

  // --- REVISI: MENU TILE DENGAN DETAIL SUBTITLE ---
  Widget _menuTile(IconData icon, String title, String subtitle, Widget page) {
    return ListTile(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: creamBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: darkBrown, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: darkBrown,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          subtitle,
          style: TextStyle(
            color: darkBrown.withOpacity(0.4),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: darkBrown.withOpacity(0.1),
        size: 20,
      ),
    );
  }

  Widget _buildLogoutCard() {
    return InkWell(
      onTap: _showLogoutConfirmation,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: dangerRed.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: dangerRed.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.power_settings_new_rounded,
              color: dangerRed,
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              "KELUAR DARI SESI",
              style: TextStyle(
                color: dangerRed,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: creamBg,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Akhiri Sesi?",
              style: TextStyle(
                color: darkBrown,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Kamu akan keluar dari akun Majelis Adventure.",
              textAlign: TextAlign.center,
              style: TextStyle(color: darkBrown.withOpacity(0.5)),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: darkBrown),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "BATAL",
                      style: TextStyle(
                        color: darkBrown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _handleLogout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dangerRed,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "KELUAR",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    await AuthService.instance.logout();
    if (mounted)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
  }

  Widget _buildLogoutOverlay() {
    return Positioned.fill(
      child: Container(
        color: darkBrown.withOpacity(0.5),
        child: const Center(
          child: CircularProgressIndicator(color: goldenYellow),
        ),
      ),
    );
  }
}
