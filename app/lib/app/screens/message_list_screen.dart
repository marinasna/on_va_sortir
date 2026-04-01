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

// MESSAGE LIST SCREEN
// ─────────────────────────────────────────────
class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  List<Message> _messages = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await MessageService.fetchMessages();
    if (mounted) setState(() { _messages = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              child: Text('Messages', style: AppTextStyles.heading1),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: _SearchBar(controller: _searchCtrl),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.orange)))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _messages.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (_, i) => _MessageTile(message: _messages[i]),
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
          const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
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

class _MessageTile extends StatelessWidget {
  final Message message;
  const _MessageTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(message: message))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      message.isGroup ? '👥' : message.name[0],
                      style: const TextStyle(fontSize: 22, fontFamily: AppTextStyles.fontFamily),
                    ),
                  ),
                ),
                if (message.unread > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          message.unread.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: AppTextStyles.fontFamily),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(message.name, style: AppTextStyles.heading3, overflow: TextOverflow.ellipsis)),
                      Text(message.time, style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(message.lastMessage, style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis, maxLines: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
