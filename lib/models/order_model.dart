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

// Data Dummy untuk testing
final List<OrderModel> dummyOrders = [
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
    orderId: "MA-1102",
    productName: "Sepatu Consina",
    price: "90.000",
    date: "12 Feb - 15 Feb 2026",
    status: OrderStatus.selesai,
    imagePath: 'lib/assets/img/majelis.png',
  ),
];