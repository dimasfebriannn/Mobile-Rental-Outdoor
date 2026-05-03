import 'package:flutter/material.dart';
import 'package:majelis_adventure/models/app_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
        title: const Text('Notifikasi'),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final settings = appState.notificationSettings;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _notificationHeader(darkBrown, goldenYellow),
                  const SizedBox(height: 24),
                  _notificationTile(
                    title: 'Pembaruan pesanan',
                    subtitle:
                        'Dapatkan notifikasi setiap kali status sewa berubah.',
                    value: settings.orderUpdates,
                    onChanged: (value) {
                      appState.updateNotificationSettings(orderUpdates: value);
                    },
                  ),
                  const SizedBox(height: 14),
                  _notificationTile(
                    title: 'Promo & diskon',
                    subtitle: 'Terima penawaran khusus dan voucher baru.',
                    value: settings.promoAlerts,
                    onChanged: (value) {
                      appState.updateNotificationSettings(promoAlerts: value);
                    },
                  ),
                  const SizedBox(height: 14),
                  _notificationTile(
                    title: 'Pengingat pengembalian',
                    subtitle: 'Ingatkan jadwal pengembalian barang sewa.',
                    value: settings.reminderAlerts,
                    onChanged: (value) {
                      appState.updateNotificationSettings(
                        reminderAlerts: value,
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _notificationTile(
                    title: 'Berita aplikasi',
                    subtitle: 'Terima update fitur dan berita terbaru.',
                    value: settings.appNews,
                    onChanged: (value) {
                      appState.updateNotificationSettings(appNews: value);
                    },
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(62, 39, 35, 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preferensi notifikasi',
                          style: TextStyle(
                            color: darkBrown,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Sesuaikan notifikasi untuk mendapatkan informasi penting yang paling relevan.',
                          style: TextStyle(
                            color: darkBrown.withOpacity(0.72),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pengaturan notifikasi tersimpan.'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Simpan Pengaturan',
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

  Widget _notificationHeader(Color darkBrown, Color goldenYellow) {
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
            child: Icon(
              Icons.notifications_rounded,
              color: goldenYellow,
              size: 28,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifikasi Saya',
                  style: TextStyle(
                    color: darkBrown,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Atur pemberitahuan agar hanya menerima info penting dari rental.',
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

  Widget _notificationTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                const SizedBox(height: 6),
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
          Switch(
            value: value,
            activeColor: const Color(0xFFE5A93D),
            activeTrackColor: const Color.fromRGBO(229, 169, 61, 0.3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
