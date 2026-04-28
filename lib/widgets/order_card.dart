import 'package:flutter/material.dart';
import '../models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final Color darkBrown = const Color(0xFF3E2723);
    final Color goldenYellow = const Color(0xFFE5A93D);
    final Color creamBg = const Color(0xFFF5EFE6);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: darkBrown.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(color: darkBrown.withOpacity(0.03)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 1. THUMBNAIL AREA (GEOMETRIC) ---
              Container(
                width: 100,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: creamBg,
                  borderRadius: BorderRadius.circular(18),
                  image: DecorationImage(
                    image: AssetImage(order.imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // --- 2. INFO AREA ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Order ID dengan gaya Tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: darkBrown.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              order.orderId,
                              style: TextStyle(
                                color: darkBrown.withOpacity(0.5),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          _buildStatusBadge(order.status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        order.productName,
                        style: TextStyle(
                          color: darkBrown,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 12, color: darkBrown.withOpacity(0.3)),
                          const SizedBox(width: 6),
                          Text(
                            order.date,
                            style: TextStyle(
                              color: darkBrown.withOpacity(0.4),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Sewa",
                                style: TextStyle(
                                  color: darkBrown.withOpacity(0.3),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Rp ${order.price}",
                                style: TextStyle(
                                  color: goldenYellow,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          // Indikator Klik Detail
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: darkBrown.withOpacity(0.2),
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

  // REVISI STATUS BADGE: LUXURY MINIMALIST
  Widget _buildStatusBadge(OrderStatus status) {
    Color statusColor;
    String label;

    switch (status) {
      case OrderStatus.diproses:
        statusColor = Colors.blueAccent;
        label = "Proses";
        break;
      case OrderStatus.aktif:
        statusColor = const Color(0xFFE5A93D);
        label = "Disewa";
        break;
      case OrderStatus.selesai:
        statusColor = Colors.greenAccent.shade700;
        label = "Selesai";
        break;
      default:
        statusColor = Colors.redAccent;
        label = "Batal";
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.4),
                blurRadius: 4,
                spreadRadius: 1,
              )
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: statusColor,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}