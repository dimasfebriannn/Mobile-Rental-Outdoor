enum OrderStatus { diproses, aktif, selesai, dibatalkan }

class OrderModel {
  final String orderId;
  final String productName;
  final String price;
  final String date;
  final OrderStatus status;
  final String imagePath;

  OrderModel({
    required this.orderId,
    required this.productName,
    required this.price,
    required this.date,
    required this.status,
    required this.imagePath,
  });
}

final List<OrderModel> dummyOrders = [
  // --- STATUS: BERJALAN (Aktif & Diproses) ---
  OrderModel(
    orderId: "MA-8821",
    productName: "Tenda Eiger 4P",
    price: "225.000",
    date: "28 Apr - 30 Apr 2026",
    status: OrderStatus.aktif,
    imagePath: 'lib/assets/img/majelis.png',
  ),
  OrderModel(
    orderId: "MA-7712",
    productName: "Carrier Osprey 60L",
    price: "165.000",
    date: "10 Mei - 13 Mei 2026",
    status: OrderStatus.diproses,
    imagePath: 'lib/assets/img/majelis.png',
  ),
  OrderModel(
    orderId: "MA-9905",
    productName: "Sleeping Bag Deuter",
    price: "45.000",
    date: "05 Mei - 07 Mei 2026",
    status: OrderStatus.diproses,
    imagePath: 'lib/assets/img/majelis.png',
  ),
  OrderModel(
    orderId: "MA-5520",
    productName: "Kompor Kovea + Gas",
    price: "35.000",
    date: "01 Mei - 03 Mei 2026",
    status: OrderStatus.aktif,
    imagePath: 'lib/assets/img/majelis.png',
  ),
  OrderModel(
    orderId: "MA-3390",
    productName: "Headlamp Petzl Tikka",
    price: "25.000",
    date: "12 Jun - 14 Jun 2026",
    status: OrderStatus.diproses,
    imagePath: 'lib/assets/img/majelis.png',
  ),

  // --- STATUS: RIWAYAT (Selesai & Dibatalkan) ---
  OrderModel(
    orderId: "MA-1102",
    productName: "Sepatu Consina Alpen",
    price: "90.000",
    date: "12 Feb - 15 Feb 2026",
    status: OrderStatus.selesai,
    imagePath: 'lib/assets/img/majelis.png',
  ),
  OrderModel(
    orderId: "MA-4411",
    productName: "Tenda Consina 2P",
    price: "150.000",
    date: "20 Mar - 22 Mar 2026",
    status: OrderStatus.dibatalkan,
    imagePath: 'lib/assets/img/majelis.png',
  ),
  OrderModel(
    orderId: "MA-1288",
    productName: "Matras Angin Naturehike",
    price: "55.000",
    date: "18 Apr - 20 Apr 2026",
    status: OrderStatus.selesai,
    imagePath: 'lib/assets/img/majelis.png',
  ),
  OrderModel(
    orderId: "MA-6677",
    productName: "Cooking Set DS-308",
    price: "40.000",
    date: "10 Jan - 12 Jan 2026",
    status: OrderStatus.selesai,
    imagePath: 'lib/assets/img/majelis.png',
  ),
  OrderModel(
    orderId: "MA-2234",
    productName: "Flysheet 3x4 Waterproof",
    price: "30.000",
    date: "05 Jan - 07 Jan 2026",
    status: OrderStatus.selesai,
    imagePath: 'lib/assets/img/majelis.png',
  ),
  OrderModel(
    orderId: "MA-9911",
    productName: "Jaket TNF Summit Series",
    price: "110.000",
    date: "01 Jan - 03 Jan 2026",
    status: OrderStatus.selesai,
    imagePath: 'lib/assets/img/majelis.png',
  ),
];