// lib/models/chat_message.dart

enum MessageRole { user, assistant }
enum MessageStatus { sending, sent, error }

class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final bool needAdmin;
  final String? whatsappUrl;
  final bool fromFaq;
  final MessageStatus status;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.needAdmin = false,
    this.whatsappUrl,
    this.fromFaq = false,
    this.status = MessageStatus.sent,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Buat pesan user
  factory ChatMessage.fromUser(String text) => ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.user,
        content: text,
        status: MessageStatus.sending,
      );

  // Parse dari JSON API
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: json['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
        content: json['message'] ?? json['reply'] ?? '',
        needAdmin: json['need_admin'] ?? false,
        whatsappUrl: json['whatsapp_url'],
        fromFaq: json['from_faq'] ?? false,
        status: MessageStatus.sent,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
            : DateTime.now(),
      );

  ChatMessage copyWith({
    MessageStatus? status,
    String? content,
    bool? needAdmin,
    String? whatsappUrl,
  }) =>
      ChatMessage(
        id: id,
        role: role,
        content: content ?? this.content,
        needAdmin: needAdmin ?? this.needAdmin,
        whatsappUrl: whatsappUrl ?? this.whatsappUrl,
        fromFaq: fromFaq,
        status: status ?? this.status,
        createdAt: createdAt,
      );

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
}