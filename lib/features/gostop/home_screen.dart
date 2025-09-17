import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/snackbar_service.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/capsule_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snackbarService = ref.read(snackbarServiceProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // App Logo/Title Section
              Column(
                children: [
                  Image.asset(
                    'lib/assets/images/gostop_score_calculator_without_background.png',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 16),
                  Image.asset(
                    'lib/assets/images/gostop_scoreboard_font.png',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 8),
                ],
              ),

              const SizedBox(height: 64),

              // Main Action Buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 게임 시작 버튼
                  CapsuleButtons.primary(
                    text: '게임 시작',
                    icon: Icons.play_arrow,
                    onPressed: () {
                      context.push('/game-setup');
                    },
                    width: double.infinity,
                    height: 60,
                    fontSize: 18,
                  ),

                  const SizedBox(height: 16),

                  // 이전 기록 보기 버튼
                  CapsuleButtons.outlined(
                    text: '이전 기록 보기',
                    icon: Icons.history,
                    onPressed: () {
                      context.push('/history');
                    },
                    width: double.infinity,
                    height: 60,
                    fontSize: 18,
                  ),
                ],
              ),

              const Spacer(),

              // // Settings Button
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     IconButton.filled(
              //       onPressed: () {
              //         context.push('/settings');
              //       },
              //       icon: const Icon(Icons.settings),
              //       iconSize: 24,
              //       style: IconButton.styleFrom(
              //         backgroundColor: AppColors.primary.withOpacity(0.1),
              //         foregroundColor: AppColors.primary,
              //       ),
              //     ),
              //     const SizedBox(width: 16),
              //     Text(
              //       '설정',
              //       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              //         color: AppColors.textSecondary,
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
