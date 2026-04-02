import 'package:flutter/material.dart';
import 'package:create_good_app/app/models/friendship.dart';
import 'package:create_good_app/app/services/friend_service.dart';

class FriendProvider with ChangeNotifier {
  static final FriendProvider _instance = FriendProvider._internal();
  static FriendProvider get instance => _instance;

  FriendProvider._internal();

  List<Friendship> _friends = [];
  bool _loading = false;

  List<Friendship> get friends => _friends;
  bool get loading => _loading;

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    
    try {
      _friends = await FriendService.fetchFriends();
    } catch (e) {
      debugPrint('Error refreshing friends: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
