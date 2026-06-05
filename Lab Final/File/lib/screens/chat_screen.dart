import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/message.dart';
import '../models/doctor.dart';
import '../services/supabase_service.dart';
import '../theme/colors.dart';
import 'video_consultation_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.isOnline,
  });

  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final bool isOnline;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _loadingHistory = true;
  RealtimeChannel? _channel;

  String get _myId {
    try {
      return SupabaseConfig.client.auth.currentUser?.id ?? 'guest';
    } catch (_) {
      return 'guest';
    }
  }

  String get _myName {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      return user?.userMetadata?['full_name'] as String? ??
          user?.email?.split('@').first ??
          'Patient';
    } catch (_) {
      return 'Patient';
    }
  }

  final List<String> _doctorReplies = [
    'Thank you for reaching out. How can I help you today?',
    'I understand. Could you describe your symptoms in more detail?',
    'I recommend scheduling a follow-up in the next few days.',
    'That sounds normal. Please continue with the prescribed medication.',
    'Please make sure to rest and stay hydrated.',
    'If the symptoms persist, come in for an in-person visit.',
    'Your recent test results look good! Keep up the good work.',
    'I\'ll review your case and get back to you shortly.',
    'Make sure you\'re taking the full course of antibiotics.',
    'Have you noticed any side effects from the current medication?',
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _subscribeRealtime();
  }

  Future<void> _loadHistory() async {
    try {
      final msgs = await SupabaseService.getMessages(
        myId: _myId,
        otherId: widget.doctorId,
      );
      if (!mounted) return;
      setState(() {
        _messages.addAll(msgs);
        _loadingHistory = false;
      });
      if (_messages.isEmpty) _addWelcomeMessage();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingHistory = false);
      _addWelcomeMessage();
    }
    _scrollToBottom();
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      id: 'welcome',
      senderId: widget.doctorId,
      senderName: widget.doctorName,
      receiverId: _myId,
      content:
          'Hello! I\'m ${widget.doctorName}. How are you feeling today?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      isRead: true,
    ));
    setState(() {});
  }

  void _subscribeRealtime() {
    try {
      _channel = SupabaseService.subscribeToMessages(
        myId: _myId,
        otherId: widget.doctorId,
        onMessage: (msg) {
          if (!mounted) return;
          // Avoid duplicate from our own send
          if (_messages.any((m) => m.id == msg.id)) return;
          setState(() => _messages.add(msg));
          _scrollToBottom();
        },
      );
    } catch (_) {
      // Supabase not configured — realtime won't work but UI still works
    }
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();

    final localMsg = ChatMessage(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      senderId: _myId,
      senderName: _myName,
      receiverId: widget.doctorId,
      content: text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    setState(() => _messages.add(localMsg));
    _scrollToBottom();

    // Persist to Supabase
    try {
      await SupabaseService.sendMessage({
        'sender_id': _myId,
        'sender_name': _myName,
        'receiver_id': widget.doctorId,
        'content': text,
        'is_read': false,
      });
    } catch (_) {
      // Message shown locally even if Supabase fails
    }

    // Simulated doctor reply (in a real app the doctor sends from their device)
    setState(() => _isTyping = true);
    await Future.delayed(Duration(milliseconds: 1200 + Random().nextInt(800)));
    if (!mounted) return;

    final replyText = _doctorReplies[Random().nextInt(_doctorReplies.length)];
    final replyMsg = ChatMessage(
      id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
      senderId: widget.doctorId,
      senderName: widget.doctorName,
      receiverId: _myId,
      content: replyText,
      timestamp: DateTime.now(),
      isRead: true,
    );

    try {
      await SupabaseService.sendMessage({
        'sender_id': widget.doctorId,
        'sender_name': widget.doctorName,
        'receiver_id': _myId,
        'content': replyText,
        'is_read': true,
      });
    } catch (_) {}

    setState(() {
      _isTyping = false;
      _messages.add(replyMsg);
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.doctorName
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(initial,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.doctorName,
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                Row(
                  children: [
                    if (widget.isOnline)
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: const BoxDecoration(
                            color: Color(0xFF69F0AE),
                            shape: BoxShape.circle),
                      ),
                    Text(
                      widget.isOnline ? 'Online' : widget.doctorSpecialty,
                      style:
                          GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_rounded),
            onPressed: () {
              final doctor = Doctor.sampleDoctors.firstWhere(
                (d) => d.id == widget.doctorId,
                orElse: () => Doctor.sampleDoctors.first,
              );
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => VideoConsultationScreen(doctor: doctor),
              ));
            },
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _loadingHistory
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (_isTyping && i == _messages.length) {
                        return _TypingBubble(name: widget.doctorName);
                      }
                      final msg = _messages[i];
                      final isMe = msg.senderId == _myId;
                      return _MessageBubble(message: msg, isMe: isMe);
                    },
                  ),
          ),
          _InputBar(controller: _input, onSend: _sendMessage),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});
  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                message.senderName.isNotEmpty ? message.senderName[0] : '?',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: isMe
                        ? []
                        : const [
                            BoxShadow(
                                color: Color(0x10000000),
                                blurRadius: 4,
                                offset: Offset(0, 2))
                          ],
                  ),
                  child: Text(
                    message.content,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isMe ? Colors.white : AppColors.text,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('h:mm a').format(message.timestamp),
                      style: GoogleFonts.inter(
                          fontSize: 10, color: AppColors.placeholder),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead
                            ? Icons.done_all_rounded
                            : Icons.done_rounded,
                        size: 12,
                        color: message.isRead
                            ? AppColors.accent
                            : AppColors.placeholder,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(name.isNotEmpty ? name[0] : '?',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Container(
                  width: 7, height: 7,
                  margin: EdgeInsets.only(left: i > 0 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 12),
      color: AppColors.surface,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file_rounded,
                color: AppColors.placeholder),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.placeholder),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10),
                ),
                style:
                    GoogleFonts.inter(fontSize: 14, color: AppColors.text),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(21),
              ),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
