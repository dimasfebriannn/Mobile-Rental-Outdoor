import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/product_card.dart';
import '../../models/product.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color creamBg = const Color(0xFFF5EFE6);
  final Color darkBrown = const Color(0xFF3E2723);
  final Color deepBlack = const Color(0xFF1B1210); // Tambahan untuk Luxury Depth
  final Color goldenYellow = const Color(0xFFE5A93D);

  int _selectedIndex = 0;
  String _activeCategory = "Semua";
  
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // HEADER LUXURY
              SliverToBoxAdapter(child: _buildLuxuryHeader()),

              const SliverToBoxAdapter(child: SizedBox(height: 50)),

              // FILTERS
              SliverToBoxAdapter(child: _buildCompactFilters()),
              
              // TITLE
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Katalog Rental", style: TextStyle(color: darkBrown, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                      Icon(Icons.sort_rounded, color: darkBrown, size: 20),
                    ],
                  ),
                ),
              ),

              // GRID PRODUK
              _filteredProducts.isEmpty 
                ? SliverToBoxAdapter(child: Center(child: Padding(padding: const EdgeInsets.only(top: 50), child: Text("Barang tidak ditemukan", style: TextStyle(color: darkBrown.withOpacity(0.5))))))
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => ProductCard(
                          product: _filteredProducts[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 500),
                                pageBuilder: (context, animation, secondaryAnimation) => DetailScreen(product: _filteredProducts[index]),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                              ),
                            );
                          }, name: '', price: '', imagePath: '',
                        ),
                        childCount: _filteredProducts.length,
                      ),
                    ),
                  ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          _buildBottomNavBar(),
        ],
      ),
    );
  }

  // ================= REDESIGN HEADER: MODERN LUXURY =================
  Widget _buildLuxuryHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background Luxury Gradient
        Container(
          height: 260,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [darkBrown, deepBlack],
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
            boxShadow: [
              BoxShadow(color: deepBlack.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Stack(
            children: [
              // Efek Cahaya Dekoratif (Ambient Glow)
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200, height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: goldenYellow.withOpacity(0.05),
                    boxShadow: [
                      BoxShadow(
                        color: goldenYellow.withOpacity(0.05),
                        blurRadius: 50,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Topography Pattern Simulation (Garis halus)
              Opacity(
                opacity: 0.05,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('lib/assets/img/majelis.png'), // Opsional: Pakai pattern kalau ada
                      fit: BoxFit.cover,
                      repeat: ImageRepeat.repeat,
                    ),
                  ),
                ),
              ),

              // Content Header
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Profile & Action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: goldenYellow.withOpacity(0.5), width: 1.5)),
                                child: CircleAvatar(radius: 20, backgroundColor: Colors.white, backgroundImage: const AssetImage('lib/assets/img/majelis.png')),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Halo, Petualang", style: TextStyle(color: creamBg.withOpacity(0.5), fontSize: 11, letterSpacing: 1)),
                                  Text("Dimas Febrian", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildHeaderAction(Icons.shopping_bag_outlined, "2"),
                              const SizedBox(width: 12),
                              _buildHeaderAction(Icons.notifications_none_rounded, "5"),
                            ],
                          ),
                        ],
                      ),
                      
                      const Spacer(),

                      // Headline yang sudah di-upgrade
                      Text(
                        "PERLENGKAPAN PRO,",
                        style: TextStyle(color: goldenYellow, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Puncak Menanti.",
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 32, 
                          fontWeight: FontWeight.w900, 
                          height: 1.0, 
                          letterSpacing: -1,
                          shadows: [Shadow(color: Colors.black.withOpacity(0.3), offset: const Offset(0, 4), blurRadius: 10)]
                        ),
                      ),
                      const SizedBox(height: 50), // Ruang untuk Search Bar
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search Bar dengan Efek Glassmorphism yang lebih kuat
        Positioned(
          bottom: -28, left: 24, right: 24,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 25, offset: const Offset(0, 10))],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => _runFilter(),
                  decoration: InputDecoration(
                    hintText: "Cari perlengkapan ekspedisi...",
                    hintStyle: TextStyle(color: darkBrown.withOpacity(0.3), fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: darkBrown, size: 24),
                    suffixIcon: Icon(Icons.tune_rounded, color: goldenYellow, size: 22),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderAction(IconData icon, String count) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10), 
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withOpacity(0.1))), 
          child: Icon(icon, color: Colors.white, size: 22)
        ),
        Positioned(
          top: 8, right: 8, 
          child: Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: goldenYellow, shape: BoxShape.circle, border: Border.all(color: darkBrown, width: 1.5)),
          )
        ),
      ],
    );
  }

  Widget _buildCompactFilters() {
    List<String> categories = ["Semua", "Tenda", "Carrier", "Sepatu", "Lampu", "Alat Masak"];
    return SizedBox(
      height: 42,
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isActive ? darkBrown : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: isActive ? [BoxShadow(color: darkBrown.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))] : [],
                border: Border.all(color: isActive ? darkBrown : Colors.grey.shade200),
              ),
              child: Center(child: Text(categories[index], style: TextStyle(color: isActive ? Colors.white : darkBrown.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.bold))),
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
        height: 95,
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: const BorderRadius.vertical(top: Radius.circular(35)), 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, -5))]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.grid_view_rounded, "Katalog", 0),
            _buildNavItem(Icons.receipt_long_rounded, "Pesanan", 1),
            _buildNavItem(Icons.favorite_border_rounded, "Favorit", 2),
            _buildNavItem(Icons.person_outline_rounded, "Akun", 3),
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: isActive ? goldenYellow.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: isActive ? darkBrown : Colors.grey.shade400, size: 24),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isActive ? darkBrown : Colors.grey.shade400, fontSize: 10, fontWeight: isActive ? FontWeight.w800 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}