// lib/screens/home/home_screen.dart
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:majelis_adventure/screens/chat/chat_screen.dart';
import 'package:majelis_adventure/screens/home/notification_screen.dart';
import 'package:majelis_adventure/screens/profile/profile_screen.dart';
import 'package:majelis_adventure/screens/recommendation/recommendation_screen.dart';
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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ── Warna ─────────────────────────────────────────────────────────────────
  static const Color latarKrem   = Color(0xFFF5EFE6);
  static const Color cokelatTua  = Color(0xFF3E2723);
  static const Color cokelatMid  = Color(0xFF6D4C41);
  static const Color emasMajelis = Color(0xFFE5A93D);
  static const Color emasLight   = Color(0xFFFFF3CD);
  static const Color putih       = Colors.white;

  // ── State navigasi ─────────────────────────────────────────────────────────
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
  bool _searchFocused = false;
  final FocusNode _searchFocus = FocusNode();

  // ── Image Picker ───────────────────────────────────────────────────────────
  final ImagePicker _imagePicker = ImagePicker();
  bool _isPickingImage = false;

  // ── Animasi ───────────────────────────────────────────────────────────────
  late AnimationController _headerAnim;
  late AnimationController _scanPulseAnim;
  late Animation<double>   _scanPulse;

  // ── Promo data ─────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> promos = [
    {
      'image': 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?q=80&w=1000',
      'tag':   'SPECIAL OFFER',
      'title': 'Diskon Member Baru',
      'desc':  'Potongan 20% sewa pertama',
      'accent': Color(0xFFE5A93D),
    },
    {
      'image': 'https://images.unsplash.com/photo-1537225228614-56cc3556d7ed?q=80&w=1000',
      'tag':   'BEST DEAL',
      'title': 'Paket Pendaki Hemat',
      'desc':  'Tenda + Carrier + Matras',
      'accent': Color(0xFF81C784),
    },
    {
      'image': 'https://images.unsplash.com/photo-1478131143081-80f7f84ca84d?q=80&w=1000',
      'tag':   'WEEKEND PROMO',
      'title': 'Promo Akhir Pekan',
      'desc':  'Sewa 3 hari, bayar 2 hari',
      'accent': Color(0xFF64B5F6),
    },
  ];

  // ── Shortcut kategori cepat ────────────────────────────────────────────────
  final List<Map<String, dynamic>> _quickAccess = [
    {'icon': Icons.terrain_rounded,         'label': 'Tenda',    'color': Color(0xFF5D4037)},
    {'icon': Icons.backpack_rounded,         'label': 'Carrier',  'color': Color(0xFF6D4C41)},
    {'icon': Icons.water_rounded,            'label': 'Sleeping', 'color': Color(0xFF795548)},
    {'icon': Icons.flashlight_on_rounded,    'label': 'Lampu',    'color': Color(0xFF8D6E63)},
    {'icon': Icons.kitchen_rounded,          'label': 'Masak',    'color': Color(0xFF4E342E)},
    {'icon': Icons.more_horiz_rounded,       'label': 'Lainnya',  'color': Color(0xFFBCAAA4)},
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 500, viewportFraction: 1.0);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      }
    });

    // Header entrance animation
    _headerAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    )..forward();

    // Scan button pulse
    _scanPulseAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scanPulse = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _scanPulseAnim, curve: Curves.easeInOut),
    );

    _searchFocus.addListener(() {
      setState(() => _searchFocused = _searchFocus.hasFocus);
    });

    _searchController.addListener(_onSearchChanged);
    _loadKategori();
    _loadBarang();
  }

  // ── API ────────────────────────────────────────────────────────────────────
  Future<void> _loadKategori() async {
    try {
      final cats = await BarangService.instance.fetchKategori();
      if (mounted) setState(() { _categories = ['Semua', ...cats]; _isLoadingCats = false; });
    } catch (e) {
      debugPrint('❌ Gagal load kategori: $e');
      if (mounted) setState(() => _isLoadingCats = false);
    }
  }

  Future<void> _loadBarang() async {
    setState(() { _isLoading = true; _errorMessage = null; _errorDetail = null; });
    try {
      final products = await BarangService.instance.fetchBarang(
        kategori: _activeCategory, search: _searchController.text,
      );
      if (mounted) setState(() { _products = products; _isLoading = false; });
    } catch (e) {
      debugPrint('❌ Error fetchBarang: $e');
      if (mounted) setState(() {
        _errorMessage = 'Gagal memuat produk. Cek koneksi internet.';
        _errorDetail  = e.toString();
        _isLoading    = false;
      });
    }
  }

  Timer? _debounce;
  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _loadBarang);
  }

  // ── Image Scan ─────────────────────────────────────────────────────────────
  void _showImageSourceSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context:         context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:         (_) => _buildImageSourceSheet(),
    );
  }

  Widget _buildImageSourceSheet() {
    return Container(
      margin:  const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
        color:        putih,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 14, bottom: 24),
            decoration: BoxDecoration(
              color: cokelatTua.withOpacity(0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Ikon animasi
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: RadialGradient(colors: [
                emasMajelis.withOpacity(0.18),
                emasMajelis.withOpacity(0.0),
              ]),
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cokelatTua,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                  color: cokelatTua.withOpacity(0.3),
                  blurRadius: 16, offset: const Offset(0, 6),
                )],
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(height: 14),
          Text('Cari dengan Gambar',
              style: TextStyle(color: cokelatTua, fontSize: 18,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'AI kami mengenali peralatan outdoor dari foto dan langsung merekomendasikan yang tersedia',
              textAlign: TextAlign.center,
              style: TextStyle(color: cokelatTua.withOpacity(0.5), fontSize: 13, height: 1.5),
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(child: _buildSourceButton(
                icon: Icons.camera_alt_rounded, label: 'Kamera',
                sublabel: 'Foto sekarang', source: ImageSource.camera,
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildSourceButton(
                icon: Icons.photo_library_rounded, label: 'Galeri',
                sublabel: 'Dari album', source: ImageSource.gallery,
              )),
            ]),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: TextStyle(color: cokelatTua.withOpacity(0.35),
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSourceButton({
    required IconData icon, required String label,
    required String sublabel, required ImageSource source,
  }) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        await _pickAndNavigate(source);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: cokelatTua,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(
            color: cokelatTua.withOpacity(0.25),
            blurRadius: 12, offset: const Offset(0, 5),
          )],
        ),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: Colors.white,
              fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(sublabel, style: TextStyle(color: Colors.white.withOpacity(0.5),
              fontSize: 11)),
        ]),
      ),
    );
  }

  Future<void> _pickAndNavigate(ImageSource source) async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);
    try {
      final picked = await _imagePicker.pickImage(
        source: source, imageQuality: 80, maxWidth: 1024, maxHeight: 1024,
      );
      if (picked == null || !mounted) return;
      final file = File(picked.path);
      if (!mounted) return;
      await Navigator.push(context, PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, anim, _) => RecommendationScreen(imageFile: file),
        transitionsBuilder: (context, anim, _, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: FadeTransition(opacity: anim, child: child),
        ),
      ));
    } catch (e) {
      debugPrint('❌ Gagal pick image: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Gagal membuka kamera/galeri.'),
            behavior: SnackBarBehavior.floating),
      );
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
    _searchFocus.dispose();
    _headerAnim.dispose();
    _scanPulseAnim.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:  return _buildCatalogPage();
      case 1:  return const HistoryScreen();
      case 2:  return const ChatScreen(hasBottomNavBar: true);
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
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(child: _buildSearchAndScan()),
        SliverToBoxAdapter(child: _buildPromoBanner()),
        SliverToBoxAdapter(child: _buildQuickAccess()),
        SliverToBoxAdapter(child: _buildCategoryFilters()),
        SliverToBoxAdapter(child: _buildCatalogHeader()),
        _buildProductGrid(),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  // ── Header Premium ─────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, __) => Opacity(
        opacity: _headerAnim.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - _headerAnim.value)),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 22),
            decoration: BoxDecoration(
              color: putih,
              boxShadow: [BoxShadow(
                color: cokelatTua.withOpacity(0.04),
                blurRadius: 12, offset: const Offset(0, 4),
              )],
            ),
            child: Row(children: [
              // Greeting
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: emasMajelis.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: emasMajelis.withOpacity(0.3)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(
                            color: emasMajelis, shape: BoxShape.circle,
                            boxShadow: [BoxShadow(
                              color: emasMajelis.withOpacity(0.6),
                              blurRadius: 4, spreadRadius: 1,
                            )],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('MAJELIS RENTAL',
                            style: TextStyle(color: emasMajelis,
                                fontSize: 9, fontWeight: FontWeight.w900,
                                letterSpacing: 1.5)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  RichText(text: TextSpan(
                    style: TextStyle(color: cokelatTua, fontWeight: FontWeight.w900,
                        fontSize: 24, height: 1.15, letterSpacing: -0.5),
                    children: const [
                      TextSpan(text: 'Halo, '),
                      TextSpan(text: 'Dimas 👋'),
                    ],
                  )),
                  const SizedBox(height: 4),
                  Text('Mau mendaki ke mana hari ini?',
                      style: TextStyle(color: cokelatTua.withOpacity(0.4),
                          fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              )),
              const SizedBox(width: 16),
              // Actions kanan
              Row(children: [
                _buildIconAction(
                  icon: Icons.shopping_bag_outlined,
                  badge: 2,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CartScreen())),
                ),
                const SizedBox(width: 10),
                _buildIconAction(
                  icon: Icons.notifications_none_rounded,
                  badge: 5,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const NotificationScreen())),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen())),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: emasMajelis.withOpacity(0.5), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 19,
                      backgroundColor: latarKrem,
                      backgroundImage: const AssetImage('lib/assets/img/majelis.png'),
                    ),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildIconAction({required IconData icon, int badge = 0, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: latarKrem,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cokelatTua.withOpacity(0.07)),
          ),
          child: Icon(icon, color: cokelatTua, size: 21),
        ),
        if (badge > 0)
          Positioned(
            right: 2, top: 2,
            child: Container(
              padding: const EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                color: emasMajelis,
                shape: BoxShape.circle,
                border: Border.all(color: putih, width: 1.5),
              ),
              child: Text(badge.toString(),
                  style: const TextStyle(color: Colors.white,
                      fontSize: 8, fontWeight: FontWeight.w900)),
            ),
          ),
      ]),
    );
  }

  // ── Search + AI Scan ───────────────────────────────────────────────────────
  Widget _buildSearchAndScan() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(children: [
        // Search bar
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 50,
            decoration: BoxDecoration(
              color: putih,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _searchFocused
                    ? cokelatTua.withOpacity(0.35)
                    : cokelatTua.withOpacity(0.07),
                width: _searchFocused ? 1.5 : 1,
              ),
              boxShadow: _searchFocused ? [BoxShadow(
                color: cokelatTua.withOpacity(0.06),
                blurRadius: 10,
              )] : [],
            ),
            child: TextField(
              controller: _searchController,
              focusNode:  _searchFocus,
              style: TextStyle(color: cokelatTua, fontSize: 14,
                  fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText:  'Cari perlengkapan gunung...',
                hintStyle: TextStyle(color: cokelatTua.withOpacity(0.3),
                    fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded,
                    color: cokelatTua.withOpacity(0.4), size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () { _searchController.clear(); _loadBarang(); },
                        child: Icon(Icons.close_rounded,
                            color: cokelatTua.withOpacity(0.3), size: 18),
                      )
                    : null,
                border:         InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // AI Scan Button — terpisah, lebih prominent
        GestureDetector(
          onTap: _isPickingImage ? null : _showImageSourceSheet,
          child: ScaleTransition(
            scale: _scanPulse,
            child: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end:   Alignment.bottomRight,
                  colors: [cokelatTua, cokelatMid],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(
                  color: cokelatTua.withOpacity(0.35),
                  blurRadius: 12, offset: const Offset(0, 5),
                )],
              ),
              child: _isPickingImage
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.document_scanner_rounded,
                      color: Colors.white, size: 22),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Promo Banner Premium ───────────────────────────────────────────────────
  Widget _buildPromoBanner() {
    return Column(children: [
      Container(
        height: 190,
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) =>
                  setState(() => _currentPromoIndex = index % promos.length),
              itemCount: 10000,
              itemBuilder: (context, index) {
                final promo  = promos[index % promos.length];
                final accent = promo['accent'] as Color;
                return Stack(fit: StackFit.expand, children: [
                  Image.network(promo['image']!, fit: BoxFit.cover),
                  // Multi-layer gradient
                  Container(decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end:   Alignment.bottomLeft,
                      colors: [
                        Colors.transparent,
                        cokelatTua.withOpacity(0.75),
                      ],
                    ),
                  )),
                  // Konten teks
                  Positioned(
                    bottom: 20, left: 20, right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: accent.withOpacity(0.5)),
                          ),
                          child: Text(promo['tag']!,
                              style: TextStyle(color: accent,
                                  fontSize: 9, fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5)),
                        ),
                        const SizedBox(height: 8),
                        Text(promo['title']!,
                            style: const TextStyle(color: Colors.white,
                                fontSize: 20, fontWeight: FontWeight.w900,
                                letterSpacing: -0.3)),
                        const SizedBox(height: 4),
                        Text(promo['desc']!,
                            style: TextStyle(color: Colors.white.withOpacity(0.75),
                                fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ]);
              },
            ),
            // Dot indikator kanan bawah
            Positioned(
              bottom: 14, right: 16,
              child: Row(
                children: List.generate(promos.length, (i) {
                  final active = _currentPromoIndex == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(left: 5),
                    height: 5,
                    width: active ? 20 : 5,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ]),
        ),
      ),
    ]);
  }

  // ── Quick Access grid ──────────────────────────────────────────────────────
  Widget _buildQuickAccess() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Kategori', style: TextStyle(color: cokelatTua,
              fontSize: 15, fontWeight: FontWeight.w900)),
          Text('Lihat Semua', style: TextStyle(color: emasMajelis,
              fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _quickAccess.map((item) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _activeCategory = item['label']);
                    _loadBarang();
                  },
                  child: Column(children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        color: _activeCategory == item['label']
                            ? cokelatTua
                            : putih,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _activeCategory == item['label']
                              ? cokelatTua
                              : cokelatTua.withOpacity(0.08),
                        ),
                        boxShadow: _activeCategory == item['label']
                            ? [BoxShadow(color: cokelatTua.withOpacity(0.3),
                                blurRadius: 10, offset: const Offset(0, 4))]
                            : [],
                      ),
                      child: Icon(item['icon'] as IconData,
                          color: _activeCategory == item['label']
                              ? Colors.white
                              : (item['color'] as Color).withOpacity(0.7),
                          size: 20),
                    ),
                    const SizedBox(height: 6),
                    Text(item['label'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _activeCategory == item['label']
                              ? cokelatTua
                              : cokelatTua.withOpacity(0.5),
                          fontSize: 10,
                          fontWeight: _activeCategory == item['label']
                              ? FontWeight.w800
                              : FontWeight.w600,
                        )),
                  ]),
                ),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }

  // ── Category Filters (pill scroll) ────────────────────────────────────────
  Widget _buildCategoryFilters() {
    if (_isLoadingCats) return const SizedBox(height: 20);
    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 18),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat      = _categories[index];
          final isActive = _activeCategory == cat;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _activeCategory = cat);
              _loadBarang();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isActive ? cokelatTua : putih,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive ? cokelatTua : cokelatTua.withOpacity(0.08),
                ),
                boxShadow: isActive ? [BoxShadow(
                  color: cokelatTua.withOpacity(0.2),
                  blurRadius: 8, offset: const Offset(0, 3),
                )] : [],
              ),
              child: Center(child: Text(cat,
                  style: TextStyle(
                    color: isActive ? Colors.white : cokelatTua.withOpacity(0.5),
                    fontSize: 12, fontWeight: FontWeight.w800,
                  ))),
            ),
          );
        },
      ),
    );
  }

  // ── Catalog Header ─────────────────────────────────────────────────────────
  Widget _buildCatalogHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Katalog Unggulan',
                style: TextStyle(color: cokelatTua,
                    fontSize: 18, fontWeight: FontWeight.w900)),
            if (!_isLoading && _products.isNotEmpty)
              Text('${_products.length} barang tersedia',
                  style: TextStyle(color: cokelatTua.withOpacity(0.35),
                      fontSize: 11)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: cokelatTua.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              Icon(Icons.tune_rounded, color: emasMajelis, size: 14),
              const SizedBox(width: 5),
              Text('Filter',
                  style: TextStyle(color: cokelatTua, fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
        ],
      ),
    );
  }

  // ── Product Grid ───────────────────────────────────────────────────────────
  Widget _buildProductGrid() {
    if (_isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 14,
            mainAxisSpacing: 14, childAspectRatio: 0.72,
          ),
          delegate: SliverChildBuilderDelegate(
            (_, __) => _buildSkeletonCard(), childCount: 6,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: putih,
                borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cokelatTua.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.wifi_off_rounded, size: 32,
                    color: cokelatTua.withOpacity(0.25)),
              ),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center,
                  style: TextStyle(color: cokelatTua,
                      fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadBarang,
                icon: const Icon(Icons.refresh_rounded,
                    color: Colors.white, size: 18),
                label: const Text('Coba Lagi',
                    style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cokelatTua,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ]),
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return SliverToBoxAdapter(child: Center(child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Column(children: [
          Icon(Icons.search_off_rounded, size: 48,
              color: cokelatTua.withOpacity(0.15)),
          const SizedBox(height: 12),
          Text('Peralatan tidak ditemukan',
              style: TextStyle(color: cokelatTua.withOpacity(0.35),
                  fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      )));
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 14,
          mainAxisSpacing: 14, childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final product = _products[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 60)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            ),
            child: ProductCard(
              product: product,
              onTap: () => Navigator.push(context, PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 350),
                pageBuilder: (context, anim, _) =>
                    DetailScreen(product: product),
                transitionsBuilder: (context, anim, _, child) =>
                    FadeTransition(opacity: anim, child: child),
              )),
            ),
          );
        }, childCount: _products.length),
      ),
    );
  }

  // ── Skeleton ───────────────────────────────────────────────────────────────
  Widget _buildSkeletonCard() {
    return _ShimmerCard(cokelatTua: cokelatTua);
  }

  // ── Bottom Nav ─────────────────────────────────────────────────────────────
  Widget _buildBottomNavBar() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: putih,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [BoxShadow(
            color: cokelatTua.withOpacity(0.08),
            blurRadius: 20, offset: const Offset(0, -4),
          )],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.grid_view_rounded, 'Katalog', 0),
            _buildNavItem(Icons.receipt_long_rounded, 'Pesanan', 1),
            _buildNavItem(Icons.forum_outlined, 'Chat', 2),
            _buildNavItem(Icons.person_pin_rounded, 'Akun', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedIndex = index);
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? cokelatTua : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isActive ? [BoxShadow(
                color: cokelatTua.withOpacity(0.25),
                blurRadius: 8, offset: const Offset(0, 3),
              )] : [],
            ),
            child: Icon(icon,
                color: isActive ? Colors.white : cokelatTua.withOpacity(0.25),
                size: 22),
          ),
          const SizedBox(height: 5),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: TextStyle(
              color: isActive ? cokelatTua : cokelatTua.withOpacity(0.3),
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
            ),
            child: Text(label),
          ),
        ]),
      ),
    );
  }
}

