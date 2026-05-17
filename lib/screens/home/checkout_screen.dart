// lib/screens/checkout/checkout_screen.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/cart_provider.dart';
import '../../services/checkout_service.dart';
import '../../models/weather_recommendation.dart';
import '../../models/product.dart';
import '../checkout/weather_recommendation_section.dart';
import '../history/history_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    // ignore: unused_element
    List<CartItem>? cartItems,
    // ignore: unused_element
    double? hargaPerHari,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // ── Warna ──────────────────────────────────────────────────────────────────
  final Color darkBrown = const Color(0xFF3E2723);
  final Color goldenYellow = const Color(0xFFE5A93D);
  final Color creamBg = const Color(0xFFF5EFE6);

  // ── Cart ───────────────────────────────────────────────────────────────────
  final _cart = CartProvider.instance;

  // ── Form state ─────────────────────────────────────────────────────────────
  DateTime? _tglAmbil;
  DateTime? _tglKembali;
  String _selectedMethod = 'midtrans';
  String _selectedIDType = 'KTP';
  File? _imageFile;
  bool _isAgreed = false;
  bool _isLoading = false;
  HasilValidasiIdentitas? _hasilValidasi;

  // ── Identity validation ────────────────────────────────────────────────────
  String? _identityValidationMessage;
  bool _isValidatingIdentity = false;
  bool _isIdentityValid = false;

  // ── Lokasi tujuan (untuk fitur cuaca) ─────────────────────────────────────
  LokasiPilihan? _lokasiTujuan;

  final ImagePicker _picker = ImagePicker();

  // ── Lifecycle ──────────────────────────────────────────────────────────────
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

  // ── Format ─────────────────────────────────────────────────────────────────
  String _formatCurrency(double amount) => NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(amount);

  // ── Durasi & Total ─────────────────────────────────────────────────────────
  int get _durasi {
    if (_tglAmbil == null || _tglKembali == null) return 0;
    final diff = _tglKembali!.difference(_tglAmbil!).inDays;
    return diff > 0 ? diff : 1;
  }

  double get _totalSewa => _cart.totalPerDay * _durasi;

  // ── Pilih tanggal ──────────────────────────────────────────────────────────
  Future<void> _selectDate(BuildContext context, bool isAmbil) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isAmbil
          ? (_tglAmbil ?? DateTime.now())
          : (_tglKembali ??
                (_tglAmbil?.add(const Duration(days: 1)) ??
                    DateTime.now().add(const Duration(days: 1)))),
      firstDate: isAmbil
          ? DateTime.now()
          : (_tglAmbil?.add(const Duration(days: 1)) ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: darkBrown,
            onPrimary: Colors.white,
            onSurface: darkBrown,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isAmbil) {
          _tglAmbil = picked;
          if (_tglKembali != null &&
              (_tglAmbil!.isAfter(_tglKembali!) ||
                  _tglAmbil!.isAtSameMomentAs(_tglKembali!))) {
            _tglKembali = null;
          }
        } else {
          _tglKembali = picked;
        }
      });
    }
  }

  // ── Pilih gambar identitas ─────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 2000,
    );
    if (image != null) {
      setState(() => _imageFile = File(image.path));
      await _validateIdentityWithAI();
    }
  }

  Future<void> _validateIdentityWithAI() async {
    if (_imageFile == null) return;

    setState(() {
      _isValidatingIdentity = true;
      _identityValidationMessage = null;
    });

    try {
      final result = await CheckoutService.instance.validasiIdentitas(
        foto: _imageFile!,
        jenisIdentitas: _selectedIDType,
      );
      setState(() {
        _isIdentityValid = result.valid;
        _identityValidationMessage = result.pesan;
      });
    } catch (_) {
      setState(() {
        _isIdentityValid = false;
        _identityValidationMessage = 'Terjadi kesalahan validasi';
      });
    } finally {
      setState(() => _isValidatingIdentity = false);
    }
  }

  // ── Tambah barang dari rekomendasi cuaca ke keranjang ─────────────────────
  void _onTambahDariRekomendasi(WeatherBarang barang) {
    final product = Product(
      id: barang.id,
      name: barang.nama,
      hargaPerHari: barang.harga,
      category: barang.kategori,
      fotoUtama: barang.foto,
      stok: barang.stok,
    );

    // Cek apakah sudah ada di cart
    final existingIndex = _cart.items.indexWhere(
      (i) => i.product.id == product.id,
    );
    if (existingIndex >= 0) {
      _cart.increment(existingIndex);
    } else {
      _cart.addProduct(product);
    }

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${barang.nama} ditambahkan ke keranjang',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        backgroundColor: darkBrown,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Image source bottom-sheet ──────────────────────────────────────────────
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: darkBrown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Unggah Foto Identitas',
              style: TextStyle(
                color: darkBrown,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pilih sumber gambar untuk jaminan identitas',
              style: TextStyle(
                color: darkBrown.withOpacity(0.4),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            _imageSourceOption(
              icon: Icons.camera_alt_outlined,
              label: 'Ambil Foto',
              subtitle: 'Gunakan kamera untuk foto langsung',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 12),
            _imageSourceOption(
              icon: Icons.photo_library_outlined,
              label: 'Pilih dari Galeri',
              subtitle: 'Ambil dari foto yang sudah tersimpan',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageSourceOption({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: creamBg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: darkBrown.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: goldenYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: goldenYellow, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: darkBrown,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: darkBrown.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
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
    );
  }

  // ── Delete confirm ─────────────────────────────────────────────────────────
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: darkBrown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(
              Icons.delete_outline_rounded,
              color: Colors.red.shade300,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              'Hapus dari Pesanan?',
              style: TextStyle(
                color: darkBrown,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkBrown.withOpacity(0.5),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: darkBrown.withOpacity(0.15)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'BATAL',
                        style: TextStyle(
                          color: darkBrown,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
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
                        if (_cart.items.isEmpty && mounted)
                          Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'HAPUS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Qty Counter ────────────────────────────────────────────────────────────
  Widget _buildQtyCounter(int index) {
    final qty = _cart.items[index].qty;
    return Container(
      decoration: BoxDecoration(
        color: creamBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
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
                color: darkBrown,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          _counterBtn(Icons.add, () => _cart.increment(index)),
        ],
      ),
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

  // ── Payment ────────────────────────────────────────────────────────────────
  Future<void> _processPayment() async {
    setState(() => _isLoading = true);
    
    try {
      final req = CheckoutRequest(
        tanggalAmbil: _tglAmbil!,
        tanggalKembali: _tglKembali!,
        metodePembayaran: _selectedMethod,
        jenisIdentitas: _selectedIDType,
        fotoIdentitas: _imageFile!,
        items: _cart.items
            .map((i) => CheckoutItem(barangId: i.product.id, qty: i.qty))
            .toList(),
      );

      final resp = await CheckoutService.instance.submitCheckout(req);
      
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (_selectedMethod == 'midtrans' && resp.redirectUrl != null) {
        final Uri url = Uri.parse(resp.redirectUrl!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.inAppWebView);
        }
      }

      final snapshot = _cart.items.toList();
      final double totalSewa = _totalSewa;
      _cart.clear();
      _showSuccessDialog(snapshot, resp.nomorTransaksi ?? 'UNKNOWN', totalSewa);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  void _showSuccessDialog(List<CartItem> snapshot, String nomorTransaksi, double totalSewaFixed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: goldenYellow.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_rounded,
                  color: goldenYellow,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'PESANAN BERHASIL',
                style: TextStyle(
                  color: darkBrown,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                nomorTransaksi,
                style: TextStyle(
                  color: goldenYellow,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: creamBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: snapshot
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.product.name,
                                  style: TextStyle(
                                    color: darkBrown.withOpacity(0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '×${item.qty}',
                                style: TextStyle(
                                  color: goldenYellow,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Total: ${_formatCurrency(totalSewaFixed)}\nDurasi: $_durasi hari',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkBrown.withOpacity(0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBrown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HistoryScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'LIHAT RIWAYAT PESANAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final canSubmit =
        _tglAmbil != null &&
        _tglKembali != null &&
        _isAgreed &&
        _imageFile != null &&
        _isIdentityValid &&
        !_isValidatingIdentity &&
        _cart.items.isNotEmpty &&
        !_isLoading;

    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // Decorative background icon
          Positioned(
            top: -30,
            left: -30,
            child: Icon(
              Icons.payments_rounded,
              size: 300,
              color: darkBrown.withOpacity(0.03),
            ),
          ),

          // ── Scrollable body ──────────────────────────────────────────────
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 110, 24, 140),
                child: Column(
                  children: [
                    // ── 1. Jadwal sewa ───────────────────────────────────────
                    _buildSectionLabel('PILIH JADWAL SEWA'),
                    _buildInteractiveScheduleCard(),
                    const SizedBox(height: 28),

                    // ── 2. Lokasi & Rekomendasi Cuaca ────────────────────────
                    WeatherRecommendationSection(
                      tanggalAmbil: _tglAmbil,
                      onTambahKeranjang: _onTambahDariRekomendasi,
                    ),
                    const SizedBox(height: 28),

                    // ── 3. Item pesanan ──────────────────────────────────────
                    _buildSectionLabel(
                      'ITEM PESANAN  •  ${_cart.totalItems} unit',
                    ),
                    _buildOrderSummaryCard(),
                    const SizedBox(height: 28),

                    // ── 4. Jaminan identitas ─────────────────────────────────
                    _buildSectionLabel('JAMINAN IDENTITAS'),
                    _buildIdentitySection(),
                    const SizedBox(height: 28),

                    // ── 5. Metode pembayaran ─────────────────────────────────
                    _buildSectionLabel('METODE PEMBAYARAN'),
                    _buildPaymentOption(
                      'Cashless (Midtrans)',
                      'Otomatis & Terintegrasi',
                      'midtrans',
                      Icons.account_balance_wallet_outlined,
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentOption(
                      'Tunai (COD)',
                      'Bayar langsung di basecamp',
                      'tunai',
                      Icons.payments_outlined,
                    ),
                    const SizedBox(height: 28),

                    // ── 6. Detail biaya ──────────────────────────────────────
                    _buildSectionLabel('DETAIL BIAYA'),
                    _buildPriceCard(),
                    const SizedBox(height: 24),

                    // ── 7. S&K ───────────────────────────────────────────────
                    _buildSKChecklist(),
                  ],
                ),
              ),
            ),
          ),

          _buildGlassTopBar(context),
          _buildFloatingBottomBar(canSubmit),
        ],
      ),
    );
  }

  // ── Order Summary Card ─────────────────────────────────────────────────────
  Widget _buildOrderSummaryCard() {
    final items = _cart.items;

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: darkBrown.withOpacity(0.08), width: 1.5),
        ),
        child: Center(
          child: Text(
            'Tidak ada item di pesanan',
            style: TextStyle(
              color: darkBrown.withOpacity(0.3),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkBrown.withOpacity(0.08), width: 1.5),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Column(
            children: [
              Dismissible(
                key: ValueKey('checkout_${item.product.id}'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  _cart.remove(index);
                  if (_cart.items.isEmpty && mounted) Navigator.pop(context);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red.shade400,
                    size: 20,
                  ),
                ),
                child: Row(
                  children: [
                    // Thumbnail
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: creamBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: item.product.fotoUtama != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item.product.fotoUtama!,
                                headers: const {
                                  'ngrok-skip-browser-warning': 'true',
                                  'User-Agent': 'MajelisApp/1.0',
                                },
                                fit: BoxFit.cover,
                                loadingBuilder: (_, child, progress) {
                                  if (progress == null) return child;
                                  return Center(
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        value:
                                            progress.expectedTotalBytes != null
                                            ? progress.cumulativeBytesLoaded /
                                                  progress.expectedTotalBytes!
                                            : null,
                                        color: goldenYellow,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: darkBrown.withOpacity(0.2),
                                    size: 22,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: darkBrown.withOpacity(0.2),
                                size: 22,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item.product.name,
                                  style: TextStyle(
                                    color: darkBrown,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showDeleteConfirm(
                                  index,
                                  item.product.name,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: darkBrown.withOpacity(0.3),
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_formatCurrency(item.product.hargaPerHari)}/hari',
                            style: TextStyle(
                              color: darkBrown.withOpacity(0.4),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildQtyCounter(index),
                              Text(
                                _formatCurrency(
                                  item.product.hargaPerHari * item.qty,
                                ),
                                style: TextStyle(
                                  color: darkBrown,
                                  fontSize: 13,
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
              ),

              if (!isLast)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: darkBrown.withOpacity(0.05),
                  ),
                )
              else
                const SizedBox(height: 4),
            ],
          );
        }),
      ),
    );
  }

  // ── Schedule Card ──────────────────────────────────────────────────────────
  Widget _buildInteractiveScheduleCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkBrown.withOpacity(0.08), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _interactiveDateItem('AMBIL', _tglAmbil, true),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: darkBrown.withOpacity(0.1),
            size: 14,
          ),
          _interactiveDateItem('KEMBALI', _tglKembali, false),
        ],
      ),
    );
  }

  Widget _interactiveDateItem(String label, DateTime? date, bool isAmbil) {
    return InkWell(
      onTap: () => _selectDate(context, isAmbil),
      borderRadius: BorderRadius.circular(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: goldenYellow,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                date != null
                    ? DateFormat('dd MMM yyyy').format(date).toUpperCase()
                    : 'MM-DD-YYYY',
                style: TextStyle(
                  color: date != null ? darkBrown : darkBrown.withOpacity(0.2),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.calendar_month_outlined,
                size: 14,
                color: date != null ? goldenYellow : darkBrown.withOpacity(0.1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Identity Section ───────────────────────────────────────────────────────
  Widget _buildIdentitySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkBrown.withOpacity(0.08), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _idTypeChip('KTP'),
              const SizedBox(width: 8),
              _idTypeChip('SIM'),
              const SizedBox(width: 8),
              _idTypeChip('PELAJAR'),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _showImageSourceSheet,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: _imageFile != null ? 200 : 90,
              decoration: BoxDecoration(
                color: creamBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _imageFile != null
                      ? goldenYellow.withOpacity(0.4)
                      : darkBrown.withOpacity(0.05),
                  width: _imageFile != null ? 1.5 : 1,
                ),
                image: _imageFile != null
                    ? DecorationImage(
                        image: FileImage(_imageFile!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _isValidatingIdentity
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: goldenYellow),
                        const SizedBox(height: 12),
                        Text(
                          'AI sedang menganalisis identitas...',
                          style: TextStyle(
                            color: darkBrown,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : _imageFile == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              color: goldenYellow,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 20,
                              color: darkBrown.withOpacity(0.1),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.photo_library_outlined,
                              color: goldenYellow,
                              size: 22,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'FOTO / UNGGAH IDENTITAS',
                          style: TextStyle(
                            color: darkBrown,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ketuk untuk memilih sumber foto',
                          style: TextStyle(
                            color: darkBrown.withOpacity(0.3),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Ganti',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ),

          if (_identityValidationMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isIdentityValid
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _isIdentityValid ? Icons.check_circle : Icons.error_outline,
                    color: _isIdentityValid ? Colors.green : Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _identityValidationMessage!,
                      style: TextStyle(
                        color: _isIdentityValid ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (_imageFile == null) ...[
            const SizedBox(height: 10),
            Text(
              'Format: JPG / PNG · Pastikan foto jelas & terbaca',
              style: TextStyle(
                color: darkBrown.withOpacity(0.3),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _idTypeChip(String type) {
    final isSelected = _selectedIDType == type;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedIDType = type;
        _imageFile = null;
        _identityValidationMessage = null;
        _isIdentityValid = false;
        _hasilValidasi = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? darkBrown : creamBg.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          type,
          style: TextStyle(
            color: isSelected ? Colors.white : darkBrown.withOpacity(0.4),
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // ── Payment Option ─────────────────────────────────────────────────────────
  Widget _buildPaymentOption(
    String title,
    String subtitle,
    String value,
    IconData icon,
  ) {
    final isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? goldenYellow.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? goldenYellow : darkBrown.withOpacity(0.08),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? goldenYellow.withOpacity(0.1) : creamBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? goldenYellow : darkBrown,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: darkBrown,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: darkBrown.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: goldenYellow, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Price Card ─────────────────────────────────────────────────────────────
  Widget _buildPriceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkBrown.withOpacity(0.08), width: 1.5),
      ),
      child: Column(
        children: [
          ..._cart.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _priceRow(
                '${item.product.name} ×${item.qty}',
                item.product.hargaPerHari * item.qty,
                small: true,
              ),
            ),
          ),
          _priceRow(
            _durasi > 0 ? 'Subtotal/hari × $_durasi hari' : 'Subtotal/hari',
            _cart.totalPerDay,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              height: 1,
              thickness: 1,
              color: darkBrown.withOpacity(0.05),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL BAYAR',
                style: TextStyle(
                  color: darkBrown.withOpacity(0.3),
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                _formatCurrency(_totalSewa),
                style: TextStyle(
                  color: darkBrown,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double price, {bool small = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            color: darkBrown.withOpacity(small ? 0.35 : 0.4),
            fontWeight: FontWeight.w700,
            fontSize: small ? 11 : 13,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Text(
        _formatCurrency(price),
        style: TextStyle(
          color: darkBrown,
          fontWeight: FontWeight.w800,
          fontSize: small ? 11 : 13,
        ),
      ),
    ],
  );

  // ── Glass Top Bar ──────────────────────────────────────────────────────────
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
                  'CHECKOUT',
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

  // ── Section Label ──────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 4, bottom: 12),
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

  // ── S&K Checklist ──────────────────────────────────────────────────────────
  Widget _buildSKChecklist() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _isAgreed,
            activeColor: darkBrown,
            checkColor: goldenYellow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            side: BorderSide(color: darkBrown.withOpacity(0.1), width: 1.5),
            onChanged: (val) => setState(() => _isAgreed = val!),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Saya menyetujui Syarat & Ketentuan penyewaan alat di Majelis '
            'Adventure, termasuk tanggung jawab atas kerusakan atau '
            'keterlambatan.',
            style: TextStyle(
              color: darkBrown.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ── Floating Bottom Bar ────────────────────────────────────────────────────
  Widget _buildFloatingBottomBar(bool canSubmit) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_durasi > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_formatCurrency(_cart.totalPerDay)}/hari × $_durasi hari',
                      style: TextStyle(
                        color: darkBrown.withOpacity(0.35),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _formatCurrency(_totalSewa),
                      style: TextStyle(
                        color: darkBrown,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: canSubmit ? _processPayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBrown,
                  disabledBackgroundColor: darkBrown.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _selectedMethod == 'tunai'
                            ? 'KONFIRMASI PESANAN'
                            : 'PROSES PEMBAYARAN',
                        style: TextStyle(
                          color: canSubmit
                              ? Colors.white
                              : darkBrown.withOpacity(0.3),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
