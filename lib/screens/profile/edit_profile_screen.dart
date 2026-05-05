import 'dart:ui';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Kontroler sesuai kolom tabel 'users' di DB
  final TextEditingController _nameController = TextEditingController(text: "Dimas Dwinugroho");
  final TextEditingController _emailController = TextEditingController(text: "dimasdwinugroho15@gmail.com");
  final TextEditingController _phoneController = TextEditingController(text: "+62 ");
  final TextEditingController _addressController = TextEditingController(text: "Jl. Gunung Mulia No. 15, Jember");

  @override
  Widget build(BuildContext context) {
    const Color darkBrown = Color(0xFF3E2723);
    const Color goldenYellow = Color(0xFFE5A93D);
    const Color creamBg = Color(0xFFF5EFE6);

    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // 1. KONTEN UTAMA
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 130, 24, 40),
              child: Column(
                children: [
                  // AVATAR EDITOR (Pencil di Tengah)
                  _buildAvatarEditor(darkBrown, goldenYellow),

                  const SizedBox(height: 45),

                  // FORM INPUT
                  _buildSectionLabel("DATA IDENTITAS EKSPEDISI", darkBrown),
                  _buildCustomTextField(
                    label: "NAMA LENGKAP",
                    controller: _nameController,
                    icon: Icons.person_rounded,
                    color: darkBrown,
                  ),
                  _buildCustomTextField(
                    label: "ALAMAT EMAIL (PERMANEN)",
                    controller: _emailController,
                    icon: Icons.lock_outline_rounded,
                    color: darkBrown,
                    isReadOnly: true, // Email tidak bisa diedit
                  ),
                  _buildCustomTextField(
                    label: "NOMOR WHATSAPP",
                    controller: _phoneController,
                    icon: Icons.phone_android_rounded,
                    color: darkBrown,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildCustomTextField(
                    label: "ALAMAT TINGGAL",
                    controller: _addressController,
                    icon: Icons.location_on_rounded,
                    color: darkBrown,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 30),

                  // ACTION BUTTON
                  _buildSaveButton(darkBrown),
                ],
              ),
            ),
          ),

          // 2. GLASS TOP BAR
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: db.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: db, size: 16),
                  ),
                ),
                Text(
                  "UBAH PROFIL", 
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

  Widget _buildAvatarEditor(Color db, Color gy) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lingkaran Foto
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: gy.withOpacity(0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: db.withOpacity(0.1),
              backgroundImage: const AssetImage('lib/assets/img/majelis.png'),
            ),
          ),
          // Overlay Gelap Transparan & Pensil di Tengah
          Container(
            width: 128, // Sesuai ukuran CircleAvatar + Padding
            height: 128,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit_rounded, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color db) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        label,
        style: TextStyle(color: db.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildCustomTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
    bool isReadOnly = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(
          color: isReadOnly ? color.withOpacity(0.4) : color, 
          fontWeight: FontWeight.w700, 
          fontSize: 15
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: isReadOnly ? color.withOpacity(0.02) : Colors.white,
          labelText: label,
          labelStyle: TextStyle(color: color.withOpacity(0.4), fontWeight: FontWeight.w800, fontSize: 10),
          prefixIcon: Icon(icon, color: color.withOpacity(0.5), size: 18),
          // Border saat normal
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: color.withOpacity(0.06), width: 1.5),
          ),
          // Border saat diklik (Dibuat halus / tidak mencolok)
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: color.withOpacity(0.2), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildSaveButton(Color db) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: db,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Text(
          "SIMPAN DATA TERBARU",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2),
        ),
      ),
    );
  }
}