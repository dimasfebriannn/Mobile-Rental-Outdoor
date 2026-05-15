// lib/screens/checkout/weather_recommendation_section.dart
//
// Widget lengkap yang ditampilkan di checkout_screen setelah user
// memilih tanggal ambil dan lokasi tujuan.
//
// Menampilkan:
//   1. Tombol "Pilih Lokasi Tujuan" → buka lokasi_picker_sheet
//   2. Jika lokasi + tanggal sudah ada → fetch cuaca otomatis
//   3. Card cuaca (suhu, kondisi, pesan peringatan)
//   4. Daftar barang rekomendasi dengan gambar + tombol "Tambah ke Keranjang"
//      Tap pada kartu → buka DetailScreen

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/weather_recommendation.dart';
import '../../models/product.dart';                      // ← untuk buat Product
import '../../providers/cart_provider.dart';
import '../../services/cuaca_service.dart';
import '../home/detail_screen.dart';                     // ← navigasi ke detail
import 'lokasi_picker_sheet.dart';

// ── Warna level cuaca ─────────────────────────────────────────────────────────
Color _levelColor(String level) {
  switch (level) {
    case 'danger':  return const Color(0xFFEF5350);
    case 'warning': return const Color(0xFFFFA726);
    case 'good':    return const Color(0xFF66BB6A);
    default:        return const Color(0xFF90A4AE);
  }
}

IconData _levelIcon(String level) {
  switch (level) {
    case 'danger':  return Icons.warning_amber_rounded;
    case 'warning': return Icons.cloud_queue_rounded;
    case 'good':    return Icons.wb_sunny_rounded;
    default:        return Icons.device_thermostat_rounded;
  }
}

class WeatherRecommendationSection extends StatefulWidget {
  final DateTime? tanggalAmbil;
  final void Function(WeatherBarang barang)? onTambahKeranjang;

  const WeatherRecommendationSection({
    super.key,
    this.tanggalAmbil,
    this.onTambahKeranjang,
  });

  @override
  State<WeatherRecommendationSection> createState() =>
      _WeatherRecommendationSectionState();
}

