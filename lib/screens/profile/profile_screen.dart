import 'package:flutter/material.dart';
import 'package:majelis_adventure/models/app_state.dart';
import '../auth/login_screen.dart';
import 'account_security_screen.dart';
import 'edit_profile_screen.dart';
import 'faq_screen.dart';
import 'help_center_screen.dart';
import 'notifications_screen.dart';
import 'payment_methods_screen.dart';
import 'personal_info_screen.dart';
import 'voucher_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final Color darkBrown = const Color(0xFF3E2723);
    final Color goldenYellow = const Color(0xFFE5A93D);
    final Color creamBg = const Color(0xFFF5EFE6);
    final Color deepBlack = const Color(0xFF1B1210);

    return Scaffold(
      backgroundColor: creamBg,
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          return SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: -90,
                  left: -80,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromRGBO(229, 169, 61, 0.08),
                    ),
                  ),
                ),
                Positioned(
                  top: 100,
                  right: -70,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromRGBO(62, 39, 35, 0.06),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 550),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, (1 - value) * 24),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 26),
                        _buildProfileHeader(
                          appState,
                          darkBrown,
                          goldenYellow,
                          deepBlack,
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              Expanded(
                                child: _statusCard(
                                  '1.2k',
                                  'Poin',
                                  Icons.star_rounded,
                                  goldenYellow,
                                  darkBrown,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _statusCard(
                                  '24',
                                  'Sewa',
                                  Icons.shopping_bag_rounded,
                                  const Color.fromRGBO(62, 39, 35, 0.08),
                                  darkBrown,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _statusCard(
                                  '5',
                                  'Voucher',
                                  Icons.confirmation_number_rounded,
                                  const Color.fromRGBO(229, 169, 61, 0.14),
                                  darkBrown,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              Expanded(
                                child: _actionCard(
                                  Icons.edit,
                                  'Edit Profil',
                                  'Perbarui data dan nomor dengan cepat',
                                  darkBrown,
                                  goldenYellow,
                                  () {
                                    _navigateToPage(
                                      context,
                                      const EditProfileScreen(),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _actionCard(
                                  Icons.card_giftcard,
                                  'Voucher',
                                  'Cek promo dan saldo diskon',
                                  darkBrown,
                                  goldenYellow,
                                  () {
                                    _navigateToPage(
                                      context,
                                      const VoucherScreen(),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildMenuSection(context, darkBrown, goldenYellow),
                        const SizedBox(height: 18),
                        _buildLogoutButton(context, darkBrown),
                        const SizedBox(height: 38),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
    AppState appState,
    Color db,
    Color gy,
    Color deepBlack,
  ) {
    final profile = appState.profile;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 560),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: Transform.scale(scale: 0.95 + value * 0.05, child: child),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(62, 39, 35, 0.06),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color.fromRGBO(229, 169, 61, 0.36),
                      width: 2,
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('lib/assets/img/majelis.png'),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: gy,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: TextStyle(
                      color: db,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    profile.email,
                    style: const TextStyle(
                      color: Color.fromRGBO(62, 39, 35, 0.65),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _statusBadge(profile.memberStatus, gy, Colors.white),
                      _statusBadge(
                        'Aktif 12 Bulan',
                        const Color.fromRGBO(62, 39, 35, 0.08),
                        db,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation =
              Tween<Offset>(
                begin: const Offset(0, 0.18),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
      ),
    );
  }

  Widget _statusBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _statusCard(
    String value,
    String label,
    IconData icon,
    Color bg,
    Color textColor,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(62, 39, 35, 0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: textColor, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color.fromRGBO(62, 39, 35, 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(
    IconData icon,
    String title,
    String subtitle,
    Color db,
    Color gy,
    VoidCallback onTap,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        overlayColor: MaterialStateProperty.all(
          const Color.fromRGBO(229, 169, 61, 0.12),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(62, 39, 35, 0.04),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(229, 169, 61, 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: gy, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  color: db,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  color: const Color.fromRGBO(62, 39, 35, 0.72),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, Color db, Color gy) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(62, 39, 35, 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          _menuItem(Icons.person_outline_rounded, 'Informasi Pribadi', db, () {
            _navigateToPage(context, const PersonalInfoScreen());
          }),
          _menuItem(
            Icons.account_balance_wallet_outlined,
            'Metode Pembayaran',
            db,
            () {
              _navigateToPage(context, const PaymentMethodsScreen());
            },
          ),
          _menuItem(Icons.security_outlined, 'Keamanan Akun', db, () {
            _navigateToPage(context, const AccountSecurityScreen());
          }),
          _menuItem(Icons.notifications_active_outlined, 'Notifikasi', db, () {
            _navigateToPage(context, const NotificationsScreen());
          }),
          _menuItem(Icons.help_outline_rounded, 'Pusat Bantuan', db, () {
            _navigateToPage(context, const HelpCenterScreen());
          }),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Divider(height: 1, thickness: 0.5),
          ),
          _menuItem(Icons.support_agent_outlined, 'Bantuan & FAQ', db, () {
            _navigateToPage(context, const FAQScreen());
          }),
        ],
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.16, end: 0.0),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: 1 - value,
          child: Transform.translate(
            offset: Offset(0, value * 18),
            child: child,
          ),
        );
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(229, 169, 61, 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: const Color.fromRGBO(62, 39, 35, 1),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: const Color.fromRGBO(62, 39, 35, 0.35),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, Color db) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Konfirmasi Logout'),
                content: const Text(
                  'Apakah Anda yakin ingin logout dari akun ini?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Tidak'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Ya'),
                  ),
                ],
              );
            },
          );

          if (!context.mounted || confirmed != true) {
            return;
          }
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const LoginScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
              transitionDuration: const Duration(milliseconds: 400),
            ),
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFBE2B4A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded, size: 20),
            SizedBox(width: 10),
            Text(
              'Keluar Akun',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
