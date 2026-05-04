import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/product.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatefulWidget {
  final Product product;

  const DetailScreen({super.key, required this.product});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final Color darkBrown = const Color(0xFF3E2723);
  final Color goldenYellow = const Color(0xFFE5A93D);
  final Color creamBg = const Color(0xFFF5EFE6);

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  bool _isBooking = false;

  // --- LOGIKA PICKER TANGGAL TUNGGAL ---
  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: isStart ? DateTime.now() : _startDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: darkBrown,
              onPrimary: Colors.white,
              onSurface: darkBrown,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Validasi agar tanggal kembali minimal H+1 dari tanggal ambil
          if (_startDate.isAfter(_endDate) || _startDate.isAtSameMomentAs(_endDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  void _handleSewa(int totalDays, String totalPrice) {
    setState(() => _isBooking = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isBooking = false);
      _showSuccessSheet(totalDays, totalPrice);
    });
  }

  void _showSuccessSheet(int days, String price) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 60),
            const SizedBox(height: 24),
            Text("Berhasil Dipesan!", style: TextStyle(color: darkBrown, fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text(
              "Pesanan untuk ${widget.product.name} telah masuk ke keranjang untuk tanggal ${_formatDate(_startDate)}.",
              textAlign: TextAlign.center,
              style: TextStyle(color: darkBrown.withOpacity(0.6), fontSize: 14),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBrown, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                ),
                child: const Text("TUTUP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hitung durasi hari
    int totalDays = _endDate.difference(_startDate).inDays;
    if (totalDays <= 0) totalDays = 1;

    int priceInt = int.parse(widget.product.price.replaceAll('.', ''));
    String totalPriceFormatted = NumberFormat.currency(
      locale: 'id', 
      symbol: 'Rp ', 
      decimalDigits: 0
    ).format(priceInt * totalDays);

    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // 1. IMAGE HERO
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Hero(
              tag: widget.product.name, 
              child: Image.asset(widget.product.imagePath, fit: BoxFit.contain)
            ),
          ),

          // 2. SCROLLABLE CONTENT
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.42),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(45)),
                      boxShadow: [
                        BoxShadow(color: darkBrown.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, -10))
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(32, 32, 32, 140),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(), // Tanpa Rating
                        const SizedBox(height: 32),
                        Text("Periode Sewa", style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 16)),
                        const SizedBox(height: 16),
                        
                        // DUAL DATE SELECTOR (MODEL BARU)
                        _buildDualDateSelectors(),

                        const SizedBox(height: 32),
                        _buildDynamicSpecs(),
                        const SizedBox(height: 32),
                        Text("Deskripsi", style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          "Peralatan ekspedisi kualitas premium yang selalu disterilisasi sebelum dan sesudah penggunaan. Jaminan kenyamanan pendakian Anda.",
                          style: TextStyle(color: darkBrown.withOpacity(0.6), height: 1.6, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          _buildBackButton(),
          _buildFloatingBottomBar(totalDays, totalPriceFormatted),
        ],
      ),
    );
  }

  // --- WIDGET DUAL DATE SELECTOR ---
  Widget _buildDualDateSelectors() {
    return Row(
      children: [
        Expanded(child: _datePickerCard("AMBIL", _startDate, true)),
        const SizedBox(width: 12),
        Expanded(child: _datePickerCard("KEMBALI", _endDate, false)),
      ],
    );
  }

  Widget _datePickerCard(String label, DateTime date, bool isStart) {
    return InkWell(
      onTap: () => _pickDate(context, isStart),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: creamBg.withOpacity(0.4),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: darkBrown.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: goldenYellow, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: darkBrown),
                const SizedBox(width: 8),
                Text(_formatDate(date), style: TextStyle(color: darkBrown, fontSize: 13, fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.product.category.toUpperCase(), style: TextStyle(color: goldenYellow, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
        const SizedBox(height: 8),
        Text(widget.product.name, style: TextStyle(color: darkBrown, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
      ],
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 50, left: 24,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: darkBrown, size: 18),
        ),
      ),
    );
  }

  Widget _buildFloatingBottomBar(int days, String price) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total ($days Hari)", style: TextStyle(color: darkBrown.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w900)),
                Text(price, style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 22)),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _isBooking ? null : () => _handleSewa(days, price),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBrown, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), 
                    elevation: 0
                  ),
                  child: _isBooking 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("SEWA SEKARANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicSpecs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _specItem(Icons.verified_user_outlined, "Official"),
        _specItem(Icons.cleaning_services_outlined, "Steril"),
        _specItem(Icons.fitness_center_rounded, "Pro Gear"),
      ],
    );
  }

  Widget _specItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: goldenYellow, size: 16),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: darkBrown, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}