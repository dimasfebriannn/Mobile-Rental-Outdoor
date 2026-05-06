import 'dart:ui';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPwController = TextEditingController();
  final _newPwController = TextEditingController();
  final _confirmPwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const Color darkBrown = Color(0xFF3E2723);
    const Color creamBg = Color(0xFFF5EFE6);

    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 130, 24, 40),
              child: Column(
                children: [
                  _buildInputGroup(darkBrown),
                  const SizedBox(height: 40),
                  _buildSaveButton(darkBrown),
                ],
              ),
            ),
          ),
          _buildGlassTopBar(context, darkBrown, "UBAH SANDI"),
        ],
      ),
    );
  }

  Widget _buildInputGroup(Color db) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel("KREDENSIAL BARU", db),
        _passwordField("Kata Sandi Saat Ini", _oldPwController, db),
        _passwordField("Kata Sandi Baru", _newPwController, db),
        _passwordField("Konfirmasi Sandi Baru", _confirmPwController, db),
      ],
    );
  }

  Widget _passwordField(String label, TextEditingController controller, Color db) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: true,
        style: TextStyle(color: db, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          labelStyle: TextStyle(color: db.withOpacity(0.4), fontWeight: FontWeight.w800, fontSize: 10),
          prefixIcon: Icon(Icons.lock_outline_rounded, color: db.withOpacity(0.5), size: 18),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: db.withOpacity(0.06), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: db.withOpacity(0.2), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }

  // Reuse Glass Top Bar logic...
  Widget _buildGlassTopBar(BuildContext context, Color db, String title) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              border: Border(bottom: BorderSide(color: db.withOpacity(0.05), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(border: Border.all(color: db.withOpacity(0.1)), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: db, size: 18),
                  ),
                ),
                Text(title, style: TextStyle(color: db, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2.5)),
                const SizedBox(width: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color db) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(label, style: TextStyle(color: db.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    );
  }

  Widget _buildSaveButton(Color db) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: db,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Text("PERBARUI KATA SANDI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
      ),
    );
  }
}