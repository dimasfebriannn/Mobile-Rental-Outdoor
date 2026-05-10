// lib/screens/recommendation/recommendation_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/recommendation.dart';
import '../../services/recommendation_service.dart';

class RecommendationScreen extends StatefulWidget {
  final File imageFile;

  const RecommendationScreen({super.key, required this.imageFile});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen>
    with SingleTickerProviderStateMixin {
  // ── Brand colors ───────────────────────────────────────────────────────────
  static const Color latarKrem   = Color(0xFFF5EFE6);
  static const Color cokelatTua  = Color(0xFF3E2723);
  static const Color emasMajelis = Color(0xFFE5A93D);

  // ── State ──────────────────────────────────────────────────────────────────
  RecommendationResult? _result;
  bool                  _isLoading  = true;
  String?               _errorMsg;

  late AnimationController _pulseController;
  late Animation<double>   _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 900),
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
    setState(() {
      _isLoading = true;
      _errorMsg  = null;
    });
    try {
      final result = await RecommendationService.instance
          .analyzeImage(widget.imageFile);
      if (mounted) setState(() { _result = result; _isLoading = false; });
    } on RecommendationException catch (e) {
      if (mounted) setState(() { _errorMsg = e.message; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg  = 'Terjadi kesalahan. Silakan coba lagi.';
          _isLoading = false;
        });
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
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

  // ── App Bar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor:     cokelatTua,
      foregroundColor:     Colors.white,
      floating:            true,
      elevation:           0,
      title: const Text(
        'Rekomendasi AI',
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  // ── Image Preview ──────────────────────────────────────────────────────────
  Widget _buildImagePreview() {
    return Container(
      height: 220,
      width:  double.infinity,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:      cokelatTua.withOpacity(0.18),
            blurRadius: 16,
            offset:     const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(widget.imageFile, fit: BoxFit.cover),
      ),
    );
  }

  // ── Loading State ──────────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:        cokelatTua,
                shape:        BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:      cokelatTua.withOpacity(0.3),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'AI sedang menganalisis gambar...',
            style: TextStyle(
                color:      cokelatTua,
                fontSize:   16,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Mencocokkan dengan perlengkapan tersedia',
            style: TextStyle(
                color:    cokelatTua.withOpacity(0.5),
                fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Error State ────────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _errorMsg!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600),
            ),
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
          ],
        ),
      ),
    );
  }

  // ── AI Result Banner ───────────────────────────────────────────────────────
  Widget _buildAiResultBanner() {
    final ai = _result!.ai;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        cokelatTua,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                _result!.isFallback
                    ? 'AI tidak mendeteksi peralatan spesifik'
                    : 'AI mendeteksi ${ai.detectedItems.length} item',
                style: const TextStyle(
                    color:      Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize:   13),
              ),
              const Spacer(),
              if (!_result!.isFallback)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:        emasMajelis.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${ai.confidencePercent}%',
                    style: const TextStyle(
                        color:      emasMajelis,
                        fontSize:   11,
                        fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
          if (ai.detectedItems.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing:   6,
              runSpacing: 6,
              children: ai.detectedItems.take(5).map((item) =>
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:        Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(item,
                      style: const TextStyle(
                          color:    Colors.white,
                          fontSize: 11)),
                ),
              ).toList(),
            ),
          ],
          if (ai.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing:   6,
              runSpacing: 6,
              children: ai.tags.map((tag) =>
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:        emasMajelis.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border:       Border.all(
                        color: emasMajelis.withOpacity(0.4)),
                  ),
                  child: Text('#$tag',
                      style: const TextStyle(
                          color:      emasMajelis,
                          fontSize:   11,
                          fontWeight: FontWeight.w700)),
                ),
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ── Section Title ──────────────────────────────────────────────────────────
  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _result!.isFallback
                    ? 'Barang Populer'
                    : 'Rekomendasi Untukmu',
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
          Text(
            _result!.message,
            style: TextStyle(
                color:    cokelatTua.withOpacity(0.5),
                fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── Product Grid ───────────────────────────────────────────────────────────
  Widget _buildProductGrid() {
    final items = _result!.recommendations;

    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text('Tidak ada barang ditemukan.',
                style: TextStyle(color: cokelatTua.withOpacity(0.4))),
          ),
        ),
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
          (context, index) => _buildRecommendationCard(items[index]),
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(RecommendedBarang barang) {
    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:      cokelatTua.withOpacity(0.06),
            blurRadius: 10,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Foto ─────────────────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
                  child: barang.fotoUrl != null
                      ? Image.network(
                          barang.fotoUrl!,
                          width:  double.infinity,
                          fit:    BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
                // Match score badge
                if (barang.matchScore > 0)
                  Positioned(
                    top:   8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:        cokelatTua,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${barang.matchScore} match',
                        style: const TextStyle(
                            color:      Colors.white,
                            fontSize:   9,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // ── Info ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  barang.nama,
                  maxLines:  2,
                  overflow:  TextOverflow.ellipsis,
                  style: const TextStyle(
                      color:      cokelatTua,
                      fontSize:   12,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  barang.hargaFormatted,
                  style: const TextStyle(
                      color:      emasMajelis,
                      fontSize:   11,
                      fontWeight: FontWeight.w700),
                ),
                if (barang.matchedTags.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    barang.matchedTags.take(2).join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color:    cokelatTua.withOpacity(0.4),
                        fontSize: 9),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: cokelatTua.withOpacity(0.06),
      child: Center(
        child: Icon(Icons.image_not_supported_outlined,
            color: cokelatTua.withOpacity(0.2), size: 32),
      ),
    );
  }
}