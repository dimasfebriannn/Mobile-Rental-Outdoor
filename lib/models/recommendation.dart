// lib/models/recommendation.dart

import '../config/api_config.dart';

class RecommendationResult {
  final AiAnalysis ai;
  final List<RecommendedBarang> recommendations;
  final bool isFallback;
  final String message;
  final int total;

  const RecommendationResult({
    required this.ai,
    required this.recommendations,
    required this.isFallback,
    required this.message,
    required this.total,
  });

  factory RecommendationResult.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> body =
        (json['data'] is Map<String, dynamic>)
            ? json['data'] as Map<String, dynamic>
            : json;

    return RecommendationResult(
      ai: AiAnalysis.fromJson(
          body['ai'] as Map<String, dynamic>? ?? {}),
      recommendations: (body['recommendations'] as List<dynamic>? ?? [])
          .map((e) => RecommendedBarang.fromJson(e as Map<String, dynamic>))
          .toList(),
      isFallback: body['is_fallback'] as bool? ?? false,
      message:    body['message'] as String? ?? '',
      total:      body['total'] as int? ?? 0,
    );
  }
}

class AiAnalysis {
  final List<String> detectedItems;
  final List<String> tags;
  final double confidence;
  final String description;

  const AiAnalysis({
    required this.detectedItems,
    required this.tags,
    required this.confidence,
    required this.description,
  });

  factory AiAnalysis.fromJson(Map<String, dynamic> json) {
    return AiAnalysis(
      detectedItems: List<String>.from(json['detected_items'] ?? []),
      tags:          List<String>.from(json['tags'] ?? []),
      confidence:    (json['confidence'] as num?)?.toDouble() ?? 0.0,
      description:   json['description'] as String? ?? '',
    );
  }

  int get confidencePercent => (confidence * 100).round();
  bool get hasDetection => detectedItems.isNotEmpty || tags.isNotEmpty;
}

class RecommendedBarang {
  final int id;
  final String nama;
  final String? deskripsi;
  final String? spesifikasi;
  final double hargaPerHari;
  final int stok;
  final String status;
  final String? fotoUrl;
  final List<String> semuaFoto;
  final BarangKategori? kategori;
  final List<BarangTag> tags;
  final int matchScore;
  final List<String> matchedTags;

  const RecommendedBarang({
    required this.id,
    required this.nama,
    this.deskripsi,
    this.spesifikasi,
    required this.hargaPerHari,
    required this.stok,
    required this.status,
    this.fotoUrl,
    required this.semuaFoto,
    this.kategori,
    required this.tags,
    required this.matchScore,
    required this.matchedTags,
  });

  // ── URL fixer ──────────────────────────────────────────────────────────────
  // Mengganti semua domain lokal/development dengan ngrok/produksi dari
  // ApiConfig. Menangkap:
  //   • http://localhost:PORT
  //   • http://127.0.0.1:PORT
  //   • http://majelis-rental.test  ← domain Laravel Herd/Valet lokal
  //   • domain .test lainnya
  static String? _fixImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;

    // Base URL aktif: https://xxx.ngrok-free.app (tanpa /api)
    final appBase = ApiConfig.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');

    // Ganti semua varian URL lokal dengan appBase
    return raw.replaceFirstMapped(
      RegExp(
        r'https?://'
        r'(localhost|127\.0\.0\.1|10\.0\.2\.2'   // emulator & loopback
        r'|[a-zA-Z0-9\-]+\.test'                  // *.test (Herd/Valet)
        r'|[a-zA-Z0-9\-]+\.local'                 // *.local (Homestead)
        r')(:\d+)?',                               // port opsional
      ),
      (_) => appBase,
    );
  }

  static List<String> _fixImageList(List<dynamic> raw) {
    return raw
        .map((e) => _fixImageUrl(e.toString()))
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toList();
  }

  factory RecommendedBarang.fromJson(Map<String, dynamic> json) {
    return RecommendedBarang(
      id:           json['id'] as int,
      nama:         json['nama'] as String,
      deskripsi:    json['deskripsi'] as String?,
      spesifikasi:  json['spesifikasi'] as String?,
      hargaPerHari: (json['harga_per_hari'] as num).toDouble(),
      stok:         json['stok'] as int,
      status:       json['status'] as String,
      fotoUrl:      _fixImageUrl(json['foto_url'] as String?),
      semuaFoto:    _fixImageList(json['semua_foto'] as List<dynamic>? ?? []),
      kategori: json['kategori'] != null
          ? BarangKategori.fromJson(
              json['kategori'] as Map<String, dynamic>)
          : null,
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => BarangTag.fromJson(e as Map<String, dynamic>))
          .toList(),
      matchScore:  json['match_score'] as int? ?? 0,
      matchedTags: List<String>.from(json['matched_tags'] ?? []),
    );
  }

  String get hargaFormatted {
    final formatted = hargaPerHari
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp $formatted/hari';
  }
}

class BarangKategori {
  final int id;
  final String nama;

  const BarangKategori({required this.id, required this.nama});

  factory BarangKategori.fromJson(Map<String, dynamic> json) =>
      BarangKategori(id: json['id'] as int, nama: json['nama'] as String);
}

class BarangTag {
  final String slug;
  final String label;

  const BarangTag({required this.slug, required this.label});

  factory BarangTag.fromJson(Map<String, dynamic> json) =>
      BarangTag(slug: json['slug'] as String, label: json['label'] as String);
}