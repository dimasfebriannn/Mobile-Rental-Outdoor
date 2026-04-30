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
          // 1. HEADER RAMPING & MEWAH
          _buildSleekHeader(),

          // 2. TAB SELECTION (PILL STYLE)
          _buildPillTabBar(),

          // 3. DAFTAR PESANAN
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(isHistory: false),
                _buildOrderList(isHistory: true),
              ],
            ),
          ),
          const SizedBox(height: 80), // Jarak untuk Bottom Nav
        ],
      ),
    );
  }

  Widget _buildSleekHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: cokelatTua.withOpacity(0.05), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "RIWAYAT",
                style: TextStyle(
                  color: emasMajelis,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Pesanan Saya",
                style: TextStyle(
                  color: cokelatTua,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cokelatTua.withOpacity(0.1)),
            ),
            child: Icon(Icons.receipt_long_rounded, color: cokelatTua, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildPillTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      padding: const EdgeInsets.all(4),
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
        tabs: const [
          Tab(text: "Berjalan"),
          Tab(text: "Selesai"),
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

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      physics: const BouncingScrollPhysics(),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return Padding(
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
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: cokelatTua.withOpacity(0.03),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_motion_rounded,
              size: 40,
              color: cokelatTua.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Belum Ada Pesanan",
            style: TextStyle(
              color: cokelatTua,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Mulai petualanganmu dengan\nmenyewa perlengkapan terbaik kami.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cokelatTua.withOpacity(0.4),
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}