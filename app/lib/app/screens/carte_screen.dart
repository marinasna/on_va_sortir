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
import 'package:create_good_app/app/core/db.dart';
import 'package:create_good_app/app/screens/chat_screen.dart';
import 'package:create_good_app/app/screens/create_event_screen.dart';
import 'package:create_good_app/app/screens/launch_screen.dart';
import 'package:create_good_app/app/screens/login_screen.dart';
import 'package:create_good_app/app/screens/main_screen.dart';
import 'package:create_good_app/app/screens/message_list_screen.dart';
import 'package:create_good_app/app/screens/parametres_screen.dart';
import 'package:create_good_app/app/screens/profil_screen.dart';
import 'package:create_good_app/app/screens/register_screen.dart';
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
  String _currentCity = 'Paris';
  final MapController _mapController = MapController();
  List<Event> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _showEventDetails(Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EventDetailsSheet(
        event: event,
        onParticipationChanged: _loadEvents,
      ),
    );
  }

  Future<void> _loadEvents() async {
    final events = await EventService.fetchEvents();
    if (mounted) {
      setState(() {
        _events = events;
        _loading = false;
      });
    }
  }

  static const List<Map<String, String>> _categories = [
    {'emoji': '✨', 'label': 'Tous'},
    {'emoji': '🌙', 'label': 'Soirée'},
    {'emoji': '🏃', 'label': 'Sport'},
    {'emoji': '🎨', 'label': 'Culture'},
    {'emoji': '🍽️', 'label': 'Resto'},
    {'emoji': '🌳', 'label': 'Nature'},
    {'emoji': '🎮', 'label': 'Gaming'},
  ];

  static const _categoryColors = [
    LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFE8491C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF7A1E2A), Color(0xFF5A1520)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF3E8914), Color(0xFF5DB820)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF440EAB), Color(0xFF6844AC)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFFF6F3B), Color(0xFFE8541C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF266603), Color(0xFF3E8914)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF3A86FF), Color(0xFF003049)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopBar(
              currentCity: _currentCity,
              onCityChanged: (city) {
                setState(() => _currentCity = city);
                if (city == 'Paris') _mapController.move(const LatLng(48.8566, 2.3522), 13.0);
                if (city == 'Lyon') _mapController.move(const LatLng(45.7640, 4.8357), 13.0);
                if (city == 'Marseille') _mapController.move(const LatLng(43.2965, 5.3698), 13.0);
              },
            ),
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
            child: _loading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _MapView(
                    mapController: _mapController, 
                    onEventTap: _showEventDetails,
                    events: _events.where((e) {
                      final selected = _categories[_selectedCategoryIndex]['label'];
                      if (selected == 'Tous') return true;
                      return e.category == selected;
                    }).toList(),
                  ),
          ),
          // FAB
          Positioned(
            bottom: 24,
            right: 16,
            child: GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(context, '/create-event');
                _loadEvents();
              },
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
  final String currentCity;
  final ValueChanged<String> onCityChanged;

  const _TopBar({required this.currentCity, required this.onCityChanged});

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
                      Text(currentCity, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: AppColors.textDark)),
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
              onTap: () {
                onCityChanged('Paris');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city, color: Colors.grey),
              title: const Text('Lyon'),
              onTap: () {
                onCityChanged('Lyon');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city, color: Colors.grey),
              title: const Text('Marseille'),
              onTap: () {
                onCityChanged('Marseille');
                Navigator.pop(context);
              },
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
  final MapController mapController;
  final List<Event> events;
  final void Function(Event) onEventTap;

  const _MapView({required this.mapController, required this.events, required this.onEventTap});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
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
          markers: events.where((e) => e.lat != 0.0 && e.lng != 0.0).map((e) {
            Color catColor = AppColors.primary;
            if (e.category == 'Sport') catColor = const Color(0xFF3E8914);
            if (e.category == 'Soirée') catColor = const Color(0xFFFF6B35);
            if (e.category == 'Culture') catColor = const Color(0xFF440EAB);
            if (e.category == 'Resto') catColor = const Color(0xFFE8541C);
            if (e.category == 'Nature') catColor = const Color(0xFF3E8914);
            if (e.category == 'Gaming') catColor = const Color(0xFF3A86FF);
            
            return Marker(
              point: LatLng(e.lat, e.lng),
              width: 48,
              height: 48,
              child: GestureDetector(
                onTap: () => onEventTap(e),
                child: _MapMarker(
                  emoji: e.emoji,
                  color: catColor,
                  round: true,
                ),
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
          child: _ZoomControls(mapController: mapController),
        ),
      ],
    );
  }
}

class _ZoomControls extends StatelessWidget {
  final MapController mapController;
  
  const _ZoomControls({required this.mapController});

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
          GestureDetector(
            onTap: () => mapController.move(mapController.camera.center, mapController.camera.zoom + 1),
            child: const _ZoomBtn(label: '+'),
          ),
          Container(height: 1, color: Colors.grey.shade300),
          GestureDetector(
            onTap: () => mapController.move(mapController.camera.center, mapController.camera.zoom - 1),
            child: const _ZoomBtn(label: '−'),
          ),
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
  final String emoji;
  final Color color;
  final bool round;

  const _MapMarker({required this.emoji, required this.color, required this.round});

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
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class _EventDetailsSheet extends StatefulWidget {
  final Event event;
  final VoidCallback onParticipationChanged;

  const _EventDetailsSheet({required this.event, required this.onParticipationChanged});

  @override
  State<_EventDetailsSheet> createState() => _EventDetailsSheetState();
}

class _EventDetailsSheetState extends State<_EventDetailsSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final curUserId = pb.authStore.record?.id;
    final isParticipating = widget.event.participants.contains(curUserId);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(AppRadius.xl), topRight: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(color: AppColors.lightOrangeBg, borderRadius: BorderRadius.circular(AppRadius.lg)),
                  child: Center(child: Text(widget.event.emoji, style: const TextStyle(fontSize: 32))),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.event.title, style: AppTextStyles.heading2, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(widget.event.category, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                const Icon(Icons.access_time_outlined, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text('${widget.event.date.day.toString().padLeft(2,'0')}/${widget.event.date.month.toString().padLeft(2,'0')}/${widget.event.date.year} à ${widget.event.date.hour.toString().padLeft(2,'0')}h${widget.event.date.minute.toString().padLeft(2, '0')}', style: AppTextStyles.body),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(Icons.group_outlined, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text('${widget.event.participants.length} Participant(s)', style: AppTextStyles.body),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: isParticipating ? 'Me désinscrire' : 'M\'inscrire',
              loading: _isLoading,
              onTap: () async {
                setState(() => _isLoading = true);
                try {
                  await EventService.toggleEventParticipation(widget.event);
                  widget.onParticipationChanged();
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                  if (mounted) setState(() => _isLoading = false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
