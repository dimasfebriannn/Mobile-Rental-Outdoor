// lib/models/weather_recommendation.dart
import 'product.dart';


/// Model untuk satu item barang yang direkomendasikan berdasarkan cuaca.
class WeatherBarang {
  final int id;
  final String nama;
  final String kategori;
  final double harga;
  final int stok;
  final String? foto;

  const WeatherBarang({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.stok,
    this.foto,
  });

  factory WeatherBarang.fromJson(Map<String, dynamic> json) {
    return WeatherBarang(
      id:       json['id'] as int,
      nama:     json['nama'] as String,
      kategori: json['kategori'] as String? ?? '',
      harga:    (json['harga'] as num?)?.toDouble() ?? 0.0,
      stok:     json['stok'] as int? ?? 0,
      foto:     Product.fixImageUrl(json['foto'] as String?),
    );
  }

  String get hargaFormatted {
    return 'Rp ${harga.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}/hari';
  }
}

/// Model data cuaca dari API.
class WeatherData {
  final String main;           // rain, clear, clouds, dst.
  final String deskripsi;
  final int suhu;
  final int suhuMin;
  final int suhuMax;
  final int kelembaban;
  final double angin;          // km/h
  final String iconUrl;
  final String level;          // danger | warning | good | neutral
  final String pesan;
  final String warna;          // red | amber | blue | green | gray

  const WeatherData({
    required this.main,
    required this.deskripsi,
    required this.suhu,
    required this.suhuMin,
    required this.suhuMax,
    required this.kelembaban,
    required this.angin,
    required this.iconUrl,
    required this.level,
    required this.pesan,
    required this.warna,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      main:       json['main'] as String? ?? 'default',
      deskripsi:  json['deskripsi'] as String? ?? '-',
      suhu:       json['suhu'] as int? ?? 0,
      suhuMin:    json['suhu_min'] as int? ?? 0,
      suhuMax:    json['suhu_max'] as int? ?? 0,
      kelembaban: json['kelembaban'] as int? ?? 0,
      angin:      (json['angin'] as num?)?.toDouble() ?? 0.0,
      iconUrl:    json['icon'] as String? ?? '',
      level:      json['level'] as String? ?? 'neutral',
      pesan:      json['pesan'] as String? ?? '',
      warna:      json['warna'] as String? ?? 'gray',
    );
  }
}

/// Response lengkap dari endpoint GET /api/cuaca
class WeatherResponse {
  final String lokasi;
  final WeatherData? cuaca;
  final List<WeatherBarang> rekomendasi;
  final String? message;

  const WeatherResponse({
    required this.lokasi,
    this.cuaca,
    required this.rekomendasi,
    this.message,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      lokasi:      json['lokasi'] as String? ?? '',
      cuaca:       json['cuaca'] != null
                   ? WeatherData.fromJson(json['cuaca'] as Map<String, dynamic>)
                   : null,
      rekomendasi: (json['rekomendasi'] as List<dynamic>?)
                   ?.map((e) => WeatherBarang.fromJson(e as Map<String, dynamic>))
                   .toList() ?? [],
      message:     json['message'] as String?,
    );
  }
}

/// Model lokasi yang dipilih user (hasil search Nominatim atau tap peta).
class LokasiPilihan {
  final String nama;
  final String namaPendek;
  final double lat;
  final double lon;

  const LokasiPilihan({
    required this.nama,
    required this.namaPendek,
    required this.lat,
    required this.lon,
  });
}