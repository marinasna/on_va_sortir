import 'package:flutter/material.dart';
import 'package:create_good_app/app/core/theme.dart';
import 'package:create_good_app/app/core/constants.dart';
import 'package:create_good_app/app/core/db.dart';
import 'package:create_good_app/app/services/friend_service.dart';
import 'package:create_good_app/app/services/message_service.dart';
import 'package:create_good_app/app/screens/chat_screen.dart';
import 'package:pocketbase/pocketbase.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;
  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  RecordModel? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await pb.collection('users').getOne(widget.userId);
      if (mounted) setState(() { _user = user; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.orange)));
    if (_error != null || _user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Erreur: Profil introuvable\n$_error', textAlign: TextAlign.center)),
      );
    }

    final name = _user!.getStringValue('name').isNotEmpty ? _user!.getStringValue('name') : 'Utilisateur';
    final username = _user!.getStringValue('username').isNotEmpty ? '@${_user!.getStringValue('username')}' : '@user';
    final age = _user!.getIntValue('age') > 0 ? '${_user!.getIntValue('age')} ans' : '';
    final school = _user!.getStringValue('school').isNotEmpty ? _user!.getStringValue('school') : 'École non renseignée';
    final location = _user!.getStringValue('location').isNotEmpty ? _user!.getStringValue('location') : 'Lieu non renseigné';
    final friendsCount = _user!.getIntValue('friends_count').toString();
    final groupsCount = _user!.getIntValue('groups_count').toString();
    final eventsCount = _user!.getIntValue('events_count').toString();
    final interests = _user!.getListValue<String>('interests');
    
    final bool isMe = pb.authStore.record?.id == widget.userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(name, style: AppTextStyles.heading3),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEader
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  top: 120,
                  left: AppSpacing.lg,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0C8A8),
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 4)),
                    ),
                    child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '👤', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            
            // Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: AppTextStyles.heading1.copyWith(fontSize: 26)),
                            const SizedBox(height: 4),
                            Text('$username${age.isNotEmpty ? ' • $age' : ''}', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      if (!isMe)
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.person_add_alt_1, color: AppColors.primary),
                              onPressed: () async {
                                try {
                                  await FriendService.sendFriendRequest(widget.userId);
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Demande envoyée à $name')));
                                } catch (e) {
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                                }
                              },
                              tooltip: 'Ajouter',
                            ),
                            IconButton(
                              icon: Icon(Icons.chat_bubble_outline, color: AppColors.orange),
                              onPressed: () async {
                                final conv = await MessageService.getOrCreatePrivateConversation(widget.userId, name);
                                if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv)));
                              },
                              tooltip: 'Message',
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
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
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Stats
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
                  
                  const SizedBox(height: AppSpacing.lg),
                  Text("Centres d'intérêt", style: AppTextStyles.heading2),
                  const SizedBox(height: AppSpacing.md),
                  if (interests.isEmpty)
                    Text('Aucun centre d\'intérêt renseigné.', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary))
                  else
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: interests.map((label) {
                        final cat = AppCategories.getCategory(label);
                        final emoji = cat?['emoji'] ?? '✨';
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.inputBg,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text('$emoji $label', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w500)),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
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
        Text(value, style: AppTextStyles.heading1.copyWith(fontSize: 24, color: AppColors.primary)),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
