// lib/models/kategori.dart

class Kategori {
  final int id;
  final String nama;
  final String slug;
  final String? ikon;
  final bool aktif;

  const Kategori({
    required this.id,
    required this.nama,
    required this.slug,
    this.ikon,
    this.aktif = true,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id:    json['id'] as int,
      nama:  json['nama'].toString(),
      slug:  (json['slug'] ?? '').toString(),
      ikon:  json['ikon']?.toString(),
      aktif: (json['aktif'] ?? 1) == 1 || json['aktif'] == true,
    );
  }
}