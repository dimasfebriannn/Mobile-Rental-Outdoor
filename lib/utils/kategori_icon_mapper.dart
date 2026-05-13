// lib/utils/kategori_icon_mapper.dart
//
// Memetakan field `ikon` dari tabel kategori_barang (DB) + nama kategori
// ke Flutter IconData. Fleksibel: jika admin menambah kategori baru,
// fallback matching berbasis keyword nama kategori akan otomatis bekerja.

import 'package:flutter/material.dart';

class KategoriIconMapper {
  KategoriIconMapper._();

  // ── Palet warna siklus untuk kategori dinamis ─────────────────────────────
  static const List<Color> _palette = [
    Color(0xFF5D4037),
    Color(0xFF6D4C41),
    Color(0xFF795548),
    Color(0xFF8D6E63),
    Color(0xFF4E342E),
    Color(0xFF3E2723),
    Color(0xFF607D8B),
    Color(0xFF546E7A),
    Color(0xFF455A64),
    Color(0xFF37474F),
  ];

  /// Kembalikan warna berdasarkan urutan index (siklus otomatis).
  static Color getColor(int index) => _palette[index % _palette.length];

  // ── Mapping field `ikon` dari DB ──────────────────────────────────────────
  // Nilai ini sesuai dengan kolom `ikon` di tabel `kategori_barang`.
  static const Map<String, IconData> _dbIconMap = {
    // Apparel / pakaian / sepatu
    'shoe':            Icons.hiking_rounded,
    'shoe-print':      Icons.hiking_rounded,
    'footwear':        Icons.hiking_rounded,
    'apparel':         Icons.checkroom_rounded,
    'clothing':        Icons.checkroom_rounded,
    'jacket':          Icons.checkroom_rounded,

    // Camping
    'tent':            Icons.holiday_village_rounded,
    'camping':         Icons.holiday_village_rounded,
    'camp':            Icons.holiday_village_rounded,

    // Hiking / carrier / tas
    'backpack':        Icons.backpack_rounded,
    'bag':             Icons.backpack_rounded,
    'carrier':         Icons.backpack_rounded,
    'hiking':          Icons.terrain_rounded,

    // Tidur / sleeping
    'bed':             Icons.hotel_rounded,
    'bed-flat':        Icons.hotel_rounded,
    'sleeping':        Icons.hotel_rounded,
    'matras':          Icons.hotel_rounded,

    // Masak / cooking
    'stove':           Icons.outdoor_grill_rounded,
    'cooking':         Icons.outdoor_grill_rounded,
    'kitchen':         Icons.outdoor_grill_rounded,
    'fire':            Icons.outdoor_grill_rounded,
    'cook':            Icons.outdoor_grill_rounded,

    // Lampu / pencahayaan
    'lamp':            Icons.flashlight_on_rounded,
    'light':           Icons.flashlight_on_rounded,
    'flashlight':      Icons.flashlight_on_rounded,
    'headlamp':        Icons.flashlight_on_rounded,

    // Aksesoris / tools
    'tool':            Icons.build_rounded,
    'tools':           Icons.build_rounded,
    'wrench':          Icons.build_rounded,
    'accessories':     Icons.watch_rounded,
    'accessory':       Icons.watch_rounded,
    'watch':           Icons.watch_rounded,

    // Air / hidrasi
    'water':           Icons.water_drop_rounded,
    'bottle':          Icons.water_drop_rounded,
    'hydration':       Icons.water_drop_rounded,

    // Navigasi / peta
    'map':             Icons.map_rounded,
    'compass':         Icons.explore_rounded,
    'navigation':      Icons.explore_rounded,

    // Lainnya
    'rope':            Icons.architecture_rounded,
    'safety':          Icons.shield_rounded,
    'first-aid':       Icons.medical_services_rounded,
    'medical':         Icons.medical_services_rounded,
    'camera':          Icons.camera_alt_rounded,
    'electronics':     Icons.battery_charging_full_rounded,
  };

