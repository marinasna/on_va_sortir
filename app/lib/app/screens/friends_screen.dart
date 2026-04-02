import 'package:flutter/material.dart';
import 'package:create_good_app/app/core/theme.dart';
import 'package:create_good_app/app/core/db.dart';
import 'package:create_good_app/app/models/friendship.dart';
import 'package:create_good_app/app/services/friend_service.dart';
import 'package:create_good_app/app/services/message_service.dart';
import 'package:create_good_app/app/screens/chat_screen.dart';
import 'package:pocketbase/pocketbase.dart';

// FRIENDS SCREEN
// ─────────────────────────────────────────────
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<Friendship> _friends = [];
  List<Friendship> _pending = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final friends = await FriendService.fetchFriends();
    final pending = await FriendService.fetchPendingRequests();
    if (mounted) setState(() { _friends = friends; _pending = pending; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Amis', style: AppTextStyles.heading2),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: AppTextStyles.label,
          tabs: [
            Tab(text: 'Mes amis (${_friends.length})'),
            Tab(text: 'Demandes (${_pending.length})'),
            const Tab(text: 'Rechercher'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // Onglet 1 : mes amis
          _loading
              ? Center(child: CircularProgressIndicator(color: AppColors.orange))
              : _friends.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
                          const SizedBox(height: AppSpacing.md),
                          Text('Aucun ami pour le moment', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: AppSpacing.sm),
                          Text('Recherchez des personnes à ajouter !', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.orange,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: _friends.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (_, i) => _FriendTile(
                          friendship: _friends[i],
                          onMessage: () async {
                            final userId = pb.authStore.record?.id ?? '';
                            final otherId = _friends[i].otherUserId(userId);
                            final otherName = _friends[i].otherUserName(userId);
                            final conv = await MessageService.getOrCreatePrivateConversation(otherId, otherName);
                            if (mounted) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv)));
                            }
                          },
                          onRemove: () async {
                            await FriendService.removeFriend(_friends[i].id);
                            _load();
                          },
                        ),
                      ),
                    ),

          // Onglet 2 : demandes reçues
          _loading
              ? Center(child: CircularProgressIndicator(color: AppColors.orange))
              : _pending.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mail_outline, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
                          const SizedBox(height: AppSpacing.md),
                          Text('Aucune demande en attente', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.orange,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: _pending.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (_, i) => _PendingTile(
                          friendship: _pending[i],
                          onAccept: () async {
                            await FriendService.acceptFriendRequest(_pending[i].id);
                            _load();
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demande acceptée !')));
                          },
                          onReject: () async {
                            await FriendService.rejectFriendRequest(_pending[i].id);
                            _load();
                          },
                        ),
                      ),
                    ),

          // Onglet 3 : rechercher
          _SearchUsersTab(onRequestSent: _load),
        ],
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  final Friendship friendship;
  final VoidCallback onMessage;
  final VoidCallback onRemove;

  const _FriendTile({required this.friendship, required this.onMessage, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final userId = pb.authStore.record?.id ?? '';
    final name = friendship.otherUserName(userId);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 20, fontFamily: AppTextStyles.fontFamily, fontWeight: FontWeight.w600))),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(name, style: AppTextStyles.heading3)),
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, color: AppColors.primary),
            onPressed: onMessage,
            tooltip: 'Envoyer un message',
          ),
          IconButton(
            icon: Icon(Icons.person_remove, color: AppColors.textSecondary, size: 20),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Supprimer cet ami ?'),
                  content: Text('Voulez-vous retirer $name de vos amis ?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                    TextButton(onPressed: () { Navigator.pop(context); onRemove(); }, child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
            },
            tooltip: 'Supprimer',
          ),
        ],
      ),
    );
  }
}

class _PendingTile extends StatelessWidget {
  final Friendship friendship;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _PendingTile({required this.friendship, required this.onAccept, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightOrangeBg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(friendship.senderName.isNotEmpty ? friendship.senderName[0].toUpperCase() : '?', style: const TextStyle(fontSize: 20, fontFamily: AppTextStyles.fontFamily, fontWeight: FontWeight.w600))),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(friendship.senderName, style: AppTextStyles.heading3),
                Text("Demande d'ami", style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.check_circle, color: AppColors.green, size: 32),
            onPressed: onAccept,
          ),
          IconButton(
            icon: Icon(Icons.cancel, color: AppColors.textSecondary, size: 32),
            onPressed: onReject,
          ),
        ],
      ),
    );
  }
}

class _SearchUsersTab extends StatefulWidget {
  final VoidCallback onRequestSent;
  const _SearchUsersTab({required this.onRequestSent});

  @override
  State<_SearchUsersTab> createState() => _SearchUsersTabState();
}

class _SearchUsersTabState extends State<_SearchUsersTab> {
  final _searchCtrl = TextEditingController();
  List<RecordModel> _results = [];
  bool _searching = false;
  Set<String> _sentRequests = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() => _searching = true);
    final results = await FriendService.searchUsers(q);
    if (mounted) setState(() { _results = results; _searching = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.inputBg,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      hintText: 'Nom ou pseudo...',
                      hintStyle: TextStyle(color: AppColors.textSecondary, fontFamily: AppTextStyles.fontFamily),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: _search,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.search, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (_searching)
            Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.orange)))
          else if (_results.isEmpty)
            Expanded(
              child: Center(
                child: Text('Recherchez des personnes par nom ou pseudo', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _results.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final user = _results[i];
                  final name = user.getStringValue('name');
                  final username = user.getStringValue('username');
                  final sent = _sentRequests.contains(user.id);

                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.purple.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 20, fontFamily: AppTextStyles.fontFamily, fontWeight: FontWeight.w600))),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: AppTextStyles.heading3),
                              if (username.isNotEmpty) Text('@$username', style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        if (sent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.inputBg,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text('Envoyée ✓', style: TextStyle(color: AppColors.textSecondary, fontFamily: AppTextStyles.fontFamily, fontSize: 13)),
                          )
                        else
                          GestureDetector(
                            onTap: () async {
                              try {
                                await FriendService.sendFriendRequest(user.id);
                                setState(() => _sentRequests.add(user.id));
                                widget.onRequestSent();
                                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Demande envoyée à $name !')));
                              } catch (e) {
                                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(AppRadius.full),
                              ),
                              child: const Text('Ajouter', style: TextStyle(color: Colors.white, fontFamily: AppTextStyles.fontFamily, fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