class _WeatherRecommendationSectionState
    extends State<WeatherRecommendationSection> {
  // ── Warna ──────────────────────────────────────────────────────────────────
  final Color darkBrown    = const Color(0xFF3E2723);
  final Color goldenYellow = const Color(0xFFE5A93D);
  final Color creamBg      = const Color(0xFFF5EFE6);

  // ── Header HTTP yang wajib disertakan (ngrok + custom UA) ─────────────────
  static const Map<String, String> _imgHeaders = {
    'ngrok-skip-browser-warning': 'true',
    'User-Agent': 'MajelisApp/1.0',
  };

  // ── State ──────────────────────────────────────────────────────────────────
  LokasiPilihan? _lokasi;
  WeatherResponse? _weatherResp;
  bool _isLoading = false;
  String? _errorMsg;

  // ── Buka picker lokasi ─────────────────────────────────────────────────────
  Future<void> _pilihLokasi() async {
    final lokasi = await showLokasiPickerSheet(context);
    if (lokasi == null || !mounted) return;

    setState(() {
      _lokasi      = lokasi;
      _weatherResp = null;
      _errorMsg    = null;
    });

    if (widget.tanggalAmbil != null) {
      await _fetchCuaca();
    }
  }

  // ── Fetch cuaca ────────────────────────────────────────────────────────────
  Future<void> _fetchCuaca() async {
    if (_lokasi == null || widget.tanggalAmbil == null) return;

    setState(() { _isLoading = true; _errorMsg = null; });

    try {
      final resp = await CuacaService.instance.cekCuaca(
        lat:          _lokasi!.lat,
        lon:          _lokasi!.lon,
        namaLokasi:   _lokasi!.namaPendek,
        tanggalAmbil: DateFormat('yyyy-MM-dd').format(widget.tanggalAmbil!),
      );
      if (mounted) setState(() => _weatherResp = resp);
    } catch (e) {
      if (mounted) setState(() => _errorMsg = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void didUpdateWidget(WeatherRecommendationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tanggalAmbil != widget.tanggalAmbil &&
        _lokasi != null &&
        widget.tanggalAmbil != null) {
      _fetchCuaca();
    }
  }

  // ── Navigasi ke DetailScreen ───────────────────────────────────────────────
  void _bukaDetail(WeatherBarang barang) {
    // Buat Product dari WeatherBarang; DetailScreen akan fetch data penuh
    // lewat _fetchDetail() karena foto list-nya kosong.
    final product = Product(
      id:          barang.id,
      name:        barang.nama,
      hargaPerHari: barang.harga,
      category:    barang.kategori,
      fotoUtama:   barang.foto,
      stok:        barang.stok,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(product: product)),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'LOKASI & REKOMENDASI CUACA',
            style: TextStyle(
              color: darkBrown.withOpacity(0.3),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
        ),

        // ── Tombol pilih lokasi ─────────────────────────────────────────────
        GestureDetector(
          onTap: _pilihLokasi,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _lokasi != null
                    ? goldenYellow.withOpacity(0.5)
                    : darkBrown.withOpacity(0.08),
                width: _lokasi != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _lokasi != null
                        ? goldenYellow.withOpacity(0.12)
                        : creamBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.place_rounded,
                    color: _lokasi != null ? goldenYellow : darkBrown.withOpacity(0.3),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _lokasi != null ? 'LOKASI TUJUAN' : 'PILIH LOKASI TUJUAN',
                        style: TextStyle(
                          color: goldenYellow,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _lokasi?.namaPendek ?? 'Pilih destinasi camping Anda',
                        style: TextStyle(
                          color: _lokasi != null
                              ? darkBrown
                              : darkBrown.withOpacity(0.35),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: darkBrown.withOpacity(0.2),
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // ── Peringatan jika lokasi dipilih tapi belum ada tanggal ──────────
        if (_lokasi != null && widget.tanggalAmbil == null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              'Pilih tanggal ambil dulu untuk melihat prediksi cuaca',
              style: TextStyle(
                color: goldenYellow,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        // ── Loading ─────────────────────────────────────────────────────────
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: goldenYellow, strokeWidth: 2),
                  const SizedBox(height: 10),
                  Text(
                    'Mengecek cuaca di ${_lokasi?.namaPendek ?? 'lokasi'}...',
                    style: TextStyle(
                      color: darkBrown.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Error ────────────────────────────────────────────────────────────
        if (_errorMsg != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade400, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Gagal memuat data cuaca. Coba lagi.',
                      style: TextStyle(color: Colors.red.shade600, fontSize: 11),
                    ),
                  ),
                  GestureDetector(
                    onTap: _fetchCuaca,
                    child: Text(
                      'COBA LAGI',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Hasil cuaca ──────────────────────────────────────────────────────
        if (_weatherResp != null && !_isLoading) ...[
          const SizedBox(height: 14),
          _buildWeatherCard(_weatherResp!),
          if (_weatherResp!.rekomendasi.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildRekomendasiHeader(),
            const SizedBox(height: 10),
            _buildRekomendasiList(_weatherResp!.rekomendasi),
          ],
          if (_weatherResp!.message != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _weatherResp!.message!,
                style: TextStyle(
                  color: darkBrown.withOpacity(0.45),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ],
    );
  }

  // ── Card cuaca ─────────────────────────────────────────────────────────────
  Widget _buildWeatherCard(WeatherResponse resp) {
    final cuaca = resp.cuaca;
    if (cuaca == null) return const SizedBox.shrink();

    final levelColor = _levelColor(cuaca.level);
    final levelIcon  = _levelIcon(cuaca.level);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: levelColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lokasi + tanggal
          Row(
            children: [
              Icon(Icons.place_rounded, size: 12, color: goldenYellow),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  resp.lokasi,
                  style: TextStyle(
                    color: darkBrown.withOpacity(0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy').format(widget.tanggalAmbil!),
                style: TextStyle(
                  color: goldenYellow,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Suhu + icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (cuaca.iconUrl.isNotEmpty)
                Image.network(
                  cuaca.iconUrl,
                  width: 56,
                  height: 56,
                  headers: _imgHeaders,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.cloud, color: goldenYellow, size: 48),
                )
              else
                Icon(Icons.wb_sunny, color: goldenYellow, size: 48),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${cuaca.suhu}°',
                          style: TextStyle(
                            color: darkBrown,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4, left: 4),
                          child: Text(
                            'C',
                            style: TextStyle(
                              color: darkBrown.withOpacity(0.5),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      cuaca.deskripsi,
                      style: TextStyle(
                        color: darkBrown.withOpacity(0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _cuacaChip(Icons.water_drop_outlined, '${cuaca.kelembaban}%', 'Lembab'),
                  const SizedBox(height: 4),
                  _cuacaChip(Icons.air_rounded, '${cuaca.angin} km/h', 'Angin'),
                  const SizedBox(height: 4),
                  _cuacaChip(Icons.thermostat_outlined, '${cuaca.suhuMin}°-${cuaca.suhuMax}°', 'Min-Max'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: levelColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(levelIcon, color: levelColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cuaca.pesan,
                    style: TextStyle(
                      color: levelColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cuacaChip(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: darkBrown.withOpacity(0.3)),
        const SizedBox(width: 3),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value,
                style: TextStyle(
                    color: darkBrown, fontSize: 10, fontWeight: FontWeight.w800)),
            Text(label,
                style: TextStyle(
                    color: darkBrown.withOpacity(0.35),
                    fontSize: 8,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  // ── Header rekomendasi ─────────────────────────────────────────────────────
  Widget _buildRekomendasiHeader() {
    return Row(
      children: [
        Icon(Icons.auto_awesome_rounded, size: 14, color: goldenYellow),
        const SizedBox(width: 6),
        Text(
          'BARANG DIREKOMENDASIKAN',
          style: TextStyle(
            color: darkBrown.withOpacity(0.5),
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const Spacer(),
        Text(
          'Tap untuk detail →',
          style: TextStyle(
            color: goldenYellow.withOpacity(0.7),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ── List horizontal rekomendasi ────────────────────────────────────────────
  Widget _buildRekomendasiList(List<WeatherBarang> items) {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _buildRekomendasiCard(items[i]),
      ),
    );
  }

  // ── Kartu rekomendasi (tap → DetailScreen) ─────────────────────────────────
  Widget _buildRekomendasiCard(WeatherBarang b) {
    final cart     = CartProvider.instance;
    final sudahAda = cart.items.any((item) => item.product.id == b.id);

    return GestureDetector(
      // ── FIX: tap kartu → buka DetailScreen ──────────────────────────────
      onTap: () => _bukaDetail(b),
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: sudahAda
                ? goldenYellow.withOpacity(0.5)
                : darkBrown.withOpacity(0.08),
            width: sudahAda ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Foto ──────────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: SizedBox(
                height: 90,
                width: double.infinity,
                child: b.foto != null && b.foto!.isNotEmpty
                    ? Image.network(
                        b.foto!,
                        fit: BoxFit.cover,
                        // ── FIX: header wajib untuk bypass ngrok warning ──
                        headers: _imgHeaders,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: creamBg,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                    : null,
                                color: goldenYellow,
                                strokeWidth: 1.5,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => _fotoPlaceholder(),
                      )
                    : _fotoPlaceholder(),
              ),
            ),

            // ── Info ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.nama,
                    style: TextStyle(
                      color: darkBrown,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    b.hargaFormatted,
                    style: TextStyle(
                      color: goldenYellow,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Tombol tambah ke keranjang ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: GestureDetector(
                // Hentikan propagasi ke GestureDetector luar (jangan buka detail)
                onTap: sudahAda
                    ? null
                    : () {
                        widget.onTambahKeranjang?.call(b);
                      },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: sudahAda
                        ? goldenYellow.withOpacity(0.1)
                        : darkBrown,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        sudahAda
                            ? Icons.check_rounded
                            : Icons.add_shopping_cart_rounded,
                        size: 12,
                        color: sudahAda ? goldenYellow : Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sudahAda ? 'DI KERANJANG' : 'TAMBAH',
                        style: TextStyle(
                          color: sudahAda ? goldenYellow : Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fotoPlaceholder() {
    return Container(
      color: creamBg,
      child: Center(
        child: Icon(
          Icons.backpack_outlined,
          color: darkBrown.withOpacity(0.2),
          size: 28,
        ),
      ),
    );
  }
}