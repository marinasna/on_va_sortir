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
class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF5E6), Color(0xFFFFE8D6)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background decorative circles
              Positioned(
                top: 40,
                left: 40,
                child: _DecorativeCircle(size: 128, color: AppColors.orange.withOpacity(0.15)),
              ),
              Positioned(
                bottom: 100,
                right: 20,
                child: _DecorativeCircle(size: 160, color: AppColors.primary.withOpacity(0.08)),
              ),
              Positioned(
                top: 200,
                right: 40,
                child: _DecorativeCircle(size: 96, color: AppColors.green.withOpacity(0.12)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    // Logo area
                    Center(
                      child: Container(
                        width: 256,
                        height: 256,
                        decoration: BoxDecoration(
                          color: AppColors.background.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _AppLogoIcon(size: 64, emoji: '📍'),
                              const SizedBox(width: 12),
                              _AppLogoIcon(size: 64, emoji: '🎉'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text('On va sortir', style: AppTextStyles.heading1.copyWith(fontSize: 44, color: AppColors.primary)),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Rencontre des étudiants autour de toi, rejoins des événements et crée des souvenirs inoubliables.',
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, height: 1.6),
                    ),
                    const Spacer(),
                    PrimaryButton(
                      label: 'Commencer',
                      onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: Text(
                        'Fais de nouvelles rencontres 🎉',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _DecorativeCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _AppLogoIcon extends StatelessWidget {
  final double size;
  final String emoji;
  const _AppLogoIcon({required this.size, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Text(emoji, style: TextStyle(fontSize: size * 0.6));
  }
}
