import 'package:flutter/material.dart';
import 'package:create_good_app/app/core/db.dart'; // Import de ton instance pb

class AccessibilityProvider with ChangeNotifier {
  bool _highContrast = false;
  bool _largeText = false;
  bool _reduceMotion = false;
  bool _screenReader = false;

  bool get highContrast => _highContrast;
  bool get largeText => _largeText;
  bool get reduceMotion => _reduceMotion;
  bool get screenReader => _screenReader;

  // Charger les préférences depuis PocketBase
  Future<void> loadPreferences() async {
    final authModel = pb.authStore.model;
    if (authModel != null) {
      final data = authModel.toJson();
      _highContrast = data['high_contrast'] ?? false;
      _largeText = data['large_text'] ?? false;
      _reduceMotion = data['reduced_animations'] ?? false;
      _screenReader = data['screen_reader_opt'] ?? false;
      notifyListeners();
    }
  }

  // Méthodes de mise à jour
  Future<void> updateHighContrast(bool value) async {
    _highContrast = value;
    notifyListeners();
    await _saveToPB('high_contrast', value);
  }

  Future<void> updateLargeText(bool value) async {
    _largeText = value;
    notifyListeners();
    await _saveToPB('large_text', value);
  }

  Future<void> updateReduceMotion(bool value) async {
    _reduceMotion = value;
    notifyListeners();
    await _saveToPB('reduced_animations', value);
  }

  Future<void> updateScreenReader(bool value) async {
    _screenReader = value;
    notifyListeners();
    await _saveToPB('screen_reader_opt', value);
  }

  Future<void> _saveToPB(String field, bool value) async {
    try {
      if (pb.authStore.isValid) {
        final userId = pb.authStore.model.id;
        await pb.collection('users').update(userId, body: {field: value});
      }
    } catch (e) {
      debugPrint("Erreur de sauvegarde accessibilité : $e");
    }
  }

  void reset() {
    _highContrast = false;
    _largeText = false;
    _reduceMotion = false;
    _screenReader = false;
    notifyListeners(); // On prévient l'app de revenir aux valeurs par défaut
    }
}