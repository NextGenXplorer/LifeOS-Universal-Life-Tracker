import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lifeos/presentation/screens/home_screen.dart';
import 'package:lifeos/presentation/screens/habits_screen.dart';
import 'package:lifeos/presentation/screens/tasks_screen.dart';
import 'package:lifeos/presentation/screens/journal_screen.dart';
import 'package:lifeos/presentation/screens/gamification_screen.dart';
import 'package:lifeos/presentation/screens/insights_screen.dart';
import 'package:lifeos/presentation/screens/automation_screen.dart';
import 'package:lifeos/presentation/screens/settings_screen.dart';
import 'package:lifeos/presentation/screens/profile_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return HomeScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HabitsScreen(),
            ),
          ),
          GoRoute(
            path: '/tasks',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TasksScreen(),
            ),
          ),
          GoRoute(
            path: '/journal',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: JournalScreen(),
            ),
          ),
          GoRoute(
            path: '/gamification',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GamificationScreen(),
            ),
          ),
          GoRoute(
            path: '/insights',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InsightsScreen(),
            ),
          ),
          GoRoute(
            path: '/automation',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AutomationScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
