// lib/models/chat_message.dart

import '../models/product.dart';

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

  /// Barang yang dilampirkan (untuk product card bubble ala Shopee).
  /// Hanya ada pada pesan pertama saat user membuka chat dari halaman detail.
  final Product? attachedProduct;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.needAdmin = false,
    this.whatsappUrl,
    this.fromFaq = false,
    this.status = MessageStatus.sent,
    this.attachedProduct,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Buat pesan user
  factory ChatMessage.fromUser(String text) => ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.user,
        content: text,
        status: MessageStatus.sending,
      );

  // Buat pesan user dengan produk terlampir (dari halaman detail → Shopee style)
  factory ChatMessage.withProduct({
    required String text,
    required Product product,
  }) =>
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.user,
        content: text,
        status: MessageStatus.sending,
        attachedProduct: product,
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
        attachedProduct: json['attached_product'] != null
            ? Product(
                id: json['attached_product']['id'] is String
                    ? int.tryParse(json['attached_product']['id']) ?? 0
                    : json['attached_product']['id'],
                name: json['attached_product']['nama'] ?? '',
                hargaPerHari: double.tryParse(json['attached_product']['harga_per_hari']?.toString() ?? '0') ?? 0.0,
                category: '', // Dummy category
                fotoUtama: Product.fixImageUrl(json['attached_product']['image_url']),
              )
            : null,
      );

  ChatMessage copyWith({
    MessageStatus? status,
    String? content,
    bool? needAdmin,
    String? whatsappUrl,
    Product? attachedProduct,
  }) =>
      ChatMessage(
        id: id,
        role: role,
        content: content ?? this.content,
        needAdmin: needAdmin ?? this.needAdmin,
        whatsappUrl: whatsappUrl ?? this.whatsappUrl,
        fromFaq: fromFaq,
        status: status ?? this.status,
        attachedProduct: attachedProduct ?? this.attachedProduct,
        createdAt: createdAt,
      );

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
}