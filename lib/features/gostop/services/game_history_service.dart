import 'package:hive_flutter/hive_flutter.dart';
import '../models/game_result.dart';

class GameHistoryService {
  static const String _boxName = 'game_results';
  static Box<GameResult>? _box;

  static Future<void> initialize() async {
    _box = await Hive.openBox<GameResult>(_boxName);
  }

  static Box<GameResult> get _ensureBox {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Game history box not initialized. Call GameHistoryService.initialize() first.');
    }
    return _box!;
  }

  /// 모든 게임 기록 가져오기 (최신순)
  static List<GameResult> getAllGameResults() {
    final results = _ensureBox.values.toList();
    results.sort((a, b) => b.gameDate.compareTo(a.gameDate)); // 최신순 정렬
    return results;
  }

  /// 게임 결과 저장
  static Future<void> saveGameResult(GameResult gameResult) async {
    await _ensureBox.add(gameResult);
  }

  /// 게임 결과 삭제
  static Future<void> deleteGameResult(int index) async {
    await _ensureBox.deleteAt(index);
  }

  /// 모든 게임 기록 삭제
  static Future<void> clearAllGameResults() async {
    await _ensureBox.clear();
  }

  /// 게임 기록 개수
  static int get gameResultCount => _ensureBox.length;

  /// 박스 변경사항 리스닝
  static Stream<BoxEvent> get watchBox => _ensureBox.watch();

  /// 최근 N개 게임 기록 가져오기
  static List<GameResult> getRecentGameResults(int count) {
    final allResults = getAllGameResults();
    return allResults.take(count).toList();
  }

  /// 특정 플레이어가 참여한 게임 기록 가져오기
  static List<GameResult> getGameResultsByPlayer(String playerName) {
    return getAllGameResults()
        .where((result) => result.players.any((player) => player.playerName == playerName))
        .toList();
  }
}