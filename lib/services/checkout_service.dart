// lib/services/checkout_service.dart
//
// Service untuk:
//  1. validasiIdentitas() → POST /api/checkout/validasi-identitas
//  2. submitCheckout()    → POST /api/checkout
//  3. getHistory()        → GET  /api/checkout/history
//  4. getDetail()         → GET  /api/checkout/{id}
//  5. reopenPayment()     → POST /api/checkout/{id}/reopen-payment
//  6. bayarDenda()        → POST /api/checkout/{id}/bayar-denda
//  7. getDetailLengkap()  → GET  /api/checkout/{id}/detail-lengkap
//
// FIXES:
//  1. validasiIdentitas: parse resp.data['data'] bukan resp.data
//     (sebelumnya selalu null karena membaca wrapper {success, data})
//  2. HasilValidasiIdentitas.fromJson: tangani kedua format nama field:
//     backend PHP → message / requiresManual / matchedGroups
//     format lama  → pesan  / perlu_manual   / sesuai_jenis

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

  // ── PERBAIKAN UTAMA ──────────────────────────────────────────────────────
  //
  // Backend PHP (OcrIdentitasService) mengembalikan field dengan nama:
  //   valid, confidence, message, requiresManual, matchedGroups, rawText
  //
  // Model lama mengharapkan:
  //   pesan, perlu_manual, sesuai_jenis  ← tidak ada di response PHP
  //
  // Solusi: baca kedua format (PHP + format lama) agar kompatibel.
  //
  factory HasilValidasiIdentitas.fromJson(Map<String, dynamic> json) {
    // 'valid' — ada di kedua format
    final valid = json['valid'] as bool? ?? false;

    // 'confidence' — sama di kedua format
    final confidence = (json['confidence'] as num?)?.toInt() ?? 0;

    // 'jenis_terdeteksi' — tidak dikirim PHP, aman null
    final jenisTerdeteksi = json['jenis_terdeteksi'] as String?;

    // 'sesuaiJenis' — PHP kirim matchedGroups (int), format lama kirim sesuai_jenis (bool)
    final matchedGroups = (json['matchedGroups'] as num?)?.toInt() ?? 0;
    final sesuaiJenis = json['sesuai_jenis'] as bool? ?? (matchedGroups > 0);

    // 'pesan' — PHP kirim 'message', format lama kirim 'pesan'
    final pesan = (json['message'] as String?)?.isNotEmpty == true
        ? json['message'] as String
        : (json['pesan'] as String? ?? '');

    // 'perluManual' — PHP kirim 'requiresManual', format lama kirim 'perlu_manual'
    final perluManual = json['requiresManual'] as bool?
        ?? json['perlu_manual'] as bool?
        ?? false;

    return HasilValidasiIdentitas(
      valid:           valid,
      confidence:      confidence,
      jenisTerdeteksi: jenisTerdeteksi,
      sesuaiJenis:     sesuaiJenis,
      pesan:           pesan,
      perluManual:     perluManual,
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

  Map<String, dynamic> toJson() => {'barang_id': barangId, 'qty': qty};
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
  final String? snapToken;
  final String? redirectUrl;
  final OcrResponse? ocr;

  const CheckoutResponse({
    required this.success,
    required this.message,
    this.transaksiId,
    this.nomorTransaksi,
    this.status,
    this.totalSewa,
    this.durasiHari,
    this.snapToken,
    this.redirectUrl,
    this.ocr,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return CheckoutResponse(
      success:        json['success'] as bool? ?? false,
      message:        json['message'] as String? ?? '',
      transaksiId:    data?['transaksi_id'] as int?,
      nomorTransaksi: data?['nomor_transaksi'] as String?,
      status:         data?['status'] as String?,
      totalSewa:      data?['total_sewa'] != null
                          ? double.tryParse(data!['total_sewa'].toString())
                          : null,
      durasiHari:     data?['durasi_hari'] as int?,
      snapToken:      data?['snap_token'] as String?,
      redirectUrl:    data?['redirect_url'] as String?,
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
    final matchedGroups = (json['matchedGroups'] as num?)?.toInt() ?? 0;
    return OcrResponse(
      status:          json['status'] as String? ?? '',
      confidence:      (json['confidence'] as num?)?.toInt() ?? 0,
      jenisTerdeteksi: json['jenis_terdeteksi'] as String?,
      sesuaiJenis:     json['sesuai_jenis'] as bool? ?? (matchedGroups > 0),
      pesan:           json['message'] as String?
                           ?? json['pesan'] as String?
                           ?? '',
      perluManual:     json['requiresManual'] as bool?
                           ?? json['perlu_manual'] as bool?
                           ?? false,
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

  // ── 1. Validasi identitas via AI ────────────────────────────────────────
  //
  // PERBAIKAN: `resp.data` berisi {success, data: {...}}.
  //   Sebelum: fromJson(resp.data)       → json['valid'] = null → invalid
  //   Sesudah: fromJson(resp.data['data']) → json['valid'] = true ✓
  //
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
        final body = resp.data as Map<String, dynamic>;

        // Ambil inner 'data' jika ada, fallback ke body langsung
        final payload = (body['data'] is Map<String, dynamic>)
            ? body['data'] as Map<String, dynamic>
            : body;

        return HasilValidasiIdentitas.fromJson(payload);
      }

      throw CheckoutException(_parseErrorMessage(resp.data));
    } on DioException catch (e) {
      throw CheckoutException(_parseDioError(e));
    }
  }

  // ── 2. Submit checkout ──────────────────────────────────────────────────
  Future<CheckoutResponse> submitCheckout(CheckoutRequest req) async {
    try {
      String fmt(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';

      final Map<String, dynamic> fields = {
        'tanggal_ambil':     fmt(req.tanggalAmbil),
        'tanggal_kembali':   fmt(req.tanggalKembali),
        'metode_pembayaran': req.metodePembayaran,
        'jenis_identitas':   req.jenisIdentitas,
        'foto_identitas':    await MultipartFile.fromFile(
          req.fotoIdentitas.path,
          filename: 'identitas.jpg',
        ),
      };

      for (int i = 0; i < req.items.length; i++) {
        fields['items[$i][barang_id]'] = req.items[i].barangId;
        fields['items[$i][qty]']       = req.items[i].qty;
      }

      final formData = FormData.fromMap(fields);
      final resp     = await _api.postMultipart(ApiConfig.checkout, formData);

      if (resp.statusCode == 201) {
        return CheckoutResponse.fromJson(resp.data as Map<String, dynamic>);
      }

      throw CheckoutException(_parseErrorMessage(resp.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
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

  // ── 5. Reopen Payment (Midtrans) ─────────────────────────────────────────
  Future<CheckoutResponse> reopenPayment(int transaksiId) async {
    try {
      final resp = await _api.post(
        ApiConfig.checkoutReopenPayment(transaksiId),
        {},
      );
      final data      = resp.data as Map<String, dynamic>;
      final snapToken = data['snap_token'] as String?;
      return CheckoutResponse(
        success:     data['success'] as bool? ?? false,
        message:     data['message'] as String? ?? '',
        snapToken:   snapToken,
        redirectUrl: snapToken != null
            ? 'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken'
            : null,
      );
    } on DioException catch (e) {
      throw CheckoutException(_parseDioError(e));
    }
  }

  // ── 6. Bayar Denda ─────────────────────────────────────────────────────
  Future<CheckoutResponse> bayarDenda(int transaksiId) async {
    try {
      final resp = await _api.post(
        ApiConfig.checkoutBayarDenda(transaksiId),
        {},
      );
      final data      = resp.data as Map<String, dynamic>;
      final snapToken = data['snap_token'] as String?;
      return CheckoutResponse(
        success:     data['success'] as bool? ?? false,
        message:     data['message'] as String? ?? '',
        snapToken:   snapToken,
        redirectUrl: snapToken != null
            ? 'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken'
            : null,
      );
    } on DioException catch (e) {
      throw CheckoutException(_parseDioError(e));
    }
  }

  // ── 7. Detail Lengkap ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> getDetailLengkap(int transaksiId) async {
    try {
      final resp = await _api.get(
        ApiConfig.checkoutDetailLengkap(transaksiId),
      );
      return resp.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw CheckoutException(_parseDioError(e));
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────
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