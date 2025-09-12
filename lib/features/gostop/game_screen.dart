import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/modern_dialog.dart';
import '../../services/snackbar_service.dart';
import '../../services/game_rules_service.dart';
import 'models/player.dart';
import 'models/gwang_selling.dart';
import 'models/game_data.dart';
import 'models/score_input.dart';
import 'services/score_calculator_service.dart';
import 'widgets/integrated_round_input_bottom_sheet.dart';
import 'widgets/score_result_dialog.dart';
import 'current_game_details_screen.dart';

// 게임 데이터 상태 관리
final gameDataProvider = StateNotifierProvider<GameDataNotifier, GameData?>((ref) {
  return GameDataNotifier();
});

class GameDataNotifier extends StateNotifier<GameData?> {
  GameDataNotifier() : super(null);

  void initializeGame({
    required List<Player> players,
    List<GwangSelling>? gwangSellings,
  }) {
    state = GameData.initialize(
      players: players,
      gwangSellings: gwangSellings,
    );
  }

  void addRoundScores(Map<String, int> roundScores) {
    if (state == null) return;
    state = state!.addRoundScores(roundScores);
  }

  void resetGame() {
    state = null;
  }
}

class GameScreen extends ConsumerStatefulWidget {
  final List<Player> players;
  final List<GwangSelling>? gwangSellings;

