import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../widgets/order_card.dart';
import 'order_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color cokelatTua = const Color(0xFF3E2723);
  final Color emasMajelis = const Color(0xFFE5A93D);
  final Color latarKrem = const Color(0xFFF5EFE6);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: latarKrem,
      body: Column(
        children: [
          // 1. HEADER RAMPING & MINIMALIS (SLIM DESIGN)
          _buildSlimHeader(),

          // 2. TAB SELECTION (MODERN SEGMENTED STYLE)
          _buildModernTabBar(),

          // 3. DAFTAR PESANAN
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildOrderList(isHistory: false),
                _buildOrderList(isHistory: true),
              ],
            ),
          ),
          const SizedBox(height: 80), 
        ],
      ),
    );
  }

  // HEADER DENGAN TINGGI YANG LEBIH RAMPING
  Widget _buildSlimHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: cokelatTua.withOpacity(0.05), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "JEJAK SEWA",
                style: TextStyle(
                  color: emasMajelis,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Riwayat Pesanan",
                style: TextStyle(
                  color: cokelatTua,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          // ICON MINIMALIS
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: latarKrem.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.receipt_long_outlined, color: cokelatTua, size: 20),
          ),
        ],
      ),
    );
  }

  // TAB BAR DENGAN DESAIN MODERN PILL YANG LEBIH FLAT
  Widget _buildModernTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cokelatTua.withOpacity(0.05)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: cokelatTua,
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: cokelatTua.withOpacity(0.4),
        labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: "Berjalan"),
          Tab(text: "Riwayat"),
        ],
      ),
    );
  }

  Widget _buildOrderList({required bool isHistory}) {
    final filteredOrders = dummyOrders.where((order) {
      if (isHistory) {
        return order.status == OrderStatus.selesai || order.status == OrderStatus.dibatalkan;
      } else {
        return order.status == OrderStatus.aktif || order.status == OrderStatus.diproses;
      }
    }).toList();

    if (filteredOrders.isEmpty) {
      return _buildEmptyState();
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // RINGKASAN DATA
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 15, 24, 5),
            child: Text(
              "${filteredOrders.length} Pesanan Ditemukan",
              style: TextStyle(
                color: cokelatTua.withOpacity(0.3),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final order = filteredOrders[index];
                
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 300),
                            pageBuilder: (context, anim, _) => OrderDetailScreen(order: order),
                            transitionsBuilder: (context, anim, _, child) => FadeTransition(opacity: anim, child: child),
                          ),
                        );
                      },
                      child: OrderCard(order: order),
                    ),
                  ),
                );
              },
              childCount: filteredOrders.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cokelatTua.withOpacity(0.05)),
            ),
            child: Icon(Icons.receipt_long_rounded, size: 35, color: cokelatTua.withOpacity(0.1)),
          ),
          const SizedBox(height: 24),
          Text(
            "Belum Ada Jejak",
            style: TextStyle(color: cokelatTua, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            "Mulai petualanganmu dengan menyewa\nalat pro di katalog kami.",
            textAlign: TextAlign.center,
            style: TextStyle(color: cokelatTua.withOpacity(0.4), fontSize: 12, height: 1.5, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 30),
          // TOMBOL MINIMALIS
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: cokelatTua, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              "LIHAT KATALOG",
              style: TextStyle(color: cokelatTua, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
            ),
          )
        ],
      ),
    );
  }
}