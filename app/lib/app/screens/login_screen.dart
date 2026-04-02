import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // AJOUTÉ
import 'package:create_good_app/app/core/accessibility_provider.dart'; // AJOUTÉ
import 'package:create_good_app/app/core/theme.dart';
import 'package:create_good_app/app/services/auth_service.dart';
import 'package:create_good_app/app/widgets/primary_button.dart';
import 'package:create_good_app/app/widgets/custom_form_field.dart';

// LOGIN SCREEN
// ─────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      // 1. Tentative de connexion
      await AuthService.login(_emailCtrl.text, _passwordCtrl.text);
      
      if (mounted) {
        // 2. CHARGEMENT DES PRÉFÉRENCES (Juste après le succès du login)
        // On utilise await pour être sûr que les données sont là avant de changer d'écran
        await context.read<AccessibilityProvider>().loadPreferences();

        // 3. Navigation vers l'écran principal
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background ellipse
          Positioned(
            top: -70,
            left: -45,
            child: Container(
              width: 539,
              height: 329,
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(200),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 96),
                  Text('Bon retour !', style: AppTextStyles.heading1.copyWith(fontSize: 32)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Connecte-toi pour retrouver tes amis', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 64),
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
                  CustomFormField(
                    label: 'Email',
                    hint: 'ton@email.com',
                    controller: _emailCtrl,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
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
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text('Mot de passe oublié ?', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: 'Se connecter',
                    loading: _loading,
                    onTap: _login,
                    trailingIcon: Icons.arrow_forward,
                  ),
                  const SizedBox(height: 48),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/register'),
                      child: RichText(
                        text: TextSpan(
                          text: "Pas encore de compte ? ",
                          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                          children: [
                            TextSpan(
                              text: "S'inscrire",
                              style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}