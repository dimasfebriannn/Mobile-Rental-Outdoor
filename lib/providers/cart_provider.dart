// lib/providers/cart_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int qty;

  CartItem({required this.product, this.qty = 1});

  // ── Serialisasi ──────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'qty': qty,
        'product': {
          'id': product.id,
          'nama': product.name,
          'harga_per_hari': product.hargaPerHari.toString(),
          'kategori': product.category,
          'foto_utama': product.fotoUtama,
          'foto': product.foto,
          'rating': product.rating,
          'stok': product.stok,
          'deskripsi': product.description,
          'spesifikasi': product.specification,
          'tags': product.tags,
        },
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        qty: json['qty'] as int,
        product: Product.fromJson(json['product'] as Map<String, dynamic>),
      );
}

class CartProvider extends ChangeNotifier {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final CartProvider instance = CartProvider._internal();
  CartProvider._internal() {
    _loadFromStorage(); // muat cart saat pertama kali diakses
  }

  static const String _storageKey = 'majelis_cart_items';

  final List<CartItem> _items = [];
  bool _isLoaded = false; // flag agar UI tahu data sudah dimuat

  // ── Getters ───────────────────────────────────────────────────────────────
  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoaded => _isLoaded;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.qty);

  double get totalPerDay =>
      _items.fold(0.0, (sum, item) => sum + item.product.hargaPerHari * item.qty);

  // ── Persistensi ───────────────────────────────────────────────────────────

  /// Muat data keranjang dari SharedPreferences saat app dibuka.
  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
        _items.clear();
        for (final entry in decoded) {
          try {
            _items.add(CartItem.fromJson(entry as Map<String, dynamic>));
          } catch (_) {
            // Lewati item yang corrupt agar app tidak crash
          }
        }
      }
    } catch (e) {
      debugPrint('[CartProvider] Gagal memuat cart: $e');
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Simpan seluruh cart ke SharedPreferences setiap kali ada perubahan.
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_items.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('[CartProvider] Gagal menyimpan cart: $e');
    }
  }

  // ── Operasi Cart ──────────────────────────────────────────────────────────

  /// Tambah produk ke keranjang; jika sudah ada, naikkan qty.
  void addProduct(Product product) {
    final idx = _items.indexWhere((e) => e.product.id == product.id);
    if (idx >= 0) {
      _items[idx].qty++;
    } else {
      _items.add(CartItem(product: product));
    }
    _saveToStorage();
    notifyListeners();
  }

  /// Naikkan qty item berdasarkan index.
  void increment(int index) {
    if (index < 0 || index >= _items.length) return;
    _items[index].qty++;
    _saveToStorage();
    notifyListeners();
  }

  /// Turunkan qty; jika qty == 1 dan diturunkan, item dihapus.
  void decrement(int index) {
    if (index < 0 || index >= _items.length) return;
    if (_items[index].qty > 1) {
      _items[index].qty--;
    } else {
      _items.removeAt(index);
    }
    _saveToStorage();
    notifyListeners();
  }

  /// Hapus item berdasarkan index.
  void remove(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    _saveToStorage();
    notifyListeners();
  }

  /// Kosongkan seluruh keranjang.
  void clear() {
    _items.clear();
    _saveToStorage();
    notifyListeners();
  }
}