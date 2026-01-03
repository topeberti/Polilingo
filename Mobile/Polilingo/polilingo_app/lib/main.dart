import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/learning_provider.dart';
import 'ui/screens/welcome_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/signup_screen.dart';
import 'ui/screens/forgot_password_screen.dart';
import 'ui/screens/profile_setup_screen.dart';
import 'ui/screens/dashboard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, LearningProvider>(
          create: (context) => LearningProvider(
            Provider.of<AuthProvider>(context, listen: false).apiClient,
          ),
          update: (context, auth, previous) {
            if (previous == null) return LearningProvider(auth.apiClient);
            previous.updateApiClient(auth.apiClient);
            return previous;
          },
        ),
      ],
      child: const PolilingoApp(),
    ),
  );
}

class PolilingoApp extends StatelessWidget {
  const PolilingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polilingo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Default to dark theme as requested
      home: const AuthWrapper(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/profile-setup': (context) => const ProfileSetupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    debugPrint('🔄 AuthWrapper building with status: ${authProvider.status}');

    switch (authProvider.status) {
      case AuthStatus.loading:
        debugPrint('⏳ Showing loading screen');
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.authenticated:
        debugPrint('✅ Showing dashboard (authenticated)');
        return const DashboardScreen();
      case AuthStatus.profileMissing:
        debugPrint('📝 Showing profile setup (profile missing)');
        return const ProfileSetupScreen();
      case AuthStatus.unauthenticated:
        debugPrint('🔓 Showing welcome screen (unauthenticated)');
        return const WelcomeScreen();
    }
  }
}
