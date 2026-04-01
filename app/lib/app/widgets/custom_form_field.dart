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

class CustomFormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffixIcon;

  const CustomFormField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            children: [
              const SizedBox(width: AppSpacing.md),
              Icon(icon, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: obscure,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (suffixIcon != null) suffixIcon!,
            ],
          ),
        ),
      ],
    );
  }
}