  // ── Keyword fallback dari nama kategori ───────────────────────────────────
  static const List<MapEntry<String, IconData>> _nameKeywords = [
    // Tenda / camping
    MapEntry('tenda',    Icons.holiday_village_rounded),
    MapEntry('tent',     Icons.holiday_village_rounded),
    MapEntry('camp',     Icons.holiday_village_rounded),
    MapEntry('shelter',  Icons.holiday_village_rounded),
    MapEntry('bivak',    Icons.holiday_village_rounded),

    // Carrier / tas / backpack
    MapEntry('carrier',  Icons.backpack_rounded),
    MapEntry('ransel',   Icons.backpack_rounded),
    MapEntry('backpack', Icons.backpack_rounded),
    MapEntry('bag',      Icons.backpack_rounded),
    MapEntry('tas',      Icons.backpack_rounded),

    // Sleeping / tidur / matras
    MapEntry('sleeping', Icons.hotel_rounded),
    MapEntry('sleep',    Icons.hotel_rounded),
    MapEntry('matras',   Icons.hotel_rounded),
    MapEntry('sleeping bag', Icons.hotel_rounded),

    // Lampu / cahaya
    MapEntry('lampu',    Icons.flashlight_on_rounded),
    MapEntry('lamp',     Icons.flashlight_on_rounded),
    MapEntry('light',    Icons.flashlight_on_rounded),
    MapEntry('senter',   Icons.flashlight_on_rounded),
    MapEntry('headlamp', Icons.flashlight_on_rounded),

    // Masak / cooking
    MapEntry('masak',    Icons.outdoor_grill_rounded),
    MapEntry('cooking',  Icons.outdoor_grill_rounded),
    MapEntry('cook',     Icons.outdoor_grill_rounded),
    MapEntry('dapur',    Icons.outdoor_grill_rounded),
    MapEntry('kompor',   Icons.outdoor_grill_rounded),
    MapEntry('kitchen',  Icons.outdoor_grill_rounded),

    // Pakaian / apparel
    MapEntry('apparel',  Icons.checkroom_rounded),
    MapEntry('pakaian',  Icons.checkroom_rounded),
    MapEntry('baju',     Icons.checkroom_rounded),
    MapEntry('jaket',    Icons.checkroom_rounded),
    MapEntry('clothing', Icons.checkroom_rounded),
    MapEntry('sepatu',   Icons.hiking_rounded),
    MapEntry('shoe',     Icons.hiking_rounded),
    MapEntry('hiking gear', Icons.terrain_rounded),

    // Air / hidrasi
    MapEntry('air',      Icons.water_drop_rounded),
    MapEntry('water',    Icons.water_drop_rounded),
    MapEntry('botol',    Icons.water_drop_rounded),
    MapEntry('hydra',    Icons.water_drop_rounded),

    // Alat navigasi
    MapEntry('navigasi', Icons.explore_rounded),
    MapEntry('compass',  Icons.explore_rounded),
    MapEntry('peta',     Icons.map_rounded),
    MapEntry('map',      Icons.map_rounded),

    // Aksesoris
    MapEntry('aksesori', Icons.watch_rounded),
    MapEntry('accessories', Icons.watch_rounded),
    MapEntry('accessory', Icons.watch_rounded),

    // Keselamatan / safety
    MapEntry('safety',   Icons.shield_rounded),
    MapEntry('keselamatan', Icons.shield_rounded),
    MapEntry('p3k',      Icons.medical_services_rounded),
    MapEntry('medis',    Icons.medical_services_rounded),
    MapEntry('medical',  Icons.medical_services_rounded),

    // Elektronik / kamera
    MapEntry('elektronik', Icons.battery_charging_full_rounded),
    MapEntry('electronic', Icons.battery_charging_full_rounded),
    MapEntry('kamera',   Icons.camera_alt_rounded),
    MapEntry('camera',   Icons.camera_alt_rounded),

    // Tali / panjat
    MapEntry('tali',     Icons.architecture_rounded),
    MapEntry('rope',     Icons.architecture_rounded),
    MapEntry('panjat',   Icons.fitness_center_rounded),
    MapEntry('climbing', Icons.fitness_center_rounded),
  ];

  /// Ambil IconData yang paling relevan.
  ///
  /// Prioritas:
  /// 1. Exact match `ikon` field dari DB
  /// 2. Keyword match dalam `ikon` field
  /// 3. Keyword match dalam `nama` kategori
  /// 4. Default fallback
  static IconData getIcon({required String? dbIcon, required String nama}) {
    // 1. Exact match dari field ikon di DB
    if (dbIcon != null && dbIcon.isNotEmpty) {
      final exact = _dbIconMap[dbIcon.toLowerCase().trim()];
      if (exact != null) return exact;

      // 2. Keyword di dalam string ikon DB
      final lowerIcon = dbIcon.toLowerCase();
      for (final entry in _dbIconMap.entries) {
        if (lowerIcon.contains(entry.key)) return entry.value;
      }
    }

    // 3. Keyword di nama kategori
    final lowerName = nama.toLowerCase();
    for (final entry in _nameKeywords) {
      if (lowerName.contains(entry.key)) return entry.value;
    }

    // 4. Fallback
    return Icons.category_rounded;
  }
}