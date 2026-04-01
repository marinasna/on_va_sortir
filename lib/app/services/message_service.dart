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

class MessageService {
  static Future<List<Message>> fetchMessages() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const [
      Message(id: '1', name: 'Marie Dubois', lastMessage: 'On se retrouve à 18h devant la fac ?', time: '14:30', unread: 2),
      Message(id: '2', name: 'Groupe Soirée Jeudi', lastMessage: 'Thomas: Super idée ! Je ramène les chips 🎉', time: '13:45', unread: 0, isGroup: true),
      Message(id: '3', name: 'Alex Martin', lastMessage: "Merci pour l'invitation !", time: 'Hier', unread: 0),
      Message(id: '4', name: 'Sophie Laurent', lastMessage: 'Tu viens au concert demain ?', time: 'Hier', unread: 1),
      Message(id: '5', name: 'Running Club 🏃', lastMessage: 'RDV dimanche 9h au parc !', time: 'Sam', unread: 0, isGroup: true),
    ];
  }
}
