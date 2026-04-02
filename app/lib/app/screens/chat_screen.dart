import 'package:flutter/material.dart';
import 'package:create_good_app/app/core/theme.dart';
import 'package:create_good_app/app/models/message.dart';
import 'package:create_good_app/app/services/message_service.dart';
import 'package:create_good_app/app/screens/public_profile_screen.dart';

// CHAT SCREEN
// ─────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  final Conversation conversation;
  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final msgs = await MessageService.fetchMessages(widget.conversation.id);
    if (mounted) {
      setState(() { _messages = msgs; _loading = false; });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    if (_ctrl.text.trim().isEmpty || _sending) return;
    final text = _ctrl.text.trim();
    _ctrl.clear();

    setState(() => _sending = true);
    try {
      final msg = await MessageService.sendMessage(widget.conversation.id, text);
      if (msg != null && mounted) {
        setState(() {
          _messages.add(msg);
          _sending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.conversation.isGroup
                    ? AppColors.orange.withOpacity(0.15)
                    : AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.conversation.isGroup ? '👥' : widget.conversation.name.isNotEmpty ? widget.conversation.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 18, fontFamily: AppTextStyles.fontFamily),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.conversation.name, style: AppTextStyles.heading3.copyWith(fontSize: 16), overflow: TextOverflow.ellipsis),
                  Text(
                    widget.conversation.isGroup
                        ? '${widget.conversation.participantIds.length} participant(s)'
                        : 'En ligne',
                    style: AppTextStyles.caption.copyWith(color: AppColors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () { setState(() => _loading = true); _loadMessages(); },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_loading)
            Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.orange)))
          else if (_messages.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_outlined, size: 48, color: AppColors.textSecondary.withOpacity(0.3)),
                    const SizedBox(height: AppSpacing.md),
                    Text('Écrivez le premier message !', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _messages.length,
                itemBuilder: (_, i) {
                  final msg = _messages[i];
                  return _ChatBubble(
                    text: msg.content,
                    mine: msg.isMine,
                    time: '${msg.created.hour.toString().padLeft(2, '0')}:${msg.created.minute.toString().padLeft(2, '0')}',
                    senderName: widget.conversation.isGroup && !msg.isMine ? msg.senderName : null,
                    senderId: widget.conversation.isGroup && !msg.isMine ? msg.senderId : null,
                  );
                },
              ),
            ),
          _ChatInput(controller: _ctrl, onSend: _send, sending: _sending),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool mine;
  final String time;
  final String? senderName;
  final String? senderId;

  const _ChatBubble({required this.text, required this.mine, required this.time, this.senderName, this.senderId});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: Column(
          crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (senderName != null && senderId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 2, left: 4),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PublicProfileScreen(userId: senderId!)));
                  },
                  child: Text(senderName!, style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: mine ? AppColors.primary : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadius.lg),
                  topRight: const Radius.circular(AppRadius.lg),
                  bottomLeft: mine ? const Radius.circular(AppRadius.lg) : const Radius.circular(4),
                  bottomRight: mine ? const Radius.circular(4) : const Radius.circular(AppRadius.lg),
                ),
              ),
              child: Text(
                text,
                style: AppTextStyles.body.copyWith(color: mine ? Colors.white : AppColors.textDark, fontSize: 15),
              ),
            ),
            const SizedBox(height: 4),
            Text(time, style: AppTextStyles.caption.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool sending;

  const _ChatInput({required this.controller, required this.onSend, this.sending = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Écrire un message...',
                  hintStyle: TextStyle(color: AppColors.textSecondary, fontFamily: AppTextStyles.fontFamily),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: sending ? null : onSend,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: sending ? AppColors.textSecondary : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: sending
                  ? const Padding(padding: EdgeInsets.all(14), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
