import 'package:create_good_app/app/models/event.dart';
import 'package:create_good_app/app/core/db.dart';
import 'package:create_good_app/app/services/message_service.dart';
import 'package:create_good_app/app/services/notification_service.dart';
import 'package:create_good_app/app/core/conversation_provider.dart';
import 'package:create_good_app/app/core/event_provider.dart';
import 'package:pocketbase/pocketbase.dart';
class EventService {
  static Future<List<Event>> fetchEvents() async {
    try {
      final records = await pb.collection('events').getFullList(
        expand: 'participants',
        sort: '-date',
      );
      final List<Event> parsedEvents = [];
      for (var record in records) {
        try {
          parsedEvents.add(Event.fromRecord(record));
        } catch (e) {
          print('Ignored broken event ${record.id}: $e');
        }
      }
      return parsedEvents;
    } catch (e) {
      print('Erreur lors de la récupération des événements: $e');
      return [];
    }
  }

  static Future<void> createEvent(Map<String, dynamic> data) async {
    try {
      final userId = pb.authStore.record?.id;
      if (userId != null) data['creator'] = userId;
      final record = await pb.collection('events').create(body: data);
      
      // Auto-join creator to conversation
      final event = Event.fromRecord(record);
      await MessageService.joinEventConversation(event.id, event.title, event.emoji);
      ConversationProvider.instance.refresh();
      EventProvider.instance.refresh();
    } catch (e) {
      print('Erreur lors de la création de l\'événement: $e');
      rethrow;
    }
  }

  static Future<bool> toggleEventParticipation(Event event) async {
    final userId = pb.authStore.record?.id;
    if (userId == null) throw Exception("Utilisateur non connecté");

    final participants = List<String>.from(event.participants);
    bool isJoining = false;

    if (participants.contains(userId)) {
      participants.remove(userId);
    } else {
      participants.add(userId);
      isJoining = true;
    }

    try {
      await pb.collection('events').update(event.id, body: {
        'participants': participants,
      });

      // Mettre à jour le compteur dans la table 'users'
      final userRecord = pb.authStore.model as RecordModel?;
      if (userRecord != null) {
        final currentCount = userRecord.getIntValue('events_count');
        final newCount = isJoining ? currentCount + 1 : (currentCount > 0 ? currentCount - 1 : 0);
        
        final updatedUser = await pb.collection('users').update(userRecord.id, body: {
          'events_count': newCount
        });
        
        // Sauvegarder localement pour que l'interface Profil se rafraîchisse naturellement
        pb.authStore.save(pb.authStore.token, updatedUser);
      }

      // gérer la conv de groupe
      await _handleEventConversation(event, isJoining);

      // Notification au créateur si quelqu'un rejoint
      if (isJoining && event.creatorId != null && event.creatorId != userId) {
        final myName = pb.authStore.record?.getStringValue('name') ?? 'Un utilisateur';
        await AppNotificationService.createNotification(
          targetUserId: event.creatorId!,
          senderId: userId,
          type: 'event_joined',
          title: 'Nouvelle participation',
          content: '$myName participe à votre événement "${event.title}"',
          actionData: event.id,
        );
      }

      // Refresh globally
      ConversationProvider.instance.refresh();
      EventProvider.instance.refresh();

      return isJoining;
    } catch (e) {
      print('Erreur mise à jour participation: $e');
      rethrow;
    }
  }

  // gérer la conversation de groupe liée à l'événement
  static Future<void> _handleEventConversation(Event event, bool isJoining) async {
    try {
      if (isJoining) {
        await MessageService.joinEventConversation(event.id, event.title, event.emoji);
      } else {
        await MessageService.leaveEventConversation(event.id);
      }
    } catch (e) {
      print('Erreur gestion conversation événement: $e');
    }
  }
}
