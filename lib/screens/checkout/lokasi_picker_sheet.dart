// lib/screens/checkout/lokasi_picker_sheet.dart
//
// Bottom sheet untuk memilih lokasi tujuan camping:
//   - Search bar → hasil dari Nominatim
//   - Peta (flutter_map + OpenStreetMap tile) → tap untuk pilih koordinat
//
// Dependency yang dibutuhkan di pubspec.yaml:
//   flutter_map: ^7.0.0
//   latlong2: ^0.9.0
//
// Usage:
//   final lokasi = await showLokasiPickerSheet(context);
//   if (lokasi != null) { ... }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/weather_recommendation.dart';
import '../../services/cuaca_service.dart';

Future<LokasiPilihan?> showLokasiPickerSheet(BuildContext context) {
  return showModalBottomSheet<LokasiPilihan>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _LokasiPickerSheet(),
  );
}

class _LokasiPickerSheet extends StatefulWidget {
  const _LokasiPickerSheet();

  @override
  State<_LokasiPickerSheet> createState() => _LokasiPickerSheetState();
}

class _LokasiPickerSheetState extends State<_LokasiPickerSheet> {
  // ── Warna (konsisten dengan checkout_screen) ────────────────────────────
  final Color darkBrown   = const Color(0xFF3E2723);
  final Color goldenYellow = const Color(0xFFE5A93D);
  final Color creamBg     = const Color(0xFFF5EFE6);

  // ── State ───────────────────────────────────────────────────────────────
  final _searchCtrl = TextEditingController();
  final _mapCtrl    = MapController();

  List<LokasiPilihan> _results    = [];
  bool _isSearching               = false;
  bool _isReversingGeocode        = false;
  LatLng _center                  = const LatLng(-7.9798, 112.6304); // Default: Malang
  LatLng? _pinLatLng;             // Pin yang ditaruh user di peta
  String? _pinNama;

  Timer? _debounce;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Search dengan debounce 600ms ────────────────────────────────────────
  void _onSearchChanged(String val) {
    _debounce?.cancel();
    if (val.trim().length < 3) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 600), () => _doSearch(val.trim()));
  }

  Future<void> _doSearch(String keyword) async {
    setState(() { _isSearching = true; _results = []; });
    try {
      final hasil = await CuacaService.instance.cariLokasi(keyword);
      if (mounted) setState(() => _results = hasil);
    } catch (_) {
      // silently fail, tetap tampilkan peta
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  // ── Tap lokasi dari hasil search ────────────────────────────────────────
  void _pilihDariSearch(LokasiPilihan lokasi) {
    setState(() {
      _pinLatLng  = LatLng(lokasi.lat, lokasi.lon);
      _pinNama    = lokasi.namaPendek.isNotEmpty ? lokasi.namaPendek : lokasi.nama;
      _center     = _pinLatLng!;
      _results    = [];
      _searchCtrl.text = lokasi.namaPendek.isNotEmpty ? lokasi.namaPendek : lokasi.nama;
    });
    _mapCtrl.move(_center, 13.0);
  }

  // ── Tap di peta → reverse geocode ───────────────────────────────────────
  Future<void> _onMapTap(TapPosition _, LatLng latlng) async {
    setState(() {
      _pinLatLng          = latlng;
      _pinNama            = null;
      _isReversingGeocode = true;
    });

    final hasil = await CuacaService.instance.reverseLokasi(latlng.latitude, latlng.longitude);

    if (mounted) {
      setState(() {
        _pinNama            = hasil?.namaPendek.isNotEmpty == true
                              ? hasil!.namaPendek
                              : hasil?.nama ?? 'Lokasi dipilih';
        _isReversingGeocode = false;
        _searchCtrl.text    = _pinNama ?? '';
      });
    }
  }

  // ── Konfirmasi pilihan ───────────────────────────────────────────────────
  void _konfirmasi() {
    if (_pinLatLng == null) return;
    Navigator.pop(
      context,
      LokasiPilihan(
        nama:       _pinNama ?? 'Lokasi pilihan',
        namaPendek: _pinNama ?? 'Lokasi pilihan',
        lat:        _pinLatLng!.latitude,
        lon:        _pinLatLng!.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      height: screenH * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // ── Handle ────────────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: darkBrown.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Header ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.place_rounded, color: goldenYellow, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Pilih Lokasi Tujuan',
                  style: TextStyle(
                    color: darkBrown,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: darkBrown.withOpacity(0.4), size: 20),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Search bar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: creamBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: darkBrown.withOpacity(0.08)),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                style: TextStyle(color: darkBrown, fontSize: 13, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Cari lokasi camping (Gunung Semeru, Ranu Kumbolo...)',
                  hintStyle: TextStyle(color: darkBrown.withOpacity(0.35), fontSize: 12),
                  prefixIcon: Icon(Icons.search, color: goldenYellow, size: 20),
                  suffixIcon: _isSearching
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: goldenYellow,
                            ),
                          ),
                        )
                      : _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, size: 16, color: darkBrown.withOpacity(0.4)),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _results = []);
                              },
                            )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                ),
              ),
            ),
          ),

          // ── Hasil pencarian ───────────────────────────────────────────────
          if (_results.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: darkBrown.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: darkBrown.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: _results.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: darkBrown.withOpacity(0.05),
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (_, i) {
                  final r = _results[i];
                  return InkWell(
                    onTap: () => _pilihDariSearch(r),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: goldenYellow, size: 16),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.namaPendek.isNotEmpty ? r.namaPendek : r.nama,
                                  style: TextStyle(
                                    color: darkBrown,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (r.nama != r.namaPendek && r.namaPendek.isNotEmpty)
                                  Text(
                                    r.nama,
                                    style: TextStyle(
                                      color: darkBrown.withOpacity(0.4),
                                      fontSize: 10,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 8),

          // ── Peta ──────────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: FlutterMap(
                  mapController: _mapCtrl,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom:   10.0,
                    onTap:         _onMapTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.majelis.rental',
                    ),
                    if (_pinLatLng != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _pinLatLng!,
                            width: 40,
                            height: 50,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: goldenYellow,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: goldenYellow.withOpacity(0.4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.terrain_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                Container(
                                  width: 2,
                                  height: 12,
                                  color: goldenYellow,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Info pin + tombol konfirmasi ───────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              16, 0, 16,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Column(
              children: [
                if (_pinLatLng != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: goldenYellow.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: goldenYellow.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: goldenYellow, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _isReversingGeocode
                              ? Text(
                                  'Mengidentifikasi lokasi...',
                                  style: TextStyle(
                                    color: darkBrown.withOpacity(0.5),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : Text(
                                  _pinNama ?? 'Lokasi dipilih',
                                  style: TextStyle(
                                    color: darkBrown,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Ketuk lokasi di peta atau cari nama destinasi',
                      style: TextStyle(
                        color: darkBrown.withOpacity(0.35),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (_pinLatLng != null && !_isReversingGeocode)
                        ? _konfirmasi
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBrown,
                      disabledBackgroundColor: darkBrown.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'GUNAKAN LOKASI INI',
                      style: TextStyle(
                        color: _pinLatLng != null ? Colors.white : darkBrown.withOpacity(0.3),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}