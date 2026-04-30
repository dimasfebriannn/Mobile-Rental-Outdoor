import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:majelis_adventure/screens/chat/chat_screen.dart';
import 'package:majelis_adventure/screens/profile/profile_screen.dart';
import '../../widgets/product_card.dart';
import '../../models/product.dart';
import '../history/history_screen.dart'; 
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color latarKrem = const Color(0xFFF5EFE6);
  final Color cokelatTua = const Color(0xFF3E2723);
  final Color emasMajelis = const Color(0xFFE5A93D);

  int _selectedIndex = 0;
  int _currentPromoIndex = 0; // Untuk indikator promosi
  String _activeCategory = "Semua";

  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];

  // Data Promosi Random (Gambar Outdoor)
  final List<Map<String, String>> promos = [
    {
      "image": "https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?q=80&w=1000",
      "title": "Diskon Member Baru",
      "subtitle": "Potongan 20% untuk sewa pertama"
    },
    {
      "image": "https://images.unsplash.com/photo-1537225228614-56cc3556d7ed?q=80&w=1000",
      "title": "Paket Pendaki Pemula",
      "subtitle": "Tenda + Carrier + Matras hanya 75rb"
    },
    {
      "image": "https://images.unsplash.com/photo-1478131143081-80f7f84ca84d?q=80&w=1000",
      "title": "Promo Akhir Pekan",
      "subtitle": "Sewa 3 hari, bayar cuma 2 hari"
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredProducts = allProducts;
  }

  void _runFilter() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = allProducts.where((product) {
        final matchCategory = _activeCategory == "Semua" || product.category == _activeCategory;
        final matchQuery = product.name.toLowerCase().contains(query);
        return matchCategory && matchQuery;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: latarKrem,
      body: Stack(
        children: [
          _buildBody(),
          _buildBottomNavBar(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: return _buildCatalogPage();
      case 1: return const HistoryScreen();
      case 2: return const ChatScreen();
      case 3: return const ProfileScreen();
      default: return _buildCatalogPage();
    }
  }

  Widget _buildCatalogPage() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildSleekHeader()),
        SliverToBoxAdapter(child: _buildSleekSearchBar()),
        
        // --- SEKSI PROMOSI (REVISI BARU) ---
        SliverToBoxAdapter(child: _buildPromotionCarousel()),

        SliverToBoxAdapter(child: _buildPillFilters()),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Katalog Pilihan", style: TextStyle(color: cokelatTua, fontSize: 18, fontWeight: FontWeight.w900)),
                Icon(Icons.tune_rounded, color: emasMajelis, size: 20),
              ],
            ),
          ),
        ),

        _filteredProducts.isEmpty
            ? SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Text("Peralatan tidak ditemukan", style: TextStyle(color: cokelatTua.withOpacity(0.3))),
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildAnimatedProductCard(_filteredProducts[index]),
                    childCount: _filteredProducts.length,
                  ),
                ),
              ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  // --- WIDGET PROMOSI CAROUSEL ---
  Widget _buildPromotionCarousel() {
    return Column(
      children: [
        Container(
          height: 180,
          margin: const EdgeInsets.only(top: 25),
          child: PageView.builder(
            onPageChanged: (index) => setState(() => _currentPromoIndex = index),
            controller: PageController(viewportFraction: 0.85),
            itemCount: promos.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(promos[index]['image']!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [cokelatTua.withOpacity(0.8), Colors.transparent],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(promos[index]['title']!, 
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(promos[index]['subtitle']!, 
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(promos.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentPromoIndex == index ? 20 : 6,
              decoration: BoxDecoration(
                color: _currentPromoIndex == index ? emasMajelis : cokelatTua.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSleekHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: cokelatTua.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("OFFICIAL RENTAL", style: TextStyle(color: emasMajelis, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
              Text("Majelis Adventure", style: TextStyle(color: cokelatTua, fontSize: 22, fontWeight: FontWeight.w900)),
            ],
          ),
          const CircleAvatar(radius: 22, backgroundColor: Color(0xFFF5EFE6), backgroundImage: AssetImage('lib/assets/img/majelis.png')),
        ],
      ),
    );
  }

  Widget _buildSleekSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cokelatTua.withOpacity(0.05)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _runFilter(),
        decoration: InputDecoration(
          hintText: "Cari alat ekspedisi...",
          hintStyle: TextStyle(color: cokelatTua.withOpacity(0.3), fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: cokelatTua, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildPillFilters() {
    List<String> categories = ["Semua", "Tenda", "Carrier", "Sepatu", "Lampu", "Alat Masak"];
    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 25),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 24),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isActive = _activeCategory == categories[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _activeCategory = categories[index];
                _runFilter();
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isActive ? cokelatTua : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isActive ? cokelatTua : cokelatTua.withOpacity(0.1)),
              ),
              child: Center(
                child: Text(categories[index], style: TextStyle(color: isActive ? Colors.white : cokelatTua.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w900)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, anim, _) => DetailScreen(product: product),
          transitionsBuilder: (context, anim, _, child) => FadeTransition(opacity: anim, child: child),
        ));
      },
      child: ProductCard(product: product, name: product.name, price: product.price, imagePath: product.imagePath, onTap: () {}),
    );
  }

  Widget _buildBottomNavBar() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(top: BorderSide(color: cokelatTua.withOpacity(0.05))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.grid_view_rounded, "Katalog", 0),
            _buildNavItem(Icons.receipt_long_rounded, "Pesanan", 1),
            _buildNavItem(Icons.forum_outlined, "Pesan", 2),
            _buildNavItem(Icons.person_pin_rounded, "Akun", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? cokelatTua : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isActive ? Colors.white : cokelatTua.withOpacity(0.3), size: 22),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isActive ? cokelatTua : cokelatTua.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}