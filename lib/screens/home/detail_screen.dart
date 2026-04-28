import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/product.dart';

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

  int _selectedDuration = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // 1. AREA GAMBAR UTAMA
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Hero(
              tag: widget.product.name,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(widget.product.imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // 2. KONTEN SCROLLABLE
          Positioned.fill(
            child: SingleChildScrollView(
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
                    padding: const EdgeInsets.fromLTRB(32, 32, 32, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- FIX HEADER OVERFLOW: Gunakan Expanded ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded( // MEMASTIKAN TEKS TIDAK NABRAK RATING
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.product.category.toUpperCase(),
                                    style: TextStyle(color: goldenYellow, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 2),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.product.name,
                                    style: TextStyle(color: darkBrown, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -1),
                                    maxLines: 2, // Jaga-jaga kalau nama sangat panjang
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: creamBg, borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  Icon(Icons.star_rounded, color: goldenYellow, size: 18),
                                  Text(" 4.9", style: TextStyle(color: darkBrown, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Info Spesifikasi (Sudah proporsional)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildQuickInfo(Icons.layers_outlined, "Bahan", "Ripstop"),
                            _buildQuickInfo(Icons.fitness_center_rounded, "Berat", "2.4 Kg"),
                            _buildQuickInfo(Icons.people_outline_rounded, "Kap.", "4 Orang"),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // --- FIX DURATION OVERFLOW: Gunakan SingleChildScrollView ---
                        Text("Durasi Sewa", style: TextStyle(color: darkBrown, fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal, // BISA DIGESER JIKA OVERFLOW
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildDurationOption(1),
                              _buildDurationOption(3),
                              _buildDurationOption(7),
                              _buildDurationOption(14),
                              _buildDurationOption(30),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        Text("Tentang Alat", style: TextStyle(color: darkBrown, fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          "Peralatan ini telah melewati proses sterilisasi dan pengecekan fisik. Sangat cocok digunakan untuk pendakian MDPL tinggi dengan cuaca ekstrem.",
                          style: TextStyle(color: darkBrown.withOpacity(0.6), height: 1.6, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. TOMBOL KEMBALI
          Positioned(
            top: 50, left: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: darkBrown, size: 20),
                  ),
                ),
              ),
            ),
          ),

          // 4. FLOATING BOTTOM BAR
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Biaya", style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 12)),
                      Text(
                        "Rp ${(int.parse(widget.product.price.replaceAll('.', '')) * _selectedDuration).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                        style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkBrown,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text("SEWA SEKARANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationOption(int days) {
    bool isSelected = _selectedDuration == days;
    return GestureDetector(
      onTap: () => setState(() => _selectedDuration = days),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? darkBrown : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? darkBrown : Colors.grey.shade300),
        ),
        child: Text("$days Hari", style: TextStyle(color: isSelected ? Colors.white : darkBrown, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: goldenYellow, size: 14),
            const SizedBox(width: 4),
            Text(title, style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: darkBrown, fontWeight: FontWeight.w800, fontSize: 13)),
      ],
    );
  }
}