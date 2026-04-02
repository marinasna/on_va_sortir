import 'package:pocketbase/pocketbase.dart';

enum NotifType { friendRequest, friendAccepted, eventInvite, eventReminder, eventJoin, eventUpdate, achievement }

class AppNotification {
  final String id;
  final String userId;
  final String? senderId;
  final String typeString;
  final String title;
  final String content;
  final String? actionData;
  final bool isRead;
  final DateTime created;
  // expanded sender logic if needed
  final RecordModel? senderRecord;

  AppNotification({
    required this.id,
    required this.userId,
    this.senderId,
    required this.typeString,
    required this.title,
    required this.content,
    this.actionData,
    required this.isRead,
    required this.created,
    this.senderRecord,
  });

  NotifType get type {
    switch (typeString) {
      case 'friend_request':
        return NotifType.friendRequest;
      case 'friend_accepted':
        return NotifType.friendAccepted;
      case 'event_joined':
        return NotifType.eventJoin;
      case 'event_invite':
        return NotifType.eventInvite;
      default:
        return NotifType.achievement;
    }
  }

  factory AppNotification.fromRecord(RecordModel record) {
    final senderExpandList = record.expand['sender'];
    final senderRec = (senderExpandList != null && senderExpandList is List && senderExpandList.isNotEmpty) 
        ? senderExpandList.first 
        : (senderExpandList is RecordModel ? senderExpandList : null);

    return AppNotification(
      id: record.id,
      userId: record.getStringValue('user'),
      senderId: record.getStringValue('sender'),
      typeString: record.getStringValue('type'),
      title: record.getStringValue('title'),
      content: record.getStringValue('content'),
      actionData: record.getStringValue('action_data'),
      isRead: record.getBoolValue('is_read'),
      created: DateTime.tryParse(record.getStringValue('created')) ?? DateTime.now(),
      senderRecord: senderRec is RecordModel ? senderRec : null,
    );
  }
}
