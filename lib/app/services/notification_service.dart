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

class AppNotificationService {
  static Future<List<AppNotification>> fetchNotifications() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      AppNotification(id: '1', text: "Marie Dubois t'a envoyé une demande d'ami", time: '5 min', type: NotifType.friendRequest, unread: true),
      AppNotification(id: '2', text: 'Alex Martin t\'a invité à "Soirée jeux de société"', time: '1h', type: NotifType.eventInvite, unread: true),
      AppNotification(id: '3', text: '"Running au parc" commence dans 2 heures', time: '2h', type: NotifType.eventReminder),
      AppNotification(id: '4', text: 'Sophie Laurent a rejoint "Concert indie rock"', time: '3h', type: NotifType.eventJoin),
      AppNotification(id: '5', text: '"Picnic au parc" L\'heure a été modifiée', time: 'Hier', type: NotifType.eventUpdate),
      AppNotification(id: '6', text: 'Tu as participé à 10 événements ! 🎉', time: 'Hier', type: NotifType.achievement),
    ];
  }
}
