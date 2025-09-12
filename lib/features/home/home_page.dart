import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common/widgets/ad_banner.dart';
import '../../features/auth/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter GoStop'),
        actions: [
          if (authState.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () => context.go('/login'),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.games,
                    size: 100,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Flutter GoStop',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    authState.isAuthenticated
                        ? '환영합니다!'
                        : '로그인해주세요',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 32),
                  if (authState.isAuthenticated) ...[
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('게임 시작'),
                      onPressed: () {
                        // Start game logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('게임을 시작합니다!'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.leaderboard),
                      label: const Text('순위표'),
                      onPressed: () {
                        // Show leaderboard
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('순위표를 확인합니다!'),
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text('로그인'),
                      onPressed: () => context.go('/login'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const AdBanner(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}