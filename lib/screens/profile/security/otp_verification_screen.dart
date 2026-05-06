import 'dart:ui';
import 'package:flutter/material.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkBrown = Color(0xFF3E2723);
    const Color creamBg = Color(0xFFF5EFE6);

    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 130, 24, 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mark_email_read_rounded, size: 80, color: darkBrown.withOpacity(0.8)),
                  const SizedBox(height: 24),
                  const Text("VERIFIKASI EMAIL", style: TextStyle(color: darkBrown, fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text(
                    "Email anda saat ini sudah terverifikasi melalui sistem OTP Majelis Adventure.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 40),
                  _buildStatusCard(darkBrown),
                ],
              ),
            ),
          ),
          _buildGlassTopBar(context, darkBrown, "OTP SYSTEM"),
        ],
      ),
    );
  }

  Widget _buildStatusCard(Color db) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: db.withOpacity(0.1), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, color: Colors.green, size: 30),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("STATUS VERIFIKASI", style: TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.w900)),
              Text("EMAIL TERVALIDASI", style: TextStyle(color: db, fontSize: 14, fontWeight: FontWeight.w900)),
            ],
          )
        ],
      ),
    );
  }

  // Same Glass Top Bar logic...
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
}