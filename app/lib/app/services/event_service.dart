import 'package:flutter/material.dart';
import 'package:create_good_app/app/core/theme.dart';
import 'package:create_good_app/app/models/event.dart';
import 'package:create_good_app/app/models/message.dart';
import 'package:create_good_app/app/models/notification.dart';
import 'package:create_good_app/app/services/event_service.dart';
import 'package:create_good_app/app/services/message_service.dart';
import 'package:create_good_app/app/services/notification_service.dart';
import 'package:create_good_app/app/services/auth_service.dart';
import 'package:create_good_app/app/widgets/primary_button.dart';
import 'package:create_good_app/app/widgets/custom_form_field.dart';
import 'package:create_good_app/app/screens/carte_screen.dart';
import 'package:create_good_app/app/screens/chat_screen.dart';
import 'package:create_good_app/app/screens/create_event_screen.dart';
import 'package:create_good_app/app/screens/launch_screen.dart';
import 'package:create_good_app/app/screens/login_screen.dart';
import 'package:create_good_app/app/screens/main_screen.dart';
import 'package:create_good_app/app/screens/message_list_screen.dart';
import 'package:create_good_app/app/screens/parametres_screen.dart';
import 'package:create_good_app/app/screens/profil_screen.dart';
import 'package:create_good_app/app/screens/register_screen.dart';
import 'dart:math' as math;

class EventService {
  static Future<List<Event>> fetchEvents() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      Event(id: '1', emoji: '🎮', title: 'Soirée jeux de société', date: 'Jeudi 27 Mars', time: '19:00', participants: 8, category: 'Soirée'),
      Event(id: '2', emoji: '🏃', title: 'Running au parc', date: 'Dimanche 30 Mars', time: '09:00', participants: 12, category: 'Sport'),
      Event(id: '3', emoji: '🎸', title: 'Concert indie rock', date: 'Vendredi 4 Avril', time: '20:30', participants: 25, category: 'Culture'),
    ];
  }

  static Future<void> createEvent(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // TODO: POST to backend (Airtable/PocketBase)
  }
}
