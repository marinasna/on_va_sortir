import 'package:create_good_app/app/models/event.dart';
import 'package:create_good_app/app/core/db.dart';

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
      await pb.collection('events').create(body: data);
    } catch (e) {
      print('Erreur lors de la création de l\'événement: $e');
      rethrow;
    }
  }
}
