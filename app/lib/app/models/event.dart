import 'package:pocketbase/pocketbase.dart';

class Event {
  final String id;
  final String emoji;
  final String title;
  final DateTime date;
  final List<String> participants;
  final String category;
  final String description;
  final String? creatorId;
  final double lat;
  final double lng;

  const Event({
    required this.id,
    required this.emoji,
    required this.title,
    required this.date,
    required this.participants,
    required this.category,
    required this.description,
    this.creatorId,
    required this.lat,
    required this.lng,
  });

  factory Event.fromRecord(RecordModel record) {
    return Event(
      id: record.id,
      emoji: record.getStringValue('emoji'),
      title: record.getStringValue('title'),
      date: DateTime.tryParse(record.getStringValue('date')) ?? DateTime.now(),
      participants: record.getListValue<String>('participants'),
      category: record.getStringValue('category'),
      description: record.getStringValue('description'),
      creatorId: record.getStringValue('creator'),
      lat: record.getDoubleValue('lat'),
      lng: record.getDoubleValue('lng'),
    );
  }
}
