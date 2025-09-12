import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/gostop/home_screen.dart';
import '../features/gostop/game_setup_screen.dart';
import '../features/gostop/rule_setup_screen.dart';
import '../features/gostop/player_setup_screen.dart';
import '../features/gostop/game_screen.dart';
import '../features/gostop/history_screen.dart';
import '../features/gostop/result_screen.dart';
import '../features/settings/settings_page.dart';
import '../features/gostop/models/player.dart';
import '../features/gostop/models/gwang_selling.dart';
import '../features/gostop/models/game_data.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/game-setup',
      name: 'game-setup',
      builder: (context, state) => const GameSetupScreen(),
    ),
    GoRoute(
      path: '/rule-setup',
      name: 'rule-setup',
      builder: (context, state) => const RuleSetupScreen(),
    ),
    GoRoute(
      path: '/player-setup',
      name: 'player-setup',
      builder: (context, state) => const PlayerSetupScreen(),
    ),
    GoRoute(
      path: '/game-main',
      name: 'game-main',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final players = extra?['players'] as List<Player>? ?? [];
        final gwangSelling = extra?['gwangSelling'] as List<GwangSelling>?;
        return GameScreen(players: players, gwangSellings: gwangSelling);
      },
    ),
    GoRoute(
      path: '/history',
      name: 'history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/result',
      name: 'result',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final gameData = extra?['gameData'] as GameData;
        final finalScores = extra?['finalScores'] as Map<String, int>;
        return ResultScreen(
          gameData: gameData,
          finalScores: finalScores,
        );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Page not found: ${state.uri}',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);