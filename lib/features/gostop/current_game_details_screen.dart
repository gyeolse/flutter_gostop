import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import 'models/game_data.dart';

class CurrentGameDetailsScreen extends ConsumerWidget {
  final GameData gameData;

  const CurrentGameDetailsScreen({
    super.key,
    required this.gameData,
  });

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
              child: const Icon(
                Icons.analytics,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '게임 상세 현황',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
            colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.secondary.withValues(alpha: 0.1)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.casino,
                  color: AppColors.primary,
                  size: 28,
                ),
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
                _buildInfoChip('총 ${gameData.currentRound - 1}판 완료', Icons.sports_esports, AppColors.primary),
                const SizedBox(width: 12),
                _buildInfoChip('${gameData.players.length}명 참여', Icons.people, AppColors.secondary),
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
                    Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 24),
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
    final maxRounds = gameData.playerScores.values.fold(0, (max, scores) => scores.length > max ? scores.length : max);
    final players = gameData.players;
    
    if (maxRounds == 0) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.table_chart,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                '아직 플레이한 라운드가 없습니다',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.table_chart, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  '라운드별 상세 점수표',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // 테이블 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    '라운드',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                ...players.map((player) => 
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          player.avatarPath,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          player.name,
                          style: TextStyle(
                            fontSize: 10,
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
          
          // 라운드별 점수 행
          ...List.generate(maxRounds, (roundIndex) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: roundIndex % 2 == 0 ? Colors.transparent : Colors.grey.shade50,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: roundIndex == maxRounds - 1 ? 0 : 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // 라운드 번호
                  SizedBox(
                    width: 60,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.secondary.withValues(alpha: 0.1)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '${roundIndex + 1}판',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  
                  // 각 플레이어의 점수
                  ...players.map((player) {
                    final playerScores = gameData.playerScores[player.id] ?? [];
                    final score = roundIndex < playerScores.length ? playerScores[roundIndex] : null;
                    
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: BoxDecoration(
                          color: score != null 
                              ? (score > 0 ? Colors.green.shade50 : score < 0 ? Colors.red.shade50 : Colors.grey.shade50)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: score != null 
                                ? (score > 0 ? Colors.green.shade200 : score < 0 ? Colors.red.shade200 : Colors.grey.shade200)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Text(
                          score != null 
                              ? (score > 0 ? '+${_formatCurrency(score)}' : score == 0 ? '0원' : _formatCurrency(score))
                              : '-',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: score != null 
                                ? (score > 0 ? Colors.green.shade700 : score < 0 ? Colors.red.shade700 : AppColors.textSecondary)
                                : Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
          
          // 합계 행
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '합계',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                // 각 플레이어의 총점
                ...players.map((player) {
                  final totalScore = gameData.totalScores[player.id] ?? 0;
                  final isLeading = totalScore == gameData.maxScore && totalScore > 0;
                  
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isLeading
                              ? [Colors.amber.shade100, Colors.orange.shade100]
                              : totalScore > 0
                                  ? [Colors.green.shade100, Colors.green.shade200]
                                  : totalScore < 0
                                      ? [Colors.red.shade100, Colors.red.shade200]
                                      : [Colors.grey.shade200, Colors.grey.shade300],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isLeading 
                              ? Colors.amber.shade400
                              : totalScore > 0
                                  ? Colors.green.shade400
                                  : totalScore < 0
                                      ? Colors.red.shade400
                                      : Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          if (isLeading)
                            Icon(
                              Icons.emoji_events,
                              color: Colors.amber.shade700,
                              size: 14,
                            ),
                          Text(
                            totalScore > 0 ? '+${_formatCurrency(totalScore)}' : _formatCurrency(totalScore),
                            style: TextStyle(
                              fontSize: 12,
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
    );
  }

  Widget _buildStatisticsCard() {
    final totalRounds = gameData.currentRound - 1;
    final totalPlayers = gameData.players.length;
    
    // 통계 계산
    final positiveScorePlayers = gameData.totalScores.values.where((score) => score > 0).length;
    final negativeScorePlayers = gameData.totalScores.values.where((score) => score < 0).length;
    final highestScore = gameData.totalScores.values.fold(0, (max, score) => score > max ? score : max);
    final lowestScore = gameData.totalScores.values.fold(0, (min, score) => score < min ? score : min);
    
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
                Icon(
                  Icons.bar_chart,
                  color: AppColors.primary,
                  size: 24,
                ),
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
            _buildStatRow('플러스 플레이어', '$positiveScorePlayers 명', Icons.trending_up, color: Colors.green),
            _buildStatRow('마이너스 플레이어', '$negativeScorePlayers 명', Icons.trending_down, color: Colors.red),
            _buildStatRow('최고 점수', _formatCurrency(highestScore), Icons.star, color: Colors.amber.shade700),
            _buildStatRow('최저 점수', _formatCurrency(lowestScore), Icons.star_outline, color: Colors.red.shade700),
            
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  Widget _buildStatRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon, 
            size: 18, 
            color: color ?? AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
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
}