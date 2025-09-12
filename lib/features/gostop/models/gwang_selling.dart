class GwangSelling {
  final String playerId;
  final String playerName;
  final bool isSelling;
  final int gwangCount;

  const GwangSelling({
    required this.playerId,
    required this.playerName,
    this.isSelling = false,
    this.gwangCount = 0,
  });

  GwangSelling copyWith({
    String? playerId,
    String? playerName,
    bool? isSelling,
    int? gwangCount,
  }) {
    return GwangSelling(
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      isSelling: isSelling ?? this.isSelling,
      gwangCount: gwangCount ?? this.gwangCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'isSelling': isSelling,
      'gwangCount': gwangCount,
    };
  }

  factory GwangSelling.fromJson(Map<String, dynamic> json) {
    return GwangSelling(
      playerId: json['playerId'] ?? '',
      playerName: json['playerName'] ?? '',
      isSelling: json['isSelling'] ?? false,
      gwangCount: json['gwangCount'] ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GwangSelling &&
        other.playerId == playerId &&
        other.playerName == playerName &&
        other.isSelling == isSelling &&
        other.gwangCount == gwangCount;
  }

  @override
  int get hashCode {
    return playerId.hashCode ^
        playerName.hashCode ^
        isSelling.hashCode ^
        gwangCount.hashCode;
  }

  @override
  String toString() {
    return 'GwangSelling(playerId: $playerId, playerName: $playerName, isSelling: $isSelling, gwangCount: $gwangCount)';
  }
}