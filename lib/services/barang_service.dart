// lib/services/barang_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Service untuk komunikasi dengan Laravel API endpoint /barang & /kategori.
// Menggunakan http package (sudah ada di pubspec jika pakai Dio, sesuaikan).
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/product.dart';

class BarangService {
  BarangService._();
  static final BarangService instance = BarangService._();

  // ── Headers default ───────────────────────────────────────────────────────
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // Jika pakai ngrok, tambahkan header ini agar tidak kena interstitial:
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
        .timeout(
          const Duration(milliseconds: ApiConfig.receiveTimeout),
        );

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

  // ── Fetch kategori ────────────────────────────────────────────────────────
  Future<List<String>> fetchKategori() async {
    final uri = Uri.parse(ApiConfig.baseUrl + ApiConfig.kategori);

    final response = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(milliseconds: ApiConfig.receiveTimeout));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true) {
        final List<dynamic> list = json['data'] as List<dynamic>;
        // Kembalikan daftar nama kategori saja
        return list
            .map((e) => (e as Map<String, dynamic>)['nama'].toString())
            .toList();
      }
    }
    throw Exception(
      'Gagal memuat kategori (status ${response.statusCode})',
    );
  }
}