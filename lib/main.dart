import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/session.dart';
import 'core/theme.dart';
import 'screens/auth_screens.dart';
import 'screens/onboarding_screen.dart';
import 'screens/today_screen.dart';
import 'screens/plan_screen.dart';
import 'screens/shopping_screen.dart';
import 'screens/recipe_screen.dart';
import 'screens/more_screens.dart';
import 'screens/shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BeissAbApp());
}

final router =
    GoRouter(initialLocation: '/splash', refreshListenable: session, routes: [
  GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
  GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
  GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
  GoRoute(
      path: '/verify-email',
      builder: (_, s) => VerifyEmailScreen(email: (s.extra ?? '').toString())),
  GoRoute(
      path: '/forgot-password',
      builder: (_, __) => const ForgotPasswordScreen()),
  GoRoute(
      path: '/reset-password',
      builder: (_, s) =>
          ResetPasswordScreen(token: s.uri.queryParameters['token'] ?? '')),
  GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
  ShellRoute(builder: (_, __, child) => AppShell(child: child), routes: [
    GoRoute(path: '/app', builder: (_, __) => const TodayScreen()),
    GoRoute(path: '/plan', builder: (_, __) => const PlanScreen()),
    GoRoute(path: '/shopping', builder: (_, __) => const ShoppingScreen()),
    GoRoute(path: '/more', builder: (_, __) => const MoreScreen())
  ]),
  GoRoute(
      path: '/recipe/:id',
      builder: (_, s) =>
          RecipeScreen(id: s.pathParameters['id'], initial: s.extra)),
  GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
  GoRoute(path: '/family', builder: (_, __) => const FamilyScreen()),
  GoRoute(
      path: '/notifications', builder: (_, __) => const NotificationScreen()),
  GoRoute(path: '/privacy', builder: (_, __) => const PrivacyScreen()),
  GoRoute(path: '/changelog', builder: (_, __) => const ChangelogScreen())
]);

class BeissAbApp extends StatelessWidget {
  const BeissAbApp({super.key});
  @override
  Widget build(c) => MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'BeissAb',
      theme: BeissAbTheme.light,
      routerConfig: router);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _S();
}

class _S extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    go();
  }

  Future<void> go() async {
    await session.bootstrap();
    if (!mounted) return;
    if (!session.signedIn) {
      context.go('/login');
      return;
    }
    context.go(await session.onboardingDone() ? '/app' : '/onboarding');
  }

  @override
  Widget build(c) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
