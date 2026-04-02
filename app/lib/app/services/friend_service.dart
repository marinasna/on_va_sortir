import 'package:create_good_app/app/models/friendship.dart';
import 'package:create_good_app/app/core/db.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:create_good_app/app/services/notification_service.dart';

class FriendService {
  // envoyer une demande d'ami
  static Future<void> sendFriendRequest(String receiverId) async {
    final userId = pb.authStore.record?.id;
    if (userId == null) throw Exception('Non connecté');

    // vérifier qu'il n'existe pas déjà une relation
    try {
      final existing = await pb.collection('friendships').getFullList(
        filter: '(sender = "$userId" && receiver = "$receiverId") || (sender = "$receiverId" && receiver = "$userId")',
      );
      if (existing.isNotEmpty) {
        throw Exception('Une demande existe déjà');
      }
    } catch (e) {
      if (e.toString().contains('existe déjà')) rethrow;
    }

    final created = await pb.collection('friendships').create(body: {
      'sender': userId,
      'receiver': receiverId,
      'status': 'pending',
    });

    final name = pb.authStore.record?.getStringValue('name') ?? 'Un utilisateur';
    await AppNotificationService.createNotification(
      targetUserId: receiverId,
      senderId: userId,
      type: 'friend_request',
      title: "Demande d'ami",
      content: "$name veut être ton ami.",
      actionData: created.id,
    );
  }

  // accepter une demande
  static Future<void> acceptFriendRequest(String friendshipId) async {
    await pb.collection('friendships').update(friendshipId, body: {
      'status': 'accepted',
    });

    try {
      final friendship = await pb.collection('friendships').getOne(friendshipId);
      final senderId = friendship.getStringValue('sender');
      final receiverId = friendship.getStringValue('receiver');

      final myName = pb.authStore.record?.getStringValue('name') ?? 'Un utilisateur';
      await AppNotificationService.createNotification(
        targetUserId: senderId,
        senderId: receiverId,
        type: 'friend_accepted',
        title: 'Demande acceptée',
        content: '$myName a accepté ta demande.',
        actionData: friendshipId,
      );
      await AppNotificationService.deleteNotificationByActionData(friendshipId);


      for (final uid in [senderId, receiverId]) {
        final user = await pb.collection('users').getOne(uid);
        final count = user.getIntValue('friends_count');
        await pb.collection('users').update(uid, body: {'friends_count': count + 1});
      }

      if (pb.authStore.record?.id == senderId || pb.authStore.record?.id == receiverId) {
        final updated = await pb.collection('users').getOne(pb.authStore.record!.id);
        pb.authStore.save(pb.authStore.token, updated);
      }
    } catch (e) {
      print('Erreur mise à jour compteur amis: $e');
    }
  }

  // refuser une demande
  static Future<void> rejectFriendRequest(String friendshipId) async {
    await pb.collection('friendships').delete(friendshipId);
    await AppNotificationService.deleteNotificationByActionData(friendshipId);
  }

  // supprimer un ami
  static Future<void> removeFriend(String friendshipId) async {
    try {
      final friendship = await pb.collection('friendships').getOne(friendshipId);
      final senderId = friendship.getStringValue('sender');
      final receiverId = friendship.getStringValue('receiver');

      await pb.collection('friendships').delete(friendshipId);

      for (final uid in [senderId, receiverId]) {
        final user = await pb.collection('users').getOne(uid);
        final count = user.getIntValue('friends_count');
        await pb.collection('users').update(uid, body: {'friends_count': count > 0 ? count - 1 : 0});
      }

      if (pb.authStore.record?.id == senderId || pb.authStore.record?.id == receiverId) {
        final updated = await pb.collection('users').getOne(pb.authStore.record!.id);
        pb.authStore.save(pb.authStore.token, updated);
      }
    } catch (e) {
      print('Erreur removeFriend: $e');
      rethrow;
    }
  }

  // récup la liste d'amis (accepted)
  static Future<List<Friendship>> fetchFriends() async {
    final userId = pb.authStore.record?.id;
    if (userId == null) return [];

    try {
      final records = await pb.collection('friendships').getFullList(
        filter: 'status = "accepted" && (sender = "$userId" || receiver = "$userId")',
        expand: 'sender,receiver',
        sort: '-updated',
      );
      return records.map((r) => Friendship.fromRecord(r)).toList();
    } catch (e) {
      print('Erreur fetchFriends: $e');
      return [];
    }
  }

  // récup les demandes reçues en attente
  static Future<List<Friendship>> fetchPendingRequests() async {
    final userId = pb.authStore.record?.id;
    if (userId == null) return [];

    try {
      final records = await pb.collection('friendships').getFullList(
        filter: 'status = "pending" && receiver = "$userId"',
        expand: 'sender,receiver',
        sort: '-created',
      );
      return records.map((r) => Friendship.fromRecord(r)).toList();
    } catch (e) {
      print('Erreur fetchPendingRequests: $e');
      return [];
    }
  }

  // rechercher des utilisateurs
  static Future<List<RecordModel>> searchUsers(String query) async {
    final userId = pb.authStore.record?.id;
    if (userId == null) return [];

    try {
      final result = await pb.collection('users').getList(
        page: 1,
        perPage: 20,
        filter: '(name ~ "$query" || username ~ "$query") && id != "$userId"',
      );
      return result.items;
    } catch (e) {
      print('Erreur searchUsers: $e');
      return [];
    }
  }
}
