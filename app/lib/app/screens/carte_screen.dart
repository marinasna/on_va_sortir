import 'package:flutter/material.dart';
import 'package:create_good_app/app/core/theme.dart';
import 'package:create_good_app/app/models/event.dart';
import 'package:create_good_app/app/screens/event_detail_screen.dart';
import 'package:create_good_app/app/models/notification.dart';
import 'package:create_good_app/app/services/event_service.dart';
import 'package:create_good_app/app/services/message_service.dart';
import 'package:create_good_app/app/services/notification_service.dart';
import 'package:create_good_app/app/services/friend_service.dart';
import 'package:create_good_app/app/widgets/primary_button.dart';
import 'package:create_good_app/app/core/db.dart';
import 'package:create_good_app/app/screens/chat_screen.dart';
import 'package:create_good_app/app/core/constants.dart';
import 'package:create_good_app/app/core/event_provider.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      EventProvider.instance.refresh();
    });
  }

  void _showEventDetails(Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EventDetailsSheet(
        event: event,
      ),
    );
  }


  final List<Map<String, dynamic>> _filterCategories = [
    {'label': 'Tous', 'emoji': '✨'},
    ...AppCategories.list
  ];

  late final List<LinearGradient> _filterColors = [
    AppCategories.getGradient('Tous'),
    ...AppCategories.list.map((c) => AppCategories.getGradient(c['label'])).toList(),
  ];

  @override
  Widget build(BuildContext context) {
    final eventProv = context.watch<EventProvider>();
    final allEvents = eventProv.events;

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
              events: allEvents,
              onEventSelected: (event) {
                _mapController.move(LatLng(event.lat, event.lng), 14.0);
                _showEventDetails(event);
              },
              onCityChanged: (city) {
                setState(() => _currentCity = city);
                if (city == 'Paris') _mapController.move(const LatLng(48.8566, 2.3522), 11.5);
                if (city == 'Lyon') _mapController.move(const LatLng(45.7640, 4.8357), 11.5);
                if (city == 'Marseille') _mapController.move(const LatLng(43.2965, 5.3698), 11.5);
              },
            ),
          ),
          // Category filter
          Positioned(
            top: MediaQuery.of(context).padding.top + 64,
            left: 0,
            right: 0,
            child: _CategoryFilter(
              categories: _filterCategories.map((e) => {'label': e['label'] as String, 'emoji': e['emoji'] as String}).toList(),
              colors: _filterColors,
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
            child: (eventProv.loading && allEvents.isEmpty)
                ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _MapView(
                    mapController: _mapController, 
                    onEventTap: _showEventDetails,
                    events: allEvents.where((e) {
                      final selected = _filterCategories[_selectedCategoryIndex]['label'];
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
              onTap: () {
                Navigator.pushNamed(context, '/create-event');
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: Icon(Icons.add, color: AppColors.onPrimary, size: 32),
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
  final List<Event> events;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<Event> onEventSelected;

  const _TopBar({
    required this.currentCity, 
    required this.events,
    required this.onCityChanged,
    required this.onEventSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
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
                      Icon(Icons.location_on, color: AppColors.orange, size: 20),
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
                onTap: () => showSearch(
                  context: context, 
                  delegate: _EventSearchDelegate(
                    events: events,
                    onEventSelected: onEventSelected,
                  ),
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.search, color: AppColors.textDark, size: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _NotificationBell(onTap: () => _showNotificationsBottomsheet(context)),
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
              leading: Icon(Icons.location_city, color: AppColors.primary),
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
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _NotificationsSheet(),
    );
  }
}

class _NotificationsSheet extends StatefulWidget {
  const _NotificationsSheet();

  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  List<AppNotification> _notifs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await AppNotificationService.fetchNotifications();
    if (mounted) setState(() { _notifs = list; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Notifications', style: AppTextStyles.heading2),
              if (_notifs.any((n) => !n.isRead))
                TextButton(
                  onPressed: () async {
                    await AppNotificationService.markAllAsRead();
                    _load();
                  },
                  child: Text('Tout marquer comme lu', style: TextStyle(color: AppColors.primary)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (_loading)
            Center(child: CircularProgressIndicator(color: AppColors.orange))
          else if (_notifs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('Aucune notification', style: TextStyle(color: Colors.grey))),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _notifs.length,
                separatorBuilder: (_, __) => Divider(height: 1, indent: 72, color: AppColors.border),
                itemBuilder: (_, i) {
                  final notif = _notifs[i];
                  IconData icon = Icons.notifications;
                  Color color = AppColors.orange;
                  
                  if (notif.type == NotifType.friendRequest) { icon = Icons.person_add; color = AppColors.primary; }
                  else if (notif.type == NotifType.friendAccepted) { icon = Icons.people; color = AppColors.green; }
                  
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color, size: 20)),
                    title: Text(notif.title, style: TextStyle(fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notif.content, style: TextStyle(color: AppColors.textDark, fontWeight: notif.isRead ? FontWeight.normal : FontWeight.w500)),
                        const SizedBox(height: 4),
                        if (notif.type == NotifType.friendRequest && !notif.isRead) ...[
                          Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 12), minimumSize: const Size(0, 30)),
                                onPressed: () async {
                                  if (notif.actionData != null) {
                                    await FriendService.acceptFriendRequest(notif.actionData!);
                                    _load();
                                  }
                                },
                                child: const Text('Accepter', style: TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () async {
                                  if (notif.actionData != null) {
                                    await FriendService.rejectFriendRequest(notif.actionData!);
                                    _load();
                                  }
                                },
                                child: Text('Refuser', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text('${notif.created.day}/${notif.created.month} ${notif.created.hour}:${notif.created.minute.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                    onTap: () async {
                      if (!notif.isRead) await AppNotificationService.markAsRead(notif.id);
                      if (notif.type == NotifType.friendAccepted && notif.senderId != null) {
                        Navigator.pop(context);
                        final conv = await MessageService.getOrCreatePrivateConversation(notif.senderId!, notif.senderRecord?.getStringValue('name') ?? 'Utilisateur');
                        if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv)));
                      } else {
                        _load();
                      }
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _EventSearchDelegate extends SearchDelegate {
  final List<Event> events;
  final ValueChanged<Event> onEventSelected;

  _EventSearchDelegate({required this.events, required this.onEventSelected});

  @override
  String get searchFieldLabel => 'Rechercher un événement ou catégorie...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back), 
      onPressed: () => close(context, null)
    );
  }

  List<Event> _getFilteredEvents() {
    if (query.length < 2) return [];
    return events.where((e) {
      final q = query.toLowerCase();
      return e.title.toLowerCase().contains(q) || 
             e.category.toLowerCase().contains(q) ||
             e.description.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 2) {
      return const Center(child: Text('Tapez au moins 2 lettres pour rechercher'));
    }
    final filtered = _getFilteredEvents();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('Aucun résultat pour "$query"', style: AppTextStyles.heading2),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final event = filtered[i];
        return _buildEventTile(context, event);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Suggestions', style: AppTextStyles.captionBold),
          ),
          ...AppCategories.list.take(3).map((cat) => ListTile(
            leading: Text(cat['emoji']!, style: const TextStyle(fontSize: 20)),
            title: Text(cat['label']!),
            onTap: () => query = cat['label']!,
          )),
        ],
      );
    }

    if (query.length < 2) {
      return const SizedBox.shrink();
    }

    final filtered = _getFilteredEvents();
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final event = filtered[i];
        return _buildEventTile(context, event);
      },
    );
  }

  Widget _buildEventTile(BuildContext context, Event event) {
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.lightOrangeBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text(event.emoji, style: const TextStyle(fontSize: 20))),
      ),
      title: Text(event.title, style: AppTextStyles.label),
      subtitle: Text(event.category, style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
      onTap: () {
        close(context, null);
        Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)));
      },
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
        initialZoom: 11.5,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.create_good_app',
        ),
        MarkerLayer(
          markers: events.where((e) => e.lat != 0.0 && e.lng != 0.0).map((e) {
            Color catColor = AppCategories.getPrimaryColor(e.category);

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

  const _EventDetailsSheet({required this.event});

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
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(event: widget.event))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(widget.event.title, style: AppTextStyles.heading2, maxLines: 2, overflow: TextOverflow.ellipsis)),
                            Icon(Icons.chevron_right, color: AppColors.textSecondary),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(widget.event.category, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (widget.event.description.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text('Description', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.xs),
              Text(widget.event.description, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDark)),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Icon(Icons.access_time_outlined, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text('${widget.event.date.day.toString().padLeft(2, '0')}/${widget.event.date.month.toString().padLeft(2, '0')}/${widget.event.date.year} à ${widget.event.date.hour.toString().padLeft(2, '0')}h${widget.event.date.minute.toString().padLeft(2, '0')}', style: AppTextStyles.body),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.group_outlined, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text('${widget.event.participants.length} Participant(s)', style: AppTextStyles.body),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            if (isParticipating)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.chat_bubble_outline, size: 20),
                    label: const Text('Discussion de groupe', style: TextStyle(fontFamily: AppTextStyles.fontFamily, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                    onPressed: () async {
                      final conv = await MessageService.joinEventConversation(widget.event.id, widget.event.title, widget.event.emoji);
                      if (mounted) {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv)));
                      }
                    },
                  ),
                ),
              ),
            PrimaryButton(
              label: isParticipating ? 'Me désinscrire' : 'M\'inscrire',
              loading: _isLoading,
              onTap: () async {
                setState(() => _isLoading = true);
                try {
                  await EventService.toggleEventParticipation(widget.event);
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

class _NotificationBell extends StatefulWidget {
  final VoidCallback onTap;
  const _NotificationBell({required this.onTap});

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    final list = await AppNotificationService.fetchNotifications();
    final count = list.where((n) => !n.isRead).length;
    if (mounted && count != _unreadCount) {
      setState(() => _unreadCount = count);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          widget.onTap();
          // Reload count when closing the bottom sheet
          Future.delayed(const Duration(milliseconds: 500), _loadCount);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_outlined, color: AppColors.textDark, size: 24),
              if (_unreadCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                    child: Center(
                      child: Text('$_unreadCount', style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
