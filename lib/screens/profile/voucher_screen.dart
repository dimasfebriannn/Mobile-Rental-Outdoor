import 'package:flutter/material.dart';
import 'package:majelis_adventure/models/app_state.dart';

class VoucherScreen extends StatelessWidget {
  const VoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final Color darkBrown = const Color(0xFF3E2723);
    final Color goldenYellow = const Color(0xFFE5A93D);
    final Color creamBg = const Color(0xFFF5EFE6);

    return Scaffold(
      backgroundColor: creamBg,
      appBar: AppBar(
        backgroundColor: creamBg,
        elevation: 0,
        foregroundColor: darkBrown,
        title: const Text('Voucher Saya'),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(62, 39, 35, 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: goldenYellow.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            Icons.confirmation_number_rounded,
                            color: goldenYellow,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Voucher Eksklusif',
                                style: TextStyle(
                                  color: darkBrown,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Gunakan voucher untuk mendapatkan diskon sewa yang lebih besar.',
                                style: TextStyle(
                                  color: darkBrown.withOpacity(0.72),
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...appState.vouchers.map(
                    (voucher) => Column(
                      children: [
                        _voucherCard(voucher, darkBrown),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _voucherCard(VoucherData voucher, Color darkBrown) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: voucher.color,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color.fromRGBO(229, 169, 61, 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(voucher.icon, color: darkBrown, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  voucher.title,
                  style: TextStyle(
                    color: darkBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            voucher.description,
            style: TextStyle(
              color: darkBrown.withOpacity(0.75),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voucher.code,
                    style: TextStyle(
                      color: darkBrown,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    voucher.expiry,
                    style: TextStyle(
                      color: darkBrown.withOpacity(0.72),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBrown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text('Gunakan'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
