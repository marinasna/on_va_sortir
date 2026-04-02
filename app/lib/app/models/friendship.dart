import 'package:pocketbase/pocketbase.dart';

class Friendship {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String status;

  const Friendship({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.status,
  });

  factory Friendship.fromRecord(RecordModel record) {
    final senderExpand = record.expand['sender'];
    final receiverExpand = record.expand['receiver'];
    final senderRecord = (senderExpand != null && senderExpand.isNotEmpty) ? senderExpand.first : null;
    final receiverRecord = (receiverExpand != null && receiverExpand.isNotEmpty) ? receiverExpand.first : null;

    return Friendship(
      id: record.id,
      senderId: record.getStringValue('sender'),
      senderName: senderRecord?.getStringValue('name') ?? 'Inconnu',
      receiverId: record.getStringValue('receiver'),
      receiverName: receiverRecord?.getStringValue('name') ?? 'Inconnu',
      status: record.getStringValue('status'),
    );
  }

  String otherUserName(String currentUserId) {
    return senderId == currentUserId ? receiverName : senderName;
  }

  String otherUserId(String currentUserId) {
    return senderId == currentUserId ? receiverId : senderId;
  }
}
