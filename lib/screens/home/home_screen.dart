import 'dart:async'; 
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
  int _currentPromoIndex = 0;
  
  // Logic untuk Unlimited Slide
  late PageController _pageController;
  Timer? _timer;

  String _activeCategory = "Semua";
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];

  final List<Map<String, String>> promos = [
    {
      "image": "https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?q=80&w=1000",
      "tag": "SPECIAL OFFER",
      "title": "Diskon Member Baru",
      "desc": "Potongan 20% sewa pertama"
    },
    {
      "image": "https://images.unsplash.com/photo-1537225228614-56cc3556d7ed?q=80&w=1000",
      "tag": "BEST DEAL",
      "title": "Paket Pendaki Hemat",
      "desc": "Tenda + Carrier + Matras"
    },
    {
      "image": "https://images.unsplash.com/photo-1478131143081-80f7f84ca84d?q=80&w=1000",
      "tag": "WEEKEND PROMO",
      "title": "Promo Akhir Pekan",
      "desc": "Sewa 3 hari, bayar 2 hari"
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredProducts = allProducts;
    
    // Inisialisasi PageController untuk unlimited loop
    _pageController = PageController(initialPage: 500, viewportFraction: 1.0);
    
    // Timer Auto-Slide otomatis setiap 3 detik
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutQuart,
      );
    });
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
  void dispose() {
    _timer?.cancel(); // Matikan timer saat pindah screen agar tidak memory leak
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
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

  Widget _buildCatalogPage() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildLuxuryHeader()),
        SliverToBoxAdapter(child: _buildSleekSearchBar()),
        
        // --- PROMO BANNER REVISI: LANCIP & AUTO-SLIDE ---
        SliverToBoxAdapter(child: _buildPromoBanner()),

        SliverToBoxAdapter(child: _buildPillFilters()),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Katalog Unggulan", 
                  style: TextStyle(color: cokelatTua, fontSize: 18, fontWeight: FontWeight.w900)),
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
                    child: Text("Peralatan tidak ditemukan", 
                      style: TextStyle(color: cokelatTua.withOpacity(0.3))),
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, 
                    crossAxisSpacing: 16, 
                    mainAxisSpacing: 16, 
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = _filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 400),
                              pageBuilder: (context, anim, _) => DetailScreen(product: product),
                              transitionsBuilder: (context, anim, _, child) => 
                                  FadeTransition(opacity: anim, child: child),
                            ),
                          );
                        },
                      );
                    },
                    childCount: _filteredProducts.length,
                  ),
                ),
              ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  Widget _buildLuxuryHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("MAJELIS ADVENTURE", style: TextStyle(color: emasMajelis, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                Text("Halo, Dimas", style: TextStyle(color: cokelatTua, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              ],
            ),
          ),
          _buildHeaderIcon(Icons.shopping_bag_outlined, 2), 
          const SizedBox(width: 12),
          _buildHeaderIcon(Icons.notifications_none_rounded, 5),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: latarKrem,
            backgroundImage: const AssetImage('lib/assets/img/majelis.png'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, int count) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cokelatTua.withOpacity(0.05)),
          ),
          child: Icon(icon, color: cokelatTua, size: 22),
        ),
        if (count > 0)
          Positioned(
            right: 4, top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: emasMajelis, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
              child: Text(count.toString(), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  // --- WIDGET PROMO BANNER REVISI ---
  Widget _buildPromoBanner() {
    return Container(
      height: 180,
      margin: const EdgeInsets.fromLTRB(24, 25, 24, 0), // Margin samping dijaga
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPromoIndex = index % promos.length;
              });
            },
            // itemCount sangat besar untuk simulasi unlimited
            itemCount: 10000, 
            itemBuilder: (context, index) {
              final promo = promos[index % promos.length];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.zero, // LANCIP
                  image: DecorationImage(
                    image: NetworkImage(promo['image']!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
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
                      Text(promo['tag']!, style: TextStyle(color: emasMajelis, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      Text(promo['title']!, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(promo['desc']!, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
          // DOTS INDICATOR (Putih & Di dalam card)
          Positioned(
            bottom: 15,
            right: 20,
            child: Row(
              children: List.generate(promos.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  width: _currentPromoIndex == i ? 18 : 6,
                  decoration: BoxDecoration(
                    color: _currentPromoIndex == i ? Colors.white : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleekSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cokelatTua.withOpacity(0.05)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _runFilter(),
        decoration: InputDecoration(
          hintText: "Cari perlengkapan gunung...",
          hintStyle: TextStyle(color: cokelatTua.withOpacity(0.3), fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: cokelatTua, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  Widget _buildPillFilters() {
    List<String> cats = ["Semua", "Tenda", "Carrier", "Sepatu", "Alat Masak"];
    return Container(
      height: 38,
      margin: const EdgeInsets.only(top: 25),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 24),
        itemCount: cats.length,
        itemBuilder: (context, index) {
          bool isActive = _activeCategory == cats[index];
          return GestureDetector(
            onTap: () {
              setState(() { _activeCategory = cats[index]; _runFilter(); });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isActive ? cokelatTua : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isActive ? cokelatTua : cokelatTua.withOpacity(0.1)),
              ),
              child: Center(
                child: Text(cats[index], style: TextStyle(color: isActive ? Colors.white : cokelatTua.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w900)),
              ),
            ),
          );
        },
      ),
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
            _buildNavItem(Icons.forum_outlined, "Percakapan", 2),
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: isActive ? cokelatTua : Colors.transparent, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: isActive ? Colors.white : cokelatTua.withOpacity(0.3), size: 22),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isActive ? cokelatTua : cokelatTua.withOpacity(0.3), fontSize: 10, fontWeight: isActive ? FontWeight.w900 : FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}