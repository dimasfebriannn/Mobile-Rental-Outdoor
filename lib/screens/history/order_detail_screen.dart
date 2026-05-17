// lib/screens/orders/order_detail_screen.dart
//
// FIXES yang diterapkan:
//  Bug B — Foto barang tidak tampil:
//    _buildImage() sekarang memanggil ImageUrlHelper.fix() sebelum load.
//    Ini mengganti http://127.0.0.1:PORT → base URL aktif (ngrok/produksi).
//  Bug C — Foto denda tidak tampil:
//    URL foto denda juga dilewatkan ke ImageUrlHelper.fix() sebelum
//    ditampilkan dengan Image.network().
//  Fix #1/#2/#3/#4 dari iterasi sebelumnya tetap dipertahankan.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/order_model.dart';
import '../../services/checkout_service.dart';
import '../../utils/image_url_helper.dart'; // FIX Bug B & C

class OrderDetailScreen extends StatefulWidget {
  final int transaksiId;
  final OrderModel order;

  const OrderDetailScreen({
    super.key,
    required this.transaksiId,
    required this.order,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen>
    with SingleTickerProviderStateMixin {
  static const Color _darkBrown    = Color(0xFF3E2723);
  static const Color _goldenYellow = Color(0xFFE5A93D);
  static const Color _creamBg      = Color(0xFFF5EFE6);

  bool _isLoading        = true;
  bool _isActionLoading  = false;
  Map<String, dynamic>? _detail;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    initializeDateFormatting('id_ID', null).then((_) => _fetchDetail());
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    await initializeDateFormatting('id_ID', null);
    setState(() => _isLoading = true);
    try {
      final data = await CheckoutService.instance.getDetailLengkap(widget.transaksiId);
      if (mounted) {
        setState(() {
          _detail    = data;
          _isLoading = false;
        });
        _animCtrl.forward(from: 0);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack('Gagal memuat detail: ${e.toString()}');
      }
    }
  }

  // ── Formatters ─────────────────────────────────────────────────────────
  String _fmtCurrency(dynamic v) {
    final d = double.tryParse(v?.toString() ?? '0') ?? 0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(d);
  }

  String _fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return DateFormat('d MMM yyyy', 'id_ID').format(d);
  }

  // ── Durasi hari dari root _detail['durasi_hari'] ────────────────────────
  int get _durasiHari {
    final fromRoot = _detail?['durasi_hari'];
    if (fromRoot != null) {
      return int.tryParse(fromRoot.toString()) ?? 0;
    }
    final details = _detail?['details'] as List?;
    if (details != null && details.isNotEmpty) {
      final first = details[0];
      if (first is Map) {
        final d = first['durasi_hari'];
        if (d != null) return int.tryParse(d.toString()) ?? 0;
      }
    }
    final tglAmbil   = _detail?['tanggal_ambil']?.toString();
    final tglKembali = _detail?['tanggal_kembali']?.toString();
    if (tglAmbil != null && tglKembali != null) {
      final a = DateTime.tryParse(tglAmbil);
      final b = DateTime.tryParse(tglKembali);
      if (a != null && b != null) return b.difference(a).inDays;
    }
    return 0;
  }

  // ── Reopen midtrans payment ────────────────────────────────────────────
  Future<void> _reopenPayment() async {
    setState(() => _isActionLoading = true);
    try {
      final resp = await CheckoutService.instance.reopenPayment(widget.transaksiId);
      if (!mounted) return;
      if (resp.success && resp.redirectUrl != null) {
        final url = Uri.parse(resp.redirectUrl!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.inAppWebView);
          await _fetchDetail();
        }
      } else {
        _showSnack(resp.message.isNotEmpty ? resp.message : 'Gagal membuka pembayaran');
      }
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  // ── Bayar denda cashless ───────────────────────────────────────────────
  Future<void> _payDenda() async {
    setState(() => _isActionLoading = true);
    try {
      final resp = await CheckoutService.instance.bayarDenda(widget.transaksiId);
      if (!mounted) return;
      if (resp.success && resp.redirectUrl != null) {
        final url = Uri.parse(resp.redirectUrl!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.inAppWebView);
        }
        await _fetchDetail();
      } else {
        _showSnack(resp.message.isNotEmpty ? resp.message : 'Gagal membuka pembayaran denda');
      }
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _darkBrown,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Status info ────────────────────────────────────────────────────────
  _StatusInfo _getStatusInfo(String? status) {
    switch (status) {
      case 'menunggu_pembayaran':
        return _StatusInfo('Menunggu Pembayaran', const Color(0xFFFF8F00), const Color(0xFFFFF8E1), Icons.hourglass_top_rounded);
      case 'dibayar':
        return _StatusInfo('Pembayaran Dikonfirmasi', const Color(0xFF1565C0), const Color(0xFFE3F2FD), Icons.verified_rounded);
      case 'berjalan':
        return _StatusInfo('Sedang Dipinjam', const Color(0xFF2E7D32), const Color(0xFFE8F5E9), Icons.directions_run_rounded);
      case 'terlambat':
        return _StatusInfo('Terlambat Dikembalikan', const Color(0xFFD32F2F), const Color(0xFFFFEBEE), Icons.warning_amber_rounded);
      case 'dikembalikan':
        return _StatusInfo('Barang Dikembalikan', const Color(0xFF6A1B9A), const Color(0xFFF3E5F5), Icons.assignment_return_rounded);
      case 'selesai':
        return _StatusInfo('Pesanan Selesai', _darkBrown, const Color(0xFFF5EFE6), Icons.check_circle_rounded);
      case 'dibatalkan':
        return _StatusInfo('Dibatalkan', const Color(0xFF757575), const Color(0xFFF5F5F5), Icons.cancel_rounded);
      default:
        return _StatusInfo('Tidak Diketahui', const Color(0xFF757575), const Color(0xFFF5F5F5), Icons.help_rounded);
    }
  }

  // ── Timeline ───────────────────────────────────────────────────────────
  List<_TimelineStep> _buildTimeline(String? status) {
    const allSteps = ['menunggu_pembayaran', 'dibayar', 'berjalan', 'dikembalikan', 'selesai'];
    final stepLabels = {
      'menunggu_pembayaran': ('Menunggu Pembayaran', 'Silakan selesaikan pembayaran'),
      'dibayar':             ('Pembayaran Dikonfirmasi', 'Siap diambil di basecamp'),
      'berjalan':            ('Sedang Dipinjam', 'Selamat beradventure!'),
      'dikembalikan':        ('Barang Dikembalikan', 'Proses verifikasi admin'),
      'selesai':             ('Selesai', 'Terima kasih sudah menyewa'),
    };
    final currentIdx = allSteps.indexOf(status ?? '');
    return allSteps.asMap().entries.map((e) {
      final idx = e.key;
      final key = e.value;
      final (label, desc) = stepLabels[key]!;
      return _TimelineStep(
        label:    label,
        desc:     desc,
        isDone:   idx < currentIdx || status == 'selesai' || status == key,
        isActive: idx == currentIdx,
        isLast:   idx == allSteps.length - 1,
      );
    }).toList();
  }

  // ── Denda helpers ──────────────────────────────────────────────────────
  bool get _hasDendaBelumLunas {
    if (_detail == null) return false;
    final totalDenda = double.tryParse(_detail!['total_denda']?.toString() ?? '0') ?? 0;
    if (totalDenda <= 0) return false;
    final List pembayaran = (_detail!['pembayaran'] as List?) ?? [];
    final sudahLunas = pembayaran.any((p) {
      if (p is! Map) return false;
      return p['jenis']?.toString() == 'denda' && p['status']?.toString() == 'lunas';
    });
    return !sudahLunas;
  }

  double get _dendaNominal =>
      double.tryParse(_detail?['total_denda']?.toString() ?? '0') ?? 0;

  List<Map<String, dynamic>> get _dendaList {
    final raw = _detail?['denda'];
    if (raw == null) return [];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  // ── Root build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _creamBg,
      body: Stack(
        children: [
          Positioned(
            top: -80, right: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _goldenYellow.withOpacity(0.05),
              ),
            ),
          ),
          Positioned.fill(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _goldenYellow))
                : FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 110),
                          _buildVoucher(),
                          const SizedBox(height: 20),
                          _buildStatusTimeline(),
                          const SizedBox(height: 20),
                          _buildItemsStruk(),
                          const SizedBox(height: 20),
                          _buildInvoiceSummary(),
                          const SizedBox(height: 20),
                          if (_dendaList.isNotEmpty) ...[
                            _buildDendaDetail(),
                            const SizedBox(height: 20),
                          ],
                          _buildActionButtons(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
          ),
          _buildGlassTopBar(),
          if (_isActionLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator(color: _goldenYellow)),
              ),
            ),
        ],
      ),
    );
  }

  // ── Glass Top Bar ──────────────────────────────────────────────────────
  Widget _buildGlassTopBar() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 14),
            color: Colors.white.withOpacity(0.85),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      border: Border.all(color: _darkBrown.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: _darkBrown, size: 15),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'DETAIL PESANAN',
                      style: TextStyle(color: _darkBrown, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _fetchDetail,
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      border: Border.all(color: _darkBrown.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.refresh_rounded, color: _darkBrown.withOpacity(0.5), size: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Voucher ────────────────────────────────────────────────────────────
  Widget _buildVoucher() {
    final status     = _detail?['status']?.toString() ?? widget.order.rawStatus;
    final nomorTrx   = _detail?['nomor_transaksi']?.toString() ?? widget.order.orderId;
    final tglAmbil   = _detail?['tanggal_ambil']?.toString() ?? '';
    final tglKembali = _detail?['tanggal_kembali']?.toString() ?? '';
    final metode     = _detail?['metode_pembayaran']?.toString() ?? '';
    final info       = _getStatusInfo(status);
    final durasi     = _durasiHari;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: _darkBrown.withOpacity(0.07), blurRadius: 30, offset: const Offset(0, 12))],
      ),
      child: Column(
        children: [
          // Status badge header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: info.bgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Icon(info.icon, size: 16, color: info.color),
                const SizedBox(width: 8),
                Text(info.label, style: TextStyle(color: info.color, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5)),
                const Spacer(),
                if (metode.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: info.color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                    child: Text(metode.toUpperCase(), style: TextStyle(color: info.color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  ),
              ],
            ),
          ),
          // Product info
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                _buildProductThumb(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MAJELIS ADVENTURE', style: TextStyle(color: _goldenYellow, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text(widget.order.productName, style: const TextStyle(color: _darkBrown, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(nomorTrx, style: TextStyle(color: _darkBrown.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Ticket punch divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                _TicketPunch(left: true),
                Expanded(
                  child: Row(
                    children: List.generate(30, (i) => Expanded(
                      child: Container(height: 1.5, margin: const EdgeInsets.symmetric(horizontal: 2), color: _darkBrown.withOpacity(0.06)),
                    )),
                  ),
                ),
                _TicketPunch(left: false),
              ],
            ),
          ),
          // Date + durasi section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    _DateBlock(label: 'AMBIL', date: _fmtDate(tglAmbil), icon: Icons.login_rounded),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: _darkBrown.withOpacity(0.04), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_forward_rounded, size: 12, color: _goldenYellow),
                          const SizedBox(width: 4),
                          Text(
                            durasi > 0 ? '$durasi hari' : '-',
                            style: TextStyle(color: _darkBrown.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    _DateBlock(label: 'KEMBALI', date: _fmtDate(tglKembali), icon: Icons.logout_rounded, alignRight: true),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('QR VERIFIKASI', style: TextStyle(color: _darkBrown.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
                        const SizedBox(height: 3),
                        Text('Valid di Basecamp', style: TextStyle(color: _darkBrown, fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const Spacer(),
                    Icon(Icons.qr_code_scanner_rounded, size: 42, color: _darkBrown.withOpacity(0.8)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FIX Bug B: Foto barang dari detail — foto_utama_url difix host-nya
  Widget _buildProductThumb() {
    String? fotoUrl;
    final details = _detail?['details'] as List?;
    if (details != null && details.isNotEmpty) {
      final first  = details[0];
      final barang = first is Map ? first['barang'] : null;
      if (barang is Map) {
        // Ambil URL dan fix host agar tidak stuck di 127.0.0.1
        fotoUrl = ImageUrlHelper.fix(
          barang['foto_utama_url']?.toString() ?? barang['foto_utama']?.toString(),
        );
      }
    }
    // Fallback ke order image (sudah difix di OrderModel.fromJson)
    if (fotoUrl == null || fotoUrl.isEmpty) {
      fotoUrl = widget.order.imagePath;
    }

    return Container(
      width: 64, height: 64,
      decoration: BoxDecoration(color: _creamBg, borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: _buildImage(fotoUrl, size: 48),
      ),
    );
  }

  // ── FIX Bug B & C: helper load image dengan URL fixer ─────────────────
  // ImageUrlHelper.fix() mengganti http://127.0.0.1:PORT → base URL aktif
  Widget _buildImage(String? url, {double size = 48}) {
    // FIX: selalu fix URL sebelum load
    final fixedUrl = ImageUrlHelper.fix(url);

    if (fixedUrl.isEmpty) {
      return Icon(Icons.backpack_outlined, color: _darkBrown, size: size * 0.6);
    }
    if (fixedUrl.startsWith('http')) {
      return Image.network(
        fixedUrl,
        fit: BoxFit.contain,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => Icon(Icons.backpack_outlined, color: _darkBrown, size: size * 0.6),
      );
    }
    return Image.asset(
      fixedUrl,
      fit: BoxFit.contain,
      width: size,
      height: size,
      errorBuilder: (_, __, ___) => Icon(Icons.backpack_outlined, color: _darkBrown, size: size * 0.6),
    );
  }

  // ── Timeline ───────────────────────────────────────────────────────────
  Widget _buildStatusTimeline() {
    final status = _detail?['status']?.toString() ?? '';
    if (status == 'dibatalkan') return const SizedBox();
    final steps = _buildTimeline(status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _darkBrown.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: _goldenYellow.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.route_rounded, color: _goldenYellow, size: 14),
              ),
              const SizedBox(width: 10),
              const Text('STATUS PESANAN', style: TextStyle(color: _darkBrown, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 20),
          ...steps.map((s) => _buildTimelineItem(s)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(_TimelineStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.isDone
                      ? (step.isActive ? _goldenYellow : _goldenYellow.withOpacity(0.25))
                      : _darkBrown.withOpacity(0.06),
                ),
                child: Icon(
                  step.isDone ? Icons.check_rounded : Icons.circle,
                  size: step.isDone ? 13 : 6,
                  color: step.isDone
                      ? (step.isActive ? Colors.white : _goldenYellow)
                      : _darkBrown.withOpacity(0.2),
                ),
              ),
              if (!step.isLast)
                Container(width: 2, height: 32, color: _darkBrown.withOpacity(0.06)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: TextStyle(
                      color: step.isDone ? _darkBrown : _darkBrown.withOpacity(0.3),
                      fontWeight: step.isActive ? FontWeight.w900 : FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  if (step.isActive || step.isDone) ...[
                    const SizedBox(height: 2),
                    Text(step.desc, style: TextStyle(color: _darkBrown.withOpacity(0.35), fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Struk Barang — FIX Bug B: foto_utama_url difix host-nya ───────────
  Widget _buildItemsStruk() {
    final items = (_detail?['details'] as List?) ?? [];
    if (items.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _darkBrown.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(color: _creamBg, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.receipt_long_rounded, color: _darkBrown, size: 14),
                ),
                const SizedBox(width: 10),
                const Text('STRUK PENYEWAAN', style: TextStyle(color: _darkBrown, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: _darkBrown.withOpacity(0.06), thickness: 1),
          ),
          ...items.asMap().entries.map((entry) {
            final item   = entry.value as Map<String, dynamic>;
            final barang = item['barang'] as Map<String, dynamic>?;
            final nama   = barang?['nama']?.toString() ?? 'Item';

            // FIX Bug B: fix host URL sebelum ditampilkan
            final foto = ImageUrlHelper.fix(
              barang?['foto_utama_url']?.toString() ?? barang?['foto_utama']?.toString(),
            );

            final qty    = item['jumlah'] ?? item['qty'] ?? 1;
            final harga  = item['harga_per_hari'];
            final durasi = item['durasi_hari'] ?? 1;
            final sub    = item['subtotal'];
            final isLast = entry.key == items.length - 1;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: _creamBg, borderRadius: BorderRadius.circular(12)),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: _buildImage(foto, size: 36),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nama, style: const TextStyle(color: _darkBrown, fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              '${_fmtCurrency(harga)}/hari × $qty × $durasi hari',
                              style: TextStyle(color: _darkBrown.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_fmtCurrency(sub), style: const TextStyle(color: _darkBrown, fontWeight: FontWeight.w800, fontSize: 13)),
                    ],
                  ),
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(color: _darkBrown.withOpacity(0.04), thickness: 1, height: 1),
                  ),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Invoice Summary ────────────────────────────────────────────────────
  Widget _buildInvoiceSummary() {
    final totalSewa   = double.tryParse(_detail?['total_sewa']?.toString() ?? '0') ?? 0;
    final totalDenda  = double.tryParse(_detail?['total_denda']?.toString() ?? '0') ?? 0;
    final statusBayar = _detail?['status_pembayaran']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _darkBrown,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _darkBrown.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: _goldenYellow.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.article_rounded, color: _goldenYellow, size: 14),
              ),
              const SizedBox(width: 10),
              const Text('RINGKASAN PEMBAYARAN', style: TextStyle(color: _goldenYellow, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 20),
          _InvoiceRow(label: 'Total Sewa', value: _fmtCurrency(totalSewa), valueColor: Colors.white),
          if (totalDenda > 0) ...[
            const SizedBox(height: 12),
            _InvoiceRow(
              label: 'Denda (ditetapkan admin)',
              value: _fmtCurrency(totalDenda),
              labelColor: const Color(0xFFFFCDD2),
              valueColor: const Color(0xFFEF9A9A),
              icon: Icons.warning_rounded,
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white.withOpacity(0.08), thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TOTAL', style: TextStyle(color: _goldenYellow.withOpacity(0.7), fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(_fmtCurrency(totalSewa + totalDenda), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusBadgeColor(statusBayar).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _statusBadgeColor(statusBayar).withOpacity(0.3)),
                ),
                child: Text(
                  _statusBayarLabel(statusBayar),
                  style: TextStyle(color: _statusBadgeColor(statusBayar), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusBadgeColor(String s) {
    switch (s) {
      case 'lunas':    return const Color(0xFF69F0AE);
      case 'menunggu': return _goldenYellow;
      case 'gagal':    return const Color(0xFFEF9A9A);
      case 'parsial':  return const Color(0xFF80DEEA);
      default:         return Colors.white54;
    }
  }

  String _statusBayarLabel(String s) {
    switch (s) {
      case 'lunas':    return 'LUNAS';
      case 'menunggu': return 'MENUNGGU';
      case 'gagal':    return 'GAGAL';
      case 'parsial':  return 'PARSIAL';
      default:         return s.toUpperCase();
    }
  }

  // ── Detail Denda — FIX Bug C: foto denda URL difix host-nya ───────────
  Widget _buildDendaDetail() {
    final dendaList = _dendaList;
    if (dendaList.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _darkBrown.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.gavel_rounded, color: Color(0xFFD32F2F), size: 14),
                ),
                const SizedBox(width: 10),
                const Text('DETAIL DENDA', style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: _darkBrown.withOpacity(0.06), thickness: 1),
          ),

          ...dendaList.asMap().entries.map((entry) {
            final d          = entry.value;
            final jenis      = d['jenis']?.toString() ?? '';
            final jumlah     = double.tryParse(d['jumlah']?.toString() ?? '0') ?? 0;
            final catatan    = d['catatan']?.toString() ?? '';
            final sudahBayar = d['dibayar_pada'] != null;
            final List<dynamic> fotos = (d['foto'] as List?) ?? [];
            final isLast = entry.key == dendaList.length - 1;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: jenis == 'kerusakan' ? const Color(0xFFFFEBEE) : const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  jenis == 'kerusakan' ? Icons.construction_rounded : Icons.timer_off_rounded,
                                  size: 11,
                                  color: jenis == 'kerusakan' ? const Color(0xFFD32F2F) : const Color(0xFFFF8F00),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  jenis == 'kerusakan' ? 'Kerusakan' : 'Keterlambatan',
                                  style: TextStyle(
                                    color: jenis == 'kerusakan' ? const Color(0xFFD32F2F) : const Color(0xFFFF8F00),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (sudahBayar)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
                              child: const Text('LUNAS', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w900, fontSize: 10)),
                            ),
                          const SizedBox(width: 8),
                          Text(_fmtCurrency(jumlah), style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w900, fontSize: 14)),
                        ],
                      ),

                      if (catatan.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: _creamBg, borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Catatan Admin', style: TextStyle(color: _darkBrown.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                              const SizedBox(height: 4),
                              Text(catatan, style: TextStyle(color: _darkBrown, fontSize: 12, fontWeight: FontWeight.w500, height: 1.4)),
                            ],
                          ),
                        ),
                      ],

                      // FIX Bug C: foto denda — fix host URL sebelum load
                      if (fotos.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text('Foto Bukti', style: TextStyle(color: _darkBrown.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 90,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: fotos.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (ctx, i) {
                              final foto = fotos[i] as Map? ?? {};
                              // FIX Bug C: ambil 'url' (sudah diisi server) lalu fix host
                              final rawUrl = foto['url']?.toString() ?? '';
                              final url    = ImageUrlHelper.fix(rawUrl);

                              return GestureDetector(
                                onTap: () => url.isNotEmpty ? _showFotoFullscreen(ctx, url) : null,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: url.startsWith('http')
                                      ? Image.network(
                                          url,
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (_, child, progress) {
                                            if (progress == null) return child;
                                            return Container(
                                              width: 90, height: 90, color: _creamBg,
                                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: _goldenYellow)),
                                            );
                                          },
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 90, height: 90, color: _creamBg,
                                            child: Icon(Icons.broken_image_rounded, color: _darkBrown.withOpacity(0.3)),
                                          ),
                                        )
                                      : Container(
                                          width: 90, height: 90, color: _creamBg,
                                          child: Icon(Icons.image_not_supported_rounded, color: _darkBrown.withOpacity(0.3)),
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isLast) ...[
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(color: _darkBrown.withOpacity(0.06), thickness: 1),
                  ),
                ] else
                  const SizedBox(height: 20),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _showFotoFullscreen(BuildContext ctx, String url) {
    showDialog(
      context: ctx,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image_rounded, color: Colors.white, size: 64),
                ),
              ),
            ),
            Positioned(
              top: 40, right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(dialogContext),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Action Buttons ─────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    if (_detail == null) return const SizedBox();

    final status = _detail!['status']?.toString() ?? '';
    final metode = _detail!['metode_pembayaran']?.toString() ?? '';

    final List<Widget> buttons = [];

    if (status == 'menunggu_pembayaran' && metode == 'midtrans') {
      buttons.add(_ActionButton(
        label: 'BAYAR SEKARANG',
        icon: Icons.payment_rounded,
        bgColor: _goldenYellow,
        textColor: _darkBrown,
        onTap: _reopenPayment,
      ));
    }

    if (_hasDendaBelumLunas) {
      buttons.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _DendaInfoBanner(nominal: _fmtCurrency(_dendaNominal)),
        ),
      );
      buttons.add(_ActionButton(
        label: 'BAYAR DENDA — CASHLESS',
        icon: Icons.contactless_rounded,
        bgColor: const Color(0xFFD32F2F),
        textColor: Colors.white,
        onTap: _payDenda,
      ));
      buttons.add(_ActionButton(
        label: 'BAYAR DENDA — TUNAI',
        icon: Icons.payments_outlined,
        bgColor: _creamBg,
        textColor: _darkBrown,
        onTap: _showTunaiDialog,
      ));
    }

    if (buttons.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: buttons
            .map((b) => Padding(padding: const EdgeInsets.only(bottom: 12), child: b))
            .toList(),
      ),
    );
  }

  void _showTunaiDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: _creamBg, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.payments_outlined, color: _darkBrown, size: 22),
              ),
              const SizedBox(height: 16),
              const Text('Pembayaran Tunai', style: TextStyle(color: _darkBrown, fontWeight: FontWeight.w900, fontSize: 17)),
              const SizedBox(height: 10),
              Text(
                'Silakan datang ke basecamp Majelis Adventure untuk melunasi denda secara tunai. Tunjukkan nomor transaksi kepada petugas.',
                style: TextStyle(color: _darkBrown.withOpacity(0.6), fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: _creamBg, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  _detail?['nomor_transaksi']?.toString() ?? widget.order.orderId,
                  style: const TextStyle(color: _darkBrown, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(color: _goldenYellow, borderRadius: BorderRadius.circular(14)),
                  child: const Center(child: Text('MENGERTI', style: TextStyle(color: _darkBrown, fontWeight: FontWeight.w900, letterSpacing: 1))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────────

class _TicketPunch extends StatelessWidget {
  final bool left;
  const _TicketPunch({required this.left});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14, height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6),
        borderRadius: BorderRadius.only(
          topRight:    left  ? const Radius.circular(28) : Radius.zero,
          bottomRight: left  ? const Radius.circular(28) : Radius.zero,
          topLeft:     !left ? const Radius.circular(28) : Radius.zero,
          bottomLeft:  !left ? const Radius.circular(28) : Radius.zero,
        ),
      ),
    );
  }
}

class _DateBlock extends StatelessWidget {
  final String label;
  final String date;
  final IconData icon;
  final bool alignRight;
  const _DateBlock({required this.label, required this.date, required this.icon, this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    const db = Color(0xFF3E2723);
    const gy = Color(0xFFE5A93D);
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: alignRight
              ? [Text(label, style: TextStyle(color: db.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.8)), const SizedBox(width: 5), Icon(icon, size: 9, color: gy)]
              : [Icon(icon, size: 9, color: gy), const SizedBox(width: 5), Text(label, style: TextStyle(color: db.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.8))],
        ),
        const SizedBox(height: 5),
        Text(date, style: const TextStyle(color: db, fontWeight: FontWeight.w900, fontSize: 14)),
      ],
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? labelColor;
  final Color valueColor;
  final IconData? icon;
  const _InvoiceRow({required this.label, required this.value, this.labelColor, required this.valueColor, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 12, color: labelColor ?? Colors.white54), const SizedBox(width: 5)],
            Text(label, style: TextStyle(color: labelColor ?? Colors.white54, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
        Text(value, style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.icon, required this.bgColor, required this.textColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: bgColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 16),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _DendaInfoBanner extends StatelessWidget {
  final String nominal;
  const _DendaInfoBanner({required this.nominal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFD32F2F), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Denda ditetapkan oleh admin', style: TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.w800, fontSize: 12)),
                const SizedBox(height: 2),
                Text('Nominal denda: $nominal — Silakan lunasi segera.', style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Internal data models ───────────────────────────────────────────────────

class _StatusInfo {
  final String label;
  final Color color;
  final Color bgColor;
  final IconData icon;
  const _StatusInfo(this.label, this.color, this.bgColor, this.icon);
}

class _TimelineStep {
  final String label;
  final String desc;
  final bool isDone;
  final bool isActive;
  final bool isLast;
  const _TimelineStep({required this.label, required this.desc, required this.isDone, required this.isActive, required this.isLast});
}