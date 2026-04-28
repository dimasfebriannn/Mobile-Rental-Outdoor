class Product {
  final String name;
  final String price;
  final String category;
  final String imagePath;
  final String rating;

  Product({
    required this.name,
    required this.price,
    required this.category,
    required this.imagePath,
    this.rating = "4.8",
  });
}

// DATA DUMMY: Bisa kamu tambah atau hapus sesuai stok alat
final List<Product> allProducts = [
  Product(name: "Tenda Eiger 4P", price: "75.000", category: "Tenda", imagePath: 'lib/assets/img/majelis.png'),
  Product(name: "Carrier Osprey 60L", price: "55.000", category: "Carrier", imagePath: 'lib/assets/img/majelis.png'),
  Product(name: "Sepatu Consina", price: "30.000", category: "Sepatu", imagePath: 'lib/assets/img/majelis.png'),
  Product(name: "Lampu Tenda Petzl", price: "15.000", category: "Lampu", imagePath: 'lib/assets/img/majelis.png'),
  Product(name: "Kompor Portable", price: "20.000", category: "Alat Masak", imagePath: 'lib/assets/img/majelis.png'),
  Product(name: "Tenda Dome 2P", price: "40.000", category: "Tenda", imagePath: 'lib/assets/img/majelis.png'),
  Product(name: "Carrier Deuter 45L", price: "45.000", category: "Carrier", imagePath: 'lib/assets/img/majelis.png'),
];