// ── Shimmer Skeleton Card ──────────────────────────────────────────────────
class _ShimmerCard extends StatefulWidget {
  final Color cokelatTua;
  const _ShimmerCard({required this.cokelatTua});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1200))..repeat();
    _anim = Tween<double>(begin: -1.5, end: 1.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  begin: Alignment(-1 + _anim.value, 0),
                  end:   Alignment( 1 + _anim.value, 0),
                  colors: [
                    widget.cokelatTua.withOpacity(0.06),
                    widget.cokelatTua.withOpacity(0.12),
                    widget.cokelatTua.withOpacity(0.06),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => Container(
                height: 11, width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    begin: Alignment(-1 + _anim.value, 0),
                    end:   Alignment( 1 + _anim.value, 0),
                    colors: [
                      widget.cokelatTua.withOpacity(0.06),
                      widget.cokelatTua.withOpacity(0.12),
                      widget.cokelatTua.withOpacity(0.06),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => Container(
                height: 9, width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    begin: Alignment(-1 + _anim.value, 0),
                    end:   Alignment( 1 + _anim.value, 0),
                    colors: [
                      widget.cokelatTua.withOpacity(0.04),
                      widget.cokelatTua.withOpacity(0.09),
                      widget.cokelatTua.withOpacity(0.04),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}