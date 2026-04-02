import 'package:create_good_app/app/models/message.dart';
import 'package:create_good_app/app/core/db.dart';

class MessageService {
  // récup les conversations de l'utilisateur courant
  static Future<List<Conversation>> fetchConversations() async {
    try {
      final userId = pb.authStore.record?.id;
      if (userId == null) return [];

      final records = await pb.collection('conversations').getFullList(
        expand: 'participants,event',
        filter: 'participants.id ?= "$userId"',
        sort: '-last_message_at,-created',
      );

      return records.map((record) {
        String name = record.getStringValue('name');

        // pour les conv privées, afficher le nom de l'autre
        if (record.getStringValue('type') == 'private') {
          final expanded = record.expand['participants'] ?? [];
          for (final p in expanded) {
            if (p.id != userId) {
              name = p.getStringValue('name');
              break;
            }
          }
        }

        return Conversation(
          id: record.id,
          type: record.getStringValue('type'),
          eventId: record.getStringValue('event').isEmpty ? null : record.getStringValue('event'),
          participantIds: record.getListValue<String>('participants'),
          name: name,
          lastMessage: record.getStringValue('last_message'),
          lastMessageAt: DateTime.tryParse(record.getStringValue('last_message_at')),
        );
      }).toList();
    } catch (e) {
      print('Erreur fetchConversations: $e');
      return [];
    }
  }

  // récup les messages d'une conversation
  static Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    try {
      final userId = pb.authStore.record?.id;
      if (userId == null) return [];

      final records = await pb.collection('messages').getFullList(
        filter: 'conversation = "$conversationId"',
        sort: '+created',
        expand: 'sender',
      );

      return records.map((r) => ChatMessage.fromRecord(r, userId)).toList();
    } catch (e) {
      print('Erreur fetchMessages: $e');
      return [];
    }
  }

  // envoyer un message
  static Future<ChatMessage?> sendMessage(String conversationId, String content) async {
    try {
      final userId = pb.authStore.record?.id;
      if (userId == null) return null;

      final record = await pb.collection('messages').create(body: {
        'conversation': conversationId,
        'sender': userId,
        'content': content,
      }, expand: 'sender');

      // maj le dernier message de la conversation
      await pb.collection('conversations').update(conversationId, body: {
        'last_message': content,
        'last_message_at': DateTime.now().toUtc().toIso8601String(),
      });

      return ChatMessage.fromRecord(record, userId);
    } catch (e) {
      print('Erreur sendMessage: $e');
      rethrow;
    }
  }

  // créer ou récup une conversation privée
  static Future<Conversation> getOrCreatePrivateConversation(String otherUserId, String otherUserName) async {
    final userId = pb.authStore.record?.id;
    if (userId == null) throw Exception('Non connecté');

    try {
      // chercher une conv privée existante entre les 2
      final existing = await pb.collection('conversations').getFullList(
        filter: 'type = "private" && participants.id ?= "$userId" && participants.id ?= "$otherUserId"',
        expand: 'participants',
      );

      if (existing.isNotEmpty) {
        final record = existing.first;
        return Conversation(
          id: record.id,
          type: 'private',
          participantIds: record.getListValue<String>('participants'),
          name: otherUserName,
        );
      }
    } catch (_) {}

    // créer la conversation
    final record = await pb.collection('conversations').create(body: {
      'type': 'private',
      'participants': [userId, otherUserId],
      'name': otherUserName,
      'last_message': '',
      'last_message_at': DateTime.now().toUtc().toIso8601String(),
    });

    return Conversation(
      id: record.id,
      type: 'private',
      participantIds: [userId, otherUserId],
      name: otherUserName,
    );
  }

  // créer ou rejoindre la conv de groupe d'un événement
  static Future<Conversation> joinEventConversation(String eventId, String eventTitle, String eventEmoji) async {
    final userId = pb.authStore.record?.id;
    if (userId == null) throw Exception('Non connecté');

    try {
      final existing = await pb.collection('conversations').getFullList(
        filter: 'type = "group" && event = "$eventId"',
      );

      if (existing.isNotEmpty) {
        final record = existing.first;
        final participants = record.getListValue<String>('participants');

        if (!participants.contains(userId)) {
          participants.add(userId);
          await pb.collection('conversations').update(record.id, body: {
            'participants': participants,
          });
        }

        return Conversation(
          id: record.id,
          type: 'group',
          eventId: eventId,
          participantIds: participants,
          name: '$eventEmoji $eventTitle',
        );
      }
    } catch (_) {}

    final record = await pb.collection('conversations').create(body: {
      'type': 'group',
      'event': eventId,
      'participants': [userId],
      'name': '$eventEmoji $eventTitle',
      'last_message': '',
      'last_message_at': DateTime.now().toUtc().toIso8601String(),
    });

    return Conversation(
      id: record.id,
      type: 'group',
      eventId: eventId,
      participantIds: [userId],
      name: '$eventEmoji $eventTitle',
    );
  }

  // quitter la conv de groupe d'un événement
  static Future<void> leaveEventConversation(String eventId) async {
    final userId = pb.authStore.record?.id;
    if (userId == null) return;

    try {
      final existing = await pb.collection('conversations').getFullList(
        filter: 'type = "group" && event = "$eventId"',
      );

      if (existing.isNotEmpty) {
        final record = existing.first;
        final participants = record.getListValue<String>('participants');
        participants.remove(userId);
        await pb.collection('conversations').update(record.id, body: {
          'participants': participants,
        });
      }
    } catch (e) {
      print('Erreur leaveEventConversation: $e');
    }
  }

  // récup la conv d'un événement
  static Future<Conversation?> getEventConversation(String eventId) async {
    try {
      final existing = await pb.collection('conversations').getFullList(
        filter: 'type = "group" && event = "$eventId"',
      );

      if (existing.isNotEmpty) {
        final record = existing.first;
        return Conversation(
          id: record.id,
          type: 'group',
          eventId: eventId,
          participantIds: record.getListValue<String>('participants'),
          name: record.getStringValue('name'),
        );
      }
    } catch (e) {
      print('Erreur getEventConversation: $e');
    }
    return null;
  }
}
