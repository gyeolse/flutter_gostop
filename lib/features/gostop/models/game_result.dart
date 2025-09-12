import 'package:hive/hive.dart';
import 'player.dart';

part 'game_result.g.dart';

@HiveType(typeId: 0)
class GameResult extends HiveObject {
  @HiveField(0)
  final DateTime gameDate;

  @HiveField(1)
  final List<PlayerResult> players;

  @HiveField(2)
  final int totalRounds;

  @HiveField(3)
  final int gameDurationMs; // Duration을 밀리초로 저장

  @HiveField(4)
  final String gameId;

  GameResult({
    required this.gameDate,
    required this.players,
    required this.totalRounds,
    required this.gameDurationMs,
    required this.gameId,
  });

  // Duration getter for convenience
  Duration get gameDuration => Duration(milliseconds: gameDurationMs);

  // 최고 점수를 낸 플레이어와 점수 찾기
  PlayerResult? get bestRoundPlayer {
    int maxScore = 0;
    PlayerResult? bestPlayer;

    for (final player in players) {
      if (player.highestScore > maxScore) {
        maxScore = player.highestScore;
        bestPlayer = player;
      }
    }

    return bestPlayer;
  }

  // 최종 우승자
  PlayerResult? get winner {
    int maxAmount = players.first.finalAmount;
    PlayerResult? winnerPlayer = players.first;

    for (final player in players) {
      if (player.finalAmount > maxAmount) {
        maxAmount = player.finalAmount;
        winnerPlayer = player;
      }
    }

    return winnerPlayer;
  }

  // 정산 계산 - 누가 누구에게 얼마를 줘야하는지
  List<Settlement> calculateSettlements() {
    final List<Settlement> settlements = [];
    final List<_SettlementPlayer> creditors = []; // 받을 사람들 (양수)
    final List<_SettlementPlayer> debtors = []; // 줄 사람들 (음수)

    // 채권자와 채무자 분리 (복사본 생성)
    for (final player in players) {
      if (player.finalAmount > 0) {
        creditors.add(_SettlementPlayer(player.playerName, player.finalAmount));
      } else if (player.finalAmount < 0) {
        debtors.add(_SettlementPlayer(player.playerName, player.finalAmount));
      }
    }

    // 정산 계산
    for (final debtor in debtors) {
      int remainingDebt = -debtor.amount; // 음수를 양수로 변환

      for (final creditor in creditors) {
        if (remainingDebt <= 0) break;

        int availableCredit = creditor.amount;
        if (availableCredit <= 0) continue;

        int transferAmount = remainingDebt < availableCredit ? remainingDebt : availableCredit;

        settlements.add(Settlement(
          from: debtor.name,
          to: creditor.name,
          amount: transferAmount,
        ));

        remainingDebt -= transferAmount;
        // 채권자의 남은 금액 업데이트 (복사본만 변경)
        creditor.amount -= transferAmount;
      }
    }

    return settlements;
  }
}

@HiveType(typeId: 1)
class PlayerResult extends HiveObject {
  @HiveField(0)
  final String playerId;

  @HiveField(1)
  final String playerName;

  @HiveField(2)
  final String avatarPath;

  @HiveField(3)
  final int winCount;

  @HiveField(4)
  final int loseCount;

  @HiveField(5)
  int finalAmount; // 최종 정산 금액

  @HiveField(6)
  final int highestScore; // 최고 점수

  @HiveField(7)
  final int bestRoundNumber; // 최고 점수를 낸 라운드 번호

  PlayerResult({
    required this.playerId,
    required this.playerName,
    required this.avatarPath,
    required this.winCount,
    required this.loseCount,
    required this.finalAmount,
    required this.highestScore,
    required this.bestRoundNumber,
  });

  // Factory constructor to create from Player and game data
  factory PlayerResult.fromPlayer(
    Player player, {
    required int winCount,
    required int loseCount,
    required int finalAmount,
    required int highestScore,
    required int bestRoundNumber,
  }) {
    return PlayerResult(
      playerId: player.id,
      playerName: player.name,
      avatarPath: player.avatarPath,
      winCount: winCount,
      loseCount: loseCount,
      finalAmount: finalAmount,
      highestScore: highestScore,
      bestRoundNumber: bestRoundNumber,
    );
  }
}

@HiveType(typeId: 2)
class Settlement extends HiveObject {
  @HiveField(0)
  final String from; // 보낼 사람

  @HiveField(1)
  final String to; // 받을 사람

  @HiveField(2)
  final int amount; // 금액

  Settlement({
    required this.from,
    required this.to,
    required this.amount,
  });
}

// 정산 계산용 헬퍼 클래스
class _SettlementPlayer {
  final String name;
  int amount;

  _SettlementPlayer(this.name, this.amount);
}