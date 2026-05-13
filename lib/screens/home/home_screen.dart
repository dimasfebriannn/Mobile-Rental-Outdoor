// lib/screens/home/home_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:majelis_adventure/screens/chat/chat_screen.dart';
import 'package:majelis_adventure/screens/home/notification_screen.dart';
import 'package:majelis_adventure/screens/profile/profile_screen.dart';
import 'package:majelis_adventure/screens/recommendation/recommendation_screen.dart';
import '../../models/kategori.dart';
import '../../providers/cart_provider.dart';
import '../../utils/kategori_icon_mapper.dart';
import '../../widgets/product_card.dart';
import '../../models/product.dart';
import '../../services/barang_service.dart';
import '../history/history_screen.dart';
import 'detail_screen.dart';
import 'cart_screen.dart';

// ── Enum opsi urutan ───────────────────────────────────────────────────────
enum SortOption {
  default_,
  hargaTerendah,
  hargaTertinggi,
  namaAZ,
  namaZA,
  stokTerbanyak,
}

extension SortOptionLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.default_:       return 'Terbaru';
      case SortOption.hargaTerendah:  return 'Harga Terendah';
      case SortOption.hargaTertinggi: return 'Harga Tertinggi';
      case SortOption.namaAZ:         return 'Nama A–Z';
      case SortOption.namaZA:         return 'Nama Z–A';
      case SortOption.stokTerbanyak:  return 'Stok Terbanyak';
    }
  }

  IconData get icon {
    switch (this) {
      case SortOption.default_:       return Icons.access_time_rounded;
      case SortOption.hargaTerendah:  return Icons.arrow_downward_rounded;
      case SortOption.hargaTertinggi: return Icons.arrow_upward_rounded;
      case SortOption.namaAZ:         return Icons.sort_by_alpha_rounded;
      case SortOption.namaZA:         return Icons.sort_by_alpha_rounded;
      case SortOption.stokTerbanyak:  return Icons.inventory_2_rounded;
    }
  }
}

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
  static const Color putih       = Colors.white;

  // ── CartProvider — live badge ──────────────────────────────────────────────
  final _cart = CartProvider.instance;

  // ── State navigasi ─────────────────────────────────────────────────────────
  int _selectedIndex     = 0;
  int _currentPromoIndex = 0;

  late PageController _pageController;
  Timer? _timer;

  // ── State API ──────────────────────────────────────────────────────────────
  List<Product>  _products      = [];
  List<Kategori> _kategoris     = [];
  bool           _isLoading     = true;
  bool           _isLoadingCats = true;
  String?        _errorMessage;

  // Kategori aktif
  String _activeCategory = 'Semua';

  final TextEditingController _searchController = TextEditingController();
  bool      _searchFocused = false;
  final FocusNode _searchFocus = FocusNode();

  // ── State Filter ───────────────────────────────────────────────────────────
  SortOption _sortOption    = SortOption.default_;
  double     _minHarga      = 0;
  double     _maxHarga      = 500000;
  bool       _hanyaTersedia = false;

  double _minHargaData = 0;
  double _maxHargaData = 500000;

  List<Product> get _displayProducts {
    var list = List<Product>.from(_products);

    list = list.where((p) {
      final h = p.hargaPerHari.toDouble();
      return h >= _minHarga && h <= _maxHarga;
    }).toList();

    if (_hanyaTersedia) {
      list = list.where((p) => p.stok > 0).toList();
    }

    switch (_sortOption) {
      case SortOption.hargaTerendah:
        list.sort((a, b) => a.hargaPerHari.compareTo(b.hargaPerHari));
        break;
      case SortOption.hargaTertinggi:
        list.sort((a, b) => b.hargaPerHari.compareTo(a.hargaPerHari));
        break;
      case SortOption.namaAZ:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.namaZA:
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.stokTerbanyak:
        list.sort((a, b) => b.stok.compareTo(a.stok));
        break;
      case SortOption.default_:
        break;
    }

    return list;
  }

  bool get _hasActiveFilter =>
      _sortOption != SortOption.default_ ||
      _hanyaTersedia ||
      _minHarga > _minHargaData ||
      _maxHarga < _maxHargaData;

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
      'accent': const Color(0xFFE5A93D),
    },
    {
      'image': 'https://images.unsplash.com/photo-1537225228614-56cc3556d7ed?q=80&w=1000',
      'tag':   'BEST DEAL',
      'title': 'Paket Pendaki Hemat',
      'desc':  'Tenda + Carrier + Matras',
      'accent': const Color(0xFF81C784),
    },
    {
      'image': 'https://images.unsplash.com/photo-1478131143081-80f7f84ca84d?q=80&w=1000',
      'tag':   'WEEKEND PROMO',
      'title': 'Promo Akhir Pekan',
      'desc':  'Sewa 3 hari, bayar 2 hari',
      'accent': const Color(0xFF64B5F6),
    },
  ];

  @override
  void initState() {
    super.initState();

    // ── Daftarkan listener CartProvider ──────────────────────────────────────
    _cart.addListener(_onCartChanged);

    _pageController = PageController(initialPage: 500, viewportFraction: 1.0);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      }
    });

    _headerAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    )..forward();

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

  // ── Callback CartProvider — rebuild badge ──────────────────────────────────
  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  // ── API ────────────────────────────────────────────────────────────────────
  Future<void> _loadKategori() async {
    try {
      final cats = await BarangService.instance.fetchKategori();
      if (mounted) setState(() { _kategoris = cats; _isLoadingCats = false; });
    } catch (e) {
      debugPrint('❌ Gagal load kategori: $e');
      if (mounted) setState(() => _isLoadingCats = false);
    }
  }

  Future<void> _loadBarang() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final products = await BarangService.instance.fetchBarang(
        kategori: _activeCategory,
        search:   _searchController.text,
      );
      if (mounted) {
        if (products.isNotEmpty) {
          final prices = products.map((p) => p.hargaPerHari.toDouble());
          final minP   = prices.reduce((a, b) => a < b ? a : b);
          final maxP   = prices.reduce((a, b) => a > b ? a : b);
          if (_products.isEmpty ||
              _minHargaData != minP ||
              _maxHargaData != maxP) {
            _minHargaData = minP;
            _maxHargaData = maxP;
            _minHarga     = minP;
            _maxHarga     = maxP;
          }
        }
        setState(() { _products = products; _isLoading = false; });
      }
    } catch (e) {
      debugPrint('❌ Error fetchBarang: $e');
      if (mounted) setState(() {
        _errorMessage = 'Gagal memuat produk. Cek koneksi internet.';
        _isLoading    = false;
      });
    }
  }

  Timer? _debounce;
  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _loadBarang);
  }

  void _selectCategory(String nama) {
    if (_activeCategory == nama) return;
    HapticFeedback.selectionClick();
    setState(() => _activeCategory = nama);
    _loadBarang();
  }

  // ── FILTER SHEET ───────────────────────────────────────────────────────────
  void _showFilterSheet() {
    HapticFeedback.lightImpact();

    SortOption tempSort     = _sortOption;
    double     tempMin      = _minHarga;
    double     tempMax      = _maxHarga;
    bool       tempTersedia = _hanyaTersedia;

    showModalBottomSheet(
      context:            context,
      backgroundColor:    Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
            decoration: BoxDecoration(
              color: putih, borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(top: 14, bottom: 4),
                  decoration: BoxDecoration(
                    color: cokelatTua.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 16, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cokelatTua.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.tune_rounded,
                            color: cokelatTua, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Filter & Urutkan',
                                style: TextStyle(color: cokelatTua,
                                    fontSize: 16, fontWeight: FontWeight.w900)),
                            Text('Sesuaikan tampilan katalog',
                                style: TextStyle(
                                    color: cokelatTua.withOpacity(0.4),
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            tempSort     = SortOption.default_;
                            tempMin      = _minHargaData;
                            tempMax      = _maxHargaData;
                            tempTersedia = false;
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: emasMajelis,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                        ),
                        child: const Text('Reset',
                            style: TextStyle(fontWeight: FontWeight.w800,
                                fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildDivider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Urutkan'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: SortOption.values.map((opt) {
                          final active = tempSort == opt;
                          return GestureDetector(
                            onTap: () =>
                                setSheetState(() => tempSort = opt),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 9),
                              decoration: BoxDecoration(
                                color: active ? cokelatTua : latarKrem,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: active
                                      ? cokelatTua
                                      : cokelatTua.withOpacity(0.1),
                                ),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min,
                                  children: [
                                Icon(opt.icon, size: 13,
                                    color: active
                                        ? Colors.white
                                        : cokelatTua.withOpacity(0.5)),
                                const SizedBox(width: 6),
                                Text(opt.label, style: TextStyle(
                                  color: active
                                      ? Colors.white
                                      : cokelatTua.withOpacity(0.65),
                                  fontSize:   12,
                                  fontWeight: FontWeight.w700,
                                )),
                              ]),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                _buildDivider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionLabel('Rentang Harga / Hari'),
                          Text(
                            '${_formatRupiah(tempMin.toInt())} – ${_formatRupiah(tempMax.toInt())}',
                            style: TextStyle(color: emasMajelis, fontSize: 12,
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_maxHargaData > _minHargaData)
                        SliderTheme(
                          data: SliderTheme.of(ctx).copyWith(
                            activeTrackColor:   cokelatTua,
                            inactiveTrackColor: cokelatTua.withOpacity(0.1),
                            thumbColor:         cokelatTua,
                            overlayColor:       cokelatTua.withOpacity(0.12),
                            rangeThumbShape:
                                const RoundRangeSliderThumbShape(
                                    enabledThumbRadius: 8),
                            trackHeight: 4,
                          ),
                          child: RangeSlider(
                            min:    _minHargaData,
                            max:    _maxHargaData,
                            values: RangeValues(tempMin, tempMax),
                            divisions: _maxHargaData > _minHargaData
                                ? ((_maxHargaData - _minHargaData) / 5000)
                                    .round()
                                    .clamp(1, 100)
                                : null,
                            onChanged: (v) => setSheetState(() {
                              tempMin = v.start;
                              tempMax = v.end;
                            }),
                          ),
                        )
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Harga: ${_formatRupiah(_minHargaData.toInt())}',
                              style: TextStyle(
                                  color: cokelatTua.withOpacity(0.5),
                                  fontSize: 13),
                            ),
                          ),
                        ),
                      if (_maxHargaData > _minHargaData)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatRupiah(_minHargaData.toInt()),
                                  style: TextStyle(
                                      color:    cokelatTua.withOpacity(0.35),
                                      fontSize: 10)),
                              Text(_formatRupiah(_maxHargaData.toInt()),
                                  style: TextStyle(
                                      color:    cokelatTua.withOpacity(0.35),
                                      fontSize: 10)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                _buildDivider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel('Ketersediaan'),
                            const SizedBox(height: 2),
                            Text('Tampilkan hanya barang yang tersedia',
                                style: TextStyle(
                                    color:    cokelatTua.withOpacity(0.4),
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setSheetState(
                            () => tempTersedia = !tempTersedia),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48, height: 26,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: tempTersedia
                                ? cokelatTua
                                : cokelatTua.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 200),
                            alignment: tempTersedia
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 20, height: 20,
                              decoration: const BoxDecoration(
                                color: putih, shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: cokelatTua.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text('Batal', style: TextStyle(
                                color:      cokelatTua.withOpacity(0.6),
                                fontSize:   14,
                                fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _sortOption    = tempSort;
                            _minHarga      = tempMin;
                            _maxHarga      = tempMax;
                            _hanyaTersedia = tempTersedia;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: cokelatTua,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(
                              color:      cokelatTua.withOpacity(0.3),
                              blurRadius: 12, offset: const Offset(0, 5),
                            )],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 8),
                                const Text('Terapkan Filter',
                                    style: TextStyle(color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatRupiah(int value) {
    if (value >= 1000000) {
      final juta = value / 1000000;
      return 'Rp ${juta % 1 == 0 ? juta.toInt() : juta.toStringAsFixed(1)} jt';
    } else if (value >= 1000) {
      final ribu = value / 1000;
      return 'Rp ${ribu % 1 == 0 ? ribu.toInt() : ribu.toStringAsFixed(1)} rb';
    }
    return 'Rp $value';
  }

  Widget _buildDivider() => Divider(
    height: 1, color: cokelatTua.withOpacity(0.06),
    indent: 20, endIndent: 20,
  );

  Widget _buildSectionLabel(String text) => Text(text,
      style: TextStyle(color: cokelatTua, fontSize: 13,
          fontWeight: FontWeight.w900));

  // ── Image Scan ─────────────────────────────────────────────────────────────
  void _showImageSourceSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context:            context,
      backgroundColor:    Colors.transparent,
      isScrollControlled: true,
      builder:            (_) => _buildImageSourceSheet(),
    );
  }

  Widget _buildImageSourceSheet() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
          color: putih, borderRadius: BorderRadius.circular(28)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 40, height: 4,
          margin: const EdgeInsets.only(top: 14, bottom: 24),
          decoration: BoxDecoration(
            color: cokelatTua.withOpacity(0.12),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: RadialGradient(colors: [
              emasMajelis.withOpacity(0.18), emasMajelis.withOpacity(0.0),
            ]),
            shape: BoxShape.circle,
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cokelatTua, shape: BoxShape.circle,
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
        Text('Cari dengan Gambar', style: TextStyle(color: cokelatTua,
            fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'AI kami mengenali peralatan outdoor dari foto dan langsung '
            'merekomendasikan yang tersedia',
            textAlign: TextAlign.center,
            style: TextStyle(color: cokelatTua.withOpacity(0.5),
                fontSize: 13, height: 1.5),
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
          child: Text('Batal', style: TextStyle(
              color: cokelatTua.withOpacity(0.35),
              fontSize: 14, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 12),
      ]),
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
          color: cokelatTua, borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(
            color: cokelatTua.withOpacity(0.25),
            blurRadius: 12, offset: const Offset(0, 5),
          )],
        ),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12), shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: Colors.white,
              fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(sublabel, style: TextStyle(
              color: Colors.white.withOpacity(0.5), fontSize: 11)),
        ]),
      ),
    );
  }

  Future<void> _pickAndNavigate(ImageSource source) async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);
    try {
      final picked = await _imagePicker.pickImage(
        source: source, imageQuality: 80,
        maxWidth: 1024, maxHeight: 1024,
      );
      if (picked == null || !mounted) return;
      final file = File(picked.path);
      if (!mounted) return;
      await Navigator.push(context, PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, anim, _) =>
            RecommendationScreen(imageFile: file),
        transitionsBuilder: (context, anim, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1), end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: FadeTransition(opacity: anim, child: child),
        ),
      ));
    } catch (e) {
      debugPrint('❌ Gagal pick image: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka kamera/galeri.'),
            behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  @override
  void dispose() {
    // ── Lepas listener CartProvider ───────────────────────────────────────────
    _cart.removeListener(_onCartChanged);

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

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    // Badge keranjang langsung dari CartProvider — otomatis update
    final cartCount = _cart.totalItems;

    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, __) => Opacity(
        opacity: _headerAnim.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - _headerAnim.value)),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
            decoration: BoxDecoration(
              color: putih,
              border: Border(bottom: BorderSide(
                  color: cokelatTua.withOpacity(0.05), width: 1)),
              boxShadow: [BoxShadow(
                color: cokelatTua.withOpacity(0.02),
                blurRadius: 10, offset: const Offset(0, 4),
              )],
            ),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('MAJELIS RENTAL', style: TextStyle(
                        color: emasMajelis, fontSize: 9,
                        fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(height: 2),
                    Text('Halo, Dimas 👋', style: TextStyle(
                        color: cokelatTua, fontSize: 22,
                        fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  ],
                ),
              ),
              Row(children: [
                // ── Icon keranjang — badge live dari CartProvider ────────────
                _buildHeaderAction(
                  icon:  Icons.shopping_bag_outlined,
                  badge: cartCount,               // ← tidak lagi hardcoded
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CartScreen())),
                ),
                const SizedBox(width: 10),
                // Notifikasi tetap statis (belum ada API notif)
                _buildHeaderAction(
                  icon:  Icons.notifications_none_rounded,
                  badge: 0,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationScreen())),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen())),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: emasMajelis.withOpacity(0.3), width: 1.5),
                    ),
                    child: CircleAvatar(
                      radius: 18, backgroundColor: latarKrem,
                      backgroundImage:
                          const AssetImage('lib/assets/img/majelis.png'),
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

  Widget _buildHeaderAction({
    required IconData icon, int badge = 0, required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: latarKrem.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: cokelatTua, size: 20),
        ),
        if (badge > 0)
          Positioned(
            top: -4, right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: emasMajelis, shape: BoxShape.circle,
                border: Border.all(color: putih, width: 1.5),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                badge > 99 ? '99+' : badge.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: putih, fontSize: 8, fontWeight: FontWeight.w900),
              ),
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
              boxShadow: _searchFocused
                  ? [BoxShadow(
                      color: cokelatTua.withOpacity(0.06), blurRadius: 10)]
                  : [],
            ),
            child: TextField(
              controller: _searchController,
              focusNode:  _searchFocus,
              style: TextStyle(color: cokelatTua, fontSize: 14,
                  fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText:  'Cari perlengkapan gunung...',
                hintStyle: TextStyle(
                    color: cokelatTua.withOpacity(0.3), fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded,
                    color: cokelatTua.withOpacity(0.4), size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _loadBarang();
                        },
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
        GestureDetector(
          onTap: _isPickingImage ? null : _showImageSourceSheet,
          child: ScaleTransition(
            scale: _scanPulse,
            child: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
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

  // ── Promo Banner ───────────────────────────────────────────────────────────
  Widget _buildPromoBanner() {
    return Column(children: [
      Container(
        height: 190,
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(children: [
            PageView.builder(
              controller:    _pageController,
              onPageChanged: (index) =>
                  setState(() => _currentPromoIndex = index % promos.length),
              itemCount: 10000,
              itemBuilder: (context, index) {
                final promo  = promos[index % promos.length];
                final accent = promo['accent'] as Color;
                return Stack(fit: StackFit.expand, children: [
                  Image.network(promo['image']!, fit: BoxFit.cover),
                  Container(decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight, end: Alignment.bottomLeft,
                      colors: [
                        Colors.transparent, cokelatTua.withOpacity(0.75)],
                    ),
                  )),
                  Positioned(
                    bottom: 20, left: 20, right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: accent.withOpacity(0.5)),
                          ),
                          child: Text(promo['tag']!, style: TextStyle(
                              color: accent, fontSize: 9,
                              fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                        ),
                        const SizedBox(height: 8),
                        Text(promo['title']!,
                            style: const TextStyle(color: Colors.white,
                                fontSize: 20, fontWeight: FontWeight.w900,
                                letterSpacing: -0.3)),
                        const SizedBox(height: 4),
                        Text(promo['desc']!, style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ]);
              },
            ),
            Positioned(
              bottom: 14, right: 16,
              child: Row(
                children: List.generate(promos.length, (i) {
                  final active = _currentPromoIndex == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(left: 5),
                    height: 5, width: active ? 20 : 5,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withOpacity(0.35),
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

  // ── Quick Access ───────────────────────────────────────────────────────────
  Widget _buildQuickAccess() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Kategori', style: TextStyle(color: cokelatTua,
              fontSize: 15, fontWeight: FontWeight.w900)),
          GestureDetector(
            onTap: () => _selectCategory('Semua'),
            child: Text('Lihat Semua', style: TextStyle(color: emasMajelis,
                fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 14),
        if (_isLoadingCats)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: cokelatTua.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 8, width: 32,
                    decoration: BoxDecoration(
                      color: cokelatTua.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ]),
              ),
            )),
          )
        else
          _buildQuickAccessRow(),
      ]),
    );
  }

  Widget _buildQuickAccessRow() {
    final displayList = _kategoris.take(5).toList();
    final int total   = displayList.length + 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(total, (index) {
        if (index == total - 1) {
          return _buildQuickAccessItem(
            icon: Icons.grid_view_rounded, label: 'Semua',
            color: const Color(0xFFBCAAA4),
            isActive: _activeCategory == 'Semua',
            onTap: () => _selectCategory('Semua'),
          );
        }
        final kat      = displayList[index];
        final icon     = KategoriIconMapper.getIcon(
            dbIcon: kat.ikon, nama: kat.nama);
        final color    = KategoriIconMapper.getColor(index);
        final isActive = _activeCategory == kat.nama;
        return _buildQuickAccessItem(
          icon: icon, label: kat.nama, color: color,
          isActive: isActive, onTap: () => _selectCategory(kat.nama),
        );
      }),
    );
  }

  Widget _buildQuickAccessItem({
    required IconData icon, required String label,
    required Color color, required bool isActive,
    required VoidCallback onTap,
  }) {
    final displayLabel =
        label.length > 7 ? '${label.substring(0, 6)}…' : label;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: GestureDetector(
          onTap: onTap,
          child: Column(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: isActive ? cokelatTua : putih,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isActive
                        ? cokelatTua
                        : cokelatTua.withOpacity(0.08)),
                boxShadow: isActive
                    ? [BoxShadow(
                        color: cokelatTua.withOpacity(0.3),
                        blurRadius: 10, offset: const Offset(0, 4),
                      )]
                    : [],
              ),
              child: Icon(icon,
                  color: isActive ? Colors.white : color.withOpacity(0.7),
                  size: 20),
            ),
            const SizedBox(height: 6),
            Text(displayLabel, textAlign: TextAlign.center,
                style: TextStyle(
                  color: isActive
                      ? cokelatTua
                      : cokelatTua.withOpacity(0.5),
                  fontSize:   10,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                )),
          ]),
        ),
      ),
    );
  }

  // ── Category Filters (pill) ────────────────────────────────────────────────
  Widget _buildCategoryFilters() {
    if (_isLoadingCats) return const SizedBox(height: 20);
    final pillList = ['Semua', ..._kategoris.map((k) => k.nama)];
    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 18),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding:         const EdgeInsets.only(left: 20),
        itemCount:       pillList.length,
        itemBuilder: (context, index) {
          final nama     = pillList[index];
          final isActive = _activeCategory == nama;
          return GestureDetector(
            onTap: () => _selectCategory(nama),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin:  const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isActive ? cokelatTua : putih,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isActive
                        ? cokelatTua
                        : cokelatTua.withOpacity(0.08)),
                boxShadow: isActive
                    ? [BoxShadow(
                        color: cokelatTua.withOpacity(0.2),
                        blurRadius: 8, offset: const Offset(0, 3),
                      )]
                    : [],
              ),
              child: Center(child: Text(nama, style: TextStyle(
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
    final label = _activeCategory == 'Semua'
        ? 'Katalog Unggulan'
        : _activeCategory;
    final displayed = _displayProducts;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(color: cokelatTua,
                fontSize: 18, fontWeight: FontWeight.w900)),
            if (!_isLoading)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  key: ValueKey(displayed.length),
                  displayed.isEmpty
                      ? 'Tidak ada barang'
                      : '${displayed.length} barang tersedia',
                  style: TextStyle(
                      color: cokelatTua.withOpacity(0.35), fontSize: 11),
                ),
              ),
          ]),
          GestureDetector(
            onTap: _showFilterSheet,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: _hasActiveFilter
                    ? cokelatTua
                    : cokelatTua.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                boxShadow: _hasActiveFilter
                    ? [BoxShadow(
                        color: cokelatTua.withOpacity(0.25),
                        blurRadius: 8, offset: const Offset(0, 3),
                      )]
                    : [],
              ),
              child: Row(children: [
                Icon(Icons.tune_rounded, color: emasMajelis, size: 14),
                const SizedBox(width: 6),
                Text('Filter', style: TextStyle(
                    color: _hasActiveFilter ? Colors.white : cokelatTua,
                    fontSize: 12, fontWeight: FontWeight.w700)),
                if (_hasActiveFilter) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                      color: emasMajelis, shape: BoxShape.circle,
                    ),
                  ),
                ],
              ]),
            ),
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
                label: const Text('Coba Lagi', style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800)),
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

    final displayed = _displayProducts;

    if (displayed.isEmpty) {
      return SliverToBoxAdapter(child: Center(child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Column(children: [
          Icon(Icons.search_off_rounded, size: 48,
              color: cokelatTua.withOpacity(0.15)),
          const SizedBox(height: 12),
          Text(
            _hasActiveFilter
                ? 'Tidak ada barang yang sesuai filter'
                : 'Peralatan tidak ditemukan',
            style: TextStyle(color: cokelatTua.withOpacity(0.35),
                fontSize: 14, fontWeight: FontWeight.w600),
          ),
          if (_hasActiveFilter) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setState(() {
                _sortOption    = SortOption.default_;
                _minHarga      = _minHargaData;
                _maxHarga      = _maxHargaData;
                _hanyaTersedia = false;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  color: cokelatTua,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Hapus Filter', style: TextStyle(
                    color: Colors.white, fontSize: 12,
                    fontWeight: FontWeight.w800)),
              ),
            ),
          ],
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
          final product = displayed[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 60)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child:  Opacity(opacity: value, child: child),
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
        }, childCount: displayed.length),
      ),
    );
  }

  Widget _buildSkeletonCard() => _ShimmerCard(cokelatTua: cokelatTua);

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
            _buildNavItem(Icons.grid_view_rounded,    'Katalog', 0),
            _buildNavItem(Icons.receipt_long_rounded, 'Pesanan', 1),
            _buildNavItem(Icons.forum_outlined,       'Chat',    2),
            _buildNavItem(Icons.person_pin_rounded,   'Akun',    3),
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
              boxShadow: isActive
                  ? [BoxShadow(
                      color: cokelatTua.withOpacity(0.25),
                      blurRadius: 8, offset: const Offset(0, 3),
                    )]
                  : [],
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
              fontSize:   10,
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
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _anim = Tween<double>(begin: -1.5, end: 1.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  begin: Alignment(-1 + _anim.value, 0),
                  end:   Alignment(1 + _anim.value, 0),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => Container(
                  height: 11, width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      begin: Alignment(-1 + _anim.value, 0),
                      end:   Alignment(1 + _anim.value, 0),
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
                      end:   Alignment(1 + _anim.value, 0),
                      colors: [
                        widget.cokelatTua.withOpacity(0.04),
                        widget.cokelatTua.withOpacity(0.09),
                        widget.cokelatTua.withOpacity(0.04),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}