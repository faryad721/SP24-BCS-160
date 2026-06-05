class ChatMessage {
  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.attachmentUrl,
    this.attachmentType,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? attachmentUrl;
  final String? attachmentType;

  factory ChatMessage.fromSupabase(Map<String, dynamic> m) => ChatMessage(
        id: (m['id'] ?? '') as String,
        senderId: (m['sender_id'] ?? '') as String,
        senderName: (m['sender_name'] ?? '') as String,
        receiverId: (m['receiver_id'] ?? '') as String,
        content: (m['content'] ?? '') as String,
        timestamp:
            DateTime.tryParse(m['created_at'] ?? '') ?? DateTime.now(),
        isRead: (m['is_read'] ?? false) as bool,
        attachmentUrl: m['attachment_url'] as String?,
        attachmentType: m['attachment_type'] as String?,
      );

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      ChatMessage.fromSupabase(json);

  Map<String, dynamic> toSupabase() => {
        'sender_id': senderId,
        'sender_name': senderName,
        'receiver_id': receiverId,
        'content': content,
        'is_read': isRead,
        'attachment_url': attachmentUrl,
        'attachment_type': attachmentType,
      };
}

class ChatConversation {
  ChatConversation({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
  });

  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  static List<ChatConversation> get samples => [
        ChatConversation(id: 'conv1', doctorId: 'd1', doctorName: 'Dr. Sarah Ahmed',  doctorSpecialty: 'Cardiologist',  lastMessage: 'Your test results look good. Continue the medication.', lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),  unreadCount: 2, isOnline: true),
        ChatConversation(id: 'conv2', doctorId: 'd3', doctorName: 'Dr. Maria Santos', doctorSpecialty: 'Pediatrician',  lastMessage: 'Please bring the child for a follow-up next week.',      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),   unreadCount: 0, isOnline: true),
        ChatConversation(id: 'conv3', doctorId: 'd5', doctorName: 'Dr. Aisha Patel',  doctorSpecialty: 'Dermatologist', lastMessage: 'Apply the cream twice daily for 2 weeks.',               lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),    unreadCount: 1, isOnline: false),
      ];
}
