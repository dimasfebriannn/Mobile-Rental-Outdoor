import 'dart:ui';
import 'package:flutter/material.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  // Mock selection - Default sesuai data user di Indonesia
  String _selectedLanguage = "id"; 

  @override
  Widget build(BuildContext context) {
    const Color darkBrown = Color(0xFF3E2723);
    const Color goldenYellow = Color(0xFFE5A93D);
    const Color creamBg = Color(0xFFF5EFE6);

    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // Background Decoration
          Positioned(
            top: -30,
            right: -30,
            child: Icon(Icons.translate_rounded, size: 300, color: darkBrown.withOpacity(0.03)),
          ),

          // Konten Utama
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 110, 24, 40),
                child: Column(
                  children: [
                    _buildLanguageHero(darkBrown),

                    const SizedBox(height: 50),

                    // GRUP PILIHAN BAHASA
                    _buildSectionLabel("PILIH BAHASA APLIKASI", darkBrown),
                    _buildDenseGroup(darkBrown, [
                      _languageOption(
                        context: context,
                        title: "Bahasa Indonesia",
                        subtitle: "Gunakan bahasa standar Indonesia",
                        code: "id",
                        icon: "🇮🇩",
                        db: darkBrown,
                      ),
                      _languageOption(
                        context: context,
                        title: "English (US)",
                        subtitle: "Use English for global interface",
                        code: "en",
                        icon: "🇺🇸",
                        db: darkBrown,
                      ),
                    ]),

                    const SizedBox(height: 40),
                    
                    Text(
                      "MAJELIS ADVENTURE LOCALE SYSTEM",
                      style: TextStyle(
                        color: darkBrown.withOpacity(0.15),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Glass Top Bar (Konsisten dengan Security & Edit Profile)
          _buildGlassTopBar(context, darkBrown),
        ],
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildGlassTopBar(BuildContext context, Color db) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              border: Border(bottom: BorderSide(color: db.withOpacity(0.05), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: db.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: db, size: 16),
                  ),
                ),
                Text(
                  "BAHASA", 
                  style: TextStyle(color: db, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)
                ),
                const SizedBox(width: 40), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageHero(Color db) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: db.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Icon(Icons.language_rounded, color: db, size: 60),
        ),
        const SizedBox(height: 24),
        Text(
          "Pilihan Bahasa", 
          style: TextStyle(color: db, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)
        ),
        Text(
          "Sesuaikan antarmuka sesuai kenyamanan Anda", 
          textAlign: TextAlign.center,
          style: TextStyle(color: db.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w600)
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label, Color db) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 6, bottom: 14),
      child: Text(
        label, 
        style: TextStyle(color: db.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2.0)
      ),
    );
  }

  Widget _buildDenseGroup(Color db, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: db.withOpacity(0.1), width: 1.5),
      ),
      child: Column(children: items),
    );
  }

  Widget _languageOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String code,
    required String icon,
    required Color db,
  }) {
    bool isSelected = _selectedLanguage == code;

    return ListTile(
      onTap: () {
        setState(() {
          _selectedLanguage = code;
        });
      },
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: db.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(icon, style: const TextStyle(fontSize: 22)),
      ),
      title: Text(
        title, 
        style: TextStyle(color: db, fontSize: 16, fontWeight: FontWeight.w800)
      ),
      subtitle: Text(
        subtitle, 
        style: TextStyle(color: db.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w600)
      ),
      trailing: isSelected 
        ? Icon(Icons.check_circle_rounded, color: db, size: 24)
        : Icon(Icons.circle_outlined, color: db.withOpacity(0.1), size: 24),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }
}