  const GameScreen({
    super.key,
    required this.players,
    this.gwangSellings,
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  @override
  void initState() {
    super.initState();
    // 게임 데이터 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameDataProvider.notifier).initializeGame(
        players: widget.players,
        gwangSellings: widget.gwangSellings,
      );
    });
  }

  void _inputScores() {
    final gameData = ref.read(gameDataProvider);
    if (gameData == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: IntegratedRoundInputBottomSheet(
          players: gameData.players,
          onRoundCompleted: _onRoundCompleted,
        ),
      ),
    );
  }
  
  void _endGame() async {
    final gameData = ref.read(gameDataProvider);
    if (gameData == null) return;

    // 총합 점수를 기반으로 가짜 ScoreInput 생성 (게임 종료용)
    final winnerEntry = gameData.totalScores.entries.reduce((a, b) => a.value > b.value ? a : b);
    final winner = gameData.players.firstWhere((p) => p.id == winnerEntry.key);
    
    final gameRules = await ref.read(gameRulesServiceProvider).loadGameRules();
    final totalScores = gameData.totalScores;
    
    showDialog(
      context: context,
      builder: (context) => ScoreResultDialog(
        players: gameData.players,
        scoreInput: ScoreInput(
          winnerId: winner.id,
          winnerScore: 0,
          loserPenalties: {},
          specialSituations: {},
          continuousFailures: {},
          gwangSelling: {},
          isPresident: false,
          isTripleFailure: false,
        ),
        calculatedScores: totalScores,
        gameRules: gameRules,
        gwangSellingCount: {},
        isGameEnd: true,
        onResultPressed: () {
          Navigator.of(context).pop(); // 다이얼로그 닫기
          context.go('/result', extra: {
            'gameData': gameData,
            'finalScores': totalScores,
          });
        },
      ),
    );
  }
  
  void _onRoundCompleted(ScoreInput scoreInput, bool isGameEnd, Map<String, int> gwangSellingCount) async {
    final gameData = ref.read(gameDataProvider);
    if (gameData == null) return;
    
    final gameRules = await ref.read(gameRulesServiceProvider).loadGameRules();
    
    // 점수 계산 (금액 기반)
    final roundScores = ScoreCalculatorService.calculateRoundScores(
      players: gameData.players,
      scoreInput: scoreInput,
      gameRules: gameRules,
      gwangSellingCount: gwangSellingCount,
    );
    
    // 점수 요약 생성 (ScoreResultDialog에서 직접 처리)
    
    // 게임 데이터 업데이트
    ref.read(gameDataProvider.notifier).addRoundScores(roundScores);
    
    // 결과 표시
    final roundMessage = isGameEnd ? '게임이 종료되었습니다!' : '${gameData.currentRound}라운드 점수가 추가되었습니다!';
    ref.read(snackbarServiceProvider).showSuccess(roundMessage);
    
    // 점수 계산 결과를 직관적인 다이얼로그로 표시
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ScoreResultDialog(
          players: gameData.players,
          scoreInput: scoreInput,
          calculatedScores: roundScores,
          gameRules: gameRules,
          gwangSellingCount: gwangSellingCount,
          isGameEnd: isGameEnd,
          onResultPressed: isGameEnd ? () {
            Navigator.of(context).pop();
            context.go('/result', extra: {
              'gameData': gameData,
              'finalScores': roundScores,
            });
          } : null,
        ),
      );
    }
  }

  void _showGameMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGameMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameData = ref.watch(gameDataProvider);

    if (gameData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitConfirmation();
        }
      },
      child: Scaffold(
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
                Icons.casino,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${gameData.currentRound} 라운드',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _showExitConfirmation,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showGameMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          // 게임 정보 헤더
          _buildGameInfoHeader(gameData),
          
          // 플레이어별 점수 현황
          Expanded(
            child: _buildScoreBoard(gameData),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // 게임 종료 버튼
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.red.shade200,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade100.withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: _endGame,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.stop_circle_outlined,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '게임 종료',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 점수 입력 버튼
              Expanded(
                flex: 2,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: _inputScores,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '이번 판 점수 입력하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildGameInfoHeader(GameData gameData) {
    final hasGwangSelling = gameData.gwangSellings != null && 
        gameData.gwangSellings!.any((g) => g.isSelling);

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.blue.shade50.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.leaderboard,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '게임 진행 상황',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${gameData.players.length}명 참여',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.green.shade700],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '진행중',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          if (hasGwangSelling) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.amber.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '광 팔기 설정',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...gameData.gwangSellings!
                      .where((g) => g.isSelling)
                      .map((g) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '• ${g.playerName}: ${g.gwangCount}장',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreBoard(GameData gameData) {
    if (gameData.currentRound == 1 && gameData.totalScores.values.every((s) => s == 0)) {
      // 게임 시작 전
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.play_circle_filled,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '게임을 시작해주세요!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '아래 버튼을 눌러 첫 번째 판의 점수를 입력하세요',
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

    return SingleChildScrollView(
      child: Column(
        children: [
          // 현재 라운드와 전체 현황
          _buildGameStatusHeader(gameData),
          
          const SizedBox(height: 24),
          
          // 현재 점수 현황 (간단하게)
          _buildCurrentScoreStatus(gameData),
          
          const SizedBox(height: 100), // FloatingActionButton 공간 확보
        ],
      ),
    );
  }

  Widget _buildPlayerScoreCard({
    required Player player,
    required int totalScore,
    required List<int> roundScores,
    required int rank,
    required bool isLeading,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: isLeading
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.amber.shade50,
                  Colors.orange.shade50,
                ],
              )
            : LinearGradient(
                colors: [Colors.white, Colors.white],
              ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLeading ? Colors.amber.shade300 : Colors.grey.shade200,
          width: isLeading ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isLeading
                ? Colors.amber.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isLeading ? 15 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // 순위 배지
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isLeading
                          ? [Colors.amber, Colors.orange]
                          : [Colors.grey.shade400, Colors.grey.shade500],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // 플레이어 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            player.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isLeading ? Colors.amber.shade800 : AppColors.textPrimary,
                            ),
                          ),
                          if (isLeading) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.emoji_events,
                              color: Colors.amber.shade600,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${roundScores.length}판 참여',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 총점
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isLeading
                          ? [Colors.amber.shade100, Colors.orange.shade100]
                          : [Colors.grey.shade100, Colors.grey.shade200],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatCurrency(totalScore),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isLeading ? Colors.amber.shade800 : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            
            // 라운드별 점수 (있을 경우)
            if (roundScores.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isLeading
                      ? Colors.amber.shade50.withValues(alpha: 0.5)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '라운드별 점수',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: roundScores.asMap().entries.map((entry) {
                        final round = entry.key + 1;
                        final score = entry.value;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: score > 0 ? Colors.green.shade100 : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$round판: ${score > 0 ? '+' : ''}${_formatCurrency(score)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: score > 0 ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                        );
                      }).toList(),
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

  void _showExitConfirmation() {
    ModernConfirmDialog.show(
      context,
      title: '게임 종료',
      content: '게임을 종료하고 홈으로 돌아가시겠습니까?\n현재 게임 진행상황은 저장되지 않습니다.',
      confirmText: '종료',
      cancelText: '취소',
      icon: Icons.exit_to_app,
      iconColor: AppColors.error,
      confirmColor: AppColors.error,
      onConfirm: () => context.go('/'),
    );
  }

  Widget _buildGameMenuSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    '게임 메뉴',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildMenuButton(
                    icon: Icons.history,
                    title: '게임 기록',
                    subtitle: '라운드별 점수 내역 보기',
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(snackbarServiceProvider).showInfo('게임 기록을 확인합니다');
                    },
                  ),
                  
                  _buildMenuButton(
                    icon: Icons.restart_alt,
                    title: '게임 재시작',
                    subtitle: '현재 게임을 초기화하고 다시 시작',
                    onTap: () {
                      Navigator.pop(context);
                      _showRestartDialog();
                    },
                  ),
                  
                  _buildMenuButton(
                    icon: Icons.exit_to_app,
                    title: '게임 종료',
                    subtitle: '게임을 종료하고 홈으로 돌아가기',
                    onTap: () {
                      Navigator.pop(context);
                      _showExitDialog();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.grey.shade50,
      ),
    );
  }

  void _showRestartDialog() {
    ModernConfirmDialog.show(
      context,
      title: '게임 재시작',
      content: '정말로 게임을 재시작하시겠습니까?\n현재까지의 모든 점수가 초기화됩니다.',
      confirmText: '재시작',
      cancelText: '취소',
      icon: Icons.refresh,
      iconColor: AppColors.warning,
      confirmColor: AppColors.warning,
      onConfirm: () {
        ref.read(gameDataProvider.notifier).resetGame();
        ref.read(gameDataProvider.notifier).initializeGame(
          players: widget.players,
          gwangSellings: widget.gwangSellings,
        );
        ref.read(snackbarServiceProvider).showSuccess('게임이 재시작되었습니다');
      },
    );
  }

  void _showExitDialog() {
    ModernConfirmDialog.show(
      context,
      title: '게임 종료',
      content: '정말로 게임을 종료하시겠습니까?\n현재까지의 모든 점수가 사라집니다.',
      confirmText: '종료',
      cancelText: '취소',
      icon: Icons.close,
      iconColor: AppColors.error,
      confirmColor: AppColors.error,
      onConfirm: () => context.go('/'),
    );
  }

  Widget _buildGameStatusHeader(GameData gameData) {
    final maxScore = gameData.maxScore;
    final leadingPlayer = gameData.leadingPlayer;
    
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.secondary.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.casino,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${gameData.currentRound}라운드',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      leadingPlayer != null 
                          ? '${leadingPlayer.name}님이 ${_formatCurrency(maxScore)}으로 1위'
                          : '게임을 시작해보세요!',
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
          if (gameData.currentRound > 1) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusChip('총 ${gameData.currentRound - 1}판', Icons.sports_esports),
                _buildStatusChip('${gameData.players.length}명 참가', Icons.people),
                _buildStatusChip('최고 ${_formatCurrency(maxScore)}', Icons.star),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreTable(GameData gameData) {
    final maxRounds = gameData.playerScores.values.map((scores) => scores.length).reduce((a, b) => a > b ? a : b);
    final rankings = gameData.playerRankings;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 테이블 헤더
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    '순위',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '플레이어',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                ...List.generate(maxRounds, (index) =>
                  Expanded(
                    child: Text(
                      '${index + 1}판',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '총점',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          // 플레이어별 점수 행
          ...rankings.asMap().entries.map((entry) {
            final index = entry.key;
            final playerEntry = entry.value;
            final player = playerEntry.key;
            final totalScore = playerEntry.value;
            final roundScores = gameData.playerScores[player.id] ?? [];
            final isLeading = index == 0 && totalScore > 0;
            
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isLeading 
                    ? Colors.amber.withValues(alpha: 0.05)
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: index == rankings.length - 1 ? 0 : 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // 순위
                  SizedBox(
                    width: 60,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isLeading ? Colors.amber : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${index + 1}위',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isLeading ? Colors.white : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  
                  // 플레이어 이름
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Text(
                          player.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isLeading ? Colors.amber.shade700 : AppColors.textPrimary,
                          ),
                        ),
                        if (isLeading) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber.shade600,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // 각 라운드 점수
                  ...List.generate(maxRounds, (roundIndex) {
                    final score = roundIndex < roundScores.length ? roundScores[roundIndex] : null;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: score != null 
                              ? (score > 0 ? Colors.green.shade50 : Colors.red.shade50)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          score != null ? (score > 0 ? '+${_formatCurrency(score)}' : _formatCurrency(score)) : '-',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: score != null 
                                ? (score > 0 ? Colors.green.shade700 : Colors.red.shade700)
                                : Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }),
                  
                  // 총점
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isLeading
                              ? [Colors.amber.shade100, Colors.orange.shade100]
                              : totalScore > 0
                                  ? [Colors.green.shade50, Colors.green.shade100]
                                  : totalScore < 0
                                      ? [Colors.red.shade50, Colors.red.shade100]
                                      : [Colors.grey.shade50, Colors.grey.shade100],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isLeading 
                              ? Colors.amber.shade300
                              : totalScore > 0
                                  ? Colors.green.shade300
                                  : totalScore < 0
                                      ? Colors.red.shade300
                                      : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        totalScore > 0 ? '+${_formatCurrency(totalScore)}' : _formatCurrency(totalScore),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isLeading
                              ? Colors.amber.shade800
                              : totalScore > 0
                                  ? Colors.green.shade700
                                  : totalScore < 0
                                      ? Colors.red.shade700
                                      : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
  
  /// 현재 점수 현황만 간단하게 표시
  Widget _buildCurrentScoreStatus(GameData gameData) {
    // 플레이어들을 총점 기준으로 정렬
    final sortedPlayers = gameData.players.map((player) {
      final totalScore = gameData.totalScores[player.id] ?? 0;
      return {'player': player, 'score': totalScore};
    }).toList()
      ..sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(20),
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
                const Icon(
                  Icons.leaderboard,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  '현재 순위',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${gameData.currentRound - 1}판 완료',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 플레이어 순위 리스트
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedPlayers.length,
            itemBuilder: (context, index) {
              final playerData = sortedPlayers[index];
              final player = playerData['player'] as Player;
              final score = playerData['score'] as int;
              final rank = index + 1;
              final isLeading = rank == 1 && score > 0;
              
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isLeading 
                    ? Colors.amber.shade50 
                    : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade100,
                      width: index < sortedPlayers.length - 1 ? 1 : 0,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // 순위 표시
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isLeading 
                          ? Colors.amber.shade400 
                          : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isLeading
                          ? const Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 20,
                            )
                          : Text(
                              '$rank',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // 플레이어 이름
                    Expanded(
                      child: Text(
                        player.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isLeading 
                            ? Colors.amber.shade800 
                            : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    
                    // 총 점수
                    Text(
                      _formatCurrency(score),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: score > 0 
                          ? Colors.green.shade600 
                          : score < 0 
                            ? Colors.red.shade600 
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // 상세 기록 보기 버튼
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CurrentGameDetailsScreen(gameData: gameData),
                    ),
                  );
                },
                icon: const Icon(Icons.analytics),
                label: const Text('상세 기록 보기'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 금액 포맷팅 함수
  String _formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';
  }
}