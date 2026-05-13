// lib/screens/chat/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/chat_message.dart';
import '../../providers/chat_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatScreen extends StatefulWidget {
  /// Jika diberikan, pesan ini akan langsung dikirim saat layar terbuka.
  /// Berguna ketika pengguna tap ikon chat dari halaman detail produk.
  final String? initialMessage;

  /// Jika true, menambahkan padding bawah untuk bottom navigation bar.
  /// Gunakan ini ketika ChatScreen digunakan sebagai tab dalam bottom nav.
  final bool hasBottomNavBar;

  const ChatScreen({
    super.key,
    this.initialMessage,
    this.hasBottomNavBar = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  // ── Warna brand ────────────────────────────────────────────────────────
  final Color _cokelatTua = const Color(0xFF3E2723);
  final Color _emasMajelis = const Color(0xFFE5A93D);
  final Color _latarKrem = const Color(0xFFF5EFE6);
  final Color _bubbleUser = const Color(0xFF3E2723);
  final Color _bubbleAI = Colors.white;

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // Prompt chip suggestions
  final List<String> _suggestions = [
    '🏕️ Cara menyewa alat',
    '💰 Berapa harga sewa?',
    '📋 Syarat & ketentuan',
    '⏰ Jam operasional',
    '⚡ Apa itu denda?',
    '🎒 Rekomendasi untuk pendakian',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ChatProvider>().loadHistory();

      // Jika ada initialMessage (dari halaman detail produk), kirim otomatis
      if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
        _controller.text = widget.initialMessage!;
        await _send();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // Auto scroll saat keyboard muncul
    Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _focusNode.unfocus();
    await context.read<ChatProvider>().sendMessage(text);
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  Future<void> _openWhatsApp(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal membuka WhatsApp'),
            backgroundColor: _cokelatTua,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── BUILD ──────────────────────────────────────────────────────────────

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _latarKrem,
      resizeToAvoidBottomInset: true,
      body: Column( // Hapus SafeArea di sini agar Header menempel ke status bar
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
          _buildInputArea(),
        ],
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────────────────
  // (Mirip dengan style history_screen untuk konsistensi)

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        24,
        60,
        24,
        20,
      ), // Padding disamakan dengan HistoryScreen
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: _cokelatTua.withOpacity(0.05), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label + Judul (Kiri)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ASISTEN CHAT',
                  style: TextStyle(
                    color: _emasMajelis,
                    fontSize: 9, // Disamakan ukurannya
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Asisten Majelis',
                  style: TextStyle(
                    color: _cokelatTua,
                    fontSize: 22, // Disamakan ukurannya
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // Tombol Action (Kanan)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tombol hapus history (hanya muncul jika tidak empty)
              Consumer<ChatProvider>(
                builder: (_, p, __) =>
                    !p.isEmpty && widget.initialMessage == null
                    ? GestureDetector(
                        onTap: () => _confirmClear(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: _latarKrem.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: _cokelatTua.withOpacity(0.4),
                            size: 18,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Tombol Back atau Icon AI
              GestureDetector(
                onTap: widget.initialMessage != null
                    ? () => Navigator.pop(context)
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _latarKrem.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.initialMessage != null
                        ? Icons.arrow_back_ios_new_rounded
                        : Icons.auto_awesome_rounded,
                    color: _cokelatTua,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        if (provider.state == ChatLoadState.loading && provider.isEmpty) {
          return Center(child: CircularProgressIndicator(color: _emasMajelis));
        }

        if (provider.isEmpty) {
          return _buildEmptyState();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: provider.messages.length + (provider.isTyping ? 1 : 0),
          itemBuilder: (_, i) {
            if (i == provider.messages.length) {
              return _buildTypingIndicator();
            }
            return _buildMessageBubble(provider.messages[i]);
          },
        );
      },
    );
  }

  // ── EMPTY STATE ────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Ilustrasi
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: _emasMajelis.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 40,
              color: _emasMajelis,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Hai! Saya Asisten Majelis 👋',
            style: TextStyle(
              color: _cokelatTua,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Saya siap membantu pertanyaan seputar penyewaan alat outdoor.\n'
            'Ketik pertanyaan Anda atau pilih topik di bawah!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _cokelatTua.withOpacity(0.5),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          // Suggestion chips
          Wrap(
            spacing: 8,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _suggestions.map((s) => _buildSuggestionChip(s)).toList(),
          ),
          const SizedBox(height: 16),
          // Hint mengetik bebas
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.keyboard_alt_outlined,
                size: 14,
                color: _cokelatTua.withOpacity(0.3),
              ),
              const SizedBox(width: 6),
              Text(
                'Atau ketik pertanyaan bebas di bawah',
                style: TextStyle(
                  color: _cokelatTua.withOpacity(0.35),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return GestureDetector(
      onTap: () {
        final clean = label.replaceAll(RegExp(r'^[^\w\s]+\s'), '').trim();
        _controller.text = clean;
        _send();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _emasMajelis.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: _cokelatTua.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _cokelatTua,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ── MESSAGE BUBBLE ─────────────────────────────────────────────────────

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(right: 8, bottom: 2),
                  decoration: BoxDecoration(
                    color: _emasMajelis.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: _emasMajelis,
                  ),
                ),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? _bubbleUser : _bubbleAI,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _cokelatTua.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isUser ? _buildUserText(msg) : _buildAIText(msg),
                ),
              ),
            ],
          ),

          // Tombol WhatsApp jika perlu admin
          if (!isUser && msg.needAdmin && msg.whatsappUrl != null)
            _buildWhatsAppButton(msg.whatsappUrl!),

          // Error & retry
          if (isUser && msg.status == MessageStatus.error) _buildErrorRetry(),

          // Timestamp
          Padding(
            padding: EdgeInsets.only(
              top: 4,
              left: isUser ? 0 : 40,
              right: isUser ? 4 : 0,
            ),
            child: Text(
              _formatTime(msg.createdAt),
              style: TextStyle(
                color: _cokelatTua.withOpacity(0.3),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserText(ChatMessage msg) {
    return msg.status == MessageStatus.sending
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  msg.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          )
        : Text(
            msg.content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          );
  }

  Widget _buildAIText(ChatMessage msg) {
    return MarkdownBody(
      data: msg.content,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(color: _cokelatTua, fontSize: 14, height: 1.5),
        strong: TextStyle(color: _cokelatTua, fontWeight: FontWeight.w800),
        listBullet: TextStyle(color: _cokelatTua),
        h1: TextStyle(
          color: _cokelatTua,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
        h2: TextStyle(
          color: _cokelatTua,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
        code: TextStyle(
          backgroundColor: _emasMajelis.withOpacity(0.08),
          color: _cokelatTua,
          fontSize: 12,
        ),
      ),
      shrinkWrap: true,
    );
  }

  Widget _buildWhatsAppButton(String url) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 36),
      child: GestureDetector(
        onTap: () => _openWhatsApp(url),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF25D366), Color(0xFF128C7E)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF25D366).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text(
                'Hubungi Admin WhatsApp',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: Colors.white, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorRetry() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 4),
      child: GestureDetector(
        onTap: () => context.read<ChatProvider>().retryLast(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.refresh_rounded,
              size: 12,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              'Gagal terkirim. Tap untuk coba lagi.',
              style: TextStyle(
                color: Colors.red.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TYPING INDICATOR ───────────────────────────────────────────────────

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 36),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: _cokelatTua.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _TypingDots(color: _emasMajelis),
          ),
        ],
      ),
    );
  }

  // ── INPUT AREA ─────────────────────────────────────────────────────────

  Widget _buildInputArea() {
    // FIX: Ambil tinggi safe area bawah (home indicator / sistem nav gesture)
    // agar input bar tidak tertutup di perangkat tanpa tombol fisik.
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // FIX: Tambahkan padding untuk bottom navigation bar jika digunakan sebagai tab
    final navBarPadding = widget.hasBottomNavBar ? 88.0 : 0.0;

    return Container(
      // Tambahkan bottomPadding ke padding bawah container + navBarPadding
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        16 + bottomPadding + navBarPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: _cokelatTua.withOpacity(0.05), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: _cokelatTua.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Text field ────────────────────────────────────────────────
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: _latarKrem,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _cokelatTua.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: _cokelatTua, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Ketik pertanyaan Anda...',
                  hintStyle: TextStyle(
                    color: _cokelatTua.withOpacity(0.35),
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (_, val, __) => val.text.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Icon(
                              Icons.edit_note_rounded,
                              color: _cokelatTua.withOpacity(0.2),
                              size: 20,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                // FIX: Tombol Enter di keyboard langsung kirim pesan
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (_controller.text.trim().isNotEmpty &&
                      !context.read<ChatProvider>().isTyping) {
                    _send();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Tombol kirim ─────────────────────────────────────────────
          Consumer<ChatProvider>(
            builder: (_, p, __) => ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (_, val, __) {
                final canSend = val.text.trim().isNotEmpty && !p.isTyping;
                return GestureDetector(
                  onTap: canSend ? _send : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: canSend
                          ? _emasMajelis
                          : _emasMajelis.withOpacity(0.25),
                      shape: BoxShape.circle,
                      boxShadow: canSend
                          ? [
                              BoxShadow(
                                color: _emasMajelis.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: p.isTyping
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: canSend ? 20 : 18,
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── DIALOG CLEAR ───────────────────────────────────────────────────────

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Riwayat Chat',
          style: TextStyle(color: _cokelatTua, fontWeight: FontWeight.w900),
        ),
        content: Text(
          'Semua percakapan akan dihapus. Lanjutkan?',
          style: TextStyle(color: _cokelatTua.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(color: _cokelatTua.withOpacity(0.5)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ChatProvider>().clearChat();
            },
            child: Text(
              'Hapus',
              style: TextStyle(
                color: Colors.red.shade400,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── UTILS ──────────────────────────────────────────────────────────────

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ── Typing dots animation ─────────────────────────────────────────────────

class _TypingDots extends StatefulWidget {
  final Color color;
  const _TypingDots({required this.color});

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    _anims = _ctrls
        .map(
          (c) => Tween<double>(
            begin: 0,
            end: 6,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)),
        )
        .toList();

    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _ctrls[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          3,
          (i) => AnimatedBuilder(
            animation: _anims[i],
            builder: (_, __) => Transform.translate(
              offset: Offset(0, -_anims[i].value),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
