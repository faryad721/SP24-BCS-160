import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/message.dart';
import '../theme/colors.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final List<ChatConversation> _conversations = ChatConversation.samples;

  @override
  Widget build(BuildContext context) {
    final totalUnread = _conversations.fold(0, (s, c) => s + c.unreadCount);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Messages',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        if (totalUnread > 0)
                          Text(
                            '$totalUnread unread message${totalUnread > 1 ? 's' : ''}',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: AppColors.primary),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        size: 20, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _conversations.isEmpty
                  ? _EmptyChat()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: _conversations.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: AppColors.border.withOpacity(0.5),
                        indent: 72,
                      ),
                      itemBuilder: (_, i) => _ConversationTile(
                        conversation: _conversations[i],
                        onTap: () {
                          setState(() {
                            _conversations[i] = ChatConversation(
                              id: _conversations[i].id,
                              doctorId: _conversations[i].doctorId,
                              doctorName: _conversations[i].doctorName,
                              doctorSpecialty: _conversations[i].doctorSpecialty,
                              lastMessage: _conversations[i].lastMessage,
                              lastMessageTime: _conversations[i].lastMessageTime,
                              unreadCount: 0,
                              isOnline: _conversations[i].isOnline,
                            );
                          });
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              doctorId: _conversations[i].doctorId,
                              doctorName: _conversations[i].doctorName,
                              doctorSpecialty: _conversations[i].doctorSpecialty,
                              isOnline: _conversations[i].isOnline,
                            ),
                          ));
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.onTap});
  final ChatConversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(conversation.lastMessageTime);
    String timeStr;
    if (diff.inMinutes < 60) {
      timeStr = '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      timeStr = '${diff.inHours}h ago';
    } else {
      timeStr = DateFormat('MMM d').format(conversation.lastMessageTime);
    }

    final initial = conversation.doctorName
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (conversation.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.doctorName,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      Text(
                        timeStr,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: conversation.unreadCount > 0
                              ? AppColors.primary
                              : AppColors.placeholder,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    conversation.doctorSpecialty,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: conversation.unreadCount > 0
                                ? AppColors.text
                                : AppColors.textSecondary,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${conversation.unreadCount}',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 72, color: AppColors.border),
          const SizedBox(height: 12),
          Text('No messages yet',
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text)),
          const SizedBox(height: 6),
          Text('Start a chat from a doctor\'s profile',
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
