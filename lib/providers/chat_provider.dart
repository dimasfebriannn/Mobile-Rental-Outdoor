// lib/providers/chat_provider.dart

import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

enum ChatLoadState { idle, loading, error }

class ChatProvider extends ChangeNotifier {
  final ChatService _service = ChatService.instance;

  List<ChatMessage> _messages = [];
  ChatLoadState _state = ChatLoadState.idle;
  String? _errorMsg;
  bool _isTyping = false;

  List<ChatMessage> get messages => _messages;
  ChatLoadState get state => _state;
  String? get errorMsg => _errorMsg;
  bool get isTyping => _isTyping;
  bool get isEmpty => _messages.isEmpty;

  // ── Inisialisasi / muat riwayat ──────────────────────────────────────────

  Future<void> loadHistory() async {
    _state = ChatLoadState.loading;
    notifyListeners();
    try {
      _messages = await _service.fetchHistory();
      _state = ChatLoadState.idle;
    } catch (_) {
      _state = ChatLoadState.idle; // Gagal load history tidak fatal
    }
    notifyListeners();
  }

  // ── Kirim pesan ──────────────────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _isTyping) return;

    // Tambah pesan user ke UI langsung
    final userMsg = ChatMessage.fromUser(text.trim());
    _messages.add(userMsg);
    _isTyping = true;
    _errorMsg = null;
    notifyListeners();

    try {
      final response = await _service.sendMessage(
        message: text.trim(),
        history: _messages,
      );

      // Update pesan user menjadi 'sent'
      final idx = _messages.indexWhere((m) => m.id == userMsg.id);
      if (idx != -1) {
        _messages[idx] = userMsg.copyWith(status: MessageStatus.sent);
      }

      // Tambah reply AI
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.assistant,
        content: response.reply,
        needAdmin: response.needAdmin,
        whatsappUrl: response.whatsappUrl,
        fromFaq: response.fromFaq,
        status: MessageStatus.sent,
      ));
    } catch (e) {
      // Tandai pesan user sebagai error
      final idx = _messages.indexWhere((m) => m.id == userMsg.id);
      if (idx != -1) {
        _messages[idx] = userMsg.copyWith(status: MessageStatus.error);
      }
      _errorMsg = 'Gagal mengirim pesan. Periksa koneksi internet Anda.';
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  // ── Hapus riwayat ────────────────────────────────────────────────────────

  Future<void> clearChat() async {
    await _service.clearHistory();
    _messages = [];
    _errorMsg = null;
    notifyListeners();
  }

  // ── Retry pesan error ────────────────────────────────────────────────────

  Future<void> retryLast() async {
    final errorIdx = _messages.lastIndexWhere((m) => m.status == MessageStatus.error);
    if (errorIdx == -1) return;
    final errorMsg = _messages[errorIdx];
    _messages.removeAt(errorIdx);
    notifyListeners();
    await sendMessage(errorMsg.content);
  }
}