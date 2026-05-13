// lib/screens/cart/cart_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../providers/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Color darkBrown    = const Color(0xFF3E2723);
  final Color goldenYellow = const Color(0xFFE5A93D);
  final Color creamBg      = const Color(0xFFF5EFE6);

  final _cart = CartProvider.instance;

  @override
  void initState() {
    super.initState();
    _cart.addListener(_onCartChanged);
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cart.removeListener(_onCartChanged);
    super.dispose();
  }

  String _formatCurrency(double amount) => NumberFormat.currency(
    locale: 'id', symbol: 'Rp ', decimalDigits: 0,
  ).format(amount);

  @override
  Widget build(BuildContext context) {
    final items = _cart.items;

    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(children: [
        // Background accent
        Positioned(
          top: -30, left: -30,
          child: Icon(
            Icons.shopping_bag_outlined,
            size: 300,
            color: darkBrown.withOpacity(0.03),
          ),
        ),

        // Konten utama
        Positioned.fill(
          child: SafeArea(
            child: items.isEmpty
                ? _buildEmptyState()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 110, 24, 140),
                    child: Column(children: [
                      _buildSectionLabel('DAFTAR PERLENGKAPAN'),
                      ...List.generate(
                        items.length,
                        (i) => _buildCartItem(i),
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryCard(),
                    ]),
                  ),
          ),
        ),

        // Glass top bar
        _buildGlassTopBar(context),

        // Floating checkout button
        if (items.isNotEmpty) _buildFloatingCheckout(),
      ]),
    );
  }

  // ── Cart Item ──────────────────────────────────────────────────────────────
  Widget _buildCartItem(int index) {
    final item    = _cart.items[index];
    final product = item.product;

    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _cart.remove(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.red, size: 24),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: darkBrown.withOpacity(0.08), width: 1.5),
        ),
        child: Row(children: [
          // Gambar produk — FIXED: Center wrapper pada placeholder & error
          Container(
            width: 85, height: 85,
            decoration: BoxDecoration(
              color: creamBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: product.fotoUtama != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      product.fotoUtama!,
                      headers: const {
                        'ngrok-skip-browser-warning': 'true',
                        'User-Agent': 'MajelisApp/1.0',
                      },
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                                : null,
                            color: goldenYellow,
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: darkBrown.withOpacity(0.2),
                          size: 30,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: darkBrown.withOpacity(0.2),
                      size: 30,
                    ),
                  ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama + tombol hapus
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: TextStyle(
                          color: darkBrown, fontSize: 15,
                          fontWeight: FontWeight.w900, letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _showDeleteConfirm(index, product.name);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(Icons.close_rounded,
                            color: darkBrown.withOpacity(0.3), size: 18),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_formatCurrency(product.hargaPerHari)}/hari',
                  style: TextStyle(
                    color: darkBrown.withOpacity(0.4),
                    fontSize: 11, fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQtyCounter(index),
                    Text(
                      _formatCurrency(product.hargaPerHari * item.qty),
                      style: TextStyle(
                        color: darkBrown, fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  void _showDeleteConfirm(int index, String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: darkBrown.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Icon(Icons.delete_outline_rounded,
              color: Colors.red.shade300, size: 40),
          const SizedBox(height: 16),
          Text('Hapus dari Keranjang?',
              style: TextStyle(
                  color: darkBrown, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(name,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: darkBrown.withOpacity(0.5),
                  fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 28),
          Row(children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: darkBrown.withOpacity(0.15)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('BATAL',
                      style: TextStyle(
                          color: darkBrown, fontWeight: FontWeight.w900)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _cart.remove(index);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('HAPUS',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900)),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildQtyCounter(int index) {
    final qty = _cart.items[index].qty;
    return Container(
      decoration: BoxDecoration(
        color: creamBg, borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        _counterBtn(
          qty <= 1 ? Icons.delete_outline_rounded : Icons.remove,
          () {
            if (qty <= 1) {
              _showDeleteConfirm(index, _cart.items[index].product.name);
            } else {
              _cart.decrement(index);
            }
          },
          color: qty <= 1 ? Colors.red.shade300 : darkBrown,
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$qty',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkBrown, fontWeight: FontWeight.w900, fontSize: 12,
            ),
          ),
        ),
        _counterBtn(Icons.add, () => _cart.increment(index)),
      ]),
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Icon(icon, size: 14, color: color ?? darkBrown),
      ),
    );
  }

  // ── Summary Card ───────────────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkBrown.withOpacity(0.08), width: 1.5),
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_cart.items.length} item dipilih',
                style: TextStyle(
                    color: darkBrown.withOpacity(0.5),
                    fontSize: 12, fontWeight: FontWeight.w700)),
            Text('Estimasi/hari',
                style: TextStyle(
                    color: darkBrown.withOpacity(0.3),
                    fontSize: 10, fontWeight: FontWeight.w900,
                    letterSpacing: 0.5)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total',
                style: TextStyle(
                    color: darkBrown, fontSize: 14,
                    fontWeight: FontWeight.w900)),
            Text(_formatCurrency(_cart.totalPerDay),
                style: TextStyle(
                    color: darkBrown, fontSize: 18,
                    fontWeight: FontWeight.w900)),
          ],
        ),
      ]),
    );
  }

  // ── Glass Top Bar ──────────────────────────────────────────────────────────
  Widget _buildGlassTopBar(BuildContext context) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              border: Border(
                bottom: BorderSide(
                  color: darkBrown.withOpacity(0.05), width: 1,
                ),
              ),
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
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: darkBrown, size: 18),
                  ),
                ),
                Column(children: [
                  Text('KERANJANG SEWA',
                      style: TextStyle(
                          color: darkBrown, fontWeight: FontWeight.w900,
                          fontSize: 13, letterSpacing: 2.5)),
                  if (_cart.totalItems > 0)
                    Text('${_cart.totalItems} unit',
                        style: TextStyle(
                            color: goldenYellow, fontSize: 10,
                            fontWeight: FontWeight.w700)),
                ]),
                _cart.items.isNotEmpty
                    ? GestureDetector(
                        onTap: _showClearCartConfirm,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red.shade200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.delete_sweep_outlined,
                              color: Colors.red.shade300, size: 18),
                        ),
                      )
                    : const SizedBox(width: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showClearCartConfirm() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: Text('Kosongkan Keranjang?',
            style: TextStyle(
                color: darkBrown, fontWeight: FontWeight.w900)),
        content: Text('Semua item akan dihapus dari keranjang.',
            style: TextStyle(color: darkBrown.withOpacity(0.5))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: TextStyle(color: darkBrown.withOpacity(0.5))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cart.clear();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Hapus Semua',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Section Label ──────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(label,
          style: TextStyle(
              color: darkBrown.withOpacity(0.3), fontSize: 11,
              fontWeight: FontWeight.w900, letterSpacing: 2.0)),
    );
  }

  // ── Floating Checkout ──────────────────────────────────────────────────────
  Widget _buildFloatingCheckout() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 35),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          boxShadow: [BoxShadow(
              color: darkBrown.withOpacity(0.05),
              blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: Row(children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ESTIMASI HARGA / HARI',
                  style: TextStyle(
                      color: darkBrown.withOpacity(0.3), fontSize: 10,
                      fontWeight: FontWeight.w900, letterSpacing: 1)),
              Text(_formatCurrency(_cart.totalPerDay),
                  style: TextStyle(
                      color: darkBrown, fontSize: 22,
                      fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutScreen(
                        cartItems: _cart.items.toList(),
                        hargaPerHari: _cart.totalPerDay,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBrown,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('LANJUT',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w900,
                        fontSize: 12, letterSpacing: 2)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined,
              size: 80, color: darkBrown.withOpacity(0.08)),
          const SizedBox(height: 16),
          Text('KERANJANG KOSONG',
              style: TextStyle(
                  color: darkBrown.withOpacity(0.2),
                  fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 8),
          Text('Tambahkan perlengkapan dari halaman produk',
              style: TextStyle(
                  color: darkBrown.withOpacity(0.3),
                  fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: darkBrown,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 14),
              elevation: 0,
            ),
            child: const Text('LIHAT PRODUK',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w900,
                    letterSpacing: 1)),
          ),
        ],
      ),
    );
  }
}