import 'package:pocketbase/pocketbase.dart';

class Conversation {
  final String id;
  final String type;
  final String? eventId;
  final List<String> participantIds;
  final String name;
  final String lastMessage;
  final DateTime? lastMessageAt;

  const Conversation({
    required this.id,
    required this.type,
    this.eventId,
    required this.participantIds,
    required this.name,
    this.lastMessage = '',
    this.lastMessageAt,
  });

  bool get isGroup => type == 'group';
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime created;
  final bool isMine;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.created,
    required this.isMine,
  });

  factory ChatMessage.fromRecord(RecordModel record, String currentUserId) {
    final senderExpand = record.expand['sender'];
    final senderRecord = (senderExpand != null && senderExpand.isNotEmpty) ? senderExpand.first : null;

    return ChatMessage(
      id: record.id,
      conversationId: record.getStringValue('conversation'),
      senderId: record.getStringValue('sender'),
      senderName: senderRecord?.getStringValue('name') ?? 'Inconnu',
      content: record.getStringValue('content'),
      created: DateTime.tryParse(record.getStringValue('created')) ?? DateTime.now(),
      isMine: record.getStringValue('sender') == currentUserId,
    );
  }
}
