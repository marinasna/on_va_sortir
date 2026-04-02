import 'package:flutter/material.dart';
import 'package:create_good_app/app/models/event.dart';
import 'package:create_good_app/app/services/event_service.dart';

class EventProvider with ChangeNotifier {
  static final EventProvider _instance = EventProvider._internal();
  static EventProvider get instance => _instance;

  EventProvider._internal();

  List<Event> _events = [];
  bool _loading = false;

  List<Event> get events => _events;
  bool get loading => _loading;

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    
    try {
      _events = await EventService.fetchEvents();
    } catch (e) {
      debugPrint('Error refreshing events: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
