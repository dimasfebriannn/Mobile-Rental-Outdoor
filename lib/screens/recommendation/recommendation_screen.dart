// lib/screens/recommendation/recommendation_screen.dart

import 'dart:io';
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
    with SingleTickerProviderStateMixin {
  static const Color latarKrem   = Color(0xFFF5EFE6);
  static const Color cokelatTua  = Color(0xFF3E2723);
  static const Color emasMajelis = Color(0xFFE5A93D);

  RecommendationResult? _result;
  bool    _isLoading    = true;
  String? _errorMsg;
  int?    _loadingCardId;

  static const Map<String, String> _imageHeaders = {
    'ngrok-skip-browser-warning': 'true',
    'User-Agent': 'MajelisApp/1.0',
  };

  late AnimationController _pulseController;
  late Animation<double>   _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _analyze();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      final result = await RecommendationService.instance
          .analyzeImage(widget.imageFile);

      // ── DEBUG: cetak foto_url setiap item ─────────────────────────────
      for (final b in result.recommendations) {
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('NAMA     : ${b.nama}');
        debugPrint('FOTO_URL : ${b.fotoUrl ?? "NULL"}');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }
      // ── END DEBUG ──────────────────────────────────────────────────────

      if (mounted) setState(() { _result = result; _isLoading = false; });
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: latarKrem,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildImagePreview()),
          if (_isLoading)
            SliverToBoxAdapter(child: _buildLoadingState())
          else if (_errorMsg != null)
            SliverToBoxAdapter(child: _buildErrorState())
          else ...[
            SliverToBoxAdapter(child: _buildAiResultBanner()),
            SliverToBoxAdapter(child: _buildSectionTitle()),
            _buildProductGrid(),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ],
      ),
    );
  }

  Widget _buildAppBar() => SliverAppBar(
    backgroundColor: cokelatTua,
    foregroundColor: Colors.white,
    floating: true,
    elevation: 0,
    title: const Text('Rekomendasi AI',
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
    leading: IconButton(
      icon:      const Icon(Icons.arrow_back_ios_new_rounded),
      onPressed: () => Navigator.pop(context),
    ),
  );

  Widget _buildImagePreview() => Container(
    height: 220,
    width:  double.infinity,
    margin: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(
          color:      cokelatTua.withOpacity(0.18),
          blurRadius: 16,
          offset:     const Offset(0, 6))],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.file(widget.imageFile, fit: BoxFit.cover),
    ),
  );

  Widget _buildLoadingState() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
    child: Column(children: [
      ScaleTransition(
        scale: _pulseAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color:    cokelatTua,
            shape:    BoxShape.circle,
            boxShadow: [BoxShadow(
                color:        cokelatTua.withOpacity(0.3),
                blurRadius:   24,
                spreadRadius: 4)],
          ),
          child: const Icon(Icons.auto_awesome_rounded,
              size: 40, color: Colors.white),
        ),
      ),
      const SizedBox(height: 24),
      Text('AI sedang menganalisis gambar...',
          style: TextStyle(color: cokelatTua, fontSize: 16,
              fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text('Mencocokkan dengan perlengkapan tersedia',
          style: TextStyle(color: cokelatTua.withOpacity(0.5), fontSize: 13)),
    ]),
  );

  Widget _buildErrorState() => Padding(
    padding: const EdgeInsets.all(24),
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Icon(Icons.error_outline_rounded,
            size: 48, color: Colors.red.shade300),
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

  Widget _buildAiResultBanner() {
    final ai = _result!.ai;
    return Container(
      margin:  const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color:        cokelatTua,
          borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.auto_awesome_rounded,
              color: Colors.white, size: 16),
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

  // ── FIX OVERFLOW: pakai Flexible agar teks tidak meluber ─────────────────
  Widget _buildSectionTitle() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kolom kiri: judul + jumlah
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
        // Kolom kanan: pesan singkat — pakai Flexible agar tidak overflow
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
          (_, i) => _buildCard(items[i]),
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildCard(RecommendedBarang barang) {
    final bool isLoadingThis = _loadingCardId == barang.id;

    return GestureDetector(
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
    );
  }

  Widget _buildNetworkImage(String? url) {
    if (url == null || url.isEmpty) {
      return _buildPlaceholder();
    }

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
        // ── DEBUG: cetak error load gambar ──────────────────────────────
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