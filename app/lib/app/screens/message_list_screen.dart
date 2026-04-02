import 'package:flutter/material.dart';
import 'package:create_good_app/app/core/theme.dart';
import 'package:create_good_app/app/core/accessibility_provider.dart';
import 'package:create_good_app/app/core/conversation_provider.dart';
import 'package:provider/provider.dart';
import 'package:create_good_app/app/models/message.dart';
import 'package:create_good_app/app/services/message_service.dart';
import 'package:create_good_app/app/screens/chat_screen.dart';
import 'package:create_good_app/app/screens/friends_screen.dart';

// MESSAGE LIST SCREEN
// ─────────────────────────────────────────────
class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Refresh on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ConversationProvider.instance.refresh();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Conversation> _getFiltered(List<Conversation> conversations) {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return conversations;
    return conversations.where((c) =>
      c.name.toLowerCase().contains(q) ||
      c.lastMessage.toLowerCase().contains(q)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Écouter les providers
    context.watch<AccessibilityProvider>();
    final convProv = context.watch<ConversationProvider>();
    final filtered = _getFiltered(convProv.conversations);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              child: Row(
                children: [
                  Text('Messages', style: AppTextStyles.heading1.copyWith(color: AppColors.textDark)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const FriendsScreen()));
                      convProv.refresh();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.orange.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person_add_alt_1, color: AppColors.orange, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: ListenableBuilder(
                listenable: _searchCtrl,
                builder: (context, _) => _SearchBar(controller: _searchCtrl),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (convProv.loading && convProv.conversations.isEmpty)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (filtered.isEmpty)
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => convProv.refresh(),
                  color: AppColors.orange,
                  child: ListView(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                            const SizedBox(height: AppSpacing.md),
                            Text('Aucune conversation', style: AppTextStyles.body.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w600)),
                            const SizedBox(height: AppSpacing.sm),
                            Text('Rejoignez un événement ou ajoutez des amis !', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => convProv.refresh(),
                  color: AppColors.orange,
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.border),
                    itemBuilder: (_, i) => _ConversationTile(
                      conversation: filtered[i],
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ChatScreen(conversation: filtered[i]),
                        ));
                        convProv.refresh();
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.md),
          Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Rechercher',
                hintStyle: TextStyle(color: AppColors.textSecondary, fontFamily: AppTextStyles.fontFamily, fontSize: 16),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  const _ConversationTile({required this.conversation, required this.onTap});

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return "à l'instant";
    if (diff.inHours < 1) return '${diff.inMinutes} min';
    if (diff.inDays < 1) return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'][dt.weekday - 1];
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: conversation.isGroup
                    ? AppColors.orange.withOpacity(0.15)
                    : AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  conversation.isGroup ? '👥' : conversation.name.isNotEmpty ? conversation.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 22, fontFamily: AppTextStyles.fontFamily),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(conversation.name, style: AppTextStyles.heading3, overflow: TextOverflow.ellipsis)),
                      Text(_formatTime(conversation.lastMessageAt), style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage.isEmpty ? 'Aucun message' : conversation.lastMessage,
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
