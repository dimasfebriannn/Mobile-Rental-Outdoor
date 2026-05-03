import 'package:flutter/material.dart';
import 'faq_screen.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color darkBrown = const Color(0xFF3E2723);
    final Color goldenYellow = const Color(0xFFE5A93D);
    final Color creamBg = const Color(0xFFF5EFE6);

    return Scaffold(
      backgroundColor: creamBg,
      appBar: AppBar(
        backgroundColor: creamBg,
        elevation: 0,
        foregroundColor: darkBrown,
        title: const Text('Pusat Bantuan'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                        color: goldenYellow.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.support_agent_rounded,
                        color: goldenYellow,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Butuh Bantuan?',
                            style: TextStyle(
                              color: darkBrown,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tim support siap membantu 24/7 untuk semua kebutuhan rentalmu.',
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
              ),
              const SizedBox(height: 24),
              Text(
                'Pilihan Bantuan',
                style: TextStyle(
                  color: darkBrown,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              _helpOption(
                context,
                title: 'Chat dengan Support',
                subtitle: 'Tanya langsung lewat chat dalam aplikasi.',
                icon: Icons.chat_bubble_outline,
                color: goldenYellow,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _helpOption(
                context,
                title: 'Telepon Darurat',
                subtitle: '+62 812 3456 7890',
                icon: Icons.call_outlined,
                color: darkBrown,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _helpOption(
                context,
                title: 'Email Support',
                subtitle: 'support@majelisrental.co.id',
                icon: Icons.email_outlined,
                color: goldenYellow,
                onTap: () {},
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FAQScreen()),
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
                  'Lihat FAQ',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _helpOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
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
              child: Icon(icon, color: color, size: 24),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color.fromRGBO(62, 39, 35, 0.72),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color.fromRGBO(62, 39, 35, 0.35),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
