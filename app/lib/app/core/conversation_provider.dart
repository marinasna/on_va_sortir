import 'package:flutter/material.dart';
import 'package:create_good_app/app/models/message.dart';
import 'package:create_good_app/app/services/message_service.dart';

class ConversationProvider with ChangeNotifier {
  static final ConversationProvider _instance = ConversationProvider._internal();
  static ConversationProvider get instance => _instance;

  ConversationProvider._internal();

  List<Conversation> _conversations = [];
  bool _loading = false;

  List<Conversation> get conversations => _conversations;
  bool get loading => _loading;

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    
    try {
      _conversations = await MessageService.fetchConversations();
    } catch (e) {
      debugPrint('Error refreshing conversations: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
