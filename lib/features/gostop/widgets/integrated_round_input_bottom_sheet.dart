import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/app_colors.dart';
import '../../../core/widgets/modern_dialog.dart';
import '../models/player.dart';
import '../models/score_input.dart';


class IntegratedRoundInputBottomSheet extends StatefulWidget {
  final List<Player> players;
  final Function(ScoreInput, bool, Map<String, int>) onRoundCompleted; // ScoreInput, isGameEnd, gwangSellingCount

  const IntegratedRoundInputBottomSheet({
    super.key,
    required this.players,
    required this.onRoundCompleted,
  });

  @override
  State<IntegratedRoundInputBottomSheet> createState() => _IntegratedRoundInputBottomSheetState();
}

class _IntegratedRoundInputBottomSheetState extends State<IntegratedRoundInputBottomSheet> {
  String? _selectedWinnerId;
  final TextEditingController _scoreController = TextEditingController();
  
  // 광 팔기 정보 (플레이어별 광 판매량)
  final Map<String, int> _gwangSellingCount = {};
  
  // 각 플레이어별 패널티 결과 (복수 선택 가능)
  final Map<String, Set<PenaltyType>> _playerResults = {};
  
  // 특수 상황 (패자)
  final Map<String, Set<SpecialSituation>> _specialSituations = {};
  
  

