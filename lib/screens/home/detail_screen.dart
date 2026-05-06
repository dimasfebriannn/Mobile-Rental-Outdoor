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

  bool _isAdding = false;

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  // --- LOGIKA TAMBAH KERANJANG (SEDERHANA) ---
  void _handleAddToCart() {
    setState(() => _isAdding = true);
    
    // Simulasi loading proses input ke tabel 'transaksi_detail'
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isAdding = false);
      _showSuccessSheet();
    });
  }

  void _showSuccessSheet() {
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.shopping_cart_checkout_rounded, color: Colors.green, size: 40),
            ),
            const SizedBox(height: 24),
            Text("Masuk Keranjang", style: TextStyle(color: darkBrown, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text(
              "${widget.product.name} telah berhasil ditambahkan. Atur jumlah sewa di menu keranjang.",
              textAlign: TextAlign.center,
              style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBrown,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text("LANJUTKAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mapping data harga dan stok dari tabel 'barang'
    final double hargaPerHari = double.tryParse(widget.product.price.replaceAll('.', '')) ?? 0.0;
    const int stokTersedia = 120; // Contoh data stok dari tabel barang

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
              child: Image.asset(widget.product.imagePath, fit: BoxFit.contain),
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
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildQuickInfo(hargaPerHari, stokTersedia),
                        
                        const SizedBox(height: 32),
                        Text("Spesifikasi Produk", style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 16)),
                        const SizedBox(height: 12),
                        _buildSpecList(),

                        const SizedBox(height: 32),
                        Text("Deskripsi", style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 16)),
                        const SizedBox(height: 10),
                        Text(
                          "Peralatan ekspedisi dari Majelis Adventure ini selalu dalam kondisi steril dan siap tempur. Jaminan keamanan untuk setiap langkah pendakian Anda sesuai standar operasional kami.",
                          style: TextStyle(color: darkBrown.withOpacity(0.6), height: 1.6, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          _buildBackButton(),
          _buildFloatingBottomBar(hargaPerHari),
        ],
      ),
    );
  }

  // --- FLOATING BAR ---
  Widget _buildFloatingBottomBar(double price) {
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
                Text("HARGA SEWA", style: TextStyle(color: darkBrown.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                Text("${_formatCurrency(price)}/hari", style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 18)),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: SizedBox(
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: _isAdding ? null : _handleAddToCart,
                  icon: _isAdding 
                    ? const SizedBox.shrink() 
                    : const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 20),
                  label: _isAdding
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("TAMBAH KERANJANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBrown,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- REUSE COMPONENTS ---
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

  Widget _buildQuickInfo(double price, int stock) {
    return Row(
      children: [
        _infoCard(Icons.payments_outlined, "TARIF HARIAN", _formatCurrency(price)),
        const SizedBox(width: 12),
        _infoCard(Icons.inventory_2_outlined, "STOK UNIT", "$stock"),
      ],
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: creamBg.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: darkBrown.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 13, color: goldenYellow),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: darkBrown.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.w900)),
            ]),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecList() {
    // Contoh spesifikasi yang merujuk pada detail teknis di tabel barang[cite: 1]
    final List<String> specs = ["Kualitas Premium", "Sterilisasi Rutin", "Ketahanan Cuaca Ekstrem", "Ringan & Ergonomis"];
    return Column(
      children: specs.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Icon(Icons.verified_outlined, color: goldenYellow, size: 16),
          const SizedBox(width: 12),
          Text(s, style: TextStyle(color: darkBrown.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
      )).toList(),
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
}