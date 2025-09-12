import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/snackbar_service.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/modern_dialog.dart';
import '../../core/widgets/modern_input_dialog.dart';
import 'models/player.dart';
import 'widgets/player_card.dart';
import 'services/players_service.dart';

// 플레이어 상태 관리
final playersProvider = StateNotifierProvider<PlayersNotifier, List<Player>>((ref) {
  return PlayersNotifier();
});

class PlayersNotifier extends StateNotifier<List<Player>> {
  PlayersNotifier() : super([]) {
    _loadPlayers();
  }

  // 저장된 플레이어들 로드
  void _loadPlayers() {
    final players = PlayersService.getAllPlayers();
    state = players;
  }

  Future<void> addPlayer(String name) async {
    if (state.length >= 10) return;
    
    final player = Player.create(
      index: state.length,
      customName: name.trim().isNotEmpty ? name.trim() : null,
    );
    
    await PlayersService.addPlayer(player);
    state = [...state, player];
  }

  Future<void> removePlayer(String playerId) async {
    await PlayersService.deletePlayer(playerId);
    state = state.where((player) => player.id != playerId).toList();
  }

  Future<void> togglePlayerSelection(String playerId) async {
    final updatedPlayers = state.map((player) {
      if (player.id == playerId) {
        final updatedPlayer = player.toggleSelection();
        PlayersService.updatePlayer(updatedPlayer);
        return updatedPlayer;
      }
      return player;
    }).toList();
    
    state = updatedPlayers;
  }

  Future<void> editPlayerName(String playerId, String newName) async {
    if (newName.trim().isEmpty) return;
    
    final updatedPlayers = state.map((player) {
      if (player.id == playerId) {
        final updatedPlayer = player.copyWith(name: newName.trim());
        PlayersService.updatePlayer(updatedPlayer);
        return updatedPlayer;
      }
      return player;
    }).toList();
    
    state = updatedPlayers;
  }

  List<Player> get selectedPlayers {
    return state.where((player) => player.isSelected).toList();
  }

  Future<void> clearAll() async {
    await PlayersService.clearAllPlayers();
    state = [];
  }
}

class PlayerSetupScreen extends ConsumerStatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  ConsumerState<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends ConsumerState<PlayerSetupScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      ref.read(playersProvider.notifier).addPlayer(name);
      _nameController.clear();
      
      ref.read(snackbarServiceProvider).showSuccess(
        name.isNotEmpty ? '$name님이 추가되었습니다' : '플레이어가 추가되었습니다'
      );
    }
  }

  void _editPlayer(Player player) {
    ModernInputDialog.show(
      context,
      title: '플레이어 이름 수정',
      labelText: '새 이름',
      initialValue: player.name,
      confirmText: '저장',
      cancelText: '취소',
      icon: Icons.edit,
      iconColor: AppColors.primary,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '이름을 입력해주세요';
        }
        return null;
      },
      onConfirm: (newName) {
        ref.read(playersProvider.notifier).editPlayerName(player.id, newName);
      },
    );
  }

  void _deletePlayer(Player player) {
    ModernConfirmDialog.show(
      context,
      title: '플레이어 삭제',
      content: '${player.name}님을 삭제하시겠습니까?',
      confirmText: '삭제',
      cancelText: '취소',
      icon: Icons.person_remove,
      iconColor: AppColors.error,
      confirmColor: AppColors.error,
      onConfirm: () {
        ref.read(playersProvider.notifier).removePlayer(player.id);
        ref.read(snackbarServiceProvider).showInfo('${player.name}님이 삭제되었습니다');
      },
    );
  }

  void _startGame() {
    final selectedPlayers = ref.read(playersProvider.notifier).selectedPlayers;
    
    if (selectedPlayers.length < 2 || selectedPlayers.length > 4) {
      ref.read(snackbarServiceProvider).showWarning('플레이어는 2~4명만 선택 가능합니다.');
      return;
    }

    // 모든 플레이어 수에 대해 바로 게임 화면으로 이동
    context.go('/game-main', extra: {
      'players': selectedPlayers,
      'gwangSelling': null,
    });
  }

  String? _validatePlayerName(String? value) {
    final players = ref.read(playersProvider);
    
    if (value != null && value.trim().isNotEmpty) {
      final trimmedValue = value.trim();
      final isDuplicate = players.any((player) => player.name == trimmedValue);
      if (isDuplicate) {
        return '이미 존재하는 이름입니다';
      }
      if (trimmedValue.length > 10) {
        return '이름은 10자 이하로 입력해주세요';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playersProvider);
    final selectedCount = players.where((p) => p.isSelected).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('플레이어 설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (players.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                ref.read(playersProvider.notifier).clearAll();
                ref.read(snackbarServiceProvider).showInfo('모든 플레이어가 삭제되었습니다');
              },
              icon: const Icon(Icons.clear_all, size: 20),
              label: const Text('전체 삭제'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // 플레이어 추가 섹션
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.blue.shade50.withValues(alpha: 0.3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
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
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.person_add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      '새 플레이어 추가',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _nameController,
                            validator: _validatePlayerName,
                            decoration: InputDecoration(
                              hintText: '플레이어 이름 (비워두면 자동 설정)',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 15,
                              ),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _addPlayer(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: players.length >= 10 
                                  ? Colors.grey.withValues(alpha: 0.2)
                                  : AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: players.length >= 10 ? null : _addPlayer,
                          icon: const Icon(Icons.add, size: 22),
                          label: const Text(
                            '추가',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade600,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '최대 10명까지 추가 가능 (현재: ${players.length}/10)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 플레이어 목록
          Expanded(
            child: players.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '아직 플레이어가 없습니다',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '위에서 플레이어를 추가해주세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  '플레이어 목록',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selectedCount >= 2 && selectedCount <= 4 
                                        ? AppColors.success.withValues(alpha: 0.1)
                                        : AppColors.warning.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: selectedCount >= 2 && selectedCount <= 4 
                                          ? AppColors.success 
                                          : AppColors.warning,
                                    ),
                                  ),
                                  child: Text(
                                    '선택됨: $selectedCount/4',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: selectedCount >= 2 && selectedCount <= 4 
                                          ? AppColors.success 
                                          : AppColors.warning,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '카드를 탭하여 게임에 참여할 플레이어를 선택하세요',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: players.length,
                          itemBuilder: (context, index) {
                            final player = players[index];
                            return PlayerCard(
                              player: player,
                              onTap: () {
                                ref.read(playersProvider.notifier)
                                    .togglePlayerSelection(player.id);
                              },
                              onEdit: () => _editPlayer(player),
                              onDelete: () => _deletePlayer(player),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),

          // 하단 게임 시작 버튼
          if (players.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: selectedCount >= 2 && selectedCount <= 4 
                        ? _startGame 
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(selectedCount >= 2 && selectedCount <= 4 
                        ? '게임 시작 ($selectedCount명)'
                        : '플레이어를 2~4명 선택하세요'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
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
}

