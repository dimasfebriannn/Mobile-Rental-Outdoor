import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  // CONSTRUCTOR REVISI: Dibuat lebih ramping karena data sudah ada di 'product'
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap, required String name, required String price, required String imagePath,
  });

  @override
  Widget build(BuildContext context) {
    const Color cokelatTua = Color(0xFF3E2723);
    const Color emasMajelis = Color(0xFFE5A93D);
    const Color latarKrem = Color(0xFFF5EFE6);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Padding layaknya bingkai/frame premium
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
            // 1. AREA GAMBAR (Dengan efek Studio)
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: product.name,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: latarKrem, // Background krem Majelis
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          product.imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  // Rating Badge (Kesan Terpercaya)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: emasMajelis, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            "4.8", // Bisa diganti dinamis nanti
                            style: TextStyle(
                              color: cokelatTua,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 2. AREA INFO & TOMBOL
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Info Teks
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            color: cokelatTua,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              "Rp ${product.price}",
                              style: const TextStyle(
                                color: emasMajelis,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              "/hari",
                              style: TextStyle(
                                color: cokelatTua.withOpacity(0.4),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Tombol Action "Sewa/Detail"
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
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}