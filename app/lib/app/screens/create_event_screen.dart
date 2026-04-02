import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:create_good_app/app/core/theme.dart';
import 'package:create_good_app/app/services/event_service.dart';
import 'package:create_good_app/app/widgets/primary_button.dart';
import 'package:create_good_app/app/widgets/custom_form_field.dart';
import 'package:create_good_app/app/core/constants.dart';
import 'package:create_good_app/app/core/db.dart';

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
  final _maxParticipantsCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  int _selectedCategory = -1;
  bool _loading = false;

  DateTime? _date;
  TimeOfDay? _time;
  
  // Field not strictly required for backend payload yet but kept for logic
  // String _finalLocationName = '';
  double _finalLat = 0.0;
  double _finalLng = 0.0;

  static const List<String> _emojiList = ['🎉', '🎮', '🏃', '⚽', '🎨', '🎭', '🎸', '🍕', '🍔', '☕', '🌳', '🏖️', '📚', '💪', '🎬', '🎵'];

  // Removed local _eventTypes

  Future<void> _submit() async {
    if (_nameCtrl.text.isEmpty || _finalLat == 0.0 || _finalLng == 0.0 || _date == null || _time == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs et sélectionner une adresse valide !')));
      return;
    }

    setState(() => _loading = true);

    // Combining Date and Time
    final finalDateTime = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    ).toUtc().toIso8601String();

    try {
      final category = _selectedCategory >= 0 ? AppCategories.list[_selectedCategory]['label'] : 'Général';
      
      await EventService.createEvent({
        'emoji': _selectedEmoji,
        'title': _nameCtrl.text,
        'description': _descCtrl.text,
        'category': category,
        'date': finalDateTime,
        // The creator is implicitly participating.
        'participants': [pb.authStore.record?.id].where((id) => id != null).toList(),
        'lat': _finalLat,
        'lng': _finalLng,
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur création: $e'),
        duration: const Duration(seconds: 5),
      ));
    }

    if (mounted) setState(() => _loading = false);
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
                    child: Center(child: Text(_selectedEmoji, style: TextStyle(fontSize: 64))),
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
                          color: _selectedEmoji == e ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
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
              itemCount: AppCategories.list.length,
              itemBuilder: (_, i) {
                final t = AppCategories.list[i];
                final sel = _selectedCategory == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = i),
                  child: Container(
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary.withValues(alpha: 0.1) : AppColors.inputBg,
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
                    decoration: InputDecoration(
                      hintText: 'Décris ton événement...',
                      hintStyle: TextStyle(color: AppColors.textSecondary, fontFamily: AppTextStyles.fontFamily),
                      contentPadding: const EdgeInsets.all(AppSpacing.md),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _DatePickerField(
                    date: _date,
                    onChanged: (d) => setState(() => _date = d),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _TimePickerField(
                    time: _time,
                    onChanged: (t) => setState(() => _time = t),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Autocomplete Lieu
            _AddressAutocomplete(
              onSelected: (lat, lng, name) {
                _finalLat = lat;
                _finalLng = lng;
              },
            ),
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

class _AddressAutocomplete extends StatefulWidget {
  final Function(double lat, double lng, String name) onSelected;
  const _AddressAutocomplete({required this.onSelected});

  @override
  State<_AddressAutocomplete> createState() => _AddressAutocompleteState();
}

class _AddressAutocompleteState extends State<_AddressAutocomplete> {
  Timer? _debounce;
  List<Map<String, dynamic>> _options = [];
  bool _searching = false;

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      if (mounted) setState(() => _options = []);
      return;
    }
    if (mounted) setState(() => _searching = true);

    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5'),
        headers: {'User-Agent': 'CreateGoodApp/1.0'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        if (mounted) {
          setState(() {
            _options = data.map((e) => e as Map<String, dynamic>).toList();
          });
        }
      }
    } catch (e) {
      // Ignorant silent error
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lieu (Saisie intelligente)', style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        Autocomplete<Map<String, dynamic>>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            
            // Trigger debounced search
            _debounce = Timer(const Duration(milliseconds: 800), () {
              _search(textEditingValue.text);
            });
            
            // Autocomplete requires returning options synchronously or a Future.
            // Since we're debouncing manually and updating state, we can return the current options.
            // But Autocomplete optionsBuilder doesn't easily trigger rebuilds from external state.
            // A better hack for Flutter Autocomplete with external debounced futures:
            return _options;
          },
          displayStringForOption: (option) => option['display_name'] ?? 'Inconnu',
          onSelected: (option) {
            double lat = double.parse(option['lat'].toString());
            double lng = double.parse(option['lon'].toString());
            String name = option['display_name'] ?? 'Inconnu';
            widget.onSelected(lat, lng, name);
            FocusScope.of(context).unfocus(); // Close keyboard safely
          },
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            return Container(
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.md),
                  Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onEditingComplete: onEditingComplete,
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        hintText: 'Ex: 15 rue de Rivoli...',
                        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                        border: InputBorder.none,
                        isDense: true,
                        suffixIcon: _searching ? const Padding(padding: EdgeInsets.all(14), child: CircularProgressIndicator(strokeWidth: 2)) : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 200, maxWidth: MediaQuery.of(context).size.width - AppSpacing.lg * 2),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(option['display_name'] ?? 'Inconnu', style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                        leading: Icon(Icons.place_outlined, color: AppColors.primary),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? date;
  final ValueChanged<DateTime> onChanged;

  const _DatePickerField({required this.date, required this.onChanged});

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
            if (d != null) onChanged(d);
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
                Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    date != null ? '${date!.day}/${date!.month}/${date!.year}' : 'Sélectionner',
                    style: AppTextStyles.body.copyWith(color: date != null ? AppColors.textDark : AppColors.textSecondary),
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

class _TimePickerField extends StatelessWidget {
  final TimeOfDay? time;
  final ValueChanged<TimeOfDay> onChanged;

  const _TimePickerField({required this.time, required this.onChanged});

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
            if (t != null) onChanged(t);
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
                Icon(Icons.access_time_outlined, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  time != null ? time!.format(context) : 'Sélectionner',
                  style: AppTextStyles.body.copyWith(color: time != null ? AppColors.textDark : AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
