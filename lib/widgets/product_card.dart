// lib/widgets/product_card.dart
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color cokelatTua  = Color(0xFF3E2723);
    const Color emasMajelis = Color(0xFFE5A93D);
    const Color latarKrem   = Color(0xFFF5EFE6);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: cokelatTua.withOpacity(0.04), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: cokelatTua.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── BAGIAN GAMBAR ──────────────────────────────────────────────
            Expanded(
              child: Hero(
                tag: 'product-${product.id}',
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: latarKrem,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildImage(),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── BAGIAN INFORMASI ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Kolom nama + harga — pakai Expanded agar tidak overflow
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            color: cokelatTua,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        // ── FIX OVERFLOW: bungkus Row harga dengan FittedBox ──
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                'Rp ${product.price}',
                                style: const TextStyle(
                                  color: emasMajelis,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '/hari',
                              style: TextStyle(
                                color: cokelatTua.withOpacity(0.4),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Tombol detail
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cokelatTua,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_outward_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Image builder: network → fallback placeholder ──────────────────────────
  Widget _buildImage() {
    const Color cokelatTua = Color(0xFF3E2723);
    const Color latarKrem  = Color(0xFFF5EFE6);

    final url = product.imageUrl;

    if (url.isEmpty) return _placeholder(cokelatTua);

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: latarKrem,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: cokelatTua.withOpacity(0.3),
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _placeholder(cokelatTua),
    );
  }

  Widget _placeholder(Color color) {
    return Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 36,
        color: color.withOpacity(0.18),
      ),
    );
  }
}