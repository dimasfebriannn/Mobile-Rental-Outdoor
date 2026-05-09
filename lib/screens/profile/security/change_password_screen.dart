// lib/screens/profile/security/change_password_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:majelis_adventure/services/profile_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  static const Color darkBrown = Color(0xFF3E2723);
  static const Color creamBg   = Color(0xFFF5EFE6);

  final _oldPwController     = TextEditingController();
  final _newPwController     = TextEditingController();
  final _confirmPwController = TextEditingController();

  bool _isSaving = false;
  bool _obscureOld     = true;
  bool _obscureNew     = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPwController.dispose();
    _newPwController.dispose();
    _confirmPwController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    // Validasi lokal dulu sebelum hit API
    if (_oldPwController.text.isEmpty || _newPwController.text.isEmpty || _confirmPwController.text.isEmpty) {
      _showSnackBar("Semua field wajib diisi", isError: true);
      return;
    }
    if (_newPwController.text != _confirmPwController.text) {
      _showSnackBar("Konfirmasi sandi baru tidak cocok", isError: true);
      return;
    }
    if (_newPwController.text.length < 8) {
      _showSnackBar("Kata sandi baru minimal 8 karakter", isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final message = await ProfileService.changePassword(
        currentPassword: _oldPwController.text,
        newPassword:     _newPwController.text,
        confirmPassword: _confirmPwController.text,
      );
      if (!mounted) return;
      _showSnackBar(message);
      // Clear semua field setelah berhasil
      _oldPwController.clear();
      _newPwController.clear();
      _confirmPwController.clear();
      // Kembali ke halaman sebelumnya setelah 1 detik
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
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 130, 24, 40),
              child: Column(
                children: [
                  _buildInputGroup(),
                  const SizedBox(height: 40),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
          _buildGlassTopBar(context, "UBAH SANDI"),
        ],
      ),
    );
  }

  Widget _buildInputGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel("KREDENSIAL BARU"),
        _passwordField("Kata Sandi Saat Ini",    _oldPwController,     _obscureOld,     (v) => setState(() => _obscureOld = v)),
        _passwordField("Kata Sandi Baru",         _newPwController,     _obscureNew,     (v) => setState(() => _obscureNew = v)),
        _passwordField("Konfirmasi Sandi Baru",   _confirmPwController, _obscureConfirm, (v) => setState(() => _obscureConfirm = v)),
      ],
    );
  }

  Widget _passwordField(
    String label,
    TextEditingController controller,
    bool obscure,
    Function(bool) onToggle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: darkBrown, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          labelStyle: TextStyle(color: darkBrown.withOpacity(0.4), fontWeight: FontWeight.w800, fontSize: 10),
          prefixIcon: Icon(Icons.lock_outline_rounded, color: darkBrown.withOpacity(0.5), size: 18),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: darkBrown.withOpacity(0.3),
              size: 18,
            ),
            onPressed: () => onToggle(!obscure),
          ),
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

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(label, style: TextStyle(color: darkBrown.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _changePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBrown,
          disabledBackgroundColor: darkBrown.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                height: 18, width: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                "PERBARUI KATA SANDI",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2),
              ),
      ),
    );
  }
}