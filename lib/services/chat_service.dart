// lib/services/chat_service.dart

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../config/api_config.dart';
import '../models/chat_message.dart';
import 'api_service.dart';

class ChatApiResponse {
  final String reply;
  final bool needAdmin;
  final String? whatsappUrl;
  final bool fromFaq;
  final String sessionId;

  ChatApiResponse({
    required this.reply,
    required this.needAdmin,
    this.whatsappUrl,
    required this.fromFaq,
    required this.sessionId,
  });

  factory ChatApiResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ChatApiResponse(
      reply: data['reply'] ?? '',
      needAdmin: data['need_admin'] ?? false,
      whatsappUrl: data['whatsapp_url'],
      fromFaq: data['from_faq'] ?? false,
      sessionId: data['session_id'] ?? '',
    );
  }
}

class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  static const _sessionKey = 'chat_session_id';
  String? _sessionId;

  // ── Session management ────────────────────────────────────────────────────

  Future<String> getSessionId() async {
    if (_sessionId != null) return _sessionId!;
    final prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString(_sessionKey);
    if (_sessionId == null) {
      _sessionId = const Uuid().v4();
      await prefs.setString(_sessionKey, _sessionId!);
    }
    return _sessionId!;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    _sessionId = null;
  }

  // ── POST /api/chat ────────────────────────────────────────────────────────

  Future<ChatApiResponse> sendMessage({
    required String message,
    required List<ChatMessage> history,
  }) async {
    final sessionId = await getSessionId();

    // Konversi history ke format API
    final historyJson = history
        .where((m) => m.status == MessageStatus.sent)
        .take(10)
        .map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.content,
            })
        .toList();

    final response = await ApiService.instance.post(
      ApiConfig.chat,
      {
        'message':    message,
        'session_id': sessionId,
        'history':    historyJson,
      },
    );

    return ChatApiResponse.fromJson(response.data as Map<String, dynamic>);
  }

  // ── GET /api/chat/history ─────────────────────────────────────────────────

  Future<List<ChatMessage>> fetchHistory() async {
    final sessionId = await getSessionId();
    try {
      final response = await ApiService.instance.get(
        ApiConfig.chatHistory,
        params: {'session_id': sessionId},
      );
      final data = (response.data['data'] as List?) ?? [];
      return data.map((j) => ChatMessage.fromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── DELETE /api/chat/clear ────────────────────────────────────────────────

  Future<void> clearHistory() async {
    final sessionId = await getSessionId();
    try {
      await ApiService.instance.delete('${ApiConfig.chat}/clear?session_id=$sessionId');
    } catch (_) {}
    await clearSession();
  }
}