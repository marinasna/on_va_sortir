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

// ─────────────────────────────────────────────
// CREATE EVENT SCREEN
// ─────────────────────────────────────────────
class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  String _selectedEmoji = '🎉';
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _maxParticipantsCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  int _selectedCategory = -1;
  bool _loading = false;

  static const List<String> _emojiList = ['🎉', '🎮', '🏃', '⚽', '🎨', '🎭', '🎸', '🍕', '🍔', '☕', '🌳', '🏖️', '📚', '💪', '🎬', '🎵'];

  static const List<Map<String, String>> _eventTypes = [
    {'emoji': '🌙', 'label': 'Soirée'},
    {'emoji': '🏃', 'label': 'Sport'},
    {'emoji': '🎨', 'label': 'Culture'},
    {'emoji': '🍽️', 'label': 'Resto'},
    {'emoji': '🌳', 'label': 'Extérieur'},
    {'emoji': '🎮', 'label': 'Jeux'},
  ];

  Future<void> _submit() async {
    setState(() => _loading = true);
    await EventService.createEvent({
      'emoji': _selectedEmoji,
      'name': _nameCtrl.text,
      'category': _selectedCategory >= 0 ? _eventTypes[_selectedCategory]['label'] : '',
      'description': _descCtrl.text,
      'location': _locationCtrl.text,
      'maxParticipants': _maxParticipantsCtrl.text,
      'price': _priceCtrl.text,
    });
    if (mounted) Navigator.pop(context);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text('Créer un événement', style: AppTextStyles.heading2),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji picker
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.lightOrangeBg,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Center(child: Text(_selectedEmoji, style: const TextStyle(fontSize: 64))),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _emojiList.map((e) => GestureDetector(
                      onTap: () => setState(() => _selectedEmoji = e),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedEmoji == e ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: _selectedEmoji == e ? Border.all(color: AppColors.primary) : null,
                        ),
                        child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            CustomFormField(label: "Nom de l'événement", hint: 'Ex: Soirée jeux de société', controller: _nameCtrl, icon: Icons.event_outlined),
            const SizedBox(height: AppSpacing.md),
            // Event type
            Text("Type d'événement", style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.4,
              ),
              itemCount: _eventTypes.length,
              itemBuilder: (_, i) {
                final t = _eventTypes[i];
                final sel = _selectedCategory == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = i),
                  child: Container(
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary.withOpacity(0.1) : AppColors.inputBg,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: sel ? AppColors.primary : AppColors.border),
                    ),
                    child: Center(
                      child: Text('${t['emoji']} ${t['label']}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDark)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description', style: AppTextStyles.label),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.inputBg,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: TextField(
                    controller: _descCtrl,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Décris ton événement...',
                      hintStyle: TextStyle(color: AppColors.textSecondary, fontFamily: AppTextStyles.fontFamily),
                      contentPadding: EdgeInsets.all(AppSpacing.md),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: _DatePickerField()),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _TimePickerField()),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            CustomFormField(label: 'Lieu', hint: 'Adresse ou lieu de rendez-vous', controller: _locationCtrl, icon: Icons.location_on_outlined),
            const SizedBox(height: AppSpacing.md),
            CustomFormField(label: 'Nombre max de participants', hint: 'Ex: 10', controller: _maxParticipantsCtrl, icon: Icons.group_outlined, keyboardType: TextInputType.number),
            const SizedBox(height: AppSpacing.md),
            CustomFormField(label: 'Prix (optionnel)', hint: 'Gratuit', controller: _priceCtrl, icon: Icons.euro_outlined, keyboardType: TextInputType.number),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(label: "Créer l'événement", loading: _loading, onTap: _submit),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatefulWidget {
  @override
  State<_DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<_DatePickerField> {
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date', style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () async {
            final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
            if (d != null) setState(() => _date = d);
          },
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _date != null ? '${_date!.day}/${_date!.month}/${_date!.year}' : 'Sélectionner',
                    style: AppTextStyles.body.copyWith(color: _date != null ? AppColors.textDark : AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimePickerField extends StatefulWidget {
  @override
  State<_TimePickerField> createState() => _TimePickerFieldState();
}

class _TimePickerFieldState extends State<_TimePickerField> {
  TimeOfDay? _time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Heure', style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () async {
            final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
            if (t != null) setState(() => _time = t);
          },
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_outlined, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _time != null ? _time!.format(context) : 'Sélectionner',
                  style: AppTextStyles.body.copyWith(color: _time != null ? AppColors.textDark : AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
