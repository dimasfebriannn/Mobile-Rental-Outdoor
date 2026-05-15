// lib/services/cuaca_service.dart
//
// Service untuk:
//   1. Cari lokasi via Nominatim (lewat backend Laravel)
//   2. Reverse geocoding koordinat → nama lokasi
//   3. Ambil cuaca + rekomendasi barang dari backend
//
// Semua request melalui ApiService (Dio) agar otomatis pakai
// base URL dan token yang sudah dikonfigurasi.

import 'package:dio/dio.dart';
import '../models/weather_recommendation.dart';
import '../services/api_service.dart';

class CuacaService {
  CuacaService._();
  static final CuacaService instance = CuacaService._();

  // ── 1. Cari lokasi ─────────────────────────────────────────────────────────
  /// Mengembalikan list lokasi yang cocok dengan keyword.
  /// Melempar exception jika request gagal.
  Future<List<LokasiPilihan>> cariLokasi(String keyword) async {
    try {
      final response = await ApiService.instance.get(
        '/lokasi/cari',
        params: {'q': keyword},
      );

      final hasil = response.data['hasil'] as List<dynamic>? ?? [];
      return hasil.map((item) {
        final m = item as Map<String, dynamic>;
        return LokasiPilihan(
          nama:       m['nama'] as String? ?? '',
          namaPendek: m['nama_pendek'] as String? ?? '',
          lat:        (m['lat'] as num).toDouble(),
          lon:        (m['lon'] as num).toDouble(),
        );
      }).toList();
    } on DioException catch (e) {
      throw Exception('Gagal mencari lokasi: ${e.message}');
    }
  }

  // ── 2. Reverse geocoding ───────────────────────────────────────────────────
  /// Koordinat → nama lokasi. Berguna ketika user tap di peta.
  Future<LokasiPilihan?> reverseLokasi(double lat, double lon) async {
    try {
      final response = await ApiService.instance.get(
        '/lokasi/reverse',
        params: {'lat': lat, 'lon': lon},
      );

      final data = response.data as Map<String, dynamic>;
      return LokasiPilihan(
        nama:       data['nama'] as String? ?? 'Lokasi tidak diketahui',
        namaPendek: data['nama_pendek'] as String? ?? '',
        lat:        lat,
        lon:        lon,
      );
    } on DioException {
      return null;
    }
  }

  // ── 3. Cek cuaca + rekomendasi barang ─────────────────────────────────────
  /// [tanggalAmbil] format 'yyyy-MM-dd'
  Future<WeatherResponse> cekCuaca({
    required double lat,
    required double lon,
    required String namaLokasi,
    required String tanggalAmbil,
  }) async {
    try {
      final response = await ApiService.instance.get(
        '/cuaca',
        params: {
          'lat':           lat,
          'lon':           lon,
          'nama_lokasi':   namaLokasi,
          'tanggal_ambil': tanggalAmbil,
        },
      );

      return WeatherResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception('Gagal mengambil data cuaca: ${e.message}');
    }
  }
}