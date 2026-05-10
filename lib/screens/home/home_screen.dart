// lib/screens/home/home_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';               // ← BARU
import 'package:majelis_adventure/screens/chat/chat_screen.dart';
import 'package:majelis_adventure/screens/home/notification_screen.dart';
import 'package:majelis_adventure/screens/profile/profile_screen.dart';
import 'package:majelis_adventure/screens/recommendation/recommendation_screen.dart'; // ← BARU
import '../../widgets/product_card.dart';
import '../../models/product.dart';
import '../../services/barang_service.dart';
import '../history/history_screen.dart';
import 'detail_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color latarKrem   = const Color(0xFFF5EFE6);
  final Color cokelatTua  = const Color(0xFF3E2723);
  final Color emasMajelis = const Color(0xFFE5A93D);

  int _selectedIndex     = 0;
  int _currentPromoIndex = 0;

  late PageController _pageController;
  Timer? _timer;

  // ── State API ──────────────────────────────────────────────────────────────
  List<Product> _products      = [];
  List<String>  _categories    = ['Semua'];
  bool          _isLoading     = true;
  bool          _isLoadingCats = true;
  String?       _errorMessage;
  String?       _errorDetail;

  String _activeCategory = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  // ── Image Picker ── BARU ───────────────────────────────────────────────────
  final ImagePicker _imagePicker = ImagePicker();
  bool _isPickingImage = false;

  // ── Promo Banner ───────────────────────────────────────────────────────────
  final List<Map<String, String>> promos = [
    {
      'image': 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?q=80&w=1000',
      'tag':   'SPECIAL OFFER',
      'title': 'Diskon Member Baru',
      'desc':  'Potongan 20% sewa pertama',
    },
    {
      'image': 'https://images.unsplash.com/photo-1537225228614-56cc3556d7ed?q=80&w=1000',
      'tag':   'BEST DEAL',
      'title': 'Paket Pendaki Hemat',
      'desc':  'Tenda + Carrier + Matras',
    },
    {
      'image': 'https://images.unsplash.com/photo-1478131143081-80f7f84ca84d?q=80&w=1000',
      'tag':   'WEEKEND PROMO',
      'title': 'Promo Akhir Pekan',
      'desc':  'Sewa 3 hari, bayar 2 hari',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 500, viewportFraction: 1.0);
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutQuart,
      );
    });
    _searchController.addListener(_onSearchChanged);
    _loadKategori();
    _loadBarang();
  }

  // ── API calls ──────────────────────────────────────────────────────────────
  Future<void> _loadKategori() async {
    try {
      final cats = await BarangService.instance.fetchKategori();
      if (mounted) {
        setState(() {
          _categories    = ['Semua', ...cats];
          _isLoadingCats = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Gagal load kategori: $e');
      if (mounted) setState(() => _isLoadingCats = false);
    }
  }

  Future<void> _loadBarang() async {
    setState(() {
      _isLoading    = true;
      _errorMessage = null;
      _errorDetail  = null;
    });
    try {
      final products = await BarangService.instance.fetchBarang(
        kategori: _activeCategory,
        search:   _searchController.text,
      );
      if (mounted) {
        setState(() {
          _products  = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error fetchBarang: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat produk. Cek koneksi internet.';
          _errorDetail  = e.toString();
          _isLoading    = false;
        });
      }
    }
  }

  Timer? _debounce;
  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _loadBarang);
  }

  // ── AI Image Scan ── BARU ──────────────────────────────────────────────────

  /// Tampilkan bottom sheet pilih Camera atau Gallery
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context:         context,
      backgroundColor: Colors.transparent,
      builder:         (_) => _buildImageSourceSheet(),
    );
  }

  Widget _buildImageSourceSheet() {
    return Container(
      margin:  const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle bar ───────────────────────────────────────────────────
          Container(
            width:  40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color:        cokelatTua.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // ── Title ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:  cokelatTua.withOpacity(0.06),
                    shape:  BoxShape.circle,
                  ),
                  child: Icon(Icons.auto_awesome_rounded,
                      color: cokelatTua, size: 26),
                ),
                const SizedBox(height: 12),
                Text(
                  'Cari dengan Gambar',
                  style: TextStyle(
                      color:      cokelatTua,
                      fontSize:   17,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI akan mengenali peralatan outdoor\ndari foto dan merekomendasikan yang tersedia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color:    cokelatTua.withOpacity(0.5),
                      fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // ── Buttons ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: _buildSourceButton(
                  icon:   Icons.camera_alt_rounded,
                  label:  'Kamera',
                  source: ImageSource.camera,
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildSourceButton(
                  icon:   Icons.photo_library_rounded,
                  label:  'Galeri',
                  source: ImageSource.gallery,
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: TextStyle(
                    color:    cokelatTua.withOpacity(0.4),
                    fontSize: 14)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSourceButton({
    required IconData    icon,
    required String      label,
    required ImageSource source,
  }) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context); // tutup bottom sheet
        await _pickAndNavigate(source);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color:        cokelatTua,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    color:      Colors.white,
                    fontSize:   13,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  /// Pick gambar → navigate ke RecommendationScreen
  Future<void> _pickAndNavigate(ImageSource source) async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final picked = await _imagePicker.pickImage(
        source:      source,
        imageQuality: 80,    // compress ke 80% untuk hemat bandwidth
        maxWidth:    1024,
        maxHeight:   1024,
      );

      if (picked == null || !mounted) return;

      final file = File(picked.path);

      if (!mounted) return;

      await Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, anim, _) =>
              RecommendationScreen(imageFile: file),
          transitionsBuilder: (context, anim, _, child) =>
              SlideTransition(
                position: Tween<Offset>(
                    begin: const Offset(0, 0.1), end: Offset.zero)
                    .animate(CurvedAnimation(
                        parent: anim, curve: Curves.easeOut)),
                child: FadeTransition(opacity: anim, child: child),
              ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Gagal pick image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:  const Text('Gagal membuka kamera/galeri.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _debounce?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:  return _buildCatalogPage();
      case 1:  return const HistoryScreen();
      case 2:  return const ChatScreen();
      case 3:  return const ProfileScreen();
      default: return _buildCatalogPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: latarKrem,
      body: Stack(children: [_buildBody(), _buildBottomNavBar()]),
    );
  }

  Widget _buildCatalogPage() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildLuxuryHeader()),
        SliverToBoxAdapter(child: _buildSleekSearchBar()),  // ← DIUPDATE
        SliverToBoxAdapter(child: _buildPromoBanner()),
        SliverToBoxAdapter(child: _buildPillFilters()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Katalog Unggulan',
                    style: TextStyle(
                        color: cokelatTua,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                Icon(Icons.tune_rounded, color: emasMajelis, size: 20),
              ],
            ),
          ),
        ),
        _buildProductGrid(),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  // ── Product Grid ───────────────────────────────────────────────────────────
  Widget _buildProductGrid() {
    if (_isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.72,
          ),
          delegate: SliverChildBuilderDelegate(
            (_, __) => _buildSkeletonCard(),
            childCount: 6,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cokelatTua.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                Icon(Icons.wifi_off_rounded,
                    size: 48, color: cokelatTua.withOpacity(0.25)),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: cokelatTua,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
                if (_errorDetail != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cokelatTua.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _errorDetail!,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: cokelatTua.withOpacity(0.6),
                          fontSize: 10,
                          fontFamily: 'monospace'),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _loadBarang,
                  icon: const Icon(Icons.refresh_rounded,
                      color: Colors.white, size: 18),
                  label: const Text('Coba Lagi',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cokelatTua,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Text('Peralatan tidak ditemukan',
                style: TextStyle(color: cokelatTua.withOpacity(0.3))),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final product = _products[index];
          return ProductCard(
            product: product,
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (context, anim, _) =>
                    DetailScreen(product: product),
                transitionsBuilder: (context, anim, _, child) =>
                    FadeTransition(opacity: anim, child: child),
              ),
            ),
          );
        }, childCount: _products.length),
      ),
    );
  }

  // ── Skeleton ───────────────────────────────────────────────────────────────
  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: cokelatTua.withOpacity(0.07),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cokelatTua.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(6),
                    )),
                const SizedBox(height: 6),
                Container(
                    height: 10,
                    width: 80,
                    decoration: BoxDecoration(
                      color: cokelatTua.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(6),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
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
                Text('MAJELIS ADVENTURE',
                    style: TextStyle(
                        color: emasMajelis,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2)),
                Text('Halo, Dimas',
                    style: TextStyle(
                        color: cokelatTua,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5)),
              ],
            ),
          ),
          _buildHeaderIcon(Icons.shopping_bag_outlined, 2, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CartScreen()));
          }),
          const SizedBox(width: 12),
          _buildHeaderIcon(Icons.notifications_none_rounded, 5, () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationScreen()));
          }),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: latarKrem,
            backgroundImage:
                const AssetImage('lib/assets/img/majelis.png'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(
      IconData icon, int count, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: cokelatTua.withOpacity(0.05)),
            ),
            child: Icon(icon, color: cokelatTua, size: 22),
          ),
          if (count > 0)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: emasMajelis,
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(count.toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  // ── Search Bar — DIUPDATE dengan tombol AI scan ────────────────────────────
  Widget _buildSleekSearchBar() {
    return Container(
      margin:  const EdgeInsets.fromLTRB(24, 20, 24, 0),
      height:  50,
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: cokelatTua.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // ── Text field ──────────────────────────────────────────────────
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:  'Cari perlengkapan gunung...',
                hintStyle: TextStyle(
                    color: cokelatTua.withOpacity(0.3), fontSize: 14),
                prefixIcon: Icon(
                    Icons.search_rounded, color: cokelatTua, size: 20),
                border:         InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),

          // ── Divider ─────────────────────────────────────────────────────
          Container(
            width:  1,
            height: 26,
            color:  cokelatTua.withOpacity(0.08),
            margin: const EdgeInsets.symmetric(horizontal: 4),
          ),

          // ── AI Scan Button ───────────────────────────────────────────────
          GestureDetector(
            onTap: _isPickingImage ? null : _showImageSourceSheet,
            child: Container(
              width:  46,
              height: double.infinity,
              decoration: BoxDecoration(
                color: cokelatTua.withOpacity(0.04),
                borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(12)),
              ),
              child: _isPickingImage
                  ? Padding(
                      padding: const EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cokelatTua,
                      ),
                    )
                  : Tooltip(
                      message: 'Cari dengan foto',
                      child: Icon(
                        Icons.camera_enhance_rounded,
                        color: cokelatTua,
                        size: 22,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Promo Banner ───────────────────────────────────────────────────────────
  Widget _buildPromoBanner() {
    return Container(
      height: 180,
      margin: const EdgeInsets.fromLTRB(24, 25, 24, 0),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(
                () => _currentPromoIndex = index % promos.length),
            itemCount: 10000,
            itemBuilder: (context, index) {
              final promo = promos[index % promos.length];
              return Container(
                decoration: BoxDecoration(
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
                      colors: [
                        cokelatTua.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(promo['tag']!,
                          style: TextStyle(
                              color: emasMajelis,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1)),
                      Text(promo['title']!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text(promo['desc']!,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
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
                    color: _currentPromoIndex == i
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
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

  // ── Pill Filters ───────────────────────────────────────────────────────────
  Widget _buildPillFilters() {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(top: 25),
      child: _isLoadingCats
          ? const SizedBox()
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 24),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat      = _categories[index];
                final isActive = _activeCategory == cat;
                return GestureDetector(
                  onTap: () {
                    setState(() => _activeCategory = cat);
                    _loadBarang();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isActive ? cokelatTua : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isActive
                            ? cokelatTua
                            : cokelatTua.withOpacity(0.1),
                      ),
                    ),
                    child: Center(
                      child: Text(cat,
                          style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : cokelatTua.withOpacity(0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w900)),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ── Bottom Nav ─────────────────────────────────────────────────────────────
  Widget _buildBottomNavBar() {
    return Positioned(
      bottom: 0,
      left:   0,
      right:  0,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(
              top: BorderSide(color: cokelatTua.withOpacity(0.05))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.grid_view_rounded, 'Katalog', 0),
            _buildNavItem(Icons.receipt_long_rounded, 'Pesanan', 1),
            _buildNavItem(Icons.forum_outlined, 'Percakapan', 2),
            _buildNavItem(Icons.person_pin_rounded, 'Akun', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _selectedIndex == index;
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? cokelatTua : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: isActive
                      ? Colors.white
                      : cokelatTua.withOpacity(0.3),
                  size: 22),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: isActive
                        ? cokelatTua
                        : cokelatTua.withOpacity(0.3),
                    fontSize: 10,
                    fontWeight: isActive
                        ? FontWeight.w900
                        : FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}