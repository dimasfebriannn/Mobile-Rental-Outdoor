// lib/screens/home/detail_screen.dart
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../services/barang_service.dart';
import 'cart_screen.dart';
import '../chat/chat_screen.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatefulWidget {
  final Product product;
  const DetailScreen({super.key, required this.product});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final Color darkBrown    = const Color(0xFF3E2723);
  final Color goldenYellow = const Color(0xFFE5A93D);
  final Color creamBg      = const Color(0xFFF5EFE6);

  static const Map<String, String> _imageHeaders = {
    'ngrok-skip-browser-warning': 'true',
    'User-Agent': 'MajelisApp/1.0',
  };

  bool _isAdding      = false;
  bool _isLoadingFull = false;

  late Product        _product;
  late PageController _fotoController;
  int  _currentFotoIndex = 0;

  // Ambil CartProvider singleton
  final _cart = CartProvider.instance;

  @override
  void initState() {
    super.initState();
    _product        = widget.product;
    _fotoController = PageController();
    if (_product.foto.isEmpty) {
      _fetchDetail();
    }
    // Dengarkan perubahan cart untuk rebuild badge
    _cart.addListener(_onCartChanged);
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cart.removeListener(_onCartChanged);
    _fotoController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    setState(() => _isLoadingFull = true);
    try {
      final full = await BarangService.instance.fetchBarangDetail(_product.id);
      if (mounted) setState(() { _product = full; _isLoadingFull = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoadingFull = false);
    }
  }

  String _formatCurrency(double amount) => NumberFormat.currency(
    locale: 'id', symbol: 'Rp ', decimalDigits: 0,
  ).format(amount);

  void _handleAddToCart() {
    setState(() => _isAdding = true);

    // Tambahkan ke CartProvider
    _cart.addProduct(_product);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isAdding = false);
      _showSuccessSheet();
    });
  }

  void _openChatForProduct() {
    final message =
        'Saya ingin bertanya tentang ${_product.name}. Apakah masih tersedia '
        'dan berapa biaya sewanya?';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(initialMessage: message),
      ),
    );
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.shopping_cart_checkout_rounded,
                color: Colors.green, size: 40),
          ),
          const SizedBox(height: 24),
          Text('Masuk Keranjang',
              style: TextStyle(
                  color: darkBrown, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text(
            '${_product.name} telah berhasil ditambahkan. '
            'Atur jumlah sewa di menu keranjang.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: darkBrown.withOpacity(0.5),
                fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 32),
          Row(children: [
            Expanded(
              child: SizedBox(
                height: 58,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: darkBrown.withOpacity(0.2)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text('LANJUTKAN',
                      style: TextStyle(
                          color: darkBrown, fontWeight: FontWeight.w900,
                          letterSpacing: 1)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _openCart();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBrown,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text('KE KERANJANG',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900,
                          letterSpacing: 1)),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final fotoList = _product.foto.isNotEmpty
        ? _product.foto
        : (_product.fotoUtama != null ? [_product.fotoUtama!] : <String>[]);

    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(children: [
        // 1. Hero foto gallery
        Positioned(
          top: 0, left: 0, right: 0,
          height: MediaQuery.of(context).size.height * 0.5,
          child: fotoList.isEmpty
              ? _buildPlaceholderImage()
              : _buildFotoGallery(fotoList),
        ),

        // 2. Scrollable content
        Positioned.fill(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.42),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(45)),
                  boxShadow: [BoxShadow(
                      color: darkBrown.withOpacity(0.1),
                      blurRadius: 30, offset: const Offset(0, -10))],
                ),
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildQuickInfo(),
                    const SizedBox(height: 32),
                    if (_product.tags.isNotEmpty) ...[
                      _buildTags(),
                      const SizedBox(height: 32),
                    ],
                    if (_isLoadingFull)
                      _buildLoadingSpec()
                    else ...[
                      if (_product.specification != null) ...[
                        Text('Spesifikasi Produk',
                            style: TextStyle(
                                color: darkBrown, fontWeight: FontWeight.w900,
                                fontSize: 16)),
                        const SizedBox(height: 12),
                        _buildSpecList(),
                        const SizedBox(height: 32),
                      ],
                      Text('Deskripsi',
                          style: TextStyle(
                              color: darkBrown, fontWeight: FontWeight.w900,
                              fontSize: 16)),
                      const SizedBox(height: 10),
                      Text(
                        _product.description ??
                            'Peralatan ekspedisi dari Majelis Adventure '
                            'selalu dalam kondisi steril dan siap tempur.',
                        style: TextStyle(
                            color: darkBrown.withOpacity(0.6),
                            height: 1.6, fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ],

                    const SizedBox(height: 32),
                    _buildAskChatBanner(),
                  ],
                ),
              ),
            ]),
          ),
        ),

        // 3. Tombol kembali (kiri atas)
        _buildBackButton(),

        // 4. Tombol cart dengan badge (kanan atas)
        _buildCartButton(),

        // 5. Dots indikator foto
        if (fotoList.length > 1) _buildFotoDots(fotoList.length),

        // 6. Bottom bar
        _buildFloatingBottomBar(),
      ]),
    );
  }

  // ── Foto Gallery ───────────────────────────────────────────────────────────
  Widget _buildFotoGallery(List<String> fotoList) {
    return PageView.builder(
      controller:    _fotoController,
      onPageChanged: (i) => setState(() => _currentFotoIndex = i),
      itemCount:     fotoList.length,
      itemBuilder:   (_, i) => Image.network(
        fotoList[i],
        headers:  _imageHeaders,
        fit:      BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            color: creamBg,
            child: Center(child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                    progress.expectedTotalBytes!
                  : null,
              color: goldenYellow, strokeWidth: 2,
            )),
          );
        },
        errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() => Container(
    color: creamBg,
    child: Center(child: Icon(
      Icons.image_not_supported_outlined,
      size: 64, color: darkBrown.withOpacity(0.2),
    )),
  );

  Widget _buildFotoDots(int count) => Positioned(
    top: MediaQuery.of(context).size.height * 0.44,
    left: 0, right: 0,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        height: 6,
        width: _currentFotoIndex == i ? 18 : 6,
        decoration: BoxDecoration(
          color: _currentFotoIndex == i
              ? darkBrown
              : darkBrown.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
      )),
    ),
  );

  // ── Tombol Kembali ─────────────────────────────────────────────────────────
  Widget _buildBackButton() => Positioned(
    top: 50, left: 24,
    child: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white, shape: BoxShape.circle,
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded,
            color: darkBrown, size: 18),
      ),
    ),
  );

  // ── Tombol Cart dengan badge (kanan atas) ──────────────────────────────────
  Widget _buildCartButton() => Positioned(
    top: 50, right: 24,
    child: GestureDetector(
      onTap: _openCart,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: darkBrown,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: darkBrown.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                color: Colors.white, size: 18),
          ),
          // Badge jumlah item
          if (_cart.totalItems > 0)
            Positioned(
              top: -4, right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: goldenYellow,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  '${_cart.totalItems}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    ),
  );

  // ── Banner "Tanya via Chat" ────────────────────────────────────────────────
  Widget _buildAskChatBanner() {
    return GestureDetector(
      onTap: _openChatForProduct,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: goldenYellow.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: goldenYellow.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: goldenYellow.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chat_bubble_outline_rounded,
                  color: goldenYellow, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ada pertanyaan tentang produk ini?',
                    style: TextStyle(
                      color: darkBrown,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tanya langsung ke Asisten Majelis ✨',
                    style: TextStyle(
                      color: darkBrown.withOpacity(0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: goldenYellow, size: 22),
          ],
        ),
      ),
    );
  }

  // ── Bottom Bar ─────────────────────────────────────────────────────────────
  Widget _buildFloatingBottomBar() => Positioned(
    bottom: 0, left: 0, right: 0,
    child: Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(children: [
        Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('HARGA SEWA',
              style: TextStyle(
                  color: darkBrown.withOpacity(0.4), fontSize: 10,
                  fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          Text('${_formatCurrency(_product.hargaPerHari)}/hari',
              style: TextStyle(
                  color: darkBrown, fontWeight: FontWeight.w900, fontSize: 18)),
        ]),
        const SizedBox(width: 16),

        // Tombol chat kecil di bottom bar
        GestureDetector(
          onTap: _openChatForProduct,
          child: Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: goldenYellow.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: goldenYellow.withOpacity(0.4)),
            ),
            child: Icon(Icons.chat_bubble_outline_rounded,
                color: goldenYellow, size: 22),
          ),
        ),
        const SizedBox(width: 10),

        Expanded(child: SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isAdding ? null : _handleAddToCart,
            icon: _isAdding
                ? const SizedBox.shrink()
                : const Icon(Icons.add_shopping_cart_rounded,
                    color: Colors.white, size: 18),
            label: _isAdding
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('KERANJANG',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w900,
                        fontSize: 12, letterSpacing: 0.5)),
            style: ElevatedButton.styleFrom(
              backgroundColor: darkBrown,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        )),
      ]),
    ),
  );

  // ── Sub-widgets ────────────────────────────────────────────────────────────
  Widget _buildHeader() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(_product.category.toUpperCase(),
          style: TextStyle(
              color: goldenYellow, fontWeight: FontWeight.w900,
              fontSize: 11, letterSpacing: 2)),
      const SizedBox(height: 8),
      Text(_product.name,
          style: TextStyle(
              color: darkBrown, fontSize: 28,
              fontWeight: FontWeight.w900, letterSpacing: -1)),
    ],
  );

  Widget _buildQuickInfo() => Row(children: [
    _infoCard(Icons.payments_outlined, 'TARIF HARIAN',
        _formatCurrency(_product.hargaPerHari)),
    const SizedBox(width: 12),
    _infoCard(Icons.inventory_2_outlined, 'STOK UNIT', '${_product.stok}'),
  ]);

  Widget _infoCard(IconData icon, String label, String value) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: creamBg.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkBrown.withOpacity(0.05)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 13, color: goldenYellow),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(
              color: darkBrown.withOpacity(0.4),
              fontSize: 9, fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(
            color: darkBrown, fontSize: 14, fontWeight: FontWeight.w900)),
      ]),
    ),
  );

  Widget _buildTags() => Wrap(
    spacing: 8, runSpacing: 8,
    children: _product.tags.map((tag) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: goldenYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldenYellow.withOpacity(0.3)),
      ),
      child: Text('#$tag',
          style: TextStyle(
              color: goldenYellow, fontSize: 11, fontWeight: FontWeight.w700)),
    )).toList(),
  );

  Widget _buildSpecList() {
    final specs = (_product.specification ?? '')
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s.trim().replaceFirst(RegExp(r'^-\s*'), ''))
        .toList();
    if (specs.isEmpty) return const SizedBox();
    return Column(children: specs.map((s) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(Icons.verified_outlined, color: goldenYellow, size: 16),
        const SizedBox(width: 12),
        Expanded(child: Text(s, style: TextStyle(
            color: darkBrown.withOpacity(0.7),
            fontSize: 13, fontWeight: FontWeight.w700))),
      ]),
    )).toList());
  }

  Widget _buildLoadingSpec() => Column(
    children: List.generate(4, (_) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
          height: 14, width: double.infinity,
          decoration: BoxDecoration(
              color: darkBrown.withOpacity(0.06),
              borderRadius: BorderRadius.circular(4))),
    )),
  );
}