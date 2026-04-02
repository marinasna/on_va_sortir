import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:create_good_app/app/core/theme.dart';
import 'package:create_good_app/app/core/accessibility_provider.dart';
import 'package:create_good_app/app/core/db.dart';
import 'package:create_good_app/app/models/event.dart';
import 'package:create_good_app/app/services/event_service.dart';
import 'package:create_good_app/app/widgets/primary_button.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Event _event;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    initializeDateFormatting('fr_FR', null);
  }

  Future<void> _toggleParticipation() async {
    setState(() => _loading = true);
    try {
      final isJoining = await EventService.toggleEventParticipation(_event);
      
      final currentUserId = pb.authStore.record?.id;
      if (currentUserId != null) {
        final newParticipants = List<String>.from(_event.participants);
        if (isJoining) {
          if (!newParticipants.contains(currentUserId)) newParticipants.add(currentUserId);
        } else {
          newParticipants.remove(currentUserId);
        }
        
        setState(() {
          _event = Event(
            id: _event.id,
            emoji: _event.emoji,
            title: _event.title,
            date: _event.date,
            participants: newParticipants,
            category: _event.category,
            description: _event.description,
            creatorId: _event.creatorId,
            lat: _event.lat,
            lng: _event.lng,
          );
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isJoining ? 'Vous avez rejoint l\'événement !' : 'Vous avez quitté l\'événement.'),
          backgroundColor: isJoining ? AppColors.green : AppColors.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AccessibilityProvider>();
    final isParticipant = pb.authStore.record != null && _event.participants.contains(pb.authStore.record!.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.orange,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(_event.emoji, style: const TextStyle(fontSize: 88)),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.onPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          _event.category.toUpperCase(),
                          style: AppTextStyles.captionBold.copyWith(color: AppColors.primary, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(_event.title, style: AppTextStyles.heading1.copyWith(fontSize: 32)),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Info Cards
                  _InfoItem(
                    icon: Icons.calendar_today_rounded,
                    title: 'Date',
                    subtitle: DateFormat('EEEE d MMMM y', 'fr_FR').format(_event.date),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _InfoItem(
                    icon: Icons.access_time_filled_rounded,
                    title: 'Heure',
                    subtitle: '${DateFormat('HH:mm').format(_event.date)}',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _InfoItem(
                    icon: Icons.people_alt_rounded,
                    title: 'Participants',
                    subtitle: '${_event.participants.length} personne(s) inscrite(s)',
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Divider(),
                  ),
                  
                  Text('Description', style: AppTextStyles.heading2),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _event.description.isNotEmpty ? _event.description : 'Aucune description fournie.',
                    style: AppTextStyles.body.copyWith(height: 1.7, color: AppColors.textDark.withOpacity(0.85)),
                  ),
                  
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 40),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: PrimaryButton(
          label: isParticipant ? 'Se désinscrire' : 'Participer',
          loading: _loading,
          onTap: _toggleParticipation,
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoItem({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            Text(subtitle, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