  @override
  void initState() {
    super.initState();
    // 초기화
    for (final player in widget.players) {
      // _gwangSellingCount는 빈 맵으로 시작 (아무도 선택되지 않은 상태)
      _playerResults[player.id] = <PenaltyType>{};
      _specialSituations[player.id] = <SpecialSituation>{};
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  bool get _is4PlayerGame => widget.players.length == 4;

  void _showAutoWinDialog(Player player, SpecialSituation situation) {
    final situationName = situation == SpecialSituation.tripleFailure ? '삼연뻑' : '대통령';
    
    ModernConfirmDialog.show(
      context,
      title: '자동 승리',
      content: '${player.name}님이 $situationName을 달성했습니다.\n${player.name}님을 승자로 처리하고 다음 라운드로 넘어가겠습니까?',
      confirmText: '승자 처리',
      cancelText: '수동 입력',
      icon: Icons.emoji_events,
      iconColor: AppColors.goStopYellow,
      confirmColor: AppColors.primary,
      onConfirm: () {
        _processAutoWin(player, situation);
      },
      onCancel: () {
        // 수동 입력을 위해 특수 상황만 추가
        setState(() {
          _specialSituations[player.id]?.add(situation);
        });
      },
    );
  }

  void _processAutoWin(Player player, SpecialSituation situation) {
    // 기본 점수 설정 (삼연뻑: 7점, 대통령: 10점)
    final autoScore = situation == SpecialSituation.tripleFailure ? 7 : 10;
    
    setState(() {
      // 승자 설정
      _selectedWinnerId = player.id;
      _scoreController.text = autoScore.toString();
      
      // 특수 상황 추가
      _specialSituations[player.id]?.add(situation);
      
      // 삼연뻑/대통령일 때는 광팔이가 있더라도 게임은 자동 완료되지만 광팔이 설정은 유지
    });

    // 자동으로 라운드 완료
    _completeRound(false);
  }

  void _completeRound(bool isGameEnd) {
    if (_selectedWinnerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('승자를 선택해주세요')),
      );
      return;
    }

    final winnerScore = int.tryParse(_scoreController.text) ?? 0;
    if (winnerScore <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('승자 점수를 입력해주세요')),
      );
      return;
    }

    // 데이터 변환
    final loserPenalties = <String, bool>{};
    final specialSituations = <String, bool>{};
    final continuousFailures = <String, bool>{};
    final gwangSelling = <String, bool>{};

    for (final player in widget.players) {
      // 광 팔기 설정 (쉬어가기 포함)
      gwangSelling[player.id] = _gwangSellingCount.containsKey(player.id);
      
      // 패자 결과에 따른 패널티 설정 (복수 선택 가능)
      if (player.id != _selectedWinnerId) {
        final penalties = _playerResults[player.id] ?? <PenaltyType>{};
        for (final penalty in penalties) {
          switch (penalty) {
            case PenaltyType.piBak:
              loserPenalties['${player.id}_piBak'] = true;
            case PenaltyType.gwangBak:
              loserPenalties['${player.id}_gwangBak'] = true;
            case PenaltyType.goBak:
              loserPenalties['${player.id}_goBak'] = true;
            case PenaltyType.meongTeongGuri:
              loserPenalties['${player.id}_meongTeongGuri'] = true;
          }
        }
      }
      
      // 특수 상황 설정 (첫뻑/연뻑/따닥/삼연뻑/대통령)
      final playerSpecials = _specialSituations[player.id] ?? <SpecialSituation>{};
      
      specialSituations['${player.id}_firstFail'] = playerSpecials.contains(SpecialSituation.firstFail);
      specialSituations['${player.id}_consecutiveFail'] = playerSpecials.contains(SpecialSituation.consecutiveFail);
      specialSituations['${player.id}_ttaDak'] = playerSpecials.contains(SpecialSituation.ttaDak);
      specialSituations['${player.id}_tripleFailure'] = playerSpecials.contains(SpecialSituation.tripleFailure);
      specialSituations['${player.id}_president'] = playerSpecials.contains(SpecialSituation.president);
    }

    final scoreInput = ScoreInput(
      winnerId: _selectedWinnerId!,
      winnerScore: winnerScore,
      loserPenalties: loserPenalties,
      specialSituations: specialSituations,
      continuousFailures: continuousFailures,
      gwangSelling: gwangSelling,
      isPresident: false,
      isTripleFailure: false,
    );

    print('=== UI에서 전달하는 _gwangSellingCount ===');
    print('_gwangSellingCount: $_gwangSellingCount');
    
    widget.onRoundCompleted(scoreInput, isGameEnd, _gwangSellingCount);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 헤더
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.sports_esports,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '이번 판 기록하기',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 광 팔기 섹션 (4인 플레이 전용)
                  if (_is4PlayerGame) ...[
                    _buildGwangSellingSection(),
                    const SizedBox(height: 32),
                  ],
                  
                  // 점수 기록 섹션
                  _buildScoreRecordingSection(),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // 하단 버튼들
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
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () => _completeRound(false),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '다음 판 진행',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGwangSellingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.star,
                color: Colors.amber.shade700,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '광 팔기 & 쉬어갈 사람',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '광을 판 플레이어와 판매량을 설정하세요 (0장도 설정 가능)',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: widget.players.length,
          itemBuilder: (context, index) {
            final player = widget.players[index];
            final gwangCount = _gwangSellingCount[player.id] ?? 0;
            final isSelected = _gwangSellingCount.containsKey(player.id);
            
            return Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.amber.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Colors.amber.shade300 : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      player.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.amber.shade800 : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isSelected) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                final currentCount = _gwangSellingCount[player.id] ?? 0;
                                if (currentCount > 0) {
                                  _gwangSellingCount[player.id] = currentCount - 1;
                                } else {
                                  _gwangSellingCount.remove(player.id);
                                }
                              });
                            },
                            icon: Icon(
                              Icons.remove_circle,
                              color: Colors.amber.shade700,
                              size: 28,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$gwangCount장',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                final currentCount = _gwangSellingCount[player.id] ?? 0;
                                if (currentCount < 7) {
                                  _gwangSellingCount[player.id] = currentCount + 1;
                                }
                              });
                            },
                            icon: Icon(
                              Icons.add_circle,
                              color: Colors.amber.shade700,
                              size: 28,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ] else ...[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _gwangSellingCount[player.id] = 0;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '쉬어가기',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildScoreRecordingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.calculate,
                color: AppColors.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '점수 기록',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 승자 선택 (간결화)
        _buildSimpleWinnerSelection(),
        
        const SizedBox(height: 16),
        
        // 승자 점수 입력
        if (_selectedWinnerId != null) ...[
          _buildWinnerScoreInput(),
          const SizedBox(height: 16),
        ],
        
        // 플레이어별 결과
        _buildPlayerResults(),
      ],
    );
  }


  Widget _buildWinnerScoreInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '승자 점수',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: TextFormField(
            controller: _scoreController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: '점수를 입력하세요',
              prefixIcon: Icon(
                Icons.emoji_events,
                color: Colors.green.shade600,
              ),
              suffixText: '점',
              suffixStyle: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: InputBorder.none,
            ),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildSimpleWinnerSelection() {
    // 광을 판 사람들(쉬어가는 사람들)은 승자가 될 수 없음
    final eligibleWinners = widget.players.where((player) => 
        !_gwangSellingCount.containsKey(player.id)).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '승자',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '※ 광을 판 플레이어(쉬어가는 사람)는 승자가 될 수 없습니다',
          style: TextStyle(
            fontSize: 12,
            color: Colors.red.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: eligibleWinners.map((player) => 
            FilterChip(
              label: Text(player.name),
              selected: _selectedWinnerId == player.id,
              onSelected: (selected) {
                setState(() {
                  _selectedWinnerId = selected ? player.id : null;
                });
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
            ),
          ).toList(),
        ),
        if (eligibleWinners.isEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              '모든 플레이어가 쉬어가서 승자를 선택할 수 없습니다.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlayerResults() {
    // 광을 판 사람들(쉬어가는 사람들)은 패자 패널티 선택에서 제외
    final eligibleLosers = widget.players.where((player) => 
        player.id != _selectedWinnerId && !_gwangSellingCount.containsKey(player.id)).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '플레이어별 결과',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '※ 광을 판 플레이어(쉬어가는 사람)는 패널티 선택에서 제외됩니다',
          style: TextStyle(
            fontSize: 12,
            color: Colors.orange.shade600,
          ),
        ),
        const SizedBox(height: 8),
        ...eligibleLosers.map((player) =>
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 패널티 타입 (피박, 광박, 고박, 멍텅구리)
                  const Text(
                    '패널티',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: PenaltyType.values.map((penalty) =>
                      FilterChip(
                        label: Text(penalty.displayName),
                        selected: _playerResults[player.id]?.contains(penalty) ?? false,
                        onSelected: (selected) {
                          setState(() {
                            final penalties = _playerResults[player.id] ?? <PenaltyType>{};
                            if (selected) {
                              penalties.add(penalty);
                            } else {
                              penalties.remove(penalty);
                            }
                            _playerResults[player.id] = penalties;
                          });
                        },
                        selectedColor: Colors.red.shade100,
                        checkmarkColor: Colors.red.shade700,
                      ),
                    ).toList(),
                  ),
                  const SizedBox(height: 12),
                  // 개별 특수 상황 (첫뻑, 연뻑, 따닥)
                  const Text(
                    '개별 특수 상황',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: SpecialSituation.values.map((situation) =>
                      FilterChip(
                        label: Text(situation.displayName),
                        selected: _specialSituations[player.id]?.contains(situation) ?? false,
                        onSelected: (selected) {
                          if (selected && (situation == SpecialSituation.tripleFailure || situation == SpecialSituation.president)) {
                            _showAutoWinDialog(player, situation);
                          } else {
                            setState(() {
                              if (selected) {
                                // 기존 선택 모두 해제하고 새로운 특수 상황만 선택
                                _specialSituations[player.id]?.clear();
                                _specialSituations[player.id]?.add(situation);
                              } else {
                                _specialSituations[player.id]?.remove(situation);
                              }
                            });
                          }
                        },
                        selectedColor: Colors.orange.shade100,
                        checkmarkColor: Colors.orange.shade700,
                      ),
                    ).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
        // 광을 판 사람들에 대한 안내
        if (widget.players.where((p) => p.id != _selectedWinnerId && _gwangSellingCount.containsKey(p.id)).isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '쉬어가는 사람들 (승패 무관)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.players.where((p) => p.id != _selectedWinnerId && _gwangSellingCount.containsKey(p.id))
                      .map((p) => '${p.name} (${_gwangSellingCount[p.id] ?? 0}장)')
                      .join(', '),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}