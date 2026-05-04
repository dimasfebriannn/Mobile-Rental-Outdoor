import 'package:flutter/material.dart';
import '../models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    const Color cokelatTua = Color(0xFF3E2723);
    const Color emasMajelis = Color(0xFFE5A93D);
    const Color latarKrem = Color(0xFFF5EFE6);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cokelatTua.withOpacity(0.05), width: 1),
        boxShadow: [
          BoxShadow(
            color: cokelatTua.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. AREA FOTO PRODUK
              Container(
                width: 100,
                color: latarKrem.withOpacity(0.5),
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Hero(
                    tag: "order_img_${order.orderId}",
                    child: Image.asset(
                      order.imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // 2. AREA DETAIL PESANAN
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ID PESANAN & STATUS INDONESIA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order.orderId.toUpperCase(),
                            style: TextStyle(
                              color: cokelatTua.withOpacity(0.3),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                          _buildStatusTag(order.status),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // NAMA PRODUK
                      Text(
                        order.productName,
                        style: const TextStyle(
                          color: cokelatTua,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // TANGGAL SEWA
                      Row(
                        children: [
                          Icon(Icons.event_available_outlined, 
                            size: 12, color: emasMajelis.withOpacity(0.7)),
                          const SizedBox(width: 6),
                          Text(
                            order.date,
                            style: TextStyle(
                              color: cokelatTua.withOpacity(0.4),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),
                      const SizedBox(height: 12),

                      // TOTAL PEMBAYARAN
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "TOTAL PEMBAYARAN",
                                style: TextStyle(
                                  color: cokelatTua.withOpacity(0.2),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                "Rp ${order.price}",
                                style: const TextStyle(
                                  color: cokelatTua,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          // INDIKATOR DETAIL
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: cokelatTua.withOpacity(0.03),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: cokelatTua,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // STATUS TAG - VERSI BAHASA INDONESIA
  Widget _buildStatusTag(OrderStatus status) {
    Color color;
    String text;

    switch (status) {
      case OrderStatus.diproses:
        color = const Color(0xFF4A90E2); // Biru Lembut
        text = "Diproses";
        break;
      case OrderStatus.aktif:
        color = const Color(0xFFE5A93D); // Emas
        text = "Disewa";
        break;
      case OrderStatus.selesai:
        color = const Color(0xFF52AD56); // Hijau Lembut
        text = "Selesai";
        break;
      default:
        color = const Color(0xFFE24A4A); // Merah Lembut
        text = "Dibatalkan";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}