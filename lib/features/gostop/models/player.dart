import 'package:hive/hive.dart';

part 'player.g.dart';

@HiveType(typeId: 3)
class Player extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String avatarPath;

  @HiveField(3)
  final bool isSelected;

  Player({
    required this.id,
    required this.name,
    required this.avatarPath,
    this.isSelected = false,
  });

  // 타짜 캐릭터 기본 이름들
  static const List<String> defaultNames = [
    '판깡장',
    '곽칠용',
    '쟁마담',
    '아구',
    '고광욜',
    '박무섬',
    '구니',
  ];

  // 기본 아바타 이미지들
  static const List<String> defaultAvatars = [
    'lib/assets/images/pangangjang.png',
    'lib/assets/images/kwakchulyeong.png',
    'lib/assets/images/jungmadam.png',
    'lib/assets/images/agui.png',
    'lib/assets/images/gogangryul.png',
    'lib/assets/images/daemori.png',
    'lib/assets/images/goni.png',
  ];

  // 기본 플레이어 생성
  factory Player.create({required int index, String? customName}) {
    final id = 'player_${DateTime.now().millisecondsSinceEpoch}_$index';
    final name = customName ?? defaultNames[index % defaultNames.length];
    final avatarPath = defaultAvatars[index % defaultAvatars.length];

    return Player(id: id, name: name, avatarPath: avatarPath);
  }

  // 복사본 생성
  Player copyWith({
    String? id,
    String? name,
    String? avatarPath,
    bool? isSelected,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  // 선택 상태 토글
  Player toggleSelection() {
    return copyWith(isSelected: !isSelected);
  }

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarPath': avatarPath,
      'isSelected': isSelected,
    };
  }

  // JSON 역직렬화
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatarPath: json['avatarPath'] ?? 'lib/assets/images/kwakchulyeong.png',
      isSelected: json['isSelected'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Player &&
        other.id == id &&
        other.name == name &&
        other.avatarPath == avatarPath &&
        other.isSelected == isSelected;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        avatarPath.hashCode ^
        isSelected.hashCode;
  }

  @override
  String toString() {
    return 'Player(id: $id, name: $name, avatarPath: $avatarPath, isSelected: $isSelected)';
  }
}
