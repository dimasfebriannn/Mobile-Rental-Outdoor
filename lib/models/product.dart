  // lib/models/product.dart
  import '../config/api_config.dart';

  class Product {
    final int id;
    final String name;
    final double hargaPerHari;
    final String category;
    final String? fotoUtama;
    final List<String> foto;
    final String rating;
    final int stok;
    final String? description;
    final String? specification;
    final List<String> tags;

    Product({
      required this.id,
      required this.name,
      required this.hargaPerHari,
      required this.category,
      this.fotoUtama,
      this.foto = const [],
      this.rating = '4.8',
      this.stok = 0,
      this.description,
      this.specification,
      this.tags = const [],
    });

    /// Format harga untuk tampilan: "75.000"
    String get price {
      return hargaPerHari
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.',
          );
    }

    /// Foto pertama yang tersedia, fallback ke string kosong
    String get imageUrl => fotoUtama ?? '';

    // ── Ganti base URL lokal (127.0.0.1 / localhost) → base URL aktif ─────────
    // Ini mengatasi kasus API masih return http://127.0.0.1:8000/storage/...
    // padahal device harus akses lewat ngrok / produksi.
    static String fixImageUrl(String? raw) {
      if (raw == null || raw.isEmpty) return '';

      // Base URL tanpa "/api" → misal https://xxx.ngrok-free.app
      final appBase = ApiConfig.baseUrl.replaceFirst(RegExp(r'/api$'), '');

      // Ganti pola http://127.0.0.1:PORT atau http://localhost:PORT
      return raw.replaceFirst(
        RegExp(r'https?://(127\.0\.0\.1|localhost)(:\d+)?'),
        appBase,
      );
    }

    factory Product.fromJson(Map<String, dynamic> json) {
      return Product(
        id:            json['id'] as int,
        name:          json['nama'] as String,
        hargaPerHari:  double.tryParse(json['harga_per_hari']?.toString() ?? '0') ?? 0.0,
        category:      json['kategori'] as String,
        fotoUtama:     Product.fixImageUrl(json['foto_utama'] as String?),
        foto:          (json['foto'] as List<dynamic>?)
                          ?.map((e) => Product.fixImageUrl(e.toString()))
                          .toList() ?? [],
        rating:        json['rating']?.toString() ?? '4.8',
        stok:          json['stok'] as int? ?? 0,
        description:   json['deskripsi'] as String?,
        specification: json['spesifikasi'] as String?,
        tags:          (json['tags'] as List<dynamic>?)
                          ?.map((e) => e.toString())
                          .toList() ?? [],
      );
    }
  }