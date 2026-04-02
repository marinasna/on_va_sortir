import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Tes imports de core/services
import 'package:create_good_app/app/core/theme.dart';
import 'package:create_good_app/app/core/accessibility_provider.dart';
import 'package:create_good_app/app/services/auth_service.dart';

// Tes imports de screens
import 'package:create_good_app/app/screens/launch_screen.dart';
import 'package:create_good_app/app/screens/login_screen.dart';
import 'package:create_good_app/app/screens/main_screen.dart';
import 'package:create_good_app/app/screens/register_screen.dart';
import 'package:create_good_app/app/screens/create_event_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
      ],
      child: const OnVaSortirApp(),
    ),
  );
}

class OnVaSortirApp extends StatelessWidget {
  const OnVaSortirApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Écouter le provider
    final acc = Provider.of<AccessibilityProvider>(context);

    return MaterialApp(
      title: 'On va sortir',
      debugShowCheckedModeBanner: false,
      // GESTION DE LA TAILLE DU TEXTE GLOBALE
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(acc.largeText ? 1.25 : 1.0),
          ),
          child: child!,
        );
      },
      theme: ThemeData(
        fontFamily: AppTextStyles.fontFamily,
        // GESTION DU CONTRASTE ÉLEVÉ (Exemple simple)
        primaryColor: acc.highContrast ? Colors.black : AppColors.primary,
        scaffoldBackgroundColor: acc.highContrast ? Colors.white : AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: acc.highContrast ? Colors.black : AppColors.primary,
          primary: acc.highContrast ? Colors.black : AppColors.primary,
        ),
        // ... reste de ton code ...
      ),
      initialRoute: '/launch',
      routes: {
        '/launch': (_) => const LaunchScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/main': (_) => const MainScreen(),
        '/create-event': (_) => const CreateEventScreen(),
      },
    );
  }
}