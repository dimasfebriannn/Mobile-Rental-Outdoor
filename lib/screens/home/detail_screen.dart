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

  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _selectedDateRange = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 1)),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      initialDateRange: _selectedDateRange,
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
      setState(() => _selectedDateRange = picked);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  // ================= LOGIC SPEK DINAMIS =================
  // Fungsi untuk menentukan spek apa yang tampil berdasarkan kategori
  Widget _buildDynamicSpecs() {
    switch (widget.product.category) {
      case "Tenda":
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickInfo(Icons.people_outline_rounded, "Kapasitas", "4 Orang"),
            _buildQuickInfo(Icons.layers_outlined, "Lapisan", "Double Layer"),
            _buildQuickInfo(Icons.fitness_center_rounded, "Berat", "2.8 Kg"),
          ],
        );
      case "Carrier":
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickInfo(Icons.takeout_dining_outlined, "Volume", "60 Liter"),
            _buildQuickInfo(Icons.accessibility_new_rounded, "Backsystem", "Adjustable"),
            _buildQuickInfo(Icons.fitness_center_rounded, "Berat", "1.5 Kg"),
          ],
        );
      case "Alat Masak":
      case "Kompor":
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickInfo(Icons.local_gas_station_outlined, "Bahan Bakar", "Butane/Gas"),
            _buildQuickInfo(Icons.speed_rounded, "Boil Time", "3.5 Menit"),
            _buildQuickInfo(Icons.settings_input_component_rounded, "Bahan", "Alloy"),
          ],
        );
      case "Lampu":
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickInfo(Icons.wb_sunny_outlined, "Terang", "350 Lumens"),
            _buildQuickInfo(Icons.battery_charging_full_rounded, "Power", "Rechargeable"),
            _buildQuickInfo(Icons.water_drop_outlined, "Fitur", "Waterproof"),
          ],
        );
      case "Sepatu":
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickInfo(Icons.high_quality_rounded, "Tipe", "Mid Cut"),
            _buildQuickInfo(Icons.shield_outlined, "Sole", "Vibram Outsole"),
            _buildQuickInfo(Icons.water_drop_outlined, "Upper", "Gore-Tex"),
          ],
        );
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickInfo(Icons.verified_user_outlined, "Kualitas", "Original"),
            _buildQuickInfo(Icons.cleaning_services_outlined, "Kondisi", "Steril"),
            _buildQuickInfo(Icons.fitness_center_rounded, "Berat", "N/A"),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalDays = _selectedDateRange?.duration.inDays ?? 1;
    if (totalDays == 0) totalDays = 1;

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

                        // SPEK DINAMIS DIPANGGIL DI SINI
                        _buildDynamicSpecs(),

                        const SizedBox(height: 32),
                        Text("Periode Sewa", style: TextStyle(color: darkBrown, fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 12),
                        _buildDateSelectorCard(),

                        const SizedBox(height: 32),
                        Text("Deskripsi Produk", style: TextStyle(color: darkBrown, fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          "Produk ini merupakan gear pilihan terbaik dari Majelis Adventure. Semua alat telah melalui pengecekan kebersihan dan keamanan yang ketat sebelum diserahkan ke pelanggan.",
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
          _buildFloatingBottomBar(totalDays),
        ],
      ),
    );
  }

  // WIDGET HELPERS
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.product.category.toUpperCase(), style: TextStyle(color: goldenYellow, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 2)),
              const SizedBox(height: 4),
              Text(widget.product.name, style: TextStyle(color: darkBrown, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -1)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: creamBg, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [Icon(Icons.star_rounded, color: goldenYellow, size: 18), Text(" 4.9", style: TextStyle(color: darkBrown, fontWeight: FontWeight.bold))]),
        ),
      ],
    );
  }

  Widget _buildDateSelectorCard() {
    return InkWell(
      onTap: () => _selectDateRange(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: creamBg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: darkBrown.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            _dateBox("Ambil", _formatDate(_selectedDateRange!.start)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: Icon(Icons.arrow_forward_rounded, color: goldenYellow, size: 20)),
            _dateBox("Kembali", _formatDate(_selectedDateRange!.end)),
            const Spacer(),
            Icon(Icons.calendar_month_rounded, color: darkBrown),
          ],
        ),
      ),
    );
  }

  Widget _dateBox(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(date, style: TextStyle(color: darkBrown, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 50, left: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.3))),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: darkBrown, size: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBottomBar(int days) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total ($days Hari)", style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold)),
                Text(
                  "Rp ${(int.parse(widget.product.price.replaceAll('.', '')) * days).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                  style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 20),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: darkBrown, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                  child: const Text("SEWA SEKARANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
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