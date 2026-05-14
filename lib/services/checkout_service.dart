// lib/services/checkout_service.dart
//
// Service untuk:
//  1. validasiIdentitas() → POST /api/checkout/validasi-identitas
//  2. submitCheckout()    → POST /api/checkout
//  3. getHistory()        → GET  /api/checkout/history
//  4. getDetail()         → GET  /api/checkout/{id}

import 'dart:io';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model hasil validasi identitas dari AI
// ─────────────────────────────────────────────────────────────────────────────
class HasilValidasiIdentitas {
  final bool valid;
  final int confidence;
  final String? jenisTerdeteksi;
  final bool sesuaiJenis;
  final String pesan;
  final bool perluManual;

  const HasilValidasiIdentitas({
    required this.valid,
    required this.confidence,
    this.jenisTerdeteksi,
    required this.sesuaiJenis,
    required this.pesan,
    required this.perluManual,
  });

  factory HasilValidasiIdentitas.fromJson(Map<String, dynamic> json) {
    return HasilValidasiIdentitas(
      valid:           json['valid']            as bool?   ?? false,
      confidence:      json['confidence']       as int?    ?? 0,
      jenisTerdeteksi: json['jenis_terdeteksi'] as String?,
      sesuaiJenis:     json['sesuai_jenis']     as bool?   ?? false,
      pesan:           json['pesan']            as String? ?? '',
      perluManual:     json['perlu_manual']     as bool?   ?? false,
    );
  }

  /// True jika foto boleh lanjut ke proses checkout
  bool get bisaLanjut => valid || perluManual;

