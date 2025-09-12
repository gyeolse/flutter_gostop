class ScoreInput {
  final String winnerId;
  final int winnerScore;
  final Map<String, bool> loserPenalties; // playerId -> penalty flags
  final Map<String, bool> specialSituations; // playerId -> special situations
  final Map<String, bool> continuousFailures; // playerId -> continuous failure flags
  final Map<String, bool> gwangSelling; // playerId -> gwang selling flags (4인 플레이 전용)
  final bool isPresident; // 대통령
  final bool isTripleFailure; // 3연뻑

  const ScoreInput({
    required this.winnerId,
    this.winnerScore = 0,
    this.loserPenalties = const {},
    this.specialSituations = const {},
    this.continuousFailures = const {},
    this.gwangSelling = const {},
    this.isPresident = false,
    this.isTripleFailure = false,
  });

  ScoreInput copyWith({
    String? winnerId,
    int? winnerScore,
    Map<String, bool>? loserPenalties,
    Map<String, bool>? specialSituations,
    Map<String, bool>? continuousFailures,
    Map<String, bool>? gwangSelling,
    bool? isPresident,
    bool? isTripleFailure,
  }) {
    return ScoreInput(
      winnerId: winnerId ?? this.winnerId,
      winnerScore: winnerScore ?? this.winnerScore,
      loserPenalties: loserPenalties ?? this.loserPenalties,
      specialSituations: specialSituations ?? this.specialSituations,
      continuousFailures: continuousFailures ?? this.continuousFailures,
      gwangSelling: gwangSelling ?? this.gwangSelling,
      isPresident: isPresident ?? this.isPresident,
      isTripleFailure: isTripleFailure ?? this.isTripleFailure,
    );
  }
}

enum PenaltyType {
  piBak('피박'),
  gwangBak('광박'),
  goBak('고박'),
  meongTeongGuri('멍텅구리');

  const PenaltyType(this.displayName);
  final String displayName;
}

enum SpecialSituation {
  firstFail('첫 뻑'),
  consecutiveFail('연뻑'),
  ttaDak('따닥'),
  tripleFailure('삼연뻑'),
  president('대통령');

  const SpecialSituation(this.displayName);
  final String displayName;
}