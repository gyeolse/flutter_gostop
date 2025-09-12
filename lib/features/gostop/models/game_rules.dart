class GameRules {
  final int pointPrice;     // 점당 금액 (원)
  final int ppeoPrice;      // 뻑 (원)
  final int ddadakPrice;    // 따닥 (원)
  final int gwangSellPrice; // 광 팔기 (원)
  final int presidentPrice; // 대통령 (원)

  const GameRules({
    required this.pointPrice,
    required this.ppeoPrice,
    required this.ddadakPrice,
    required this.gwangSellPrice,
    required this.presidentPrice,
  });

  // 기본값
  static const GameRules defaultRules = GameRules(
    pointPrice: 100,
    ppeoPrice: 1000,
    ddadakPrice: 1000,
    gwangSellPrice: 1000,
    presidentPrice: 1000,
  );

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'pointPrice': pointPrice,
      'ppeoPrice': ppeoPrice,
      'ddadakPrice': ddadakPrice,
      'gwangSellPrice': gwangSellPrice,
      'presidentPrice': presidentPrice,
    };
  }

  // JSON 역직렬화
  factory GameRules.fromJson(Map<String, dynamic> json) {
    return GameRules(
      pointPrice: json['pointPrice'] ?? defaultRules.pointPrice,
      ppeoPrice: json['ppeoPrice'] ?? defaultRules.ppeoPrice,
      ddadakPrice: json['ddadakPrice'] ?? defaultRules.ddadakPrice,
      gwangSellPrice: json['gwangSellPrice'] ?? defaultRules.gwangSellPrice,
      presidentPrice: json['presidentPrice'] ?? defaultRules.presidentPrice,
    );
  }

  // SharedPreferences용 Map
  Map<String, int> toPrefsMap() {
    return {
      'pointPrice': pointPrice,
      'ppeoPrice': ppeoPrice,
      'ddadakPrice': ddadakPrice,
      'gwangSellPrice': gwangSellPrice,
      'presidentPrice': presidentPrice,
    };
  }

  // SharedPreferences에서 생성
  factory GameRules.fromPrefsMap(Map<String, int> map) {
    return GameRules(
      pointPrice: map['pointPrice'] ?? defaultRules.pointPrice,
      ppeoPrice: map['ppeoPrice'] ?? defaultRules.ppeoPrice,
      ddadakPrice: map['ddadakPrice'] ?? defaultRules.ddadakPrice,
      gwangSellPrice: map['gwangSellPrice'] ?? defaultRules.gwangSellPrice,
      presidentPrice: map['presidentPrice'] ?? defaultRules.presidentPrice,
    );
  }

  // 복사본 생성
  GameRules copyWith({
    int? pointPrice,
    int? ppeoPrice,
    int? ddadakPrice,
    int? gwangSellPrice,
    int? presidentPrice,
  }) {
    return GameRules(
      pointPrice: pointPrice ?? this.pointPrice,
      ppeoPrice: ppeoPrice ?? this.ppeoPrice,
      ddadakPrice: ddadakPrice ?? this.ddadakPrice,
      gwangSellPrice: gwangSellPrice ?? this.gwangSellPrice,
      presidentPrice: presidentPrice ?? this.presidentPrice,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameRules &&
        other.pointPrice == pointPrice &&
        other.ppeoPrice == ppeoPrice &&
        other.ddadakPrice == ddadakPrice &&
        other.gwangSellPrice == gwangSellPrice &&
        other.presidentPrice == presidentPrice;
  }

  @override
  int get hashCode {
    return pointPrice.hashCode ^
        ppeoPrice.hashCode ^
        ddadakPrice.hashCode ^
        gwangSellPrice.hashCode ^
        presidentPrice.hashCode;
  }

  @override
  String toString() {
    return 'GameRules(pointPrice: $pointPrice, ppeoPrice: $ppeoPrice, ddadakPrice: $ddadakPrice, gwangSellPrice: $gwangSellPrice, presidentPrice: $presidentPrice)';
  }
}