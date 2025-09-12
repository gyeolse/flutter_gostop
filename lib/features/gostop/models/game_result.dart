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
    final List<PlayerResult> creditors = []; // 받을 사람들 (양수)
    final List<PlayerResult> debtors = []; // 줄 사람들 (음수)

    // 채권자와 채무자 분리
    for (final player in players) {
      if (player.finalAmount > 0) {
        creditors.add(player);
      } else if (player.finalAmount < 0) {
        debtors.add(player);
      }
    }

    // 정산 계산
    for (final debtor in debtors) {
      int remainingDebt = -debtor.finalAmount; // 음수를 양수로 변환

      for (final creditor in creditors) {
        if (remainingDebt <= 0) break;

        int availableCredit = creditor.finalAmount;
        if (availableCredit <= 0) continue;

        int transferAmount = remainingDebt < availableCredit ? remainingDebt : availableCredit;

        settlements.add(Settlement(
          from: debtor.playerName,
          to: creditor.playerName,
          amount: transferAmount,
        ));

        remainingDebt -= transferAmount;
        // 채권자의 남은 금액 업데이트 (실제 객체는 변경하지 않음)
        creditor.finalAmount -= transferAmount;
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

  PlayerResult({
    required this.playerId,
    required this.playerName,
    required this.avatarPath,
    required this.winCount,
    required this.loseCount,
    required this.finalAmount,
    required this.highestScore,
  });

  // Factory constructor to create from Player and game data
  factory PlayerResult.fromPlayer(
    Player player, {
    required int winCount,
    required int loseCount,
    required int finalAmount,
    required int highestScore,
  }) {
    return PlayerResult(
      playerId: player.id,
      playerName: player.name,
      avatarPath: player.avatarPath,
      winCount: winCount,
      loseCount: loseCount,
      finalAmount: finalAmount,
      highestScore: highestScore,
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