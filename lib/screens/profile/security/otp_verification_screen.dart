// lib/screens/profile/security/otp_verification_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:majelis_adventure/services/profile_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const Color darkBrown = Color(0xFF3E2723);
  static const Color creamBg   = Color(0xFFF5EFE6);

  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final profile = await ProfileService.getProfile();
      if (mounted) setState(() { _profile = profile; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Icon(
                    Icons.mark_email_read_rounded,
                    size: 80,
                    color: darkBrown.withOpacity(0.8),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "VERIFIKASI EMAIL",
                    style: TextStyle(color: darkBrown, fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _profile != null
                        ? "Email ${_profile!.email} terdaftar di sistem Majelis Adventure."
                        : "Email Anda terdaftar di sistem OTP Majelis Adventure.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: darkBrown.withOpacity(0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _isLoading ? _buildLoadingCard() : _buildStatusCard(),
                ],
              ),
            ),
          ),
          _buildGlassTopBar(context, "OTP SYSTEM"),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: darkBrown.withOpacity(0.1), width: 1.5),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(color: darkBrown, strokeWidth: 2),
          ),
          const SizedBox(width: 16),
          Text("Memeriksa status...", style: TextStyle(color: darkBrown.withOpacity(0.5), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final isVerified = _profile?.isEmailVerified ?? false;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isVerified ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.verified_rounded : Icons.pending_outlined,
            color: isVerified ? Colors.green : Colors.orange,
            size: 30,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "STATUS VERIFIKASI",
                style: TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.w900),
              ),
              Text(
                isVerified ? "EMAIL TERVALIDASI" : "BELUM DIVERIFIKASI",
                style: TextStyle(
                  color: isVerified ? Colors.green.shade700 : Colors.orange.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
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
}