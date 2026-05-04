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
    const Color cokelatTua = Color(0xFF3E2723);
    const Color emasMajelis = Color(0xFFE5A93D);
    const Color latarKrem = Color(0xFFF5EFE6);

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
            // BAGIAN GAMBAR
            Expanded(
              child: Hero(
                tag: product.name,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: latarKrem,
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
            ),
            const SizedBox(height: 12),
            // BAGIAN INFORMASI PRODUK
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
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
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
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
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // TOMBOL DETAIL KECIL
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
}