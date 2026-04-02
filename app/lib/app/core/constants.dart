import 'package:flutter/material.dart';

class AppCategories {
  static const List<Map<String, dynamic>> list = [
    {'label': 'Gaming', 'emoji': '🎮', 'color': [Color(0xFF3A86FF), Color(0xFF003049)]},
    {'label': 'Sport', 'emoji': '🏃', 'color': [Color(0xFF3E8914), Color(0xFF5DB820)]},
    {'label': 'Food', 'emoji': '🍽️', 'color': [Color(0xFFFF6F3B), Color(0xFFE8541C)]},
    {'label': 'Soirées', 'emoji': '🌙', 'color': [Color(0xFF7A1E2A), Color(0xFF5A1520)]},
    {'label': 'Nature', 'emoji': '🌳', 'color': [Color(0xFF266603), Color(0xFF3E8914)]},
    {'label': 'Culture', 'emoji': '🎨', 'color': [Color(0xFF440EAB), Color(0xFF6844AC)]},
  ];

  static Map<String, dynamic>? getCategory(String label) {
    try {
      return list.firstWhere((cat) => cat['label'] == label);
    } catch (_) {
      return null;
    }
  }

  static LinearGradient getGradient(String label) {
    final cat = getCategory(label);
    if (cat != null) {
      final colors = cat['color'] as List<Color>;
      return LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight);
    }
    return const LinearGradient(colors: [Color(0xFF9E9E9E), Color(0xFF616161)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  }

  static Color getPrimaryColor(String label) {
    final cat = getCategory(label);
    if (cat != null) {
      return (cat['color'] as List<Color>).first;
    }
    return Colors.grey;
  }
}
