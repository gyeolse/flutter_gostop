import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/widgets/capsule_button.dart';
import '../models/player.dart';
import '../models/score_input.dart';
import '../models/game_rules.dart';

class ScoreResultDialog extends StatelessWidget {
  final List<Player> players;
  final ScoreInput scoreInput;
  final Map<String, int> calculatedScores;
  final GameRules gameRules;
  final Map<String, int> gwangSellingCount;
  final bool isGameEnd;
  final VoidCallback? onResultPressed;

  const ScoreResultDialog({
    super.key,
    required this.players,
    required this.scoreInput,
    required this.calculatedScores,
    required this.gameRules,
    this.gwangSellingCount = const {},
    this.isGameEnd = false,
    this.onResultPressed,
  });

  @override
  Widget build(BuildContext context) {
    final winner = players.firstWhere((p) => p.id == scoreInput.winnerId);
    final sortedScores = calculatedScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 400,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            _buildHeader(winner),
            
            // 스크롤 가능한 결과 내용
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 승자 정보
                    _buildWinnerSection(winner),
                    
                    // 플레이어별 점수 변화
                    _buildScoreChangeSection(sortedScores),
                    
                    // 특수 상황 및 패널티 요약 (게임 종료시에는 숨김)
                    if (!isGameEnd) _buildSpecialSituationsSection(),
                  ],
                ),
              ),
            ),
            
            // 액션 버튼
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Player winner) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGameEnd 
            ? [Colors.amber.shade400, Colors.orange.shade400]
            : [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // 메인 아이콘을 더 세련되게
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isGameEnd ? Icons.emoji_events : Icons.calculate,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          
          // 메인 제목
          Text(
            isGameEnd ? '🎉 게임 종료!' : '✨ 점수 계산 완료',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 승자 정보를 더 강조
          if (!isGameEnd) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${winner.name}님이 ${scoreInput.winnerScore}점으로 승리!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '👑',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  '최종 우승자: ${winner.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWinnerSection(Player winner) {
    final winnerScore = calculatedScores[winner.id] ?? 0;
    
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGameEnd 
            ? [Colors.amber.shade50, Colors.amber.shade100]
            : [Colors.green.shade50, Colors.green.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGameEnd 
            ? Colors.amber.shade300
            : Colors.green.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isGameEnd 
                ? Colors.amber.shade500
                : Colors.green.shade500,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isGameEnd ? Icons.emoji_events : Icons.trending_up,
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
                  isGameEnd ? '👑 ${winner.name}' : '🏆 ${winner.name}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isGameEnd 
                      ? Colors.amber.shade800
                      : Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isGameEnd 
                    ? '최종 우승자'
                    : '${scoreInput.winnerScore}점으로 승리',
                  style: TextStyle(
                    fontSize: 14,
                    color: isGameEnd 
                      ? Colors.amber.shade600
                      : Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            isGameEnd 
              ? _formatCurrency(winnerScore)
              : '+${_formatCurrency(winnerScore)}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isGameEnd 
                ? Colors.amber.shade700
                : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreChangeSection(List<MapEntry<String, int>> sortedScores) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isGameEnd ? '최종 점수' : '금액 변화',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          ...sortedScores.map((entry) {
            final player = players.firstWhere((p) => p.id == entry.key);
            final amount = entry.value;
            final isWinner = player.id == scoreInput.winnerId;
            
            return _buildPlayerScoreRow(player, amount, isWinner);
          }),
        ],
      ),
    );
  }

  Widget _buildPlayerScoreRow(Player player, int amount, bool isWinner) {
    final isPositive = amount > 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // 플레이어 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isPositive ? Colors.green.shade100 : Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                player.avatarPath,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 플레이어 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (isWinner) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '승자',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                _buildPlayerDetailsText(player),
              ],
            ),
          ),
          
          // 금액 표시
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isGameEnd 
                  ? _formatCurrency(amount)
                  : (isPositive ? '+${_formatCurrency(amount)}' : _formatCurrency(amount)),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? Colors.green.shade600 : Colors.red.shade600,
                ),
              ),
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? Colors.green.shade500 : Colors.red.shade500,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerDetailsText(Player player) {
    final details = <String>[];
    
    // 광 팔기
    final gwangCount = gwangSellingCount[player.id] ?? 0;
    if (gwangCount > 0) {
      details.add('광팔기 $gwangCount장');
    }
    
    // 패널티 확인
    final penalties = <String>[];
    if (scoreInput.loserPenalties['${player.id}_piBak'] == true) penalties.add('피박');
    if (scoreInput.loserPenalties['${player.id}_gwangBak'] == true) penalties.add('광박');
    if (scoreInput.loserPenalties['${player.id}_goBak'] == true) penalties.add('고박');
    if (scoreInput.loserPenalties['${player.id}_meongTeongGuri'] == true) penalties.add('멍텅구리');
    
    if (penalties.isNotEmpty) {
      details.add(penalties.join('+'));
    }
    
    // 특수 상황
    final specials = <String>[];
    if (scoreInput.specialSituations['${player.id}_firstFail'] == true) specials.add('첫뻑');
    if (scoreInput.specialSituations['${player.id}_consecutiveFail'] == true) specials.add('연뻑');
    if (scoreInput.specialSituations['${player.id}_ttaDak'] == true) specials.add('따닥');
    if (scoreInput.specialSituations['${player.id}_tripleFailure'] == true) specials.add('삼연뻑');
    if (scoreInput.specialSituations['${player.id}_president'] == true) specials.add('대통령');
    
    if (specials.isNotEmpty) {
      details.add(specials.join(', '));
    }
    
    return Text(
      details.isEmpty ? '일반' : details.join(' • '),
      style: TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildSpecialSituationsSection() {
    final hasSpecialSituations = scoreInput.specialSituations.values.any((v) => v == true);
    final hasPenalties = scoreInput.loserPenalties.values.any((v) => v == true);
    final hasGwangSelling = gwangSellingCount.values.any((v) => v > 0);
    
    if (!hasSpecialSituations && !hasPenalties && !hasGwangSelling) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '상황 요약',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasSpecialSituations) _buildSpecialSituationsList(),
          if (hasPenalties) _buildPenaltiesList(),
          if (hasGwangSelling) _buildGwangSellingList(),
        ],
      ),
    );
  }

  Widget _buildSpecialSituationsList() {
    final specials = <Widget>[];
    
    for (final player in players) {
      final playerSpecials = <String>[];
      if (scoreInput.specialSituations['${player.id}_firstFail'] == true) playerSpecials.add('첫뻑');
      if (scoreInput.specialSituations['${player.id}_consecutiveFail'] == true) playerSpecials.add('연뻑');
      if (scoreInput.specialSituations['${player.id}_ttaDak'] == true) playerSpecials.add('따닥');
      if (scoreInput.specialSituations['${player.id}_tripleFailure'] == true) playerSpecials.add('삼연뻑');
      if (scoreInput.specialSituations['${player.id}_president'] == true) playerSpecials.add('대통령');
      
      if (playerSpecials.isNotEmpty) {
        specials.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '🎯 ${player.name}: ${playerSpecials.join(', ')}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade600,
              ),
            ),
          ),
        );
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: specials,
    );
  }

  Widget _buildPenaltiesList() {
    final penalties = <Widget>[];
    
    for (final player in players) {
      final playerPenalties = <String>[];
      if (scoreInput.loserPenalties['${player.id}_piBak'] == true) playerPenalties.add('피박');
      if (scoreInput.loserPenalties['${player.id}_gwangBak'] == true) playerPenalties.add('광박');
      if (scoreInput.loserPenalties['${player.id}_goBak'] == true) playerPenalties.add('고박');
      if (scoreInput.loserPenalties['${player.id}_meongTeongGuri'] == true) playerPenalties.add('멍텅구리');
      
      if (playerPenalties.isNotEmpty) {
        penalties.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '⚠️ ${player.name}: ${playerPenalties.join('+')}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange.shade600,
              ),
            ),
          ),
        );
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: penalties,
    );
  }

  Widget _buildGwangSellingList() {
    final gwangSellers = <Widget>[];
    
    for (final player in players) {
      final gwangCount = gwangSellingCount[player.id] ?? 0;
      if (gwangCount > 0) {
        gwangSellers.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '⭐ ${player.name}: 광 $gwangCount장 판매',
              style: TextStyle(
                fontSize: 14,
                color: Colors.amber.shade700,
              ),
            ),
          ),
        );
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: gwangSellers,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (isGameEnd) ...[
            Expanded(
              child: CapsuleButtons.primary(
                text: '최종 결과 보기',
                icon: Icons.emoji_events,
                onPressed: onResultPressed,
                width: double.infinity,
                height: 48,
                fontSize: 16,
              ),
            ),
          ] else ...[
            Expanded(
              child: CapsuleButtons.primary(
                text: '확인',
                onPressed: () => Navigator.of(context).pop(),
                width: double.infinity,
                height: 48,
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';
  }
}