import 'player.dart';
import 'gwang_selling.dart';

class GameData {
  final List<Player> players;
  final List<GwangSelling>? gwangSellings;
  final int currentRound;
  final Map<String, List<int>> playerScores; // playerId -> scores for each round
  final Map<String, int> totalScores; // playerId -> total score
  final DateTime gameStartTime; // 게임 시작 시간

  const GameData({
    required this.players,
    this.gwangSellings,
    this.currentRound = 1,
    required this.playerScores,
    required this.totalScores,
    required this.gameStartTime,
  });

  // 초기 게임 데이터 생성
  factory GameData.initialize({
    required List<Player> players,
    List<GwangSelling>? gwangSellings,
  }) {
    final playerScores = <String, List<int>>{};
    final totalScores = <String, int>{};
    
    for (final player in players) {
      playerScores[player.id] = [];
      totalScores[player.id] = 0;
    }

    return GameData(
      players: players,
      gwangSellings: gwangSellings,
      currentRound: 1,
      playerScores: playerScores,
      totalScores: totalScores,
      gameStartTime: DateTime.now(),
    );
  }

  // 새 라운드 점수 추가
  GameData addRoundScores(Map<String, int> roundScores) {
    final newPlayerScores = Map<String, List<int>>.from(playerScores);
    final newTotalScores = Map<String, int>.from(totalScores);

    for (final entry in roundScores.entries) {
      final playerId = entry.key;
      final score = entry.value;
      
      newPlayerScores[playerId] = [...(newPlayerScores[playerId] ?? []), score];
      newTotalScores[playerId] = (newTotalScores[playerId] ?? 0) + score;
    }

    return copyWith(
      currentRound: currentRound + 1,
      playerScores: newPlayerScores,
      totalScores: newTotalScores,
    );
  }

  // 복사본 생성
  GameData copyWith({
    List<Player>? players,
    List<GwangSelling>? gwangSellings,
    int? currentRound,
    Map<String, List<int>>? playerScores,
    Map<String, int>? totalScores,
    DateTime? gameStartTime,
  }) {
    return GameData(
      players: players ?? this.players,
      gwangSellings: gwangSellings ?? this.gwangSellings,
      currentRound: currentRound ?? this.currentRound,
      playerScores: playerScores ?? this.playerScores,
      totalScores: totalScores ?? this.totalScores,
      gameStartTime: gameStartTime ?? this.gameStartTime,
    );
  }

  // 최고 점수 플레이어
  Player? get leadingPlayer {
    if (totalScores.isEmpty) return null;
    
    final maxScore = totalScores.values.reduce((a, b) => a > b ? a : b);
    final leadingPlayerId = totalScores.entries
        .firstWhere((entry) => entry.value == maxScore)
        .key;
    
    return players.firstWhere((player) => player.id == leadingPlayerId);
  }

  // 최고 점수
  int get maxScore {
    if (totalScores.isEmpty) return 0;
    return totalScores.values.reduce((a, b) => a > b ? a : b);
  }

  // 플레이어별 현재 순위 (1위, 2위, 3위, 4위)
  List<MapEntry<Player, int>> get playerRankings {
    final sortedScores = totalScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedScores.map((entry) {
      final player = players.firstWhere((p) => p.id == entry.key);
      return MapEntry(player, entry.value);
    }).toList();
  }

  // 게임 진행 시간
  Duration get gameDuration {
    return DateTime.now().difference(gameStartTime);
  }

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'players': players.map((p) => p.toJson()).toList(),
      'gwangSellings': gwangSellings?.map((g) => g.toJson()).toList(),
      'currentRound': currentRound,
      'playerScores': playerScores,
      'totalScores': totalScores,
      'gameStartTime': gameStartTime.toIso8601String(),
    };
  }

  // JSON 역직렬화
  factory GameData.fromJson(Map<String, dynamic> json) {
    return GameData(
      players: (json['players'] as List<dynamic>?)
          ?.map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList() ?? [],
      gwangSellings: (json['gwangSellings'] as List<dynamic>?)
          ?.map((g) => GwangSelling.fromJson(g as Map<String, dynamic>))
          .toList(),
      currentRound: json['currentRound'] ?? 1,
      playerScores: Map<String, List<int>>.from(
        (json['playerScores'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, List<int>.from(value)),
        ) ?? {},
      ),
      totalScores: Map<String, int>.from(json['totalScores'] ?? {}),
      gameStartTime: json['gameStartTime'] != null 
          ? DateTime.parse(json['gameStartTime'])
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameData &&
        other.currentRound == currentRound &&
        other.players == players &&
        other.gwangSellings == gwangSellings &&
        other.playerScores.toString() == playerScores.toString() &&
        other.totalScores.toString() == totalScores.toString();
  }

  @override
  int get hashCode {
    return currentRound.hashCode ^
        players.hashCode ^
        gwangSellings.hashCode ^
        playerScores.hashCode ^
        totalScores.hashCode;
  }

  @override
  String toString() {
    return 'GameData(players: ${players.length}, currentRound: $currentRound, totalScores: $totalScores)';
  }
}