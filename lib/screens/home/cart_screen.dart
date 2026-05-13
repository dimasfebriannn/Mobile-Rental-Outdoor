import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Color darkBrown = const Color(0xFF3E2723);
  final Color goldenYellow = const Color(0xFFE5A93D);
  final Color creamBg = const Color(0xFFF5EFE6);

  List<Map<String, dynamic>> cartItems = [
    {
      "id": 10,
      "nama": "Tenda Eiger Guardian",
      "harga_per_hari": 60000.00,
      "qty": 1,
      "img": "lib/assets/img/majelis.png",
    },
    {
      "id": 14,
      "nama": "Carrier Osprey 60L",
      "harga_per_hari": 75000.00,
      "qty": 1,
      "img": "lib/assets/img/majelis.png",
    },
  ];

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  // Estimasi total di keranjang dihitung per 1 hari sebagai standar awal
  double get _totalEstimationPerDay {
    double total = 0;
    for (var item in cartItems) {
      total += (item['harga_per_hari'] * item['qty']);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // Background Accent
          Positioned(
            top: -30,
            left: -30,
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 300,
              color: darkBrown.withOpacity(0.03),
            ),
          ),

          // Konten Utama
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 110, 24, 140),
                child: Column(
                  children: [
                    // Langsung masuk ke Daftar Perlengkapan agar lebih ramping
                    _buildSectionLabel("DAFTAR PERLENGKAPAN"),
                    ...cartItems
                        .asMap()
                        .entries
                        .map((entry) => _buildDenseCartItem(entry.key))
                        .toList(),
                    if (cartItems.isEmpty) _buildEmptyState(),
                  ],
                ),
              ),
            ),
          ),

          // Glass Top Bar melayang
          _buildGlassTopBar(context),

          // Floating Checkout Button
          if (cartItems.isNotEmpty) _buildFloatingCheckout(),
        ],
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildGlassTopBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              border: Border(
                bottom: BorderSide(
                  color: darkBrown.withOpacity(0.05),
                  width: 1,
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
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: darkBrown,
                      size: 18,
                    ),
                  ),
                ),
                Text(
                  "KERANJANG SEWA",
                  style: TextStyle(
                    color: darkBrown,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        label,
        style: TextStyle(
          color: darkBrown.withOpacity(0.3),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildDenseCartItem(int index) {
    final item = cartItems[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkBrown.withOpacity(0.08), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              color: creamBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset(item['img'], fit: BoxFit.contain),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nama'],
                  style: TextStyle(
                    color: darkBrown,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "${_formatCurrency(item['harga_per_hari'])}/hari",
                  style: TextStyle(
                    color: darkBrown.withOpacity(0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQtyCounter(index),
                    Text(
                      _formatCurrency(item['harga_per_hari'] * item['qty']),
                      style: TextStyle(
                        color: darkBrown,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyCounter(int index) {
    return Container(
      decoration: BoxDecoration(
        color: creamBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _counterBtn(
            Icons.remove,
            () => setState(() {
              if (cartItems[index]['qty'] > 1) cartItems[index]['qty']--;
            }),
          ),
          Text(
            "${cartItems[index]['qty']}",
            style: TextStyle(
              color: darkBrown,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          _counterBtn(
            Icons.add,
            () => setState(() => cartItems[index]['qty']++),
          ),
        ],
      ),
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Icon(icon, size: 14, color: darkBrown),
      ),
    );
  }

  Widget _buildFloatingCheckout() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 35),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          boxShadow: [
            BoxShadow(
              color: darkBrown.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ESTIMASI HARGA / HARI",
                  style: TextStyle(
                    color: darkBrown.withOpacity(0.3),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  _formatCurrency(_totalEstimationPerDay),
                  style: TextStyle(
                    color: darkBrown,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Berpindah ke Checkout dengan mengirimkan harga total harian
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(
                          hargaPerHari: _totalEstimationPerDay,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBrown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "LANJUT",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Column(
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 80,
            color: darkBrown.withOpacity(0.05),
          ),
          const SizedBox(height: 16),
          Text(
            "KERANJANG KOSONG",
            style: TextStyle(
              color: darkBrown.withOpacity(0.2),
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
