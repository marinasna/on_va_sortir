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

// PROFIL SCREEN
// ─────────────────────────────────────────────
class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  List<Event> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    EventService.fetchEvents().then((e) {
      if (mounted) setState(() { _events = e; _loading = false; });
    });
  }

  static const List<Map<String, String>> _interests = [
    {'emoji': '🎮', 'label': 'Gaming'},
    {'emoji': '🏃', 'label': 'Sport'},
    {'emoji': '🎨', 'label': 'Art'},
    {'emoji': '📚', 'label': 'Lecture'},
    {'emoji': '🎬', 'label': 'Cinéma'},
    {'emoji': '🍕', 'label': 'Food'},
  ];

  static const List<Map<String, String>> _badges = [
    {'emoji': '🏆', 'label': 'Top Host'},
    {'emoji': '⭐', 'label': 'Rising Star'},
    {'emoji': '💬', 'label': 'Social'},
    {'emoji': '🧭', 'label': 'Explorer'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _ProfilHeader()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Centres d'intérêt", style: AppTextStyles.heading2),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _interests.map((i) => _InterestChip(emoji: i['emoji']!, label: i['label']!)).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Badges', style: AppTextStyles.heading2),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: _badges.map((b) => _BadgeItem(emoji: b['emoji']!, label: b['label']!)).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Mes événements à venir', style: AppTextStyles.heading2),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          if (_loading)
            const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColors.orange))))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _EventTile(event: _events[i]),
                ),
                childCount: _events.length,
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(
                label: '+ Créer un nouvel événement',
                onTap: () => Navigator.pushNamed(context, '/create-event'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = pb.authStore.model is RecordModel ? pb.authStore.model as RecordModel : null;
    final String name = user != null && user.getStringValue('name').isNotEmpty ? user.getStringValue('name') : 'Utilisateur';
    final String username = user != null && user.getStringValue('username').isNotEmpty ? '@${user.getStringValue('username')}' : '@user';
    final String age = user != null && user.getIntValue('age') > 0 ? '${user.getIntValue('age')} ans' : '';
    final String school = user != null && user.getStringValue('school').isNotEmpty ? user.getStringValue('school') : 'École non renseignée';
    final String location = user != null && user.getStringValue('location').isNotEmpty ? user.getStringValue('location') : 'Lieu non renseigné';
    final String eventsCount = user != null ? user.getIntValue('events_count').toString() : '0';
    final String friendsCount = user != null ? user.getIntValue('friends_count').toString() : '0';
    final String groupsCount = user != null ? user.getIntValue('groups_count').toString() : '0';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: AppSpacing.md,
          right: AppSpacing.md,
          child: SafeArea(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParametresScreen())),
              ),
            ),
          ),
        ),
        Positioned(
          top: 100,
          left: 38,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0C8A8),
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 3)),
                ),
                child: const Center(child: Text('👤', style: TextStyle(fontSize: 48))),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 210),
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Text(name, style: AppTextStyles.heading1.copyWith(fontSize: 28)),
              const SizedBox(height: 4),
              Text('$username${age.isNotEmpty ? ' • $age' : ''}', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.school_outlined, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(school, style: AppTextStyles.bodySmall),
                  const SizedBox(width: AppSpacing.md),
                  const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(location, style: AppTextStyles.bodySmall),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(value: eventsCount, label: 'Événements'),
                    Container(width: 1, height: 40, color: AppColors.border),
                    _StatItem(value: friendsCount, label: 'Amis'),
                    Container(width: 1, height: 40, color: AppColors.border),
                    _StatItem(value: groupsCount, label: 'Groupes'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.heading1.copyWith(fontSize: 28, color: AppColors.primary)),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _InterestChip extends StatelessWidget {
  final String emoji;
  final String label;
  const _InterestChip({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.border),
      ),
      child: Text('$emoji $label', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w500)),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final String emoji;
  final String label;
  const _BadgeItem({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.lightOrangeBg,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final Event event;
  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.lightOrangeBg,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(child: Text(event.emoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: AppTextStyles.heading3.copyWith(fontSize: 15)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('${event.date.day.toString().padLeft(2, "0")}/${event.date.month.toString().padLeft(2, "0")}/${event.date.year}', style: AppTextStyles.caption),
                    const SizedBox(width: 8),
                    Text('${event.date.hour.toString().padLeft(2, "0")}:${event.date.minute.toString().padLeft(2, "0")}', style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.group_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('${event.participants.length} participants', style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
