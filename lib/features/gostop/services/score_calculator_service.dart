import '../models/player.dart';
import '../models/score_input.dart';
import '../models/game_rules.dart';

class ScoreCalculatorService {
  static Map<String, int> calculateRoundScores({
    required List<Player> players,
    required ScoreInput scoreInput,
    required GameRules gameRules,
    Map<String, int> gwangSellingCount = const {},
  }) {
    final scores = <String, int>{};

    // 모든 플레이어 금액 초기화
    for (final player in players) {
      scores[player.id] = 0;
    }

    // 광 팔기 금액 계산 (광을 판 사람들은 패자가 아님)
    final gwangSellers = <String>{};
    for (final player in players) {
      if (player.id != scoreInput.winnerId) {
        // 승자는 광 팔기 불가
        final gwangCount = gwangSellingCount[player.id] ?? 0;
        if (gwangCount > 0) {
          scores[player.id] = gwangCount * gameRules.gwangSellPrice;
          gwangSellers.add(player.id);
        }
      }
    }

    // 실제 패자들: 승자도 아니고 광 판매자도 아닌 사람들
    final actualLosers = players
        .where(
          (p) => p.id != scoreInput.winnerId && !gwangSellers.contains(p.id),
        )
        .toList();

    // 1단계: 게임 승부 금액 계산 (승자가 각 패자에게서 받음)
    for (final loser in actualLosers) {
      // 기본 패배 금액: 승자 점수 * 점당 금액
      int baseLoserAmount = scoreInput.winnerScore * gameRules.pointPrice;

      // 패널티 계산: 각 패널티마다 2배씩 적용 (복수 선택 가능)
      int penaltyMultiplier = 1;
      if (scoreInput.loserPenalties['${loser.id}_piBak'] == true) {
        penaltyMultiplier *= 2; // 피박
      }
      if (scoreInput.loserPenalties['${loser.id}_gwangBak'] == true) {
        penaltyMultiplier *= 2; // 광박
      }
      if (scoreInput.loserPenalties['${loser.id}_goBak'] == true) {
        penaltyMultiplier *= 2; // 고박
      }
      if (scoreInput.loserPenalties['${loser.id}_meongTeongGuri'] == true) {
        penaltyMultiplier *= 2; // 멍텅구리
      }

      baseLoserAmount *= penaltyMultiplier;

      // 패자는 승자에게 지불
      scores[loser.id] = (scores[loser.id] ?? 0) - baseLoserAmount;
      // 승자는 패자로부터 받음
      scores[scoreInput.winnerId] =
          (scores[scoreInput.winnerId] ?? 0) + baseLoserAmount;
    }

    // 2단계: 특수 상황 보상 계산 (특수상황을 한 플레이어가 다른 모든 플레이어에게서 받음)
    for (final player in players) {
      int specialEarningsPerPlayer = 0;

      // 첫뻑 보상 (1인당)
      if (scoreInput.specialSituations['${player.id}_firstFail'] == true) {
        specialEarningsPerPlayer += gameRules.ppeoPrice;
      }

      // 연뻑 보상 (1인당)
      if (scoreInput.specialSituations['${player.id}_consecutiveFail'] ==
          true) {
        specialEarningsPerPlayer += gameRules.ppeoPrice * 2;
      }

      // 따닥 보상 (1인당)
      if (scoreInput.specialSituations['${player.id}_ttaDak'] == true) {
        specialEarningsPerPlayer += gameRules.ddadakPrice;
      }

      // 삼연뻑 보상 (1인당) - 첫뻑 점수의 4배
      if (scoreInput.specialSituations['${player.id}_tripleFailure'] == true) {
        specialEarningsPerPlayer += gameRules.ppeoPrice * 4;
      }

      // 대통령 보상 (1인당)
      if (scoreInput.specialSituations['${player.id}_president'] == true) {
        specialEarningsPerPlayer += gameRules.presidentPrice;
      }

      if (specialEarningsPerPlayer > 0) {
        // 다른 모든 플레이어에게서 해당 금액을 받음
        final otherPlayers = players.where((p) => p.id != player.id).toList();

        for (final otherPlayer in otherPlayers) {
          // 특수상황 플레이어가 다른 플레이어로부터 받음
          scores[player.id] =
              (scores[player.id] ?? 0) + specialEarningsPerPlayer;
          // 다른 플레이어가 특수상황 플레이어에게 지불
          scores[otherPlayer.id] =
              (scores[otherPlayer.id] ?? 0) - specialEarningsPerPlayer;
        }
      }
    }

    return scores;
  }

