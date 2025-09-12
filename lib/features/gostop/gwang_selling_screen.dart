import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/snackbar_service.dart';
import '../../core/app_colors.dart';
import 'models/player.dart';
import 'models/gwang_selling.dart';

// 광 팔기 상태 관리
final gwangSellingProvider = StateNotifierProvider<GwangSellingNotifier, List<GwangSelling>>((ref) {
  return GwangSellingNotifier();
});

class GwangSellingNotifier extends StateNotifier<List<GwangSelling>> {
  GwangSellingNotifier() : super([]);

  void initializePlayers(List<Player> players) {
    state = players.map((player) => GwangSelling(
      playerId: player.id,
      playerName: player.name,
      isSelling: false,
      gwangCount: 0,
    )).toList();
  }

  void toggleSelling(String playerId, bool isSelling) {
    state = state.map((gwang) {
      if (gwang.playerId == playerId) {
        return gwang.copyWith(
          isSelling: isSelling,
          gwangCount: isSelling ? gwang.gwangCount : 0,
        );
      }
      return gwang;
    }).toList();
  }

  void updateGwangCount(String playerId, int count) {
    state = state.map((gwang) {
      if (gwang.playerId == playerId) {
        return gwang.copyWith(gwangCount: count);
      }
      return gwang;
    }).toList();
  }

  List<GwangSelling> get sellingPlayers {
    return state.where((gwang) => gwang.isSelling && gwang.gwangCount > 0).toList();
  }
}

class GwangSellingScreen extends ConsumerStatefulWidget {
  final List<Player> players;

  const GwangSellingScreen({
    super.key,
    required this.players,
  });

  @override
  ConsumerState<GwangSellingScreen> createState() => _GwangSellingScreenState();
}

class _GwangSellingScreenState extends ConsumerState<GwangSellingScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // 플레이어별 컨트롤러 초기화
    for (final player in widget.players) {
      _controllers[player.id] = TextEditingController(text: '0');
    }
    // Provider 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gwangSellingProvider.notifier).initializePlayers(widget.players);
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onGwangCountChanged(String playerId, String value) {
    final count = int.tryParse(value) ?? 0;
    final clampedCount = count.clamp(0, 7);
    
    ref.read(gwangSellingProvider.notifier).updateGwangCount(playerId, clampedCount);
    
    // 컨트롤러 값 업데이트 (범위 제한)
    if (count != clampedCount) {
      _controllers[playerId]?.value = TextEditingValue(
        text: clampedCount.toString(),
        selection: TextSelection.collapsed(offset: clampedCount.toString().length),
      );
    }
  }

  void _proceedToGame() {
    final sellingPlayers = ref.read(gwangSellingProvider.notifier).sellingPlayers;
    
    if (sellingPlayers.isNotEmpty) {
      final names = sellingPlayers.map((g) => '${g.playerName}(${g.gwangCount}장)').join(', ');
      ref.read(snackbarServiceProvider).showInfo('$names 광 팔기가 설정되었습니다');
    }

    // 선택된 플레이어 정보와 광 팔기 정보를 게임 화면으로 전달
    context.go('/game-main', extra: {
      'players': widget.players,
      'gwangSelling': ref.read(gwangSellingProvider),
    });
  }

  @override
  Widget build(BuildContext context) {
    final gwangSellings = ref.watch(gwangSellingProvider);
    final sellingCount = gwangSellings.where((g) => g.isSelling).length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.star,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '광 팔기 설정',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '4명 게임',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 안내 섹션
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.amber.shade50,
                  Colors.orange.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.amber.shade200,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber, Colors.orange],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      '광 팔기 설정',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '4명 게임에서만 광 팔기가 가능합니다.\n광을 팔 플레이어를 선택하고 장수를 입력해주세요.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                if (sellingCount > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade600,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '현재 ${sellingCount}명이 광 팔기를 선택했습니다',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 플레이어 목록
          Expanded(
            child: gwangSellings.isEmpty 
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: gwangSellings.length,
                    itemBuilder: (context, index) {
                      final gwang = gwangSellings[index];
                      return _buildPlayerCard(gwang);
                    },
                  ),
          ),

          // 하단 확인 버튼
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _proceedToGame,
                  icon: const Icon(Icons.play_arrow, size: 24),
                  label: const Text(
                    '게임 시작하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(GwangSelling gwang) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gwang.isSelling ? AppColors.primary : Colors.grey.shade200,
          width: gwang.isSelling ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: gwang.isSelling 
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: gwang.isSelling ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // 플레이어 아바타
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: gwang.isSelling
                        ? LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          )
                        : LinearGradient(
                            colors: [Colors.grey.shade100, Colors.grey.shade200],
                          ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: gwang.isSelling
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      gwang.playerName[0],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: gwang.isSelling ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // 플레이어 이름과 체크박스
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gwang.playerName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: gwang.isSelling ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Transform.scale(
                            scale: 1.2,
                            child: Checkbox(
                              value: gwang.isSelling,
                              onChanged: (value) {
                                ref.read(gwangSellingProvider.notifier)
                                    .toggleSelling(gwang.playerId, value ?? false);
                              },
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '광 팔기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 광 장수 입력
            if (gwang.isSelling) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.05),
                      AppColors.secondary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star_border,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '광 장수',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 80,
                      child: TextFormField(
                        controller: _controllers[gwang.playerId],
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                        ],
                        onChanged: (value) => _onGwangCountChanged(gwang.playerId, value),
                        decoration: InputDecoration(
                          suffixText: '장',
                          suffixStyle: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '※ 0~7장까지 입력 가능합니다',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}