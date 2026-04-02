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
import 'package:create_good_app/app/core/constants.dart';

// REGISTER SCREEN
// ─────────────────────────────────────────────
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController(text: '22');
  final _phoneCtrl = TextEditingController(text: '+33 6 12 34 56 78');
  final _locationCtrl = TextEditingController(text: 'Paris, France');
  String _gender = 'Non précisé';
  bool _loading = false;
  bool _obscure = true;
  String? _errorMessage;
  final List<String> _selectedInterests = [];

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await AuthService.register({
        'email': _emailCtrl.text,
        'password': _passwordCtrl.text,
        'name': _nameCtrl.text,
        'age': _ageCtrl.text,
        'gender': _gender,
        'location': _locationCtrl.text,
        'phone': _phoneCtrl.text,
        'interests': _selectedInterests,
      });
      if (mounted) Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64),
              Text('Parle-nous de toi', style: AppTextStyles.heading1.copyWith(fontSize: 32)),
              const SizedBox(height: AppSpacing.sm),
              Text("Quelques infos pour commencer l'aventure", style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.xl),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(_errorMessage!, style: AppTextStyles.body.copyWith(color: Colors.red))),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              CustomFormField(label: 'Nom complet', hint: 'Camille Dupont', controller: _nameCtrl, icon: Icons.person_outline),
              const SizedBox(height: AppSpacing.md),
              CustomFormField(label: 'Email', hint: 'ton@email.com', controller: _emailCtrl, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: AppSpacing.md),
              CustomFormField(
                label: 'Mot de passe',
                hint: '••••••••',
                controller: _passwordCtrl,
                icon: Icons.lock_outline,
                obscure: _obscure,
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textSecondary, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              CustomFormField(label: 'Âge', hint: '22', controller: _ageCtrl, icon: Icons.cake_outlined, keyboardType: TextInputType.number),
              const SizedBox(height: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sexe', style: AppTextStyles.label),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    height: 58,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.inputBg,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _gender,
                            isExpanded: true,
                            underline: const SizedBox(),
                            style: AppTextStyles.body,
                            items: ['Non précisé', 'Homme', 'Femme', 'Autre']
                                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                .toList(),
                            onChanged: (v) => setState(() => _gender = v!),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              CustomFormField(label: 'Localisation', hint: 'Paris, France', controller: _locationCtrl, icon: Icons.location_on_outlined),
              const SizedBox(height: AppSpacing.md),
              const SizedBox(height: AppSpacing.md),
              CustomFormField(label: 'Numéro de téléphone', hint: '+33 6 12 34 56 78', controller: _phoneCtrl, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Centres d\'intérêt', style: AppTextStyles.label),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppCategories.list.map((cat) {
                      final label = cat['label'] as String;
                      final emoji = cat['emoji'] as String;
                      final isSelected = _selectedInterests.contains(label);
                      return ChoiceChip(
                        label: Text('$emoji $label'),
                        selected: isSelected,
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        backgroundColor: AppColors.inputBg,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedInterests.add(label);
                            } else {
                              _selectedInterests.remove(label);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(label: 'Créer mon profil', loading: _loading, onTap: _register),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: RichText(
                    text: TextSpan(
                      text: 'Déjà un compte ? ',
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: 'Se connecter',
                          style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
