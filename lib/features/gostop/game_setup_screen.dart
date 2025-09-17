import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/capsule_button.dart';

class GameSetupScreen extends ConsumerWidget {
  const GameSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게임 설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.settings, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text(
              '게임을 시작하기 전에\n설정을 완료해주세요',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // 규칙 설정 버튼
            CapsuleButtons.primary(
              text: '게임 규칙 설정',
              icon: Icons.rule,
              onPressed: () => context.push('/rule-setup'),
              width: double.infinity,
              height: 60,
              fontSize: 18,
            ),

            const SizedBox(height: 16),

            // 플레이어 설정 버튼
            CapsuleButtons.outlined(
              text: '플레이어 설정',
              icon: Icons.people,
              onPressed: () => context.push('/player-setup'),
              width: double.infinity,
              height: 60,
              fontSize: 18,
            ),

            const SizedBox(height: 32),

            // 설명 텍스트
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.info,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '설정 안내',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• 게임 규칙을 먼저 설정해주세요\n• 설정한 내용은 자동으로 저장됩니다',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
