// lib/providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int qty;

  CartItem({required this.product, this.qty = 1});
}

class CartProvider extends ChangeNotifier {
  // Singleton agar bisa diakses dari mana saja tanpa package provider
  static final CartProvider instance = CartProvider._internal();
  CartProvider._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, item) => sum + item.qty);

  double get totalPerDay =>
      _items.fold(0, (sum, item) => sum + item.product.hargaPerHari * item.qty);

  // Tambah produk ke keranjang; jika sudah ada, naikkan qty
  void addProduct(Product product) {
    final idx = _items.indexWhere((e) => e.product.id == product.id);
    if (idx >= 0) {
      _items[idx].qty++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  // Naikkan qty item berdasarkan index
  void increment(int index) {
    if (index < 0 || index >= _items.length) return;
    _items[index].qty++;
    notifyListeners();
  }

  // Turunkan qty; jika qty == 1 dan diturunkan, item dihapus
  void decrement(int index) {
    if (index < 0 || index >= _items.length) return;
    if (_items[index].qty > 1) {
      _items[index].qty--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  // Hapus item berdasarkan index
  void remove(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}