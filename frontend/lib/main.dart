import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/notification_service.dart';
import 'core/theme.dart';
import 'features/achievements/achievements_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/growth/growth_screen.dart';
import 'features/onboarding/welcome_screen.dart';
import 'features/quests/quests_screen.dart';
import 'features/vault/vault_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Editorial UI: match status bar to the warm paper background.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: IkoTheme.background,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Best-effort init; never block startup.
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseAnalytics.instance;
  } catch (_) {/* offline-first; non-fatal */}

  await NotificationService.instance.init();

  runApp(const ProviderScope(child: IkoApp()));
}

/// Premium fade+slide page transition. Subtle, fast, editorial.
CustomTransitionPage<T> _ikoPage<T>(Widget child, GoRouterState state) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class IkoApp extends ConsumerWidget {
  const IkoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', pageBuilder: (c, s) => _ikoPage(const WelcomeScreen(), s)),
        GoRoute(path: '/dashboard', pageBuilder: (c, s) => _ikoPage(const DashboardScreen(), s)),
        GoRoute(path: '/quests', pageBuilder: (c, s) => _ikoPage(const QuestsScreen(), s)),
        GoRoute(path: '/vault', pageBuilder: (c, s) => _ikoPage(const VaultScreen(), s)),
        GoRoute(path: '/growth', pageBuilder: (c, s) => _ikoPage(const GrowthScreen(), s)),
        GoRoute(path: '/achievements', pageBuilder: (c, s) => _ikoPage(const AchievementsScreen(), s)),
      ],
    );

    return MaterialApp.router(
      title: 'IKO',
      theme: IkoTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
