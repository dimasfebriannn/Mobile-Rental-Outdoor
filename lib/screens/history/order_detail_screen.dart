import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/order_model.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final Color darkBrown = const Color(0xFF3E2723);
    final Color goldenYellow = const Color(0xFFE5A93D);
    final Color creamBg = const Color(0xFFF5EFE6);
    final Color deepBlack = const Color(0xFF1B1210);

    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // 1. DYNAMIC BACKGROUND ACCENT
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: goldenYellow.withOpacity(0.1),
              ),
            ),
          ),

          // 2. SCROLLABLE CONTENT
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 120),
                  
                  // THE LUXURY TICKET
                  _buildPremiumTicket(context, darkBrown, goldenYellow),

                  const SizedBox(height: 24),

                  // TRACKING JOURNEY
                  _buildTrackingJourney(darkBrown, goldenYellow),

                  const SizedBox(height: 24),

                  // PAYMENT SUMMARY
                  _buildPaymentReceipt(darkBrown, goldenYellow),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),

          // 3. MINIMALIST TOP BAR
          _buildLuxuryTopBar(context, darkBrown),
        ],
      ),
    );
  }

  // WIDGET: Premium Digital Ticket
  Widget _buildPremiumTicket(BuildContext context, Color db, Color gy) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: db.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Product Image with Glass Effect
                Container(
                  width: 80, height: 80,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5EFE6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(order.imagePath, fit: BoxFit.contain),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: db.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.orderId,
                          style: TextStyle(color: db, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order.productName,
                        style: TextStyle(color: db, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Dotted Line Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: List.generate(30, (index) => Expanded(
                child: Container(
                  color: index % 2 == 0 ? Colors.transparent : Colors.grey.withOpacity(0.2),
                  height: 2,
                ),
              )),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ticketDetail("PICKUP DATE", order.date.split(' - ')[0], db),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: gy.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.sync_alt_rounded, color: gy, size: 16),
                ),
                _ticketDetail("RETURN DATE", order.date.split(' - ')[1], db),
              ],
            ),
          ),
          
          // QR CODE SIMULATION (Adding Tech-Luxury feel)
          Container(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                Icon(Icons.qr_code_2_rounded, size: 60, color: db.withOpacity(0.8)),
                const SizedBox(height: 8),
                Text("SCAN AT BASECAMP", style: TextStyle(color: db.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _ticketDetail(String label, String date, Color db) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: db.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(date, style: TextStyle(color: db, fontWeight: FontWeight.w900, fontSize: 14)),
      ],
    );
  }

  // WIDGET: Tracking Journey (Timeline)
  Widget _buildTrackingJourney(Color db, Color gy) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("JOURNEY STATUS", style: TextStyle(color: db, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
          const SizedBox(height: 24),
          _buildStep(Icons.check_circle_rounded, "Confirmed", "Order has been verified", true, db, gy),
          _buildStep(Icons.directions_walk_rounded, "Ready for Pickup", "Gear is sterilized & ready", true, db, gy),
          _buildStep(Icons.landscape_rounded, "On Adventure", "Currently in your possession", false, db, gy),
        ],
      ),
    );
  }

  Widget _buildStep(IconData icon, String title, String sub, bool isDone, Color db, Color gy) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, color: isDone ? gy : Colors.grey.shade300, size: 22),
            Container(width: 2, height: 30, color: Colors.grey.shade100),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: isDone ? db : db.withOpacity(0.3), fontWeight: FontWeight.w900, fontSize: 13)),
            Text(sub, style: TextStyle(color: db.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  // WIDGET: Payment Receipt
  Widget _buildPaymentReceipt(Color db, Color gy) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [db, const Color(0xFF1B1210)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          _receiptRow("Rental Price", "Rp ${order.price}", Colors.white.withOpacity(0.4)),
          const SizedBox(height: 12),
          _receiptRow("Security Deposit", "Rp 50.000", Colors.white.withOpacity(0.4)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.white10, thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("GRAND TOTAL", style: TextStyle(color: gy, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
              Text("Rp 275.000", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
            ],
          )
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String val, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
        Text(val, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }

  // WIDGET: Luxury Top Bar
  Widget _buildLuxuryTopBar(BuildContext context, Color db) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
            color: Colors.white.withOpacity(0.7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back_ios_new_rounded, color: db, size: 20),
                ),
                Text(
                  "ORDER DETAILS",
                  style: TextStyle(color: db, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2),
                ),
                Icon(Icons.share_outlined, color: db, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}