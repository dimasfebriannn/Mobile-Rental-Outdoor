// lib/screens/orders/history_screen.dart
//
// Halaman riwayat pesanan — menampilkan semua transaksi user
// dengan tab filter: Semua / Aktif / Selesai / Dibatalkan.
//
// FIXES:
//  1. Exception dari OrderModel.fromJson ditangkap per-item
//     sehingga satu data rusak tidak menjatuhkan seluruh list.
//  2. Gambar ditangani gracefully: full URL, storage path, atau asset.
//  3. Pull-to-refresh dengan RefreshIndicator.
//  4. rawStatus dipakai untuk chip status yang akurat.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../models/order_model.dart';
import '../../services/checkout_service.dart';
import 'order_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  // ── Konstanta warna (seragam dengan OrderDetailScreen) ─────────────────
  static const Color _darkBrown    = Color(0xFF3E2723);
  static const Color _goldenYellow = Color(0xFFE5A93D);
  static const Color _creamBg      = Color(0xFFF5EFE6);

  late TabController _tabController;

  List<OrderModel> _orders = [];
  bool   _isLoading = true;
  String? _error;

  // ── Lifecycle ───────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    initializeDateFormatting('id_ID', null).then((_) => _fetchOrders());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Fetch data ──────────────────────────────────────────────────────────
  Future<void> _fetchOrders() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error     = null;
    });

    try {
      final raw = await CheckoutService.instance.getHistory();

      // Parse per-item; jika satu item gagal parse, skip (bukan crash semua).
      final orders = <OrderModel>[];
      for (final item in raw) {
        if (item is! Map<String, dynamic>) continue;
        try {
          orders.add(OrderModel.fromJson(item));
        } catch (e, st) {
          debugPrint('[HistoryScreen] Parse error pada item: $e\n$st');
        }
      }

      if (mounted) {
        setState(() {
          _orders    = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[HistoryScreen] Fetch error: $e');
      if (mounted) {
        setState(() {
          _error     = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // ── Filter per tab ──────────────────────────────────────────────────────
  List<OrderModel> _filtered(int tabIndex) {
    switch (tabIndex) {
      case 1: // Aktif
        return _orders
            .where((o) =>
                o.status == OrderStatus.aktif ||
                o.status == OrderStatus.diproses)
            .toList();
      case 2: // Selesai
        return _orders
            .where((o) => o.status == OrderStatus.selesai)
            .toList();
      case 3: // Dibatalkan
        return _orders
            .where((o) => o.status == OrderStatus.dibatalkan)
            .toList();
      default: // Semua
        return _orders;
    }
  }

  // ── Root build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _creamBg,
      body: Stack(
        children: [
          // Dekorasi lingkaran background
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
          Positioned(
            bottom: -60, left: -40,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _darkBrown.withOpacity(0.03),
              ),
            ),
          ),

          // Konten utama
          Positioned.fill(
            child: Column(
              children: [
                const SizedBox(height: 108),
                _buildTabBar(),
                const SizedBox(height: 14),
                Expanded(child: _buildBody()),
              ],
            ),
          ),

          // Glass top bar (selalu di atas)
          _buildGlassTopBar(),
        ],
      ),
    );
  }

  // ── Glass Top Bar ───────────────────────────────────────────────────────
  Widget _buildGlassTopBar() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 14),
            color: Colors.white.withOpacity(0.88),
            child: Row(
              children: [
                // Icon + judul
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: _darkBrown.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: _darkBrown, size: 16),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Riwayat',
                      style: TextStyle(
                        color: _goldenYellow,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Text(
                      'Pesanan Saya',
                      style: TextStyle(
                        color: _darkBrown,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Tombol refresh
                GestureDetector(
                  onTap: _fetchOrders,
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _darkBrown.withOpacity(0.08)),
                      boxShadow: [
                        BoxShadow(
                          color: _darkBrown.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      color: _darkBrown.withOpacity(0.5),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── TabBar ──────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _darkBrown.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: _darkBrown,
          borderRadius: BorderRadius.circular(11),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: _darkBrown.withOpacity(0.4),
        labelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Semua'),
          Tab(text: 'Aktif'),
          Tab(text: 'Selesai'),
          Tab(text: 'Batal'),
        ],
      ),
    );
  }

  // ── Body (loading / error / list) ───────────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _goldenYellow, strokeWidth: 2.5),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return TabBarView(
      controller: _tabController,
      children: List.generate(4, (i) => _buildList(_filtered(i))),
    );
  }

  // ── Error state ─────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _darkBrown.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 40,
                color: _darkBrown.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Gagal memuat data',
              style: TextStyle(
                color: _darkBrown,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Periksa koneksi internet Anda\nlalu coba lagi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _darkBrown.withOpacity(0.4),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _fetchOrders,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  color: _darkBrown,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _darkBrown.withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── List pesanan ────────────────────────────────────────────────────────
  Widget _buildList(List<OrderModel> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _darkBrown.withOpacity(0.05),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 36,
                color: _darkBrown.withOpacity(0.18),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada pesanan',
              style: TextStyle(
                color: _darkBrown.withOpacity(0.35),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _goldenYellow,
      backgroundColor: Colors.white,
      onRefresh: _fetchOrders,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _buildOrderCard(items[i]),
      ),
    );
  }

  // ── Kartu pesanan ───────────────────────────────────────────────────────
  Widget _buildOrderCard(OrderModel order) {
    final si  = _statusInfo(order.rawStatus);
    final fmt = NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0,
    );
    final hasDenda   = (order.dendaNominal ?? 0) > 0;
    final dendaLunas = order.dendaStatus == 'lunas';

    return GestureDetector(
      onTap: () async {
        await Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(
              transaksiId: order.id,
              order: order,
            ),
          ),
        );
        // Refresh setelah kembali dari detail (misal: baru bayar denda)
        _fetchOrders();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _darkBrown.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Status bar ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: si.bgColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(si.icon, size: 13, color: si.color),
                  const SizedBox(width: 6),
                  Text(
                    si.label,
                    style: TextStyle(
                      color: si.color,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    order.orderId,
                    style: TextStyle(
                      color: si.color.withOpacity(0.65),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            // ── Konten utama ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Gambar produk
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: _creamBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: _buildProductImage(order.imagePath),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nama & tanggal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.productName,
                          style: const TextStyle(
                            color: _darkBrown,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 10,
                              color: _goldenYellow,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                order.date,
                                style: TextStyle(
                                  color: _darkBrown.withOpacity(0.4),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Harga & badge denda
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        fmt.format(order.totalSewa ?? 0),
                        style: const TextStyle(
                          color: _darkBrown,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                      if (hasDenda) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: dendaLunas
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            dendaLunas ? 'Denda Lunas' : 'Ada Denda',
                            style: TextStyle(
                              color: dendaLunas
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFD32F2F),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // ── Footer: tombol lihat detail ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _creamBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lihat Detail',
                          style: TextStyle(
                            color: _darkBrown.withOpacity(0.6),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: _darkBrown.withOpacity(0.35),
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
    );
  }

  // ── Gambar produk (network / asset / fallback) ──────────────────────────
  Widget _buildProductImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _fallbackIcon(),
      );
    }
    if (path.startsWith('lib/') || path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _fallbackIcon(),
      );
    }
    // Path storage mentah (mis. 'barang/abc.jpg') — tampilkan icon saja
    // karena URL base berubah setiap ngrok restart.
    // Gambar lengkap tetap tampil di OrderDetailScreen via foto_utama_url.
    return _fallbackIcon();
  }

  Widget _fallbackIcon() => const Icon(
    Icons.backpack_outlined,
    color: _darkBrown,
    size: 26,
  );

  // ── Status info ─────────────────────────────────────────────────────────
  _StatusInfo _statusInfo(String raw) {
    switch (raw) {
      case 'menunggu_pembayaran':
        return _StatusInfo(
          'Menunggu Pembayaran',
          const Color(0xFFFF8F00),
          const Color(0xFFFFF8E1),
          Icons.hourglass_top_rounded,
        );
      case 'dibayar':
        return _StatusInfo(
          'Pembayaran Dikonfirmasi',
          const Color(0xFF1565C0),
          const Color(0xFFE3F2FD),
          Icons.verified_rounded,
        );
      case 'berjalan':
        return _StatusInfo(
          'Sedang Dipinjam',
          const Color(0xFF2E7D32),
          const Color(0xFFE8F5E9),
          Icons.directions_run_rounded,
        );
      case 'terlambat':
        return _StatusInfo(
          'Terlambat Dikembalikan',
          const Color(0xFFD32F2F),
          const Color(0xFFFFEBEE),
          Icons.warning_amber_rounded,
        );
      case 'dikembalikan':
        return _StatusInfo(
          'Barang Dikembalikan',
          const Color(0xFF6A1B9A),
          const Color(0xFFF3E5F5),
          Icons.assignment_return_rounded,
        );
      case 'selesai':
        return _StatusInfo(
          'Pesanan Selesai',
          _darkBrown,
          _creamBg,
          Icons.check_circle_rounded,
        );
      case 'dibatalkan':
        return _StatusInfo(
          'Dibatalkan',
          const Color(0xFF757575),
          const Color(0xFFF5F5F5),
          Icons.cancel_rounded,
        );
      default:
        return _StatusInfo(
          'Diproses',
          const Color(0xFFFF8F00),
          const Color(0xFFFFF8E1),
          Icons.pending_rounded,
        );
    }
  }
}

// ── Data model internal ────────────────────────────────────────────────────

class _StatusInfo {
  final String  label;
  final Color   color;
  final Color   bgColor;
  final IconData icon;

  const _StatusInfo(this.label, this.color, this.bgColor, this.icon);
}