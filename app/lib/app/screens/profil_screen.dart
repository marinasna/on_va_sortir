import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:create_good_app/app/core/theme.dart';
import 'package:create_good_app/app/models/event.dart';
import 'package:create_good_app/app/services/auth_service.dart';
import 'package:create_good_app/app/widgets/primary_button.dart';
import 'package:create_good_app/app/screens/friends_screen.dart';
import 'package:create_good_app/app/core/constants.dart';
import 'package:create_good_app/app/core/accessibility_provider.dart';
import 'package:create_good_app/app/core/event_provider.dart';
import 'package:create_good_app/app/core/friend_provider.dart';
import 'package:create_good_app/app/screens/event_detail_screen.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:create_good_app/app/core/db.dart';
import 'dart:async';

// PROFIL SCREEN
// ─────────────────────────────────────────────
class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  late StreamSubscription<AuthStoreEvent> _authSub;

  @override
  void initState() {
    super.initState();
    // Refresh on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      EventProvider.instance.refresh();
      FriendProvider.instance.refresh();
      context.read<AccessibilityProvider>().loadPreferences();
    });

    _authSub = pb.authStore.onChange.listen((event) {
      if (mounted) {
        setState(() {}); // For user info
        EventProvider.instance.refresh();
      }
    });
  }


  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Écouter les providers
    context.watch<AccessibilityProvider>();
    final eventProv = context.watch<EventProvider>();
    final friendProv = context.watch<FriendProvider>();
    
    final curUserId = pb.authStore.record?.id;
    final joinedEvents = eventProv.events.where((e) => e.participants.contains(curUserId)).toList();
    final friendsCount = friendProv.friends.length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ProfilHeader(
              eventsCount: joinedEvents.length,
              friendsCount: friendsCount,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Centres d'intérêt", style: AppTextStyles.heading2),
                  const SizedBox(height: AppSpacing.md),
                  Builder(
                    builder: (context) {
                      final user = pb.authStore.model is RecordModel ? pb.authStore.model as RecordModel : null;
                      final userInterests = user?.getListValue<String>('interests') ?? [];
                      if (userInterests.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Aucun centre d\'intérêt renseigné.', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                        );
                      }
                      return Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: userInterests.map((label) {
                          final cat = AppCategories.getCategory(label);
                          final emoji = cat?['emoji'] ?? '✨';
                          return _InterestChip(emoji: emoji as String, label: label);
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Mes événements à venir', style: AppTextStyles.heading2),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          if (eventProv.loading && eventProv.events.isEmpty)
            const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())))
          else if (joinedEvents.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_busy, size: 48, color: AppColors.textSecondary.withOpacity(0.5)),
                      const SizedBox(height: AppSpacing.md),
                      Text('Aucun événement rejoint', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EventDetailScreen(event: joinedEvents[i])),
                    ),
                    child: _EventTile(event: joinedEvents[i]),
                  ),
                ),
                childCount: joinedEvents.length,
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: PrimaryButton(
                label: '+ Créer un nouvel événement',
                onTap: () => Navigator.pushNamed(context, '/create-event'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Accessibilité', style: AppTextStyles.heading2),
                  const SizedBox(height: AppSpacing.md),
                  Consumer<AccessibilityProvider>(
                    builder: (context, acc, child) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            _AccessibilityToggle(
                              icon: Icons.text_fields,
                              title: 'Texte agrandi',
                              subtitle: 'Police plus grande',
                              value: acc.largeText,
                              onChanged: (v) => acc.updateLargeText(v),
                            ),
                            const Divider(height: 1, indent: 56),
                            _AccessibilityToggle(
                              icon: Icons.contrast,
                              title: 'Contraste élevé',
                              subtitle: 'Couleurs simplifiées',
                              value: acc.highContrast,
                              onChanged: (v) => acc.updateHighContrast(v),
                            ),
                            const Divider(height: 1, indent: 56),
                            _AccessibilityToggle(
                              icon: Icons.dark_mode,
                              title: 'Mode sombre',
                              subtitle: 'Interface foncée',
                              value: acc.darkMode,
                              onChanged: (v) => acc.updateDarkMode(v),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: AppSpacing.xl),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        context.read<AccessibilityProvider>().reset();
                        AuthService.logout();
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                      },
                      icon: Icon(Icons.logout, color: AppColors.primary),
                      label: Text(
                        'Se déconnecter',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilHeader extends StatelessWidget {
  final int eventsCount;
  final int friendsCount;
  
  const _ProfilHeader({
    required this.eventsCount,
    required this.friendsCount,
  });

  @override
  Widget build(BuildContext context) {
    // Écouter le provider pour la réactivité du thème
    context.watch<AccessibilityProvider>();
    final user = pb.authStore.record;
    final String name = user != null && user.getStringValue('name').isNotEmpty ? user.getStringValue('name') : 'Utilisateur';
    final String username = user != null && user.getStringValue('username').isNotEmpty ? '@${user.getStringValue('username')}' : '@user';
    final String age = user != null && user.getIntValue('age') > 0 ? '${user.getIntValue('age')} ans' : '';
    final String school = user != null && user.getStringValue('school').isNotEmpty ? user.getStringValue('school') : 'École non renseignée';
    final String location = user != null && user.getStringValue('location').isNotEmpty ? user.getStringValue('location') : 'Lieu non renseigné';
    final String friendsCountStr = friendsCount.toString();
    final String groupsCountStr = eventsCount.toString();

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
        // Icône paramètres supprimée
        Positioned(
          top: 100,
          left: 38,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: AppColors.lightOrangeBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 3),
                ),
                child: const Center(child: Text('👤', style: TextStyle(fontSize: 48))),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                  child: Icon(Icons.edit, color: Colors.white, size: 18),
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
                  Icon(Icons.school_outlined, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(school, style: AppTextStyles.bodySmall),
                  const SizedBox(width: AppSpacing.md),
                  Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
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
                    _StatItem(value: eventsCount.toString(), label: 'Événements'),
                    Container(width: 1, height: 40, color: AppColors.border),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FriendsScreen())),
                      child: _StatItem(value: friendsCountStr, label: 'Amis'),
                    ),
                    Container(width: 1, height: 40, color: AppColors.border),
                    _StatItem(value: groupsCountStr, label: 'Groupes'),
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
                    Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('${event.date.day.toString().padLeft(2, "0")}/${event.date.month.toString().padLeft(2, "0")}/${event.date.year}', style: AppTextStyles.caption),
                    const SizedBox(width: 8),
                    Text('${event.date.hour.toString().padLeft(2, "0")}:${event.date.minute.toString().padLeft(2, "0")}', style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.group_outlined, size: 14, color: AppColors.textSecondary),
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

class _AccessibilityToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AccessibilityToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(AppRadius.sm)),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
