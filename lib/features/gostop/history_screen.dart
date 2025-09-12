import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/modern_dialog.dart';
import 'models/game_result.dart';
import 'services/game_history_service.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<GameResult> _gameResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGameHistory();
  }

  void _loadGameHistory() {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final results = GameHistoryService.getAllGameResults();
      setState(() {
        _gameResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _gameResults = [];
        _isLoading = false;
      });
      debugPrint('게임 기록 로딩 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Icons.history,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '게임 기록',
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
        actions: [
          if (_gameResults.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _showClearAllDialog,
              tooltip: '전체 기록 삭제',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _gameResults.isEmpty
              ? _buildEmptyState()
              : _buildGameHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 24),
          Text(
            '아직 게임 기록이 없습니다',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          Text(
            '게임을 완료하면 기록이 여기에 표시됩니다',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGameHistoryList() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadGameHistory();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _gameResults.length,
        itemBuilder: (context, index) {
          final gameResult = _gameResults[index];
          return _buildGameResultCard(gameResult, index);
        },
      ),
    );
  }

  Widget _buildGameResultCard(GameResult gameResult, int index) {
    final winner = gameResult.winner;
    final settlements = gameResult.calculateSettlements();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showGameResultDetails(gameResult),
        onLongPress: () => _showDeleteDialog(gameResult, index),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 게임 날짜 및 시간
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(gameResult.gameDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${gameResult.totalRounds}판',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 우승자 정보
              if (winner != null) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        color: Colors.amber.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            winner.playerName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                            ),
                          ),
                          Text(
                            '${_formatCurrency(winner.finalAmount)} 우승',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              
              // 플레이어별 최종 금액
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '최종 정산',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...gameResult.players.map((player) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              player.playerName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              player.finalAmount > 0 
                                  ? '+${_formatCurrency(player.finalAmount)}'
                                  : _formatCurrency(player.finalAmount),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: player.finalAmount > 0 
                                    ? Colors.green.shade600
                                    : player.finalAmount < 0
                                        ? Colors.red.shade600
                                        : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              
              // 게임 시간
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '게임 시간: ${_formatDuration(gameResult.gameDuration)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGameResultDetails(GameResult gameResult) {
    final settlements = gameResult.calculateSettlements();
    final winner = gameResult.winner;
    final bestPlayer = gameResult.bestRoundPlayer;
    
    ModernInfoDialog.show(
      context,
      title: '게임 상세 기록',
      content: _buildDetailedContent(gameResult, settlements, winner, bestPlayer),
      icon: Icons.info_outline,
      iconColor: AppColors.primary,
    );
  }

  String _buildDetailedContent(GameResult gameResult, List<Settlement> settlements, 
      PlayerResult? winner, PlayerResult? bestPlayer) {
    final buffer = StringBuffer();
    
    buffer.writeln('📅 게임 날짜: ${_formatDateTime(gameResult.gameDate)}');
    buffer.writeln('⏱️ 게임 시간: ${_formatDuration(gameResult.gameDuration)}');
    buffer.writeln('🎯 총 라운드: ${gameResult.totalRounds}판');
    buffer.writeln('');
    
    if (winner != null) {
      buffer.writeln('🏆 우승자: ${winner.playerName} (${_formatCurrency(winner.finalAmount)})');
      buffer.writeln('');
    }
    
    if (bestPlayer != null) {
      buffer.writeln('⭐ 최고 점수: ${bestPlayer.playerName} (${bestPlayer.highestScore}점)');
      buffer.writeln('');
    }
    
    buffer.writeln('💰 정산 내역:');
    for (final settlement in settlements) {
      buffer.writeln('${settlement.from} → ${settlement.to}: ${_formatCurrency(settlement.amount)}');
    }
    
    return buffer.toString();
  }

  void _showDeleteDialog(GameResult gameResult, int index) {
    ModernConfirmDialog.show(
      context,
      title: '게임 기록 삭제',
      content: '${_formatDate(gameResult.gameDate)} 게임 기록을 삭제하시겠습니까?',
      confirmText: '삭제',
      cancelText: '취소',
      icon: Icons.delete_outline,
      iconColor: AppColors.error,
      confirmColor: AppColors.error,
      onConfirm: () async {
        try {
          await GameHistoryService.deleteGameResult(index);
          _loadGameHistory();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('게임 기록이 삭제되었습니다')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('삭제 중 오류가 발생했습니다')),
            );
          }
        }
      },
    );
  }

  void _showClearAllDialog() {
    ModernConfirmDialog.show(
      context,
      title: '전체 기록 삭제',
      content: '모든 게임 기록을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
      confirmText: '전체 삭제',
      cancelText: '취소',
      icon: Icons.delete_sweep,
      iconColor: AppColors.error,
      confirmColor: AppColors.error,
      onConfirm: () async {
        try {
          await GameHistoryService.clearAllGameResults();
          _loadGameHistory();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('모든 게임 기록이 삭제되었습니다')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('삭제 중 오류가 발생했습니다')),
            );
          }
        }
      },
    );
  }

  /// 날짜 포맷팅 (MM/dd)
  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  /// 날짜시간 포맷팅 (yyyy/MM/dd HH:mm)
  String _formatDateTime(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// 금액 포맷팅
  String _formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';
  }

  /// 시간 포맷팅
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else {
      return '${minutes}분';
    }
  }
}