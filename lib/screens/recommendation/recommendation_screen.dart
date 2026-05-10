// lib/screens/recommendation/recommendation_screen.dart

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/recommendation.dart';
import '../../models/product.dart';
import '../../services/barang_service.dart';
import '../../services/recommendation_service.dart';
import '../home/detail_screen.dart';

class RecommendationScreen extends StatefulWidget {
  final File imageFile;
  const RecommendationScreen({super.key, required this.imageFile});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen>
    with TickerProviderStateMixin {
  // ── Warna konsisten ────────────────────────────────────────────────────────
  static const Color latarKrem   = Color(0xFFF5EFE6);
  static const Color cokelatTua  = Color(0xFF3E2723);
  static const Color emasMajelis = Color(0xFFE5A93D);

  // ── State utama (TIDAK DIUBAH) ─────────────────────────────────────────────
  RecommendationResult? _result;
  bool    _isLoading    = true;
  String? _errorMsg;
  int?    _loadingCardId;

  static const Map<String, String> _imageHeaders = {
    'ngrok-skip-browser-warning': 'true',
    'User-Agent': 'MajelisApp/1.0',
  };

  // ── Animasi Controllers ────────────────────────────────────────────────────
  late AnimationController _pulseController;
  late Animation<double>   _pulseAnimation;

  late AnimationController _orbitController;
  late AnimationController _shimmerController;
  late Animation<double>   _shimmerAnimation;

  late AnimationController _fadeInController;
  late Animation<double>   _fadeInAnimation;
  late Animation<Offset>   _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse utama (bola AI)
    _pulseController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Orbit partikel mengelilingi ikon AI
    _orbitController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2400),
    )..repeat();

    // Shimmer teks loading
    _shimmerController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600),
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Fade + slide saat hasil muncul
    _fadeInController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    );
    _fadeInAnimation = CurvedAnimation(
        parent: _fadeInController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08), end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _fadeInController, curve: Curves.easeOut));

    _analyze();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _orbitController.dispose();
    _shimmerController.dispose();
    _fadeInController.dispose();
    super.dispose();
  }

  // ── Logic TIDAK DIUBAH ─────────────────────────────────────────────────────
  Future<void> _analyze() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    _fadeInController.reset();
    try {
      final result = await RecommendationService.instance
          .analyzeImage(widget.imageFile);

      for (final b in result.recommendations) {
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('NAMA     : ${b.nama}');
        debugPrint('FOTO_URL : ${b.fotoUrl ?? "NULL"}');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }

      if (mounted) {
        setState(() { _result = result; _isLoading = false; });
        _fadeInController.forward();
      }
    } on RecommendationException catch (e) {
      if (mounted) setState(() { _errorMsg = e.message; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() {
        _errorMsg  = 'Terjadi kesalahan. Silakan coba lagi.';
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToDetail(RecommendedBarang barang) async {
    if (_loadingCardId != null) return;
    setState(() => _loadingCardId = barang.id);
    try {
      final Product product =
          await BarangService.instance.fetchBarangDetail(barang.id);
      if (!mounted) return;
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => DetailScreen(product: product)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:         const Text('Gagal membuka detail. Coba lagi.'),
        backgroundColor: cokelatTua,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } finally {
      if (mounted) setState(() => _loadingCardId = null);
    }
  }

  // ── Build utama ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: latarKrem,
      body: Column(
        children: [
          // Header baru — konsisten dengan home & history
          _buildHeader(),
          // Konten utama
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildImagePreview()),
                if (_isLoading)
                  SliverToBoxAdapter(child: _buildLoadingState())
                else if (_errorMsg != null)
                  SliverToBoxAdapter(child: _buildErrorState())
                else ...[
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeInAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildAiResultBanner(),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeInAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildSectionTitle(),
                      ),
                    ),
                  ),
                  _buildProductGrid(),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header baru: konsisten dengan HomeScreen & HistoryScreen ──────────────
  Widget _buildHeader() {
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
          // Tombol kembali + judul (gaya history_screen)
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: latarKrem,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: cokelatTua.withOpacity(0.07), width: 1),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: cokelatTua, size: 16),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI IMAGE SCAN',
                    style: TextStyle(
                      color:       emasMajelis,
                      fontSize:    9,
                      fontWeight:  FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rekomendasi AI',
                    style: TextStyle(
                      color:      cokelatTua,
                      fontSize:   22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Ikon kanan dekoratif
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: latarKrem.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.auto_awesome_rounded,
                color: cokelatTua, size: 20),
          ),
        ],
      ),
    );
  }

  // ── Foto preview ───────────────────────────────────────────────────────────
  Widget _buildImagePreview() => Container(
    height: 200,
    width:  double.infinity,
    margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(
          color:      cokelatTua.withOpacity(0.15),
          blurRadius: 20,
          offset:     const Offset(0, 8))],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(widget.imageFile, fit: BoxFit.cover),
          // Overlay gradient bawah
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end:   Alignment.topCenter,
                  colors: [
                    cokelatTua.withOpacity(0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12, left: 14,
            child: Row(children: [
              const Icon(Icons.image_search_rounded,
                  color: Colors.white, size: 14),
              const SizedBox(width: 6),
              Text('Gambar yang dianalisis',
                  style: TextStyle(
                    color:      Colors.white.withOpacity(0.9),
                    fontSize:   11,
                    fontWeight: FontWeight.w700,
                  )),
            ]),
          ),
        ],
      ),
    ),
  );

  // ── Loading State: animasi orbit partikel ─────────────────────────────────
  Widget _buildLoadingState() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
    child: Column(children: [
      SizedBox(
        width: 120, height: 120,
        child: Stack(alignment: Alignment.center, children: [
          // Ring orbit
          AnimatedBuilder(
            animation: _orbitController,
            builder: (_, __) => CustomPaint(
              size: const Size(120, 120),
              painter: _OrbitPainter(
                progress:   _orbitController.value,
                color:      cokelatTua,
                dotCount:   4,
                radius:     52,
                dotRadius:  4,
              ),
            ),
          ),
          // Ring orbit kedua (lebih kecil, arah berlawanan)
          AnimatedBuilder(
            animation: _orbitController,
            builder: (_, __) => CustomPaint(
              size: const Size(120, 120),
              painter: _OrbitPainter(
                progress:   1 - _orbitController.value,
                color:      emasMajelis,
                dotCount:   3,
                radius:     36,
                dotRadius:  3,
              ),
            ),
          ),
          // Ikon tengah dengan pulse
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 58, height: 58,
              decoration: BoxDecoration(
                color:    cokelatTua,
                shape:    BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:        cokelatTua.withOpacity(0.35),
                    blurRadius:   20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 26, color: Colors.white),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 28),
      // Teks shimmer
      AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (_, __) => ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.centerLeft,
            end:   Alignment.centerRight,
            colors: [
              cokelatTua.withOpacity(0.3),
              cokelatTua,
              cokelatTua.withOpacity(0.3),
            ],
            stops: [
              (_shimmerAnimation.value - 0.5).clamp(0.0, 1.0),
              _shimmerAnimation.value.clamp(0.0, 1.0),
              (_shimmerAnimation.value + 0.5).clamp(0.0, 1.0),
            ],
          ).createShader(bounds),
          child: const Text('AI sedang menganalisis gambar...',
              style: TextStyle(color: Colors.white,
                  fontSize: 16, fontWeight: FontWeight.w800)),
        ),
      ),
      const SizedBox(height: 8),
      Text('Mencocokkan dengan perlengkapan tersedia',
          style: TextStyle(
              color: cokelatTua.withOpacity(0.4), fontSize: 13)),
      const SizedBox(height: 24),
      // Dot step indicator animasi
      _buildLoadingSteps(),
    ]),
  );

  Widget _buildLoadingSteps() {
    final steps = [
      'Membaca gambar...',
      'Mendeteksi peralatan...',
      'Mencocokkan katalog...',
    ];
    return Column(
      children: List.generate(steps.length, (i) {
        return AnimatedBuilder(
          animation: _orbitController,
          builder: (_, __) {
            final phase = (_orbitController.value * steps.length - i)
                .clamp(0.0, 1.0);
            final active = phase > 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width:  active ? 8 : 6,
                  height: active ? 8 : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active
                        ? emasMajelis
                        : cokelatTua.withOpacity(0.15),
                  ),
                ),
                const SizedBox(width: 8),
                Text(steps[i],
                    style: TextStyle(
                        color: active
                            ? cokelatTua
                            : cokelatTua.withOpacity(0.3),
                        fontSize:   12,
                        fontWeight: active
                            ? FontWeight.w700
                            : FontWeight.w500)),
              ]),
            );
          },
        );
      }),
    );
  }

  // ── Error State ────────────────────────────────────────────────────────────
  Widget _buildErrorState() => Padding(
    padding: const EdgeInsets.all(24),
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade300),
        const SizedBox(height: 16),
        Text(_errorMsg!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _analyze,
          icon:  const Icon(Icons.refresh_rounded, color: Colors.white),
          label: const Text('Coba Lagi',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          style: ElevatedButton.styleFrom(
            backgroundColor: cokelatTua,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ]),
    ),
  );

  // ── AI Result Banner ───────────────────────────────────────────────────────
  Widget _buildAiResultBanner() {
    final ai = _result!.ai;
    return Container(
      margin:  const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color:        cokelatTua,
          borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(
            _result!.isFallback
                ? 'AI tidak mendeteksi peralatan spesifik'
                : 'AI mendeteksi ${ai.detectedItems.length} item',
            style: const TextStyle(color: Colors.white,
                fontWeight: FontWeight.w700, fontSize: 13),
          )),
          if (!_result!.isFallback)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color:        emasMajelis.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8)),
              child: Text('${ai.confidencePercent}%',
                  style: const TextStyle(color: emasMajelis,
                      fontSize: 11, fontWeight: FontWeight.w800)),
            ),
        ]),
        if (ai.detectedItems.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 6, runSpacing: 6,
              children: ai.detectedItems.take(5).map((item) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color:        Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(item,
                    style: const TextStyle(color: Colors.white, fontSize: 11)),
              )).toList()),
        ],
        if (ai.tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 6, runSpacing: 6,
              children: ai.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:        emasMajelis.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: emasMajelis.withOpacity(0.4)),
                ),
                child: Text('#$tag',
                    style: const TextStyle(color: emasMajelis,
                        fontSize: 11, fontWeight: FontWeight.w700)),
              )).toList()),
        ],
      ]),
    );
  }

  // ── Section Title ──────────────────────────────────────────────────────────
  Widget _buildSectionTitle() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _result!.isFallback ? 'Barang Populer' : 'Rekomendasi Untukmu',
                style: const TextStyle(
                    color:      cokelatTua,
                    fontSize:   18,
                    fontWeight: FontWeight.w900),
              ),
              Text(
                '${_result!.total} barang ditemukan',
                style: TextStyle(
                    color:    cokelatTua.withOpacity(0.4),
                    fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            _result!.message,
            textAlign:  TextAlign.right,
            maxLines:   2,
            overflow:   TextOverflow.ellipsis,
            style: TextStyle(
                color:    cokelatTua.withOpacity(0.5),
                fontSize: 11),
          ),
        ),
      ],
    ),
  );

  // ── Product Grid (TIDAK DIUBAH) ────────────────────────────────────────────
  Widget _buildProductGrid() {
    final items = _result!.recommendations;
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text('Tidak ada barang ditemukan.',
              style: TextStyle(color: cokelatTua.withOpacity(0.4))),
        )),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:   2,
          crossAxisSpacing: 14,
          mainAxisSpacing:  14,
          childAspectRatio: 0.70,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) => _buildCard(items[i], i),
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildCard(RecommendedBarang barang, int index) {
    final bool isLoadingThis = _loadingCardId == barang.id;

    // Staggered fade-in per card
    return TweenAnimationBuilder<double>(
      tween:    Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + (index * 80)),
      curve:    Curves.easeOutCubic,
      builder:  (context, value, child) => Transform.translate(
        offset: Offset(0, 24 * (1 - value)),
        child:  Opacity(opacity: value, child: child),
      ),
      child: GestureDetector(
        onTap: () => _navigateToDetail(barang),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(
              color: isLoadingThis
                  ? cokelatTua.withOpacity(0.15)
                  : cokelatTua.withOpacity(0.06),
              blurRadius: isLoadingThis ? 18 : 10,
              offset:     const Offset(0, 4),
            )],
          ),
          child: Stack(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Stack(children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
                  child: _buildNetworkImage(barang.fotoUrl),
                ),
                if (barang.matchScore > 0)
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color:        cokelatTua,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text('${barang.matchScore} match',
                          style: const TextStyle(
                              color:      Colors.white,
                              fontSize:   9,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
              ])),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(barang.nama,
                        maxLines: 2,
                        overflow:  TextOverflow.ellipsis,
                        style: const TextStyle(
                            color:      cokelatTua,
                            fontSize:   12,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(barang.hargaFormatted,
                        style: const TextStyle(
                            color:      emasMajelis,
                            fontSize:   11,
                            fontWeight: FontWeight.w700)),
                    if (barang.matchedTags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(barang.matchedTags.take(2).join(' · '),
                          maxLines: 1,
                          overflow:  TextOverflow.ellipsis,
                          style: TextStyle(
                              color:    cokelatTua.withOpacity(0.4),
                              fontSize: 9)),
                    ],
                  ],
                ),
              ),
            ]),
            if (isLoadingThis)
              Positioned.fill(child: Container(
                decoration: BoxDecoration(
                    color:        cokelatTua.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(20)),
                child: const Center(child: SizedBox(
                  width: 28, height: 28,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )),
              )),
          ]),
        ),
      ),
    );
  }

  Widget _buildNetworkImage(String? url) {
    if (url == null || url.isEmpty) return _buildPlaceholder();
    return Image.network(
      url,
      headers: _imageHeaders,
      width:   double.infinity,
      height:  double.infinity,
      fit:     BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: cokelatTua.withOpacity(0.05),
          child: Center(child: SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                    progress.expectedTotalBytes!
                  : null,
              color:       emasMajelis,
              strokeWidth: 2,
            ),
          )),
        );
      },
      errorBuilder: (_, error, __) {
        debugPrint('❌ Gagal load gambar: $url\nError: $error');
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() => Container(
    color: cokelatTua.withOpacity(0.06),
    child: Center(child: Icon(
      Icons.image_not_supported_outlined,
      color: cokelatTua.withOpacity(0.2),
      size:  32,
    )),
  );
}

// ── Custom Painter: Orbit partikel melingkar ───────────────────────────────
class _OrbitPainter extends CustomPainter {
  final double progress;
  final Color  color;
  final int    dotCount;
  final double radius;
  final double dotRadius;

  const _OrbitPainter({
    required this.progress,
    required this.color,
    required this.dotCount,
    required this.radius,
    required this.dotRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint  = Paint()..color = color;

    for (int i = 0; i < dotCount; i++) {
      final angle = (progress * 2 * pi) + (i * 2 * pi / dotCount);
      final opacity = (0.3 + 0.7 * ((sin(angle) + 1) / 2)).clamp(0.2, 1.0);
      paint.color = color.withOpacity(opacity);
      final dx = center.dx + radius * cos(angle);
      final dy = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(dx, dy), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.progress != progress;
}