import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:create_good_app/app/core/accessibility_provider.dart';
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


// PARAMÈTRES SCREEN
// ─────────────────────────────────────────────
class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les réglages depuis PocketBase au démarrage de l'écran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AccessibilityProvider>().loadPreferences();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Récupérer le provider pour écouter les changements
    final acc = Provider.of<AccessibilityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        title: Text('Paramètres', style: AppTextStyles.heading2),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compte
            _SettingsSection(
              title: 'Compte',
              children: [
                _SettingsNavItem(
                    icon: Icons.person_outline,
                    label: 'Informations personnelles',
                    onTap: () {}),
                _SettingsDivider(),
                _SettingsNavItem(
                    icon: Icons.lock_outline,
                    label: 'Confidentialité et sécurité',
                    onTap: () {}),
                _SettingsDivider(),
                _SettingsNavItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () {}),
              ],
            ),
            // Accessibilité
            _SettingsSectionHeader(
              title: 'Accessibilité',
              icon: Icons.accessibility_new_outlined,
            ),
            _AccessibilityToggle(
              icon: Icons.contrast,
              title: 'Contraste élevé',
              subtitle: 'Améliore la lisibilité',
              value: acc.highContrast,
              onChanged: (v) => acc.updateHighContrast(v),
            ),
            _SettingsDivider(),
            _AccessibilityToggle(
              icon: Icons.text_fields,
              title: 'Texte agrandi',
              subtitle: 'Police plus grande',
              value: acc.largeText,
              onChanged: (v) => acc.updateLargeText(v),
            ),
            _SettingsDivider(),
            _AccessibilityToggle(
              icon: Icons.animation,
              title: 'Réduire les animations',
              subtitle: 'Moins de mouvement',
              value: acc.reduceMotion,
              onChanged: (v) => acc.updateReduceMotion(v),
            ),
            _SettingsDivider(),
            _AccessibilityToggle(
              icon: Icons.record_voice_over_outlined,
              title: "Lecteur d'écran",
              subtitle: 'Support vocal',
              value: acc.screenReader,
              onChanged: (v) => acc.updateScreenReader(v),
            ),
            const SizedBox(height: AppSpacing.md),
            // Préférences
            _SettingsSection(
              title: 'Préférences',
              children: [
                _SettingsNavItemWithValue(
                    icon: Icons.language,
                    label: 'Langue',
                    value: 'Français',
                    onTap: () {}),
                _SettingsDivider(),
                _SettingsNavItem(
                    icon: Icons.dark_mode_outlined,
                    label: 'Mode sombre',
                    onTap: () {}),
                _SettingsDivider(),
                _SettingsNavItem(
                    icon: Icons.help_outline, label: 'Aide et support', onTap: () {}),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Déconnexion
Center(
  child: TextButton.icon(
    onPressed: () {
      context.read<AccessibilityProvider>().reset(); 
      AuthService.logout();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    },
    icon: const Icon(Icons.logout, color: AppColors.primary),
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
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SettingsSectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Text(title,
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

class _SettingsNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingsNavItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(AppRadius.sm)),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(label, style: AppTextStyles.body),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 16, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}

class _SettingsNavItemWithValue extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  const _SettingsNavItemWithValue(
      {required this.icon,
      required this.label,
      required this.value,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(AppRadius.sm)),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(label, style: AppTextStyles.body),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: AppTextStyles.bodySmall),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios,
              size: 16, color: AppColors.textSecondary),
        ],
      ),
      onTap: onTap,
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
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(AppRadius.sm)),
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

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
        height: 1, color: AppColors.border, indent: 16, endIndent: 16);
  }
}