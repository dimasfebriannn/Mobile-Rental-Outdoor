// lib/screens/orders/order_detail_screen.dart
//
// PERUBAHAN BARU:
//  ✅ QR Code nomor transaksi (menggantikan placeholder "QR Verifikasi")
//  ✅ Status timeline dilengkapi tanggal & jam
//  ✅ E-Struk (digital receipt) lengkap dengan status real-time
//  ✅ Keterangan COD vs Cashless + instruksi tunjukkan QR/nomor
//  ✅ Warning H+1 otomatis batal jika COD belum ke basecamp
//
// DEPENDENCY BARU yang harus ditambahkan di pubspec.yaml:
//   qr_flutter: ^4.1.0
//
// FIXES lama yang tetap dipertahankan:
//  Bug B — Foto barang tidak tampil (ImageUrlHelper.fix)
//  Bug C — Foto denda tidak tampil
//  Fix #1/#2/#3/#4 dari iterasi sebelumnya

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/order_model.dart';
import '../../services/checkout_service.dart';
import '../../utils/image_url_helper.dart';

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

  // ── Tab controller untuk E-Struk ──────────────────────────────────────
  int _selectedTab = 0; // 0 = Detail, 1 = E-Struk

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

  // ── Formatters ──────────────────────────────────────────────────────────
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

  String _fmtDateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(d);
  }

  String _fmtDateTimeFull(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(dt);
  }

  // ── Durasi hari ─────────────────────────────────────────────────────────
  int get _durasiHari {
    final fromRoot = _detail?['durasi_hari'];
    if (fromRoot != null) return int.tryParse(fromRoot.toString()) ?? 0;
    final details = _detail?['details'] as List?;
    if (details != null && details.isNotEmpty) {
      final d = details[0]['durasi_hari'];
      if (d != null) return int.tryParse(d.toString()) ?? 0;
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

  // ── Apakah COD ──────────────────────────────────────────────────────────
  bool get _isCod {
    final metode = _detail?['metode_pembayaran']?.toString() ?? '';
    return metode.toLowerCase() == 'tunai';
  }

  // ── Deadline COD (H+1 dari tanggal ambil) ──────────────────────────────
  DateTime? get _deadlineCod {
    final tglAmbil = _detail?['tanggal_ambil']?.toString();
    if (tglAmbil == null) return null;
    final dt = DateTime.tryParse(tglAmbil);
    if (dt == null) return null;
    return dt.add(const Duration(days: 1));
  }

  bool get _codMelampauiDeadline {
    final deadline = _deadlineCod;
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline);
  }

  // ── Actions ──────────────────────────────────────────────────────────────
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

  // ── Status helpers ───────────────────────────────────────────────────────
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

    // Ambil timestamps dari riwayat status jika ada
    final riwayat = (_detail?['riwayat_status'] as List?) ?? [];

    String? getTimestamp(String s) {
      for (final r in riwayat) {
        if (r is Map && r['status']?.toString() == s) {
          return r['created_at']?.toString();
        }
      }
      // Fallback: gunakan tanggal dari field transaksi
      if (s == 'menunggu_pembayaran') return _detail?['created_at']?.toString();
      if (s == 'berjalan') return _detail?['tanggal_ambil']?.toString();
      if (s == 'selesai') return _detail?['updated_at']?.toString();
      return null;
    }

    return allSteps.asMap().entries.map((e) {
      final idx = e.key;
      final key = e.value;
      final (label, desc) = stepLabels[key]!;
      final isDone = idx < currentIdx || status == 'selesai' || status == key;
      return _TimelineStep(
        label:    label,
        desc:     desc,
        isDone:   isDone,
        isActive: idx == currentIdx,
        isLast:   idx == allSteps.length - 1,
        timestamp: isDone ? getTimestamp(key) : null,
      );
    }).toList();
  }

  // ── Denda helpers ────────────────────────────────────────────────────────
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
      return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  // ════════════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════════════
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
                    child: Column(
                      children: [
                        const SizedBox(height: 110),
                        // ── Tab Bar ────────────────────────────────────────
                        _buildTabBar(),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _selectedTab == 0
                              ? _buildDetailTab()
                              : _buildEStrukTab(),
                        ),
                      ],
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

  // ── Tab Bar ─────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: _darkBrown.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            _TabItem(label: 'Detail Pesanan', icon: Icons.receipt_outlined, isSelected: _selectedTab == 0, onTap: () => setState(() => _selectedTab = 0)),
            _TabItem(label: 'E-Struk', icon: Icons.description_outlined, isSelected: _selectedTab == 1, onTap: () => setState(() => _selectedTab = 1)),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // TAB 1: DETAIL PESANAN
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildDetailTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildVoucher(),
          const SizedBox(height: 20),
          // COD info banner
          if (_isCod) ...[
            _buildCodInfoBanner(),
            const SizedBox(height: 20),
          ],
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
    );
  }

  // ── COD Info Banner ──────────────────────────────────────────────────────
  Widget _buildCodInfoBanner() {
    final status     = _detail?['status']?.toString() ?? widget.order.rawStatus;
    final nomorTrx   = _detail?['nomor_transaksi']?.toString() ?? widget.order.orderId;
    final deadline   = _deadlineCod;
    final sudahLewat = _codMelampauiDeadline;

    // Jika sudah bayar/berjalan, tidak perlu tampil banner COD pending
    if (status == 'berjalan' || status == 'selesai' || status == 'dibatalkan') {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: sudahLewat ? const Color(0xFFFFEBEE) : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sudahLewat ? const Color(0xFFFFCDD2) : const Color(0xFFFFE082),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                sudahLewat ? Icons.cancel_outlined : Icons.store_outlined,
                color: sudahLewat ? const Color(0xFFD32F2F) : const Color(0xFFFF8F00),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                sudahLewat ? 'Batas Waktu Habis' : 'Pembayaran Tunai (COD)',
                style: TextStyle(
                  color: sudahLewat ? const Color(0xFFB71C1C) : const Color(0xFFE65100),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (sudahLewat) ...[
            Text(
              'Pesanan ini akan otomatis DIBATALKAN karena Anda belum datang ke basecamp pada H+1 tanggal ambil.',
              style: TextStyle(color: const Color(0xFFD32F2F), fontSize: 12, height: 1.5),
            ),
            if (deadline != null) ...[
              const SizedBox(height: 6),
              Text(
                'Batas: ${_fmtDateTimeFull(deadline)}',
                style: const TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ],
          ] else ...[
            Text(
              'Silakan datang ke basecamp Majelis Rental dan tunjukkan nomor transaksi atau QR Code di bawah kepada petugas untuk menyelesaikan pembayaran.',
              style: TextStyle(color: const Color(0xFF5D4037), fontSize: 12, height: 1.5),
            ),
            if (deadline != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 13, color: const Color(0xFFFF8F00)),
                  const SizedBox(width: 4),
                  Text(
                    'Batas kedatangan: ${_fmtDateTimeFull(deadline)}',
                    style: const TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            // Mini QR untuk COD
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: _creamBg, borderRadius: BorderRadius.circular(10)),
                    child: QrImageView(
                      data: nomorTrx,
                      version: QrVersions.auto,
                      size: 64,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nomor Transaksi', style: TextStyle(color: _darkBrown.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text(nomorTrx, style: const TextStyle(color: _darkBrown, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.3)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: nomorTrx));
                            _showSnack('Nomor transaksi disalin!');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _goldenYellow.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Salin Nomor', style: TextStyle(color: _darkBrown, fontSize: 10, fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Glass Top Bar ────────────────────────────────────────────────────────
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

  // ── Voucher — dengan QR Code nomor transaksi ─────────────────────────────
  Widget _buildVoucher() {
    final status     = _detail?['status']?.toString() ?? widget.order.rawStatus;
    final nomorTrx   = _detail?['nomor_transaksi']?.toString() ?? widget.order.orderId;
    final tglAmbil   = _detail?['tanggal_ambil']?.toString() ?? '';
    final tglKembali = _detail?['tanggal_kembali']?.toString() ?? '';
    final metode     = _detail?['metode_pembayaran']?.toString() ?? '';
    final info       = _getStatusInfo(status);
    final durasi     = _durasiHari;
    final isCod      = metode.toLowerCase() == 'tunai';

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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: info.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCod ? Icons.payments_outlined : Icons.contactless_rounded,
                        size: 10,
                        color: info.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCod ? 'TUNAI' : (metode.isNotEmpty ? metode.toUpperCase() : 'CASHLESS'),
                        style: TextStyle(color: info.color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                    ],
                  ),
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
                      Text('MAJELIS RENTAL', style: TextStyle(color: _goldenYellow, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text(
                        widget.order.productName,
                        style: const TextStyle(color: _darkBrown, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: nomorTrx));
                          _showSnack('Nomor transaksi disalin!');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(nomorTrx, style: TextStyle(color: _darkBrown.withOpacity(0.35), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                            const SizedBox(width: 4),
                            Icon(Icons.copy_outlined, size: 10, color: _darkBrown.withOpacity(0.25)),
                          ],
                        ),
                      ),
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
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                const SizedBox(height: 20),
                // ── QR Code nomor transaksi (BARU) ──────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _creamBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      // QR Code
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: _darkBrown.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: QrImageView(
                          data: nomorTrx,
                          version: QrVersions.auto,
                          size: 80,
                          backgroundColor: Colors.white,
                          errorCorrectionLevel: QrErrorCorrectLevel.M,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NOMOR TRANSAKSI',
                              style: TextStyle(color: _darkBrown.withOpacity(0.35), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              nomorTrx,
                              style: const TextStyle(color: _darkBrown, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.3),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isCod
                                  ? 'Tunjukkan QR ini ke petugas basecamp'
                                  : 'Scan untuk verifikasi di basecamp',
                              style: TextStyle(color: _darkBrown.withOpacity(0.4), fontSize: 11, height: 1.3),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => _showQrFullscreen(nomorTrx),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _goldenYellow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.qr_code_rounded, size: 12, color: _darkBrown),
                                    const SizedBox(width: 4),
                                    const Text('Perbesar QR', style: TextStyle(color: _darkBrown, fontSize: 10, fontWeight: FontWeight.w900)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── QR Fullscreen ────────────────────────────────────────────────────────
  void _showQrFullscreen(String nomorTrx) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MAJELIS RENTAL',
                style: TextStyle(color: _goldenYellow, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2),
              ),
              const SizedBox(height: 4),
              const Text(
                'QR Verifikasi Transaksi',
                style: TextStyle(color: _darkBrown, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 20),
              QrImageView(
                data: nomorTrx,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: _creamBg, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  nomorTrx,
                  style: const TextStyle(color: _darkBrown, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tunjukkan QR ini kepada petugas basecamp\nuntuk verifikasi pesanan Anda.',
                style: TextStyle(color: _darkBrown.withOpacity(0.5), fontSize: 11, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: _darkBrown, borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                    child: Text('TUTUP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Product Thumb ────────────────────────────────────────────────────────
  Widget _buildProductThumb() {
    String? fotoUrl;
    final details = _detail?['details'] as List?;
    if (details != null && details.isNotEmpty) {
      final barang = details[0] is Map ? (details[0] as Map)['barang'] : null;
      if (barang is Map) {
        fotoUrl = ImageUrlHelper.fix(barang['foto_utama_url']?.toString() ?? barang['foto_utama']?.toString());
      }
    }
    fotoUrl ??= widget.order.imagePath;

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

  Widget _buildImage(String? url, {double size = 48}) {
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

  // ── Timeline — dengan tanggal & jam ─────────────────────────────────────
  Widget _buildStatusTimeline() {
    final status = _detail?['status']?.toString() ?? '';
    if (status == 'dibatalkan') {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: _darkBrown.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.cancel_rounded, color: Color(0xFF757575), size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pesanan Dibatalkan', style: TextStyle(color: _darkBrown, fontWeight: FontWeight.w900, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('Transaksi ini telah dibatalkan.', style: TextStyle(color: Color(0xFF757575), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      );
    }

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
                Container(width: 2, height: 36, color: _darkBrown.withOpacity(0.06)),
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
                  if (step.isDone || step.isActive) ...[
                    const SizedBox(height: 2),
                    Text(step.desc, style: TextStyle(color: _darkBrown.withOpacity(0.35), fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                  // ── Timestamp (BARU) ───────────────────────────────
                  if (step.timestamp != null && step.isDone) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 10, color: _goldenYellow.withOpacity(0.7)),
                        const SizedBox(width: 4),
                        Text(
                          _fmtDateTime(step.timestamp),
                          style: TextStyle(color: _goldenYellow.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
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

  // ── Struk Barang ─────────────────────────────────────────────────────────
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
                const Text('ITEM PESANAN', style: TextStyle(color: _darkBrown, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
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
            final foto   = ImageUrlHelper.fix(barang?['foto_utama_url']?.toString() ?? barang?['foto_utama']?.toString());
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

  // ── Invoice Summary ──────────────────────────────────────────────────────
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

  // ── Denda Detail ─────────────────────────────────────────────────────────
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
                              final url  = ImageUrlHelper.fix(foto['url']?.toString() ?? '');
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
                                            return Container(width: 90, height: 90, color: _creamBg, child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: _goldenYellow)));
                                          },
                                          errorBuilder: (_, __, ___) => Container(width: 90, height: 90, color: _creamBg, child: Icon(Icons.broken_image_rounded, color: _darkBrown.withOpacity(0.3))),
                                        )
                                      : Container(width: 90, height: 90, color: _creamBg, child: Icon(Icons.image_not_supported_rounded, color: _darkBrown.withOpacity(0.3))),
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
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_rounded, color: Colors.white, size: 64),
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

  // ── Action Buttons ───────────────────────────────────────────────────────
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
                'Silakan datang ke basecamp Majelis Rental untuk melunasi denda secara tunai. Tunjukkan nomor transaksi kepada petugas.',
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

  // ════════════════════════════════════════════════════════════════════════
  // TAB 2: E-STRUK DIGITAL
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildEStrukTab() {
    if (_detail == null) return const Center(child: CircularProgressIndicator(color: _goldenYellow));

    final status       = _detail!['status']?.toString() ?? '';
    final nomorTrx     = _detail!['nomor_transaksi']?.toString() ?? widget.order.orderId;
    final tglAmbil     = _detail!['tanggal_ambil']?.toString() ?? '';
    final tglKembali   = _detail!['tanggal_kembali']?.toString() ?? '';
    final metode       = _detail!['metode_pembayaran']?.toString() ?? '';
    final totalSewa    = double.tryParse(_detail!['total_sewa']?.toString() ?? '0') ?? 0;
    final totalDenda   = double.tryParse(_detail!['total_denda']?.toString() ?? '0') ?? 0;
    final statusBayar  = _detail!['status_pembayaran']?.toString() ?? '';
    final createdAt    = _detail!['created_at']?.toString();
    final updatedAt    = _detail!['updated_at']?.toString();
    final items        = (_detail!['details'] as List?) ?? [];
    final durasi       = _durasiHari;
    final isCod        = metode.toLowerCase() == 'tunai';
    final info         = _getStatusInfo(status);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: _darkBrown.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 12))],
            ),
            child: Column(
              children: [
                // ── Header E-Struk ───────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _darkBrown,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Text('MAJELIS RENTAL', style: TextStyle(color: _goldenYellow, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text('Basecamp Rental', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                      const SizedBox(height: 16),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: info.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: info.color.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(info.icon, size: 14, color: info.color),
                            const SizedBox(width: 6),
                            Text(info.label.toUpperCase(), style: TextStyle(color: info.color, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      QrImageView(
                        data: nomorTrx,
                        version: QrVersions.auto,
                        size: 120,
                        backgroundColor: Colors.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                      ),
                      const SizedBox(height: 10),
                      Text(nomorTrx, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text(_fmtDateTime(createdAt), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                    ],
                  ),
                ),

                // ── Dashed Divider ───────────────────────────────────────
                _EStrukDivider(),

                // ── Info Dasar ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      _EStrukRow(label: 'Status', value: info.label, valueColor: info.color),
                      const SizedBox(height: 8),
                      _EStrukRow(
                        label: 'Metode Pembayaran',
                        value: isCod ? 'Tunai (COD)' : 'Cashless (Midtrans)',
                        icon: isCod ? Icons.payments_outlined : Icons.contactless_rounded,
                      ),
                      const SizedBox(height: 8),
                      _EStrukRow(label: 'Tanggal Ambil', value: _fmtDate(tglAmbil)),
                      const SizedBox(height: 8),
                      _EStrukRow(label: 'Tanggal Kembali', value: _fmtDate(tglKembali)),
                      const SizedBox(height: 8),
                      _EStrukRow(label: 'Durasi', value: '$durasi hari'),
                      const SizedBox(height: 8),
                      _EStrukRow(label: 'Dibuat', value: _fmtDateTime(createdAt)),
                      const SizedBox(height: 8),
                      _EStrukRow(label: 'Diperbarui', value: _fmtDateTime(updatedAt)),
                    ],
                  ),
                ),

                // ── COD Info di E-Struk ──────────────────────────────────
                if (isCod && (status == 'menunggu_pembayaran' || status == 'dibayar')) ...[
                  _EStrukDivider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _codMelampauiDeadline ? const Color(0xFFFFEBEE) : const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _codMelampauiDeadline ? const Color(0xFFFFCDD2) : const Color(0xFFFFE082),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _codMelampauiDeadline ? '⚠ Batas Waktu Habis' : '📋 Instruksi COD',
                            style: TextStyle(
                              color: _codMelampauiDeadline ? const Color(0xFFB71C1C) : const Color(0xFFE65100),
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _codMelampauiDeadline
                                ? 'Transaksi ini akan dibatalkan karena melewati batas kedatangan H+1.'
                                : 'Datang ke basecamp dan tunjukkan QR Code atau nomor transaksi di atas kepada petugas.',
                            style: TextStyle(
                              color: _codMelampauiDeadline ? const Color(0xFFD32F2F) : const Color(0xFF5D4037),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          if (_deadlineCod != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Batas: ${_fmtDateTimeFull(_deadlineCod)}',
                              style: TextStyle(
                                color: _codMelampauiDeadline ? const Color(0xFFB71C1C) : const Color(0xFFFF8F00),
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],

                // ── Dashed Divider ───────────────────────────────────────
                _EStrukDivider(),

                // ── Item List ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Text('ITEM SEWA', style: TextStyle(color: _darkBrown.withOpacity(0.4), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ...items.map((item) {
                  final m      = item as Map<String, dynamic>;
                  final barang = m['barang'] as Map<String, dynamic>?;
                  final nama   = barang?['nama']?.toString() ?? 'Item';
                  final qty    = m['jumlah'] ?? m['qty'] ?? 1;
                  final harga  = m['harga_per_hari'];
                  final dur    = m['durasi_hari'] ?? 1;
                  final sub    = m['subtotal'];

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nama, style: const TextStyle(color: _darkBrown, fontWeight: FontWeight.w700, fontSize: 13)),
                              Text(
                                '${_fmtCurrency(harga)}/hari × $qty × $dur hari',
                                style: TextStyle(color: _darkBrown.withOpacity(0.4), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Text(_fmtCurrency(sub), style: const TextStyle(color: _darkBrown, fontWeight: FontWeight.w800, fontSize: 13)),
                      ],
                    ),
                  );
                }),

                // ── Dashed Divider ───────────────────────────────────────
                _EStrukDivider(),

                // ── Total ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal Sewa', style: TextStyle(color: _darkBrown.withOpacity(0.5), fontSize: 13)),
                          Text(_fmtCurrency(totalSewa), style: const TextStyle(color: _darkBrown, fontWeight: FontWeight.w700, fontSize: 13)),
                        ],
                      ),
                      if (totalDenda > 0) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, size: 13, color: Color(0xFFD32F2F)),
                                const SizedBox(width: 4),
                                Text('Denda', style: TextStyle(color: const Color(0xFFD32F2F).withOpacity(0.8), fontSize: 13)),
                              ],
                            ),
                            Text(_fmtCurrency(totalDenda), style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w700, fontSize: 13)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      Container(height: 1.5, color: _darkBrown.withOpacity(0.08)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL', style: TextStyle(color: _darkBrown, fontWeight: FontWeight.w900, fontSize: 15)),
                          Text(_fmtCurrency(totalSewa + totalDenda), style: const TextStyle(color: _darkBrown, fontWeight: FontWeight.w900, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Status Bayar', style: TextStyle(color: _darkBrown.withOpacity(0.4), fontSize: 12)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusBadgeColor(statusBayar).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _statusBayarLabel(statusBayar),
                              style: TextStyle(
                                color: _statusBadgeColor(statusBayar) == Colors.white54 ? _darkBrown : _statusBadgeColor(statusBayar),
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ── Denda detail di e-struk ──────────────────────
                      if (_dendaList.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('DETAIL DENDA', style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                              const SizedBox(height: 8),
                              ..._dendaList.map((d) {
                                final jenis      = d['jenis']?.toString() ?? '';
                                final jumlah     = double.tryParse(d['jumlah']?.toString() ?? '0') ?? 0;
                                final sudahBayar = d['dibayar_pada'] != null;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        jenis == 'kerusakan' ? Icons.construction_rounded : Icons.timer_off_rounded,
                                        size: 12,
                                        color: const Color(0xFFD32F2F),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          jenis == 'kerusakan' ? 'Kerusakan' : 'Keterlambatan',
                                          style: const TextStyle(color: Color(0xFF5D4037), fontSize: 12),
                                        ),
                                      ),
                                      if (sudahBayar)
                                        Container(
                                          margin: const EdgeInsets.only(right: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(6)),
                                          child: const Text('LUNAS', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w900, fontSize: 9)),
                                        ),
                                      Text(_fmtCurrency(jumlah), style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w700, fontSize: 12)),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Footer ───────────────────────────────────────────────
                _EStrukDivider(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text('Terima kasih telah menyewa di', style: TextStyle(color: _darkBrown.withOpacity(0.4), fontSize: 11)),
                      Text('Majelis Rental', style: const TextStyle(color: _darkBrown, fontWeight: FontWeight.w900, fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(
                        'Struk ini diperbarui secara otomatis.\nStatus terkini: ${info.label}',
                        style: TextStyle(color: _darkBrown.withOpacity(0.3), fontSize: 10, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _TabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const darkBrown    = Color(0xFF3E2723);
    const goldenYellow = Color(0xFFE5A93D);
    const creamBg      = Color(0xFFF5EFE6);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? darkBrown : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isSelected ? goldenYellow : darkBrown.withOpacity(0.3)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : darkBrown.withOpacity(0.4),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EStrukDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: List.generate(60, (i) => Expanded(
          child: Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            color: i.isEven ? const Color(0xFF3E2723).withOpacity(0.08) : Colors.transparent,
          ),
        )),
      ),
    );
  }
}

class _EStrukRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;

  const _EStrukRow({required this.label, required this.value, this.valueColor, this.icon});

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF3E2723);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: darkBrown.withOpacity(0.45), fontSize: 12)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 12, color: valueColor ?? darkBrown), const SizedBox(width: 4)],
            Text(value, style: TextStyle(color: valueColor ?? darkBrown, fontWeight: FontWeight.w700, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

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
  final String? timestamp; // BARU: tanggal & jam event
  const _TimelineStep({
    required this.label,
    required this.desc,
    required this.isDone,
    required this.isActive,
    required this.isLast,
    this.timestamp,
  });
}