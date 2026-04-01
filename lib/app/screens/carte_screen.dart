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
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// CARTE (MAP) SCREEN
// ─────────────────────────────────────────────
class CarteScreen extends StatefulWidget {
  const CarteScreen({super.key});

  @override
  State<CarteScreen> createState() => _CarteScreenState();
}

class _CarteScreenState extends State<CarteScreen> {
  int _selectedCategoryIndex = 0;

  static const List<Map<String, String>> _categories = [
    {'emoji': '✨', 'label': 'Tous'},
    {'emoji': '🌙', 'label': 'Soirées'},
    {'emoji': '🏃', 'label': 'Sport'},
    {'emoji': '🎨', 'label': 'Culture'},
    {'emoji': '🍽️', 'label': 'Resto'},
    {'emoji': '🌳', 'label': 'Nature'},
  ];

  static const List<Map<String, dynamic>> _markers = [
    {'lat': 48.8566, 'lng': 2.3522, 'count': 15, 'color': Color(0xFFFF6B35), 'round': true},
    {'lat': 48.8606, 'lng': 2.3322, 'count': 10, 'color': Color(0xFF3E8914), 'round': true},
    {'lat': 48.8466, 'lng': 2.3422, 'count': 12, 'color': Color(0xFF7A1E2A), 'round': false},
    {'lat': 48.8266, 'lng': 2.3622, 'count': 4, 'color': Color(0xFFFFA07A), 'round': false},
    {'lat': 48.8766, 'lng': 2.3622, 'count': 5, 'color': Color(0xFFFF6B35), 'round': true},
    {'lat': 48.8866, 'lng': 2.3222, 'count': 8, 'color': Color(0xFF3E8914), 'round': true},
    {'lat': 48.8516, 'lng': 2.3722, 'count': 20, 'color': Color(0xFF6844AC), 'round': true},
    {'lat': 48.8616, 'lng': 2.3822, 'count': 7, 'color': Color(0xFF7A1E2A), 'round': false},
  ];

  static const _categoryColors = [
    LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFE8491C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF7A1E2A), Color(0xFF5A1520)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF3E8914), Color(0xFF5DB820)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF440EAB), Color(0xFF6844AC)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFFF6F3B), Color(0xFFE8541C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF266603), Color(0xFF3E8914)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopBar(),
          ),
          // Category filter
          Positioned(
            top: MediaQuery.of(context).padding.top + 64,
            left: 0,
            right: 0,
            child: _CategoryFilter(
              categories: _categories,
              colors: _categoryColors,
              selectedIndex: _selectedCategoryIndex,
              onSelect: (i) => setState(() => _selectedCategoryIndex = i),
            ),
          ),
          // Map area
          Positioned(
            top: MediaQuery.of(context).padding.top + 64 + 136,
            bottom: 0,
            left: 0,
            right: 0,
            child: _MapView(markers: _markers),
          ),
          // "Étudiants ici" badge
          Positioned(
            top: MediaQuery.of(context).padding.top + 64 + 136 + 16,
            left: 0,
            right: 0,
            child: Center(child: _EtudiantsBadge()),
          ),
          // FAB
          Positioned(
            bottom: 24,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/create-event'),
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFE8491C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0x40000000), blurRadius: 20, offset: Offset(0, 8)),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: Row(
          children: [
            Material(
              color: AppColors.lightOrangeBg,
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.full),
                onTap: () => _showLocationBottomsheet(context),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, color: AppColors.orange, size: 20),
                      const SizedBox(width: 4),
                      Text('Paris', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      const SizedBox(width: 4),
                      Text('▼', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            Material(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.full),
                onTap: () => showSearch(context: context, delegate: _DummySearchDelegate()),
                child: Container(
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.search, color: AppColors.textSecondary, size: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: () => _showNotificationsBottomsheet(context),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_outlined, color: AppColors.textDark, size: 24),
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                          child: Center(
                            child: Text('3', style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationBottomsheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choisir une ville', style: AppTextStyles.heading2),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.location_city, color: AppColors.primary),
              title: const Text('Paris'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.location_city, color: Colors.grey),
              title: const Text('Lyon'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.location_city, color: Colors.grey),
              title: const Text('Marseille'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsBottomsheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications', style: AppTextStyles.heading2),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const CircleAvatar(backgroundColor: AppColors.lightOrangeBg, child: Text('🍕')),
              title: const Text('Nouvelle invitation'),
              subtitle: const Text('Jean vous invite à "Soirée Pizza"'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: AppColors.lightOrangeBg, child: Text('🔥')),
              title: const Text('2 nouveaux amis'),
              subtitle: const Text('Alice et Bob ont accepté votre demande'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _DummySearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Text("Résultats de recherche pour '$query'"));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView(
      children: const [
        ListTile(leading: Icon(Icons.search), title: Text("Rechercher des soirées étudiantes...")),
        ListTile(leading: Icon(Icons.search), title: Text("Rechercher des musées à visiter...")),
      ],
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final List<Map<String, String>> categories;
  final List<LinearGradient> colors;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _CategoryFilter({
    required this.categories,
    required this.colors,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 136,
      color: AppColors.background,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final cat = categories[i];
          final active = i == selectedIndex;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelect(i),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Opacity(
                opacity: active ? 1.0 : 0.7,
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: active ? 80 : 64,
                        height: active ? 80 : 64,
                        decoration: BoxDecoration(
                          gradient: colors[i],
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Center(
                          child: Text(cat['emoji']!, style: const TextStyle(fontSize: 28)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cat['label']!,
                        style: AppTextStyles.captionBold.copyWith(
                          color: active ? AppColors.orange : AppColors.textLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MapView extends StatelessWidget {
  final List<Map<String, dynamic>> markers;

  const _MapView({required this.markers});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: const LatLng(48.8566, 2.3522), // Paris
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.create_good_app',
        ),
        MarkerLayer(
          markers: markers.map((m) {
            return Marker(
              point: LatLng(m['lat'] as double, m['lng'] as double),
              width: 48,
              height: 48,
              child: _MapMarker(
                count: m['count'] as int,
                color: m['color'] as Color,
                round: m['round'] as bool,
              ),
            );
          }).toList(),
        ),
        // Map attribution
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            color: Colors.white.withValues(alpha: 0.8),
            child: Text('© OpenStreetMap contributors', style: AppTextStyles.caption.copyWith(fontSize: 10)),
          ),
        ),
        // Zoom controls
        Positioned(
          top: 10,
          left: 10,
          child: _ZoomControls(),
        ),
      ],
    );
  }
}

class _ZoomControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ZoomBtn(label: '+'),
          Container(height: 1, color: Colors.grey.shade300),
          _ZoomBtn(label: '−'),
        ],
      ),
    );
  }
}

class _ZoomBtn extends StatelessWidget {
  final String label;
  const _ZoomBtn({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: Center(
        child: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87)),
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final int count;
  final Color color;
  final bool round;

  const _MapMarker({required this.count, required this.color, required this.round});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        shape: round ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: round ? null : BorderRadius.circular(4),
        border: Border.all(color: Colors.white, width: 2.4),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Center(
        child: Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}

class _EtudiantsBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.full)),
            child: Text('100+', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 8),
          Text('Étudiants ici', style: AppTextStyles.button.copyWith(fontSize: 16)),
        ],
      ),
    );
  }
}

