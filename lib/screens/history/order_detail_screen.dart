import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/order_model.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    const Color darkBrown = Color(0xFF3E2723);
    const Color goldenYellow = Color(0xFFE5A93D);
    const Color creamBg = Color(0xFFF5EFE6);

    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // 1. DYNAMIC BACKGROUND ACCENT
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: goldenYellow.withOpacity(0.05),
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
                  
                  // THE ELITE VOUCHER
                  _buildEliteVoucher(context, darkBrown, goldenYellow),

                  const SizedBox(height: 24),

                  // EXPEDITION PROGRESS
                  _buildExpeditionProgress(darkBrown, goldenYellow),

                  const SizedBox(height: 24),

                  // INVOICE SUMMARY
                  _buildInvoiceSummary(darkBrown, goldenYellow),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // 3. MINIMALIST GLASS TOP BAR
          _buildGlassTopBar(context, darkBrown),
        ],
      ),
    );
  }

  // WIDGET: Elite Voucher dengan Cut-out Effect
  Widget _buildEliteVoucher(BuildContext context, Color db, Color gy) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: db.withOpacity(0.06), blurRadius: 40, offset: const Offset(0, 20))
            ],
          ),
          child: Column(
            children: [
              // Bagian Atas: Info Produk
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5EFE6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(order.imagePath, fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("ADVENTURE GEAR", style: TextStyle(color: gy, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                          const SizedBox(height: 4),
                          Text(order.productName, style: TextStyle(color: db, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
                          const SizedBox(height: 4),
                          Text(order.orderId, style: TextStyle(color: db.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Garis Putus-putus dengan Lubang Tiket
              Row(
                children: [
                  _ticketPunch(true, db),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: List.generate(20, (index) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 1.5,
                            color: db.withOpacity(0.05),
                          ),
                        )),
                      ),
                    ),
                  ),
                  _ticketPunch(false, db),
                ],
              ),

              // Bagian Bawah: Info Waktu
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoBlock("PICK-UP", order.date.split(' - ')[0], db, Icons.login_rounded),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: db.withOpacity(0.03), shape: BoxShape.circle),
                          child: Icon(Icons.arrow_forward_rounded, color: gy, size: 16),
                        ),
                        _infoBlock("RETURN", order.date.split(' - ')[1], db, Icons.logout_rounded),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // QR Code & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("QR AUTHENTICATION", style: TextStyle(color: db.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
                            const SizedBox(height: 4),
                            Text("Valid at Basecamp", style: TextStyle(color: db, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Icon(Icons.qr_code_scanner_rounded, size: 45, color: db.withOpacity(0.8)),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ticketPunch(bool isLeft, Color db) {
    return Container(
      height: 30, width: 15,
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6), // Sama dengan background screen
        borderRadius: BorderRadius.only(
          topRight: isLeft ? const Radius.circular(30) : Radius.zero,
          bottomRight: isLeft ? const Radius.circular(30) : Radius.zero,
          topLeft: !isLeft ? const Radius.circular(30) : Radius.zero,
          bottomLeft: !isLeft ? const Radius.circular(30) : Radius.zero,
        ),
      ),
    );
  }

  Widget _infoBlock(String label, String value, Color db, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 10, color: db.withOpacity(0.3)),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: db.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: db, fontWeight: FontWeight.w900, fontSize: 13)),
      ],
    );
  }

  // WIDGET: Expedition Progress
  Widget _buildExpeditionProgress(Color db, Color gy) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("EXPEDITION PROGRESS", style: TextStyle(color: db, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
          const SizedBox(height: 24),
          _stepItem("Booking Confirmed", "Verified by system", true, true, db, gy),
          _stepItem("Gear Sterilized", "Ready for pick-up", true, true, db, gy),
          _stepItem("Adventure Time", "Currently in use", false, false, db, gy),
        ],
      ),
    );
  }

  Widget _stepItem(String title, String desc, bool isCompleted, bool isLast, Color db, Color gy) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, 
                 color: isCompleted ? gy : db.withOpacity(0.1), size: 18),
            if (isLast) Container(width: 1, height: 30, color: db.withOpacity(0.05)),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: isCompleted ? db : db.withOpacity(0.3), fontWeight: FontWeight.w900, fontSize: 13)),
            const SizedBox(height: 2),
            Text(desc, style: TextStyle(color: db.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
          ],
        ),
      ],
    );
  }

  // WIDGET: Invoice Summary
  Widget _buildInvoiceSummary(Color db, Color gy) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: db,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          _rowInvoice("Rental Base Price", "Rp ${order.price}", Colors.white54),
          const SizedBox(height: 12),
          _rowInvoice("Service & Cleaning", "Rp 15.000", Colors.white54),
          const SizedBox(height: 12),
          _rowInvoice("Security Deposit", "Rp 50.000", Colors.white54),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white10, thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("TOTAL PAID", style: TextStyle(color: gy, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
              Text("Rp 265.000", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          )
        ],
      ),
    );
  }

  Widget _rowInvoice(String label, String val, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }

  // WIDGET: Glass Top Bar
  Widget _buildGlassTopBar(BuildContext context, Color db) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 15),
            color: Colors.white.withOpacity(0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: db.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: db, size: 16),
                  ),
                ),
                Text("ORDER DETAILS", style: TextStyle(color: db, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
                Icon(Icons.more_vert_rounded, color: db, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}