// lib/screens/profile/edit_profile_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:majelis_adventure/services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color darkBrown    = Color(0xFF3E2723);
  static const Color goldenYellow = Color(0xFFE5A93D);
  static const Color creamBg      = Color(0xFFF5EFE6);

  // Controller sesuai kolom tabel 'users'
  final _nameController    = TextEditingController();
  final _emailController   = TextEditingController();
  final _phoneController   = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = true;   // loading data awal
  bool _isSaving  = false;  // loading saat simpan
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Ambil data profil dari API, isi ke controller
  Future<void> _fetchProfile() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      final profile = await ProfileService.getProfile();
      if (!mounted) return;
      _nameController.text    = profile.name;
      _emailController.text   = profile.email;
      _phoneController.text   = profile.phone ?? '';
      _addressController.text = profile.alamat ?? '';
      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() { _errorMsg = e.toString(); _isLoading = false; });
    }
  }

  // Kirim update ke API
  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar("Nama tidak boleh kosong", isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ProfileService.updateProfile(
        name:   _nameController.text.trim(),
        phone:  _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        alamat: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      );
      if (!mounted) return;
      _showSnackBar("Profil berhasil diperbarui ✓");
      // Kembali ke ProfileScreen setelah 1 detik
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _showSnackBar(e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: isError ? const Color(0xFFBE2B4A) : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // 1. KONTEN UTAMA
          Positioned.fill(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMsg != null
                    ? _buildErrorState()
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 130, 24, 40),
                        child: Column(
                          children: [
                            _buildAvatarEditor(),
                            const SizedBox(height: 45),
                            _buildSectionLabel("DATA IDENTITAS EKSPEDISI", darkBrown),
                            _buildCustomTextField(
                              label: "NAMA LENGKAP",
                              controller: _nameController,
                              icon: Icons.person_rounded,
                            ),
                            _buildCustomTextField(
                              label: "ALAMAT EMAIL (PERMANEN)",
                              controller: _emailController,
                              icon: Icons.lock_outline_rounded,
                              isReadOnly: true,  // Email tidak bisa diubah
                            ),
                            _buildCustomTextField(
                              label: "NOMOR WHATSAPP",
                              controller: _phoneController,
                              icon: Icons.phone_android_rounded,
                              keyboardType: TextInputType.phone,
                            ),
                            _buildCustomTextField(
                              label: "ALAMAT TINGGAL",
                              controller: _addressController,
                              icon: Icons.location_on_rounded,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 30),
                            _buildSaveButton(),
                          ],
                        ),
                      ),
          ),

          // 2. GLASS TOP BAR
          _buildGlassTopBar(context),
        ],
      ),
    );
  }

  // ── STATE VIEWS ──────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: darkBrown, strokeWidth: 2),
          const SizedBox(height: 16),
          Text("Memuat data profil...", style: TextStyle(color: darkBrown.withOpacity(0.5), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, color: darkBrown.withOpacity(0.3), size: 60),
            const SizedBox(height: 16),
            Text("Gagal memuat data", style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(_errorMsg!, textAlign: TextAlign.center, style: TextStyle(color: darkBrown.withOpacity(0.4))),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchProfile,
              style: ElevatedButton.styleFrom(backgroundColor: darkBrown, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text("Coba Lagi", style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  // ── WIDGET COMPONENTS ────────────────────────────────────────────
  Widget _buildGlassTopBar(BuildContext context) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              border: Border(bottom: BorderSide(color: darkBrown.withOpacity(0.05), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: darkBrown.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: darkBrown, size: 16),
                  ),
                ),
                Text("UBAH PROFIL", style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
                const SizedBox(width: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarEditor() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: goldenYellow.withOpacity(0.2), width: 2),
            ),
            child: const CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFFF5EFE6),
              backgroundImage: AssetImage('lib/assets/img/majelis.png'),
            ),
          ),
          Container(
            width: 128,
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
      child: Text(label, style: TextStyle(color: db.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    );
  }

  Widget _buildCustomTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
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
          color: isReadOnly ? darkBrown.withOpacity(0.4) : darkBrown,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: isReadOnly ? darkBrown.withOpacity(0.02) : Colors.white,
          labelText: label,
          labelStyle: TextStyle(color: darkBrown.withOpacity(0.4), fontWeight: FontWeight.w800, fontSize: 10),
          prefixIcon: Icon(icon, color: darkBrown.withOpacity(0.5), size: 18),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: darkBrown.withOpacity(0.06), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: darkBrown.withOpacity(0.2), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBrown,
          foregroundColor: Colors.white,
          disabledBackgroundColor: darkBrown.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                "SIMPAN DATA TERBARU",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2),
              ),
      ),
    );
  }
}