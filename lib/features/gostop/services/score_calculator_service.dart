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

    print('=== 금액 계산 시작 ===');
    print('초기 gwangSellingCount: $gwangSellingCount');
    
    // 광팔이 식별 (광을 판 사람들 = 이번 판을 쉬어가는 사람들)
    final gwangSellers = <String>{};
    for (final player in players) {
      if (gwangSellingCount.containsKey(player.id)) {
        final gwangCount = gwangSellingCount[player.id] ?? 0;
        gwangSellers.add(player.id);
        print('광팔이: ${player.name} ($gwangCount장)');
      }
    }
    
    print('광팔이 목록: ${gwangSellers.map((id) => players.firstWhere((p) => p.id == id).name).join(", ")}');

    // 실제 게임 참여자들: 광팔이를 제외한 사람들
    final actualGamePlayers = players.where((p) => !gwangSellers.contains(p.id)).toList();
    final actualLosers = actualGamePlayers.where((p) => p.id != scoreInput.winnerId).toList();
    
    print('실제 게임 참여자: ${actualGamePlayers.map((p) => p.name).join(", ")}');
    print('실제 패자: ${actualLosers.map((p) => p.name).join(", ")}');

    // 삼연뻑이나 대통령인지 확인
    bool isTripleFailure = false;
    bool isPresident = false;
    
    for (final player in players) {
      if (scoreInput.specialSituations['${player.id}_tripleFailure'] == true) {
        isTripleFailure = true;
        break;
      }
      if (scoreInput.specialSituations['${player.id}_president'] == true) {
        isPresident = true;
        break;
      }
    }
    
    // 1단계: 게임 승부 금액 계산 (승자가 각 패자에게서 받음)
    // 삼연뻑이나 대통령일 때는 일반 승부 계산을 하지 않음
    if (!isTripleFailure && !isPresident) {
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
      scores[scoreInput.winnerId] = (scores[scoreInput.winnerId] ?? 0) + baseLoserAmount;
      
      print('${loser.name} → 승자: ${baseLoserAmount}원 (기본: ${scoreInput.winnerScore * gameRules.pointPrice}, 배수: $penaltyMultiplier)');
      }
    } else {
      print('삼연뻑/대통령으로 인한 일반 승부 계산 생략');
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
        // 특수상황 지불자: 광팔이를 제외한 실제 게임 참여자들
        final payingPlayers = actualGamePlayers.where((p) => p.id != player.id).toList();
        
        print('${player.name}의 특수상황: 1인당 ${specialEarningsPerPlayer}원');
        print('지불자: ${payingPlayers.map((p) => p.name).join(", ")}');

        for (final payingPlayer in payingPlayers) {
          // 특수상황 플레이어가 다른 플레이어로부터 받음
          scores[player.id] = (scores[player.id] ?? 0) + specialEarningsPerPlayer;
          // 다른 플레이어가 특수상황 플레이어에게 지불 (광팔이 제외)
          scores[payingPlayer.id] = (scores[payingPlayer.id] ?? 0) - specialEarningsPerPlayer;
          
          print('${payingPlayer.name} → ${player.name}: ${specialEarningsPerPlayer}원');
        }
      }
    }

    // 3단계: 광팔이 계산 (게임 참여자들이 광팔이에게 지불)
    if (gwangSellers.isNotEmpty && actualGamePlayers.isNotEmpty) {
      print('\n=== 광팔이 계산 시작 ===');
      
      for (final gwangSeller in gwangSellers) {
        final gwangCount = gwangSellingCount[gwangSeller] ?? 0;
        final gwangSellerName = players.firstWhere((p) => p.id == gwangSeller).name;
        
        print('\n광팔이: $gwangSellerName ($gwangCount장)');
        
        int totalGwangPayment = 0;
        
        // 게임 참여자들이 광팔이에게 지불
        if (gwangCount > 0) {
          // 실제로 광을 판 경우에만 금액 지불
          for (final gamePlayer in actualGamePlayers) {
            final basePayment = gameRules.gwangSellPrice;
            final payment = basePayment * gwangCount; // 장수만큼 배수
            
            scores[gamePlayer.id] = (scores[gamePlayer.id] ?? 0) - payment;
            totalGwangPayment += payment;
            
            print('${gamePlayer.name} → $gwangSellerName: ${payment}원 (기본: $basePayment, 배수: $gwangCount)');
          }
        } else {
          // 0장 (쉬어가기)인 경우 광팔기 금액 없음
          print('$gwangSellerName은 쉬어가기로 광팔기 금액 없음');
        }
        
        // 광팔이가 받음
        scores[gwangSeller] = (scores[gwangSeller] ?? 0) + totalGwangPayment;
        print('$gwangSellerName 총 수입: ${totalGwangPayment}원');
      }
    } else if (gwangSellers.isNotEmpty) {
      print('\n경고: 모든 플레이어가 광팔이입니다. 게임이 진행되지 않습니다.');
    }
    
    print('\n=== 최종 결과 ===');
    for (final player in players) {
      final amount = scores[player.id] ?? 0;
      print('${player.name}: ${amount}원');
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
      // 광을 판 사람들을 제외한 실제 게임 참여자 수 (광팔기 맵에 없는 사람들만)
      final actualGamePlayers = players.where((p) => 
          (gwangSellingCount[p.id] ?? 0) == 0).length;
      final otherPlayersCount = actualGamePlayers - 1;

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

      // 특수 상황 지불 정보 (다른 플레이어의 특수상황에 대한 지불, 광을 판 사람 제외)
      final specialPayments = <String>[];
      for (final otherPlayer in players.where((p) => 
          p.id != player.id && (gwangSellingCount[p.id] ?? 0) == 0)) {
        // 광을 판 사람은 지불하지 않음 (현재 플레이어가 광을 안 팔았을 경우만)
        if ((gwangSellingCount[player.id] ?? 0) == 0) {
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
