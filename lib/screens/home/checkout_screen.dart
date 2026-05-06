import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalSewa;
  final DateTime tglAmbil;
  final DateTime tglKembali;

  const CheckoutScreen({
    super.key, 
    required this.totalSewa, 
    required this.tglAmbil, 
    required this.tglKembali
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final Color darkBrown = const Color(0xFF3E2723);
  final Color goldenYellow = const Color(0xFFE5A93D);
  final Color creamBg = const Color(0xFFF5EFE6);

  String _selectedMethod = "midtrans"; 
  String _selectedIDType = "KTP"; 
  bool _isAgreed = false; 
  bool _isLoading = false;

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  // --- LOGIKA PROSES PEMBAYARAN ---
  Future<void> _processPayment() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulasi hit ke API Laravel
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (_selectedMethod == "midtrans") {
      _showPaymentGatewayMock();
    } else {
      _showPremiumSuccessDialog();
    }
  }

  // --- REVISI: POPUP SUKSES PREMIUM ---
  void _showPremiumSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Success Luxury
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: goldenYellow.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.verified_rounded, color: goldenYellow, size: 50),
              ),
              const SizedBox(height: 24),
              Text(
                "PESANAN BERHASIL", 
                style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5)
              ),
              const SizedBox(height: 12),
              Text(
                "Nomor Transaksi Anda:",
                style: TextStyle(color: darkBrown.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              // Simulasi nomor_transaksi dari DB
              Text(
                "TRX-MAJELIS-2026-001", 
                style: TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)
              ),
              const SizedBox(height: 20),
              Text(
                "Perlengkapan Anda telah disiapkan. Silakan ambil di basecamp sesuai jadwal pengambilan.",
                textAlign: TextAlign.center,
                style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBrown,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text("KEMBALI KE BERANDA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentGatewayMock() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            Text("MIDTRANS SNAP", style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const Spacer(),
            Icon(Icons.qr_code_2_rounded, size: 200, color: darkBrown),
            const SizedBox(height: 10),
            Text("Selesaikan pembayaran dalam 24 jam", style: TextStyle(color: darkBrown.withOpacity(0.4), fontSize: 12)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00AEF0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: () { Navigator.pop(context); _showPremiumSuccessDialog(); },
                child: const Text("SIMULASI BAYAR QRIS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          Positioned(top: -30, left: -30, child: Icon(Icons.payments_rounded, size: 300, color: darkBrown.withOpacity(0.03))),
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 110, 24, 140),
                child: Column(
                  children: [
                    _buildSectionLabel("RINGKASAN JADWAL"),
                    _buildDenseScheduleCard(),
                    const SizedBox(height: 28),
                    _buildSectionLabel("JAMINAN IDENTITAS"),
                    _buildIdentitySection(),
                    const SizedBox(height: 28),
                    _buildSectionLabel("METODE PEMBAYARAN"),
                    _buildDensePaymentOption("Cashless (Midtrans)", "Otomatis & Terintegrasi", "midtrans", Icons.account_balance_wallet_outlined),
                    const SizedBox(height: 10),
                    _buildDensePaymentOption("Tunai (COD)", "Bayar langsung di basecamp", "tunai", Icons.payments_outlined),
                    const SizedBox(height: 28),
                    _buildSectionLabel("DETAIL BIAYA"),
                    _buildDensePriceCard(),
                    const SizedBox(height: 24),
                    _buildSKChecklist(),
                  ],
                ),
              ),
            ),
          ),
          _buildGlassTopBar(context),
          _buildFloatingBottomBar(),
        ],
      ),
    );
  }

  // --- REUSED COMPONENTS (RAMPING & DENSE) ---

  Widget _buildGlassTopBar(BuildContext context) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 15),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), border: Border(bottom: BorderSide(color: darkBrown.withOpacity(0.05), width: 1))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(border: Border.all(color: darkBrown.withOpacity(0.1)), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.arrow_back_ios_new_rounded, color: darkBrown, size: 18)),
                ),
                Text("CHECKOUT", style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2.5)),
                const SizedBox(width: 40), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Container(width: double.infinity, padding: const EdgeInsets.only(left: 4, bottom: 12), child: Text(label, style: TextStyle(color: darkBrown.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2.0)));
  }

  Widget _buildDenseScheduleCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: darkBrown.withOpacity(0.08), width: 1.5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _dateInfo("AMBIL", widget.tglAmbil),
          Icon(Icons.arrow_forward_ios_rounded, color: darkBrown.withOpacity(0.1), size: 14),
          _dateInfo("KEMBALI", widget.tglKembali),
        ],
      ),
    );
  }

  Widget _dateInfo(String label, DateTime date) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: goldenYellow, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)), const SizedBox(height: 4), Text(DateFormat('dd MMM yyyy').format(date).toUpperCase(), style: TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w900))]);
  }

  Widget _buildIdentitySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: darkBrown.withOpacity(0.08), width: 1.5)),
      child: Column(children: [
        Row(children: [_idTypeChip("KTP"), const SizedBox(width: 8), _idTypeChip("SIM"), const SizedBox(width: 8), _idTypeChip("PELAJAR")]),
        const SizedBox(height: 16),
        InkWell(onTap: () {}, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: creamBg.withOpacity(0.5), borderRadius: BorderRadius.circular(14), border: Border.all(color: darkBrown.withOpacity(0.05))), child: Column(children: [Icon(Icons.camera_enhance_outlined, color: goldenYellow, size: 24), const SizedBox(height: 8), Text("UNGGAH FOTO IDENTITAS", style: TextStyle(color: darkBrown, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))]))),
      ]),
    );
  }

  Widget _idTypeChip(String type) {
    bool isSelected = _selectedIDType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedIDType = type),
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: isSelected ? darkBrown : creamBg.withOpacity(0.3), borderRadius: BorderRadius.circular(10)), child: Text(type, style: TextStyle(color: isSelected ? Colors.white : darkBrown.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w900))),
    );
  }

  Widget _buildDensePaymentOption(String title, String subtitle, String value, IconData icon) {
    bool isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: isSelected ? goldenYellow.withOpacity(0.05) : Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: isSelected ? goldenYellow : darkBrown.withOpacity(0.08), width: 1.5)), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isSelected ? goldenYellow.withOpacity(0.1) : creamBg, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: isSelected ? goldenYellow : darkBrown, size: 22)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: -0.3)), Text(subtitle, style: TextStyle(color: darkBrown.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w600))])), if (isSelected) Icon(Icons.check_circle_rounded, color: goldenYellow, size: 20)])),
    );
  }

  Widget _buildDensePriceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: darkBrown.withOpacity(0.08), width: 1.5)),
      child: Column(children: [
        _priceRow("Subtotal Sewa", widget.totalSewa),
        const SizedBox(height: 10),
        _priceRow("Biaya Layanan", 2000), 
        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, thickness: 1)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("TOTAL BAYAR", style: TextStyle(color: darkBrown.withOpacity(0.3), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)), Text(_formatCurrency(widget.totalSewa + 2000), style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 18))]),
      ]),
    );
  }

  Widget _priceRow(String label, double price) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: darkBrown.withOpacity(0.4), fontWeight: FontWeight.w700, fontSize: 13)), Text(_formatCurrency(price), style: TextStyle(color: darkBrown, fontWeight: FontWeight.w800, fontSize: 13))]);
  }

  Widget _buildSKChecklist() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(height: 24, width: 24, child: Checkbox(value: _isAgreed, activeColor: darkBrown, checkColor: goldenYellow, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), side: BorderSide(color: darkBrown.withOpacity(0.1), width: 1.5), onChanged: (val) => setState(() => _isAgreed = val!))), const SizedBox(width: 12), Expanded(child: Text("Saya menyetujui Syarat & Ketentuan penyewaan alat di Majelis Adventure, termasuk tanggung jawab atas kerusakan atau keterlambatan.", style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w600, height: 1.5)))]);
  }

  Widget _buildFloatingBottomBar() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 35),
        decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(35)), boxShadow: [BoxShadow(color: darkBrown.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (_isAgreed && !_isLoading) ? _processPayment : null, 
            style: ElevatedButton.styleFrom(backgroundColor: darkBrown, disabledBackgroundColor: darkBrown.withOpacity(0.1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
            child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(_selectedMethod == "tunai" ? "KONFIRMASI PESANAN" : "PROSES PEMBAYARAN", style: TextStyle(color: _isAgreed ? Colors.white : darkBrown.withOpacity(0.3), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
          ),
        ),
      ),
    );
  }
}