  /// 금액 요약 정보를 생성합니다.
  static String generateScoreSummary({
    required List<Player> players,
    required ScoreInput scoreInput,
    required Map<String, int> calculatedScores,
    required GameRules gameRules,
    Map<String, int> gwangSellingCount = const {},
  }) {
    final winner = players.firstWhere((p) => p.id == scoreInput.winnerId);
    final winnerAmount = calculatedScores[scoreInput.winnerId] ?? 0;

    String summary = '🏆 ${winner.name}: +${_formatCurrency(winnerAmount)}\n';

    final otherPlayers = players
        .where((p) => p.id != scoreInput.winnerId)
        .toList();
    for (final player in otherPlayers) {
      final playerAmount = calculatedScores[player.id] ?? 0;
      final sign = playerAmount >= 0 ? '+' : '';
      final icon = playerAmount >= 0 ? '💰' : '📉';
      summary +=
          '$icon ${player.name}: $sign${_formatCurrency(playerAmount)}\n';

      // 세부 정보
      final details = <String>[];

      // 광 팔기 정보
      final gwangCount = gwangSellingCount[player.id] ?? 0;
      if (gwangCount > 0) {
        details.add(
          '광팔기 $gwangCount장 (+${_formatCurrency(gwangCount * gameRules.gwangSellPrice)})',
        );
      }

      // 특수 상황 보상 정보 (해당 플레이어가 받은 경우)
      final specialEarnings = <String>[];
      final otherPlayersCount = players.length - 1;

      if (scoreInput.specialSituations['${player.id}_firstFail'] == true) {
        final totalEarning = gameRules.ppeoPrice * otherPlayersCount;
        specialEarnings.add('첫뻑 (+${_formatCurrency(totalEarning)})');
      }
      if (scoreInput.specialSituations['${player.id}_consecutiveFail'] ==
          true) {
        final totalEarning = gameRules.ppeoPrice * otherPlayersCount;
        specialEarnings.add('연뻑 (+${_formatCurrency(totalEarning)})');
      }
      if (scoreInput.specialSituations['${player.id}_ttaDak'] == true) {
        final totalEarning = gameRules.ddadakPrice * otherPlayersCount;
        specialEarnings.add('따닥 (+${_formatCurrency(totalEarning)})');
      }
      if (scoreInput.specialSituations['${player.id}_tripleFailure'] == true) {
        final totalEarning = gameRules.ppeoPrice * 4 * otherPlayersCount;
        specialEarnings.add('삼연뻑 (+${_formatCurrency(totalEarning)})');
      }
      if (scoreInput.specialSituations['${player.id}_president'] == true) {
        final totalEarning = gameRules.presidentPrice * otherPlayersCount;
        specialEarnings.add('대통령 (+${_formatCurrency(totalEarning)})');
      }

      if (specialEarnings.isNotEmpty) {
        details.addAll(specialEarnings);
      }

      // 특수 상황 지불 정보 (다른 플레이어의 특수상황에 대한 지불)
      final specialPayments = <String>[];
      for (final otherPlayer in players.where((p) => p.id != player.id)) {
        if (scoreInput.specialSituations['${otherPlayer.id}_firstFail'] ==
            true) {
          specialPayments.add(
            '${otherPlayer.name} 첫뻑 (-${_formatCurrency(gameRules.ppeoPrice)})',
          );
        }
        if (scoreInput.specialSituations['${otherPlayer.id}_consecutiveFail'] ==
            true) {
          specialPayments.add(
            '${otherPlayer.name} 연뻑 (-${_formatCurrency(gameRules.ppeoPrice)})',
          );
        }
        if (scoreInput.specialSituations['${otherPlayer.id}_ttaDak'] == true) {
          specialPayments.add(
            '${otherPlayer.name} 따닥 (-${_formatCurrency(gameRules.ddadakPrice)})',
          );
        }
        if (scoreInput.specialSituations['${otherPlayer.id}_tripleFailure'] ==
            true) {
          specialPayments.add(
            '${otherPlayer.name} 삼연뻑 (-${_formatCurrency(gameRules.ppeoPrice * 4)})',
          );
        }
        if (scoreInput.specialSituations['${otherPlayer.id}_president'] ==
            true) {
          specialPayments.add(
            '${otherPlayer.name} 대통령 (-${_formatCurrency(gameRules.presidentPrice)})',
          );
        }
      }

      if (specialPayments.isNotEmpty) {
        details.addAll(specialPayments);
      }

      // 패배 관련 정보 (음수인 경우만)
      if (playerAmount < 0) {
        // 페널티 정보
        final penalties = <String>[];
        if (scoreInput.loserPenalties['${player.id}_piBak'] == true)
          penalties.add('피박');
        if (scoreInput.loserPenalties['${player.id}_gwangBak'] == true)
          penalties.add('광박');
        if (scoreInput.loserPenalties['${player.id}_goBak'] == true)
          penalties.add('고박');
        if (scoreInput.loserPenalties['${player.id}_meongTeongGuri'] == true)
          penalties.add('멍텅구리');

        if (penalties.isNotEmpty) {
          final baseAmount = scoreInput.winnerScore * gameRules.pointPrice;

          // 패널티 배수 계산
          int penaltyMultiplier = 1;
          if (scoreInput.loserPenalties['${player.id}_piBak'] == true) {
            penaltyMultiplier *= 2;
          }
          if (scoreInput.loserPenalties['${player.id}_gwangBak'] == true) {
            penaltyMultiplier *= 2;
          }
          if (scoreInput.loserPenalties['${player.id}_goBak'] == true) {
            penaltyMultiplier *= 2;
          }
          if (scoreInput.loserPenalties['${player.id}_meongTeongGuri'] ==
              true) {
            penaltyMultiplier *= 2;
          }

          final penaltyAmount = baseAmount * penaltyMultiplier;
          final multiplierText = penaltyMultiplier > 1
              ? ' ($penaltyMultiplier배)'
              : '';
          details.add(
            '${penalties.join('+')} (-${_formatCurrency(penaltyAmount)})$multiplierText',
          );
        }
      }

      if (details.isNotEmpty) {
        summary += '   └ ${details.join(', ')}\n';
      }
    }

    return summary;
  }

  /// 금액 포맷팅 함수
  static String _formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';
  }
}
