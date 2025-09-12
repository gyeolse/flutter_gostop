import 'package:hive_flutter/hive_flutter.dart';
import '../models/player.dart';

class PlayersService {
  static const String _boxName = 'players';
  static Box<Player>? _box;

  static Future<void> initialize() async {
    _box = await Hive.openBox<Player>(_boxName);
  }

  static Box<Player> get _ensureBox {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Players box not initialized. Call PlayersService.initialize() first.');
    }
    return _box!;
  }

  /// 모든 플레이어 가져오기
  static List<Player> getAllPlayers() {
    return _ensureBox.values.toList();
  }

  /// 플레이어 추가
  static Future<void> addPlayer(Player player) async {
    await _ensureBox.put(player.id, player);
  }

  /// 플레이어 업데이트
  static Future<void> updatePlayer(Player player) async {
    await _ensureBox.put(player.id, player);
  }

  /// 플레이어 삭제
  static Future<void> deletePlayer(String playerId) async {
    await _ensureBox.delete(playerId);
  }

  /// 모든 플레이어 삭제
  static Future<void> clearAllPlayers() async {
    await _ensureBox.clear();
  }

  /// 플레이어 존재 확인
  static bool containsPlayer(String playerId) {
    return _ensureBox.containsKey(playerId);
  }

  /// 특정 플레이어 가져오기
  static Player? getPlayer(String playerId) {
    return _ensureBox.get(playerId);
  }

  /// 플레이어 개수
  static int get playerCount => _ensureBox.length;

  /// 박스 변경사항 리스닝
  static Stream<BoxEvent> get watchBox => _ensureBox.watch();
}