  /// Label status untuk ditampilkan di UI
  String get statusLabel {
    if (valid && !perluManual) return 'Terverifikasi';
    if (perluManual) return 'Perlu Verifikasi Manual';
    return 'Tidak Valid';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Model item checkout
// ─────────────────────────────────────────────────────────────────────────────
class CheckoutItem {
  final int barangId;
  final int qty;

  const CheckoutItem({required this.barangId, required this.qty});

  Map<String, dynamic> toJson() => {
    'barang_id': barangId,
    'qty':       qty,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Model request checkout
// ─────────────────────────────────────────────────────────────────────────────
class CheckoutRequest {
  final DateTime tanggalAmbil;
  final DateTime tanggalKembali;
  final String metodePembayaran; // 'midtrans' | 'tunai'
  final String jenisIdentitas;   // 'KTP' | 'SIM' | 'PELAJAR'
  final File fotoIdentitas;
  final List<CheckoutItem> items;

  const CheckoutRequest({
    required this.tanggalAmbil,
    required this.tanggalKembali,
    required this.metodePembayaran,
    required this.jenisIdentitas,
    required this.fotoIdentitas,
    required this.items,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Model response checkout
// ─────────────────────────────────────────────────────────────────────────────
class CheckoutResponse {
  final bool success;
  final String message;
  final int? transaksiId;
  final String? nomorTransaksi;
  final String? status;
  final double? totalSewa;
  final int? durasiHari;
  final OcrResponse? ocr;

  const CheckoutResponse({
    required this.success,
    required this.message,
    this.transaksiId,
    this.nomorTransaksi,
    this.status,
    this.totalSewa,
    this.durasiHari,
    this.ocr,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return CheckoutResponse(
      success:        json['success']          as bool?   ?? false,
      message:        json['message']          as String? ?? '',
      transaksiId:    data?['transaksi_id']    as int?,
      nomorTransaksi: data?['nomor_transaksi'] as String?,
      status:         data?['status']          as String?,
      totalSewa:      (data?['total_sewa']     as num?)?.toDouble(),
      durasiHari:     data?['durasi_hari']     as int?,
      ocr: data?['ocr'] != null
          ? OcrResponse.fromJson(data!['ocr'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Model detail OCR dari response checkout
// ─────────────────────────────────────────────────────────────────────────────
class OcrResponse {
  final String status;
  final int confidence;
  final String? jenisTerdeteksi;
  final bool sesuaiJenis;
  final String pesan;
  final bool perluManual;

  const OcrResponse({
    required this.status,
    required this.confidence,
    this.jenisTerdeteksi,
    required this.sesuaiJenis,
    required this.pesan,
    required this.perluManual,
  });

  factory OcrResponse.fromJson(Map<String, dynamic> json) {
    return OcrResponse(
      status:          json['status']            as String? ?? '',
      confidence:      json['confidence']        as int?    ?? 0,
      jenisTerdeteksi: json['jenis_terdeteksi']  as String?,
      sesuaiJenis:     json['sesuai_jenis']      as bool?   ?? false,
      pesan:           json['pesan']             as String? ?? '',
      perluManual:     json['perlu_manual']      as bool?   ?? false,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CheckoutService
// ─────────────────────────────────────────────────────────────────────────────
class CheckoutService {
  CheckoutService._();
  static final CheckoutService instance = CheckoutService._();

  final _api = ApiService.instance;

  // ── 1. Validasi identitas via AI (Groq LLaMA-4 Scout) ──────────────────
  /// Kirim foto ke endpoint /api/checkout/validasi-identitas.
  /// Lempar [CheckoutException] jika request gagal.
  Future<HasilValidasiIdentitas> validasiIdentitas({
    required File foto,
    required String jenisIdentitas,
  }) async {
    try {
      final formData = FormData.fromMap({
        'foto_identitas': await MultipartFile.fromFile(
          foto.path,
          filename: 'identitas.jpg',
        ),
        'jenis_identitas': jenisIdentitas,
      });

      final resp = await _api.postMultipart(
        ApiConfig.checkoutValidasiIdentitas,
        formData,
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return HasilValidasiIdentitas.fromJson(
          resp.data as Map<String, dynamic>,
        );
      }

      throw CheckoutException(_parseErrorMessage(resp.data));
    } on DioException catch (e) {
      throw CheckoutException(_parseDioError(e));
    }
  }

  // ── 2. Submit checkout ──────────────────────────────────────────────────
  /// Kirim seluruh data checkout ke /api/checkout.
  /// Validasi OCR dijalankan ulang di server; client tidak perlu
  /// pra-validasi terpisah (tapi boleh melakukannya untuk UX yang lebih baik).
  Future<CheckoutResponse> submitCheckout(CheckoutRequest req) async {
    try {
      String fmt(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';

      // Susun form-data items[] secara manual agar Dio mengirim array benar
      final Map<String, dynamic> fields = {
        'tanggal_ambil':     fmt(req.tanggalAmbil),
        'tanggal_kembali':   fmt(req.tanggalKembali),
        'metode_pembayaran': req.metodePembayaran,
        'jenis_identitas':   req.jenisIdentitas,
        'foto_identitas': await MultipartFile.fromFile(
          req.fotoIdentitas.path,
          filename: 'identitas.jpg',
        ),
      };

      for (int i = 0; i < req.items.length; i++) {
        fields['items[$i][barang_id]'] = req.items[i].barangId;
        fields['items[$i][qty]']       = req.items[i].qty;
      }

      final formData = FormData.fromMap(fields);

      final resp = await _api.postMultipart(ApiConfig.checkout, formData);

      if (resp.statusCode == 201) {
        return CheckoutResponse.fromJson(resp.data as Map<String, dynamic>);
      }

      throw CheckoutException(_parseErrorMessage(resp.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        // Validasi gagal — termasuk identitas ditolak AI
        throw CheckoutException(_parseErrorMessage(e.response?.data));
      }
      throw CheckoutException(_parseDioError(e));
    }
  }

  // ── 3. Riwayat transaksi ────────────────────────────────────────────────
  Future<List<dynamic>> getHistory() async {
    try {
      final resp = await _api.get(ApiConfig.checkoutHistory);
      return (resp.data['data']?['data'] ?? []) as List<dynamic>;
    } on DioException catch (e) {
      throw CheckoutException(_parseDioError(e));
    }
  }

  // ── 4. Detail transaksi ─────────────────────────────────────────────────
  Future<Map<String, dynamic>> getDetail(int id) async {
    try {
      final resp = await _api.get(ApiConfig.checkoutDetail(id));
      return resp.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw CheckoutException(_parseDioError(e));
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────
  String _parseErrorMessage(dynamic data) {
    if (data is Map) {
      if (data['message'] != null) return data['message'].toString();
      if (data['errors'] != null) {
        final errors = data['errors'] as Map;
        return errors.values.first is List
            ? (errors.values.first as List).first.toString()
            : errors.values.first.toString();
      }
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  String _parseDioError(DioException e) {
    if (e.response != null) return _parseErrorMessage(e.response!.data);
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi timeout. Periksa jaringan Anda.';
    }
    return 'Gagal terhubung ke server.';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Exception
// ─────────────────────────────────────────────────────────────────────────────
class CheckoutException implements Exception {
  final String message;
  const CheckoutException(this.message);

  @override
  String toString() => message;
}