// lib/services/barang_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Service untuk komunikasi dengan Laravel API endpoint /barang & /kategori.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/kategori.dart';
import '../models/product.dart';

class BarangService {
  BarangService._();
  static final BarangService instance = BarangService._();

  // ── Headers default ───────────────────────────────────────────────────────
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // Header wajib agar tidak kena interstitial ngrok
        'ngrok-skip-browser-warning': 'true',
      };

  // ── Fetch semua barang (+ filter opsional) ────────────────────────────────
  /// [kategori] : nama kategori, kirim null / "Semua" untuk semua
  /// [search]   : kata kunci pencarian nama barang
  Future<List<Product>> fetchBarang({
    String? kategori,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (kategori != null && kategori.isNotEmpty && kategori != 'Semua') {
      queryParams['kategori'] = kategori;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final uri = Uri.parse(ApiConfig.baseUrl + ApiConfig.barang)
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(milliseconds: ApiConfig.receiveTimeout));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true) {
        final List<dynamic> list = json['data'] as List<dynamic>;
        return list
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    throw Exception(
      'Gagal memuat data barang (status ${response.statusCode})',
    );
  }

  // ── Fetch detail 1 barang ─────────────────────────────────────────────────
  Future<Product> fetchBarangDetail(int id) async {
    final uri = Uri.parse(
      ApiConfig.baseUrl + ApiConfig.barangDetail(id),
    );

    final response = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(milliseconds: ApiConfig.receiveTimeout));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true) {
        return Product.fromJson(json['data'] as Map<String, dynamic>);
      }
    }
    throw Exception(
      'Gagal memuat detail barang (status ${response.statusCode})',
    );
  }

  // ── Fetch kategori (return model lengkap) ─────────────────────────────────
  /// Mengembalikan [List<Kategori>] dengan id, nama, slug, ikon, aktif.
  /// Digunakan oleh HomeScreen untuk menampilkan icon dinamis.
  Future<List<Kategori>> fetchKategori() async {
    final uri = Uri.parse(ApiConfig.baseUrl + ApiConfig.kategori);

    final response = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(milliseconds: ApiConfig.receiveTimeout));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true) {
        final List<dynamic> list = json['data'] as List<dynamic>;
        return list
            .map((e) => Kategori.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    throw Exception(
      'Gagal memuat kategori (status ${response.statusCode})',
    );
  }

  /// Shortcut: hanya nama kategori (backward compat jika dibutuhkan).
  Future<List<String>> fetchKategoriNames() async {
    final list = await fetchKategori();
    return list.map((k) => k.nama).toList();
  }
}