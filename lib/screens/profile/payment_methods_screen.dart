import 'package:flutter/material.dart';
import 'package:majelis_adventure/models/app_state.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

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
        title: const Text('Metode Pembayaran'),
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
                  _headerCard(darkBrown, goldenYellow),
                  const SizedBox(height: 24),
                  Text(
                    'Metode Tersimpan',
                    style: TextStyle(
                      color: darkBrown,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...appState.paymentMethods.map(
                    (method) => Column(
                      children: [
                        _methodItem(
                          method: method,
                          isSelected:
                              method.value == appState.selectedPaymentMethod,
                          onTap: () =>
                              appState.selectPaymentMethod(method.value),
                          darkBrown: darkBrown,
                          goldenYellow: goldenYellow,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  Text(
                    'Info Pembayaran',
                    style: TextStyle(
                      color: darkBrown,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(62, 39, 35, 0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Metode aktif',
                          style: TextStyle(
                            color: darkBrown.withOpacity(0.75),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          appState.selectedPaymentMethod,
                          style: TextStyle(
                            color: darkBrown,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Pembayaran otomatis akan menggunakan metode ini saat Anda melakukan sewa alat.',
                          style: TextStyle(
                            color: darkBrown.withOpacity(0.72),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Tambah Metode Pembayaran'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
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

  Widget _headerCard(Color darkBrown, Color goldenYellow) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(62, 39, 35, 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
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
            child: Icon(Icons.payment_rounded, color: goldenYellow, size: 30),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bayar Lebih Cepat',
                  style: TextStyle(
                    color: darkBrown,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih metode pembayaran favoritmu untuk mempercepat proses pemesanan.',
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
    );
  }

  Widget _methodItem({
    required PaymentMethod method,
    required bool isSelected,
    required VoidCallback onTap,
    required Color darkBrown,
    required Color goldenYellow,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? goldenYellow
                : const Color.fromRGBO(229, 229, 229, 1),
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(62, 39, 35, 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: goldenYellow.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(method.icon, color: darkBrown, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.label,
                    style: TextStyle(
                      color: darkBrown,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    method.details,
                    style: TextStyle(
                      color: darkBrown.withOpacity(0.72),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: goldenYellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
