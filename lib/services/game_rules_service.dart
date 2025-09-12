import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/gostop/models/game_rules.dart';
import 'local_storage_service.dart';

final gameRulesServiceProvider = Provider<GameRulesService>((ref) {
  final localStorage = ref.read(localStorageServiceProvider);
  return GameRulesService(localStorage);
});

final gameRulesProvider = StateNotifierProvider<GameRulesNotifier, GameRules>((ref) {
  final service = ref.read(gameRulesServiceProvider);
  return GameRulesNotifier(service);
});

class GameRulesService {
  static const String _pointPriceKey = 'game_rules_point_price';
  static const String _ppeoPriceKey = 'game_rules_ppeo_price';
  static const String _ddadakPriceKey = 'game_rules_ddadak_price';
  static const String _gwangSellPriceKey = 'game_rules_gwang_sell_price';
  static const String _presidentPriceKey = 'game_rules_president_price';

  final LocalStorageService _localStorage;

  GameRulesService(this._localStorage);

  Future<GameRules> loadGameRules() async {
    try {
      final pointPrice = await _localStorage.getInt(_pointPriceKey) ?? GameRules.defaultRules.pointPrice;
      final ppeoPrice = await _localStorage.getInt(_ppeoPriceKey) ?? GameRules.defaultRules.ppeoPrice;
      final ddadakPrice = await _localStorage.getInt(_ddadakPriceKey) ?? GameRules.defaultRules.ddadakPrice;
      final gwangSellPrice = await _localStorage.getInt(_gwangSellPriceKey) ?? GameRules.defaultRules.gwangSellPrice;
      final presidentPrice = await _localStorage.getInt(_presidentPriceKey) ?? GameRules.defaultRules.presidentPrice;

      return GameRules(
        pointPrice: pointPrice,
        ppeoPrice: ppeoPrice,
        ddadakPrice: ddadakPrice,
        gwangSellPrice: gwangSellPrice,
        presidentPrice: presidentPrice,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error loading game rules: $e');
      }
      return GameRules.defaultRules;
    }
  }

  Future<void> saveGameRules(GameRules rules) async {
    try {
      await Future.wait([
        _localStorage.setInt(_pointPriceKey, rules.pointPrice),
        _localStorage.setInt(_ppeoPriceKey, rules.ppeoPrice),
        _localStorage.setInt(_ddadakPriceKey, rules.ddadakPrice),
        _localStorage.setInt(_gwangSellPriceKey, rules.gwangSellPrice),
        _localStorage.setInt(_presidentPriceKey, rules.presidentPrice),
      ]);

      if (kDebugMode) {
        print('Game rules saved: $rules');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving game rules: $e');
      }
      throw Exception('게임 규칙을 저장하는데 실패했습니다.');
    }
  }

  Future<void> resetToDefault() async {
    await saveGameRules(GameRules.defaultRules);
  }

  Future<void> clearGameRules() async {
    try {
      await Future.wait([
        _localStorage.remove(_pointPriceKey),
        _localStorage.remove(_ppeoPriceKey),
        _localStorage.remove(_ddadakPriceKey),
        _localStorage.remove(_gwangSellPriceKey),
        _localStorage.remove(_presidentPriceKey),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing game rules: $e');
      }
    }
  }
}

class GameRulesNotifier extends StateNotifier<GameRules> {
  final GameRulesService _service;

  GameRulesNotifier(this._service) : super(GameRules.defaultRules) {
    loadRules();
  }

  Future<void> loadRules() async {
    try {
      final rules = await _service.loadGameRules();
      state = rules;
    } catch (e) {
      if (kDebugMode) {
        print('Error in GameRulesNotifier.loadRules: $e');
      }
    }
  }

  Future<void> updateRules(GameRules rules) async {
    try {
      await _service.saveGameRules(rules);
      state = rules;
    } catch (e) {
      if (kDebugMode) {
        print('Error in GameRulesNotifier.updateRules: $e');
      }
      rethrow;
    }
  }

  Future<void> updatePointPrice(int price) async {
    final newRules = state.copyWith(pointPrice: price);
    await updateRules(newRules);
  }

  Future<void> updatePpeoPrice(int price) async {
    final newRules = state.copyWith(ppeoPrice: price);
    await updateRules(newRules);
  }

  Future<void> updateDdadakPrice(int price) async {
    final newRules = state.copyWith(ddadakPrice: price);
    await updateRules(newRules);
  }

  Future<void> updateGwangSellPrice(int price) async {
    final newRules = state.copyWith(gwangSellPrice: price);
    await updateRules(newRules);
  }

  Future<void> updatePresidentPrice(int price) async {
    final newRules = state.copyWith(presidentPrice: price);
    await updateRules(newRules);
  }

  Future<void> resetToDefault() async {
    await updateRules(GameRules.defaultRules);
  }
}