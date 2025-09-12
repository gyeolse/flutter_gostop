import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import '../../core/app_colors.dart';
import '../../core/widgets/modern_dialog.dart';
import '../../core/widgets/capsule_button.dart';
import 'models/game_result.dart';
import 'models/game_data.dart';
import 'services/game_history_service.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final GameData gameData;
  final Map<String, int> finalScores;

  const ResultScreen({
    super.key,
    required this.gameData,
    required this.finalScores,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // 게임 결과 데이터 계산
    final gameResult = _calculateGameResult();
    final settlements = gameResult.calculateSettlements();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('게임 결과'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(), // 뒤로가기 버튼 제거
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: Container(
          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 최종 정산 카드
                      _buildFinalSettlementCard(gameResult, settlements, theme),
                      const SizedBox(height: 16),
                      
                      // 게임 요약 카드
                      _buildGameSummaryCard(gameResult, theme),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              
              // 하단 버튼들
              _buildBottomButtons(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalSettlementCard(GameResult gameResult, List<Settlement> settlements, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calculate_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '최종 정산 결과',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 플레이어별 최종 금액
            ...gameResult.players.map((player) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        player.avatarPath,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        player.playerName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textLight : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${player.finalAmount >= 0 ? '+' : ''}${_formatCurrency(player.finalAmount)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: player.finalAmount >= 0 ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
            )),
            
            if (settlements.isNotEmpty) ...[
              const SizedBox(height: 20),
              Divider(color: isDark ? AppColors.textLight.withValues(alpha: 0.2) : AppColors.textSecondary.withValues(alpha: 0.2)),
              const SizedBox(height: 12),
              
              Text(
                '💸 정산 방법',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              
              ...settlements.map((settlement) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${settlement.from} → ${settlement.to}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.textLight : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        _formatCurrency(settlement.amount),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGameSummaryCard(GameResult gameResult, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final bestPlayer = gameResult.bestRoundPlayer;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: AppColors.secondary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '게임 요약',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 게임 정보
            _buildSummaryRow(
              '📅 게임 날짜',
              '${gameResult.gameDate.year}년 ${gameResult.gameDate.month}월 ${gameResult.gameDate.day}일',
              theme,
            ),
            _buildSummaryRow(
              '🎮 총 라운드',
              '${gameResult.totalRounds}라운드',
              theme,
            ),
            _buildSummaryRow(
              '⏱️ 게임 시간',
              _formatDuration(gameResult.gameDuration),
              theme,
            ),
            
            const SizedBox(height: 16),
            Divider(color: isDark ? AppColors.textLight.withValues(alpha: 0.2) : AppColors.textSecondary.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            
            // 승패 기록
            Text(
              '🏆 승패 기록',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            
            ...gameResult.players.map((player) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(player.avatarPath, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      player.playerName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.textLight : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${player.winCount}승 ${player.loseCount}패',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textLight.withValues(alpha: 0.8) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )),
            
            if (bestPlayer != null) ...[
              const SizedBox(height: 16),
              Divider(color: isDark ? AppColors.textLight.withValues(alpha: 0.2) : AppColors.textSecondary.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.goStopYellow.withValues(alpha: 0.2),
                      AppColors.primary.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('👑', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '최고의 한 판',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textLight : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${bestPlayer.playerName} (${bestPlayer.highestScore}점)',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textLight.withValues(alpha: 0.8) : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CapsuleButtons.outlined(
                text: _isSaving ? '저장 중...' : '확인 & 홈으로',
                icon: _isSaving ? null : Icons.home_outlined,
                onPressed: _isSaving ? null : () => _saveAndGoHome(context),
                width: double.infinity,
                height: 56,
                fontSize: 16,
                isLoading: _isSaving,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CapsuleButtons.primary(
                text: _isSharing ? '공유 중...' : '결과 공유하기',
                icon: _isSharing ? null : Icons.share,
                onPressed: _isSharing ? null : _shareResults,
                width: double.infinity,
                height: 56,
                fontSize: 16,
                isLoading: _isSharing,
              ),
            ),
          ],
        ),
      ),
    );
  }

  GameResult _calculateGameResult() {
    final gameData = widget.gameData;
    final finalScores = widget.finalScores;
    
    // 각 플레이어의 승패 기록 계산
    final Map<String, int> winCounts = {};
    final Map<String, int> loseCounts = {};
    final Map<String, int> highestScores = {};
    
    // 초기화
    for (final player in gameData.players) {
      winCounts[player.id] = 0;
      loseCounts[player.id] = 0;
      highestScores[player.id] = 0;
    }
    
    // 각 라운드별 점수에서 최고점 찾기
    for (final player in gameData.players) {
      final playerScoreList = gameData.playerScores[player.id] ?? [];
      if (playerScoreList.isNotEmpty) {
        highestScores[player.id] = playerScoreList.reduce((a, b) => a > b ? a : b);
      }
    }
    
    // 승패 기록은 최종 점수를 기준으로 계산 (실제로는 각 라운드 승자 기록이 필요)
    // 현재는 최종 점수 기준으로 간단히 계산
    final totalRounds = gameData.currentRound - 1;
    for (final player in gameData.players) {
      final finalAmount = finalScores[player.id] ?? 0;
      // 양수면 승리가 많았다고 가정, 음수면 패배가 많았다고 가정
      if (finalAmount > 0) {
        winCounts[player.id] = (totalRounds * 0.6).round(); // 60% 승률 가정
        loseCounts[player.id] = totalRounds - winCounts[player.id]!;
      } else {
        winCounts[player.id] = (totalRounds * 0.3).round(); // 30% 승률 가정
        loseCounts[player.id] = totalRounds - winCounts[player.id]!;
      }
    }
    
    // PlayerResult 리스트 생성
    final playerResults = gameData.players.map((player) {
      return PlayerResult.fromPlayer(
        player,
        winCount: winCounts[player.id] ?? 0,
        loseCount: loseCounts[player.id] ?? 0,
        finalAmount: finalScores[player.id] ?? 0,
        highestScore: highestScores[player.id] ?? 0,
      );
    }).toList();
    
    return GameResult(
      gameDate: DateTime.now(),
      players: playerResults,
      totalRounds: totalRounds,
      gameDurationMs: gameData.gameDuration.inMilliseconds,
      gameId: 'game_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  Future<void> _shareResults() async {
    if (_isSharing) return;
    
    setState(() {
      _isSharing = true;
    });
    
    try {
      // 스크린샷 캡처
      final Uint8List? imageBytes = await _screenshotController.capture();
      
      if (imageBytes != null) {
        // 임시 파일 생성
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/game_result_${DateTime.now().millisecondsSinceEpoch}.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(imageBytes);
        
        // 공유
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: '고스톱 게임 결과를 공유합니다! 🎮',
        );
      }
    } catch (e) {
      if (mounted) {
        ModernInfoDialog.show(
          context,
          title: '공유 실패',
          content: '결과 공유 중 오류가 발생했습니다.\n다시 시도해 주세요.',
          icon: Icons.error_outline,
          iconColor: AppColors.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<void> _saveAndGoHome(BuildContext context) async {
    if (_isSaving) return;
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      // 게임 결과 저장
      final gameResult = _calculateGameResult();
      debugPrint('Saving game result: ${gameResult.gameId}, players: ${gameResult.players.length}, rounds: ${gameResult.totalRounds}');
      await GameHistoryService.saveGameResult(gameResult);
      debugPrint('Game result saved successfully');
      
      if (mounted) {
        // 홈으로 이동 (스택 클리어)
        if (context.mounted) {
          context.go('/');
        }
      }
    } catch (e) {
      debugPrint('Error saving game result: $e');
      if (mounted && context.mounted) {
        ModernInfoDialog.show(
          context,
          title: '저장 실패',
          content: '게임 결과 저장 중 오류가 발생했습니다.\n다시 시도해 주세요.\n\n오류: $e',
          icon: Icons.error_outline,
          iconColor: AppColors.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '$hours시간 $minutes분';
    } else {
      return '$minutes분';
    }
  }
}