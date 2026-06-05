import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme.dart';
import 'features/dashboard/dashboard_screen.dart';

import 'features/onboarding/welcome_screen.dart';
import 'features/quests/quests_screen.dart';
import 'features/vault/vault_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';

import 'features/growth/growth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize analytics
  FirebaseAnalytics.instance;

  runApp(const ProviderScope(child: IkoApp()));
}

class IkoApp extends ConsumerWidget {
  const IkoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/quests',
          builder: (context, state) => const QuestsScreen(),
        ),
        GoRoute(
          path: '/vault',
          builder: (context, state) => const VaultScreen(),
        ),
        GoRoute(
          path: '/growth',
          builder: (context, state) => const GrowthScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
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
