// lib/models/recommendation.dart

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
    return RecommendationResult(
      ai:              AiAnalysis.fromJson(json['ai'] as Map<String, dynamic>? ?? {}),
      recommendations: (json['recommendations'] as List<dynamic>? ?? [])
          .map((e) => RecommendedBarang.fromJson(e as Map<String, dynamic>))
          .toList(),
      isFallback: json['is_fallback'] as bool? ?? false,
      message:    json['message'] as String? ?? '',
      total:      json['total'] as int? ?? 0,
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

  /// Confidence dalam persen (0–100)
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

  factory RecommendedBarang.fromJson(Map<String, dynamic> json) {
    return RecommendedBarang(
      id:          json['id'] as int,
      nama:        json['nama'] as String,
      deskripsi:   json['deskripsi'] as String?,
      spesifikasi: json['spesifikasi'] as String?,
      hargaPerHari: (json['harga_per_hari'] as num).toDouble(),
      stok:        json['stok'] as int,
      status:      json['status'] as String,
      fotoUrl:     json['foto_url'] as String?,
      semuaFoto:   List<String>.from(json['semua_foto'] ?? []),
      kategori: json['kategori'] != null
          ? BarangKategori.fromJson(json['kategori'])
          : null,
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => BarangTag.fromJson(e))
          .toList(),
      matchScore:  json['match_score'] as int? ?? 0,
      matchedTags: List<String>.from(json['matched_tags'] ?? []),
    );
  }

  String get hargaFormatted {
    final formatted = hargaPerHari.toStringAsFixed(0).replaceAllMapped(
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
      BarangKategori(id: json['id'], nama: json['nama']);
}

class BarangTag {
  final String slug;
  final String label;

  const BarangTag({required this.slug, required this.label});

  factory BarangTag.fromJson(Map<String, dynamic> json) =>
      BarangTag(slug: json['slug'], label: json['label']);
}