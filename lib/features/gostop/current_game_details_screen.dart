import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import 'models/game_data.dart';

class CurrentGameDetailsScreen extends ConsumerWidget {
  final GameData gameData;

  const CurrentGameDetailsScreen({super.key, required this.gameData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.analytics, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              '게임 상세 현황',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 게임 요약 카드
            _buildGameSummaryCard(),
            const SizedBox(height: 16),

            // 상세 점수표 카드
            _buildDetailedScoreTable(),
            const SizedBox(height: 16),

            // 통계 카드
            _buildStatisticsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameSummaryCard() {
    final maxScore = gameData.maxScore;
    final leadingPlayer = gameData.leadingPlayer;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.1),
              AppColors.secondary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.casino, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  '게임 진행 상황',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _buildInfoChip(
                  '총 ${gameData.currentRound - 1}판 완료',
                  Icons.sports_esports,
                  AppColors.primary,
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  '${gameData.players.length}명 참여',
                  Icons.people,
                  AppColors.secondary,
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (leadingPlayer != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.amber.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '현재 1위',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade800,
                            ),
                          ),
                          Text(
                            '${leadingPlayer.name} - ${_formatCurrency(maxScore)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
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

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedScoreTable() {
    final maxRounds = gameData.playerScores.values.fold(
      0,
      (max, scores) => scores.length > max ? scores.length : max,
    );
    final players = gameData.players;

    if (maxRounds == 0) {
      return Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.table_chart_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '아직 플레이한 라운드가 없습니다',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '첫 번째 판을 시작해보세요!',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          // 헤더 - 더 세련되게
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.table_chart,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '라운드별 상세 점수표',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          // 개선된 테이블 컨텐츠
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 플레이어 헤더
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          '라운드',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ...players.map(
                        (player) => Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: _isImageAvatar(player.avatarPath)
                                      ? ClipOval(
                                          child: Image.asset(
                                            player.avatarPath,
                                            width: 36,
                                            height: 36,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Text(
                                          player.avatarPath,
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                player.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 라운드별 점수 행들
                ...List.generate(maxRounds, (roundIndex) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // 라운드 번호 - 더 돋보이게
                        SizedBox(
                          width: 80,
                          child: Text(
                            '${roundIndex + 1}판',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // 각 플레이어의 점수 - 더 깔끔하게
                        ...players.map((player) {
                          final playerScores =
                              gameData.playerScores[player.id] ?? [];
                          final score = roundIndex < playerScores.length
                              ? playerScores[roundIndex]
                              : null;

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: Text(
                                score != null
                                    ? (score > 0
                                          ? '+${_formatCurrency(score)}'
                                          : score == 0
                                          ? '0원'
                                          : _formatCurrency(score))
                                    : '-',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: score != null
                                      ? (score > 0
                                            ? Colors.green.shade700
                                            : score < 0
                                            ? Colors.red.shade700
                                            : AppColors.textSecondary)
                                      : Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // 합계 행 - 더 강조되게
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade100, Colors.grey.shade50],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          '합계',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // 각 플레이어의 총점
                      ...players.map((player) {
                        final totalScore = gameData.totalScores[player.id] ?? 0;
                        final isLeading =
                            totalScore == gameData.maxScore && totalScore > 0;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Column(
                              children: [
                                Text(
                                  totalScore > 0
                                      ? '+${_formatCurrency(totalScore)}'
                                      : _formatCurrency(totalScore),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isLeading
                                        ? Colors.amber.shade800
                                        : totalScore > 0
                                        ? Colors.green.shade800
                                        : totalScore < 0
                                        ? Colors.red.shade800
                                        : AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final totalRounds = gameData.currentRound - 1;
    final totalPlayers = gameData.players.length;

    // 통계 계산
    final positiveScorePlayers = gameData.totalScores.values
        .where((score) => score > 0)
        .length;
    final negativeScorePlayers = gameData.totalScores.values
        .where((score) => score < 0)
        .length;
    final highestScore = gameData.totalScores.values.fold(
      0,
      (max, score) => score > max ? score : max,
    );
    final lowestScore = gameData.totalScores.values.fold(
      0,
      (min, score) => score < min ? score : min,
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  '게임 통계',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 통계 정보
            _buildStatRow('총 라운드', '$totalRounds 판', Icons.casino),
            _buildStatRow('참여 플레이어', '$totalPlayers 명', Icons.people),
            _buildStatRow(
              '플러스 플레이어',
              '$positiveScorePlayers 명',
              Icons.trending_up,
              color: Colors.green,
            ),
            _buildStatRow(
              '마이너스 플레이어',
              '$negativeScorePlayers 명',
              Icons.trending_down,
              color: Colors.red,
            ),
            _buildStatRow(
              '최고 점수',
              _formatCurrency(highestScore),
              Icons.star,
              color: Colors.amber.shade700,
            ),
            _buildStatRow(
              '최저 점수',
              _formatCurrency(lowestScore),
              Icons.star_outline,
              color: Colors.red.shade700,
            ),

            const SizedBox(height: 16),

            // 진행률 표시
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.indigo.shade50],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.timeline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '게임 진행 상태',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          totalRounds > 0 ? '활발히 진행 중' : '게임 시작 대기중',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: totalRounds > 0 ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      totalRounds > 0 ? '진행중' : '대기',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildStatRow(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';
  }

  // 아바타가 이미지 파일인지 확인하는 헬퍼 메서드
  bool _isImageAvatar(String avatar) {
    return avatar.contains('lib/assets/images/') && avatar.endsWith('.png');
  }
}
