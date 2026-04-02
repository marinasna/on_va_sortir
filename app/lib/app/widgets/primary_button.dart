import 'package:flutter/material.dart';
import 'package:create_good_app/app/core/theme.dart';

// SHARED WIDGETS
// ─────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final IconData? trailingIcon;

  const PrimaryButton({
    required this.label,
    this.onTap,
    this.loading = false,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Center(
            child: loading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, style: AppTextStyles.button),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Icon(trailingIcon, color: AppColors.onPrimary, size: 20),
                    ],
                  ],
                ),
          ),
        ),
      ),
    );
  }
}
