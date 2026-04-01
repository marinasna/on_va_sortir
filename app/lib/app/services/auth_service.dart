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
import 'package:pocketbase/pocketbase.dart';
import 'package:create_good_app/app/core/db.dart';
class AuthService {
  static Future<void> login(String email, String password) async {
    try {
      await pb.collection('users').authWithPassword(email, password);
    } on ClientException catch (e) {
      throw Exception(e.response['message'] ?? 'Email ou mot de passe incorrect');
    } catch (e) {
      throw Exception('Erreur de connexion');
    }
  }

  static Future<void> register(Map<String, dynamic> data) async {
    try {
      final email = data['email'] as String;
      final password = data['password'] as String;
      final name = data['name'] as String;
      
      final username = email.split('@')[0].replaceAll(RegExp(r'[^a-zA-Z0-9]'), '') + DateTime.now().millisecondsSinceEpoch.toString().substring(9);
      final body = <String, dynamic>{
        "username": username.toLowerCase(),
        "email": email,
        "emailVisibility": true,
        "password": password,
        "passwordConfirm": password,
        "name": name,
        "age": int.tryParse(data['age'] ?? '0') ?? 0,
        "gender": data['gender'] ?? '',
        "location": data['location'] ?? '',
        "phone": data['phone'] ?? '',
        "school": "",
        "events_count": 0,
        "friends_count": 0,
        "groups_count": 0,
      };
      
      await pb.collection('users').create(body: body);
      await login(email, password);
    } on ClientException catch (e) {
      throw Exception(e.response['message'] ?? 'Erreur lors de l\'inscription');
    } catch (e) {
      throw Exception('Une erreur est survenue');
    }
  }

  static void logout() {
    pb.authStore.clear();
  }

  static bool get isAuthenticated => pb.authStore.isValid;
}
