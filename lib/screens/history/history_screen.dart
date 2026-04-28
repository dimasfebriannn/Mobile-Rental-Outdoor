import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../widgets/order_card.dart';
import 'order_detail_screen.dart'; // Pastikan import detail pesanan ada

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color darkBrown = const Color(0xFF3E2723);
  final Color goldenYellow = const Color(0xFFE5A93D);
  final Color creamBg = const Color(0xFFF5EFE6);
  final Color deepBlack = const Color(0xFF1B1210);

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
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // 1. ELEMEN DEKORATIF BACKGROUND
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: goldenYellow.withOpacity(0.03),
              ),
            ),
          ),

          // 2. KONTEN UTAMA
          Column(
            children: [
              _buildLuxuryHeader(),
              _buildCustomTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrderList(isHistory: false),
                    _buildOrderList(isHistory: true),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Spasi agar tidak tertutup bottom nav
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLuxuryHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pesanan Saya",
                style: TextStyle(
                  color: darkBrown,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Lacak dan kelola rental alatmu",
                style: TextStyle(
                  color: darkBrown.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
            ),
            child: Icon(Icons.receipt_long_outlined, color: darkBrown, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: goldenYellow, width: 3),
          insets: const EdgeInsets.symmetric(horizontal: 40),
        ),
        labelColor: darkBrown,
        unselectedLabelColor: darkBrown.withOpacity(0.3),
        labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        // MODIFIKASI: Menambahkan GestureDetector untuk menangani tap
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    OrderDetailScreen(order: order),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          },
          child: OrderCard(order: order),
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
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_motion_outlined,
              size: 60,
              color: darkBrown.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Belum Ada Jejak",
            style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            "Mulailah petualangan barumu\ndengan menyewa alat pro kami.",
            textAlign: TextAlign.center,
            style: TextStyle(color: darkBrown.withOpacity(0.4), fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}