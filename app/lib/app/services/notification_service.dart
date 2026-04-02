import 'package:create_good_app/app/models/notification.dart';
import 'package:create_good_app/app/core/db.dart';
import 'package:pocketbase/pocketbase.dart';

class AppNotificationService {
  static Future<List<AppNotification>> fetchNotifications() async {
    final userId = pb.authStore.record?.id;
    if (userId == null) return [];

    try {
      final records = await pb.collection('notifications').getFullList(
        filter: 'user = "$userId"',
        sort: '-created',
        expand: 'sender',
      );
      
      return records.map((r) => AppNotification.fromRecord(r)).toList();
    } catch (e) {
      print('Erreur fetchNotifications: $e');
      return [];
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    try {
      await pb.collection('notifications').update(notificationId, body: {
        'is_read': true,
      });
    } catch (e) {
      print('Erreur markAsRead: $e');
    }
  }

  static Future<void> markAllAsRead() async {
    final userId = pb.authStore.record?.id;
    if (userId == null) return;
    
    try {
      final unread = await pb.collection('notifications').getFullList(
        filter: 'user = "$userId" && is_read = false',
      );
      
      for (final r in unread) {
        await pb.collection('notifications').update(r.id, body: {'is_read': true});
      }
    } catch (e) {
      print('Erreur markAllAsRead: $e');
    }
  }

  static Future<void> createNotification({
    required String targetUserId,
    String? senderId,
    required String type,
    required String title,
    required String content,
    String? actionData,
  }) async {
    try {
      await pb.collection('notifications').create(body: {
        'user': targetUserId,
        'sender': senderId ?? '',
        'type': type,
        'title': title,
        'content': content,
        'action_data': actionData ?? '',
        'is_read': false,
      });
    } catch (e) {
      print('Erreur createNotification: $e');
    }
  }

  static Future<void> deleteNotificationByActionData(String actionData) async {
    final userId = pb.authStore.record?.id;
    if (userId == null) return;

    try {
      final records = await pb.collection('notifications').getFullList(
        filter: 'user = "$userId" && action_data = "$actionData"',
      );
      for (final r in records) {
        await pb.collection('notifications').delete(r.id);
      }
    } catch (e) {
      print('Erreur deleteNotificationByActionData: $e');
    }
  }
}
