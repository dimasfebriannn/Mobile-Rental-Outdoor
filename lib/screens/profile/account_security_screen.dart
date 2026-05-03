import 'package:flutter/material.dart';
import 'package:majelis_adventure/models/app_state.dart';

class AccountSecurityScreen extends StatelessWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final Color darkBrown = const Color(0xFF3E2723);
    final Color goldenYellow = const Color(0xFFE5A93D);
    final Color creamBg = const Color(0xFFF5EFE6);

    return Scaffold(
      backgroundColor: creamBg,
      appBar: AppBar(
        backgroundColor: creamBg,
        elevation: 0,
        foregroundColor: darkBrown,
        title: const Text('Keamanan Akun'),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final settings = appState.securitySettings;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _securityHeader(darkBrown, goldenYellow),
                  const SizedBox(height: 24),
                  _securityItem(
                    title: 'Ubah Kata Sandi',
                    subtitle:
                        'Ganti password secara berkala untuk menjaga akun aman.',
                    icon: Icons.lock_outline,
                    color: darkBrown,
                    actionLabel: 'Ubah',
                    onTap: () {},
                  ),
                  const SizedBox(height: 14),
                  _securityItem(
                    title: 'Autentikasi Dua Faktor',
                    subtitle: settings.twoFactor
                        ? '2FA aktif melalui SMS dan email'
                        : '2FA nonaktif',
                    icon: Icons.shield_outlined,
                    color: goldenYellow,
                    actionLabel: settings.twoFactor ? 'Matikan' : 'Aktifkan',
                    onTap: () {
                      appState.updateSecuritySettings(
                        twoFactor: !settings.twoFactor,
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _securityItem(
                    title: 'Face ID / Fingerprint',
                    subtitle: settings.faceId
                        ? 'Autentikasi biometrik aktif'
                        : 'Biometrik tidak aktif',
                    icon: Icons.fingerprint,
                    color: darkBrown,
                    actionLabel: settings.faceId ? 'Matikan' : 'Aktifkan',
                    onTap: () {
                      appState.updateSecuritySettings(faceId: !settings.faceId);
                    },
                  ),
                  const SizedBox(height: 14),
                  _securityItem(
                    title: 'Notifikasi Perangkat Baru',
                    subtitle: settings.deviceAlerts
                        ? 'Notifikasi akan dikirim ke emailmu'
                        : 'Notifikasi dimatikan',
                    icon: Icons.devices_rounded,
                    color: goldenYellow,
                    actionLabel: settings.deviceAlerts ? 'Matikan' : 'Aktifkan',
                    onTap: () {
                      appState.updateSecuritySettings(
                        deviceAlerts: !settings.deviceAlerts,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Audit Keamanan Sekarang',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _securityHeader(Color darkBrown, Color goldenYellow) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(62, 39, 35, 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: goldenYellow.withOpacity(0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.security_rounded, color: goldenYellow, size: 28),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keamanan Akunmu',
                  style: TextStyle(
                    color: darkBrown,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pastikan akun kamu terlindungi dengan pengaturan keamanan terbaik.',
                  style: TextStyle(
                    color: darkBrown.withOpacity(0.72),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _securityItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(62, 39, 35, 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color.fromRGBO(62, 39, 35, 1),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color.fromRGBO(62, 39, 35, 0.72),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onTap, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
