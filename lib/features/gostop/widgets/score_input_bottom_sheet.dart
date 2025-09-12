import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/app_colors.dart';
import '../models/player.dart';
import '../models/score_input.dart';

class ScoreInputBottomSheet extends StatefulWidget {
  final List<Player> players;
  final Function(ScoreInput) onScoreCalculated;

  const ScoreInputBottomSheet({
    super.key,
    required this.players,
    required this.onScoreCalculated,
  });

  @override
  State<ScoreInputBottomSheet> createState() => _ScoreInputBottomSheetState();
}

class _ScoreInputBottomSheetState extends State<ScoreInputBottomSheet> {
  String? _selectedWinnerId;
  final TextEditingController _scoreController = TextEditingController();
  
  // 패자 페널티
  final Map<String, Set<PenaltyType>> _penalties = {};
  
  // 특수 상황 (패자)
  final Map<String, Set<SpecialSituation>> _specialSituations = {};
  
  // 전체 게임 특수 상황
  bool _isPresident = false;
  bool _isTripleFailure = false;

  @override
  void initState() {
    super.initState();
    // 초기화
    for (final player in widget.players) {
      _penalties[player.id] = <PenaltyType>{};
      _specialSituations[player.id] = <SpecialSituation>{};
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  List<Player> get _losers {
    if (_selectedWinnerId == null) return [];
    return widget.players.where((p) => p.id != _selectedWinnerId).toList();
  }

  void _calculateScore() {
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

    // 패널티를 Map<String, bool> 형태로 변환
    final loserPenalties = <String, bool>{};
    final specialSituations = <String, bool>{};
    final continuousFailures = <String, bool>{};

    for (final player in widget.players) {
      // 패널티 설정
      loserPenalties['${player.id}_piBak'] = _penalties[player.id]?.contains(PenaltyType.piBak) ?? false;
      loserPenalties['${player.id}_gwangBak'] = _penalties[player.id]?.contains(PenaltyType.gwangBak) ?? false;
      loserPenalties['${player.id}_goBak'] = _penalties[player.id]?.contains(PenaltyType.goBak) ?? false;
      
      // 특수 상황 설정
      specialSituations['${player.id}_firstFail'] = _specialSituations[player.id]?.contains(SpecialSituation.firstFail) ?? false;
      specialSituations['${player.id}_consecutiveFail'] = _specialSituations[player.id]?.contains(SpecialSituation.consecutiveFail) ?? false;
      specialSituations['${player.id}_ttaDak'] = _specialSituations[player.id]?.contains(SpecialSituation.ttaDak) ?? false;
    }

    final scoreInput = ScoreInput(
      winnerId: _selectedWinnerId!,
      winnerScore: winnerScore,
      loserPenalties: loserPenalties,
      specialSituations: specialSituations,
      continuousFailures: continuousFailures,
      isPresident: _isPresident,
      isTripleFailure: _isTripleFailure,
    );

    widget.onScoreCalculated(scoreInput);
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
                    Icons.calculate,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '이번 판 점수 입력',
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
                  // 승자 선택
                  _buildWinnerSelection(),
                  
                  const SizedBox(height: 24),
                  
                  // 승자 점수 입력
                  if (_selectedWinnerId != null) ...[
                    _buildWinnerScoreInput(),
                    const SizedBox(height: 24),
                  ],
                  
                  // 패자 페널티
                  if (_losers.isNotEmpty) ...[
                    _buildLoserPenalties(),
                    const SizedBox(height: 24),
                  ],
                  
                  // 특수 상황
                  _buildSpecialSituations(),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // 계산 완료 버튼
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
                child: ElevatedButton(
                  onPressed: _calculateScore,
                  child: const Text(
                    '계산 완료',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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

  Widget _buildWinnerSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '승자 선택',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.players.map((player) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _selectedWinnerId == player.id 
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _selectedWinnerId == player.id 
                  ? AppColors.primary 
                  : Colors.grey.shade200,
              width: _selectedWinnerId == player.id ? 2 : 1,
            ),
          ),
          child: RadioListTile<String>(
            title: Text(
              player.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _selectedWinnerId == player.id 
                    ? AppColors.primary 
                    : AppColors.textPrimary,
              ),
            ),
            value: player.id,
            groupValue: _selectedWinnerId,
            onChanged: (value) {
              setState(() {
                _selectedWinnerId = value;
              });
            },
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        )).toList(),
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: _scoreController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: '점수를 입력하세요',
              suffixText: '점',
              suffixStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              border: InputBorder.none,
            ),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildLoserPenalties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '패자 페널티',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ..._losers.map((player) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade200),
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
                const SizedBox(height: 12),
                
                // 페널티 체크박스
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: PenaltyType.values.map((penalty) => 
                    FilterChip(
                      label: Text(penalty.displayName),
                      selected: _penalties[player.id]?.contains(penalty) ?? false,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _penalties[player.id]?.add(penalty);
                          } else {
                            _penalties[player.id]?.remove(penalty);
                          }
                        });
                      },
                      selectedColor: Colors.red.shade100,
                      checkmarkColor: Colors.red.shade700,
                    ),
                  ).toList(),
                ),
                
                const SizedBox(height: 12),
                
                // 특수 상황 체크박스
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SpecialSituation.values.map((situation) => 
                    FilterChip(
                      label: Text(situation.displayName),
                      selected: _specialSituations[player.id]?.contains(situation) ?? false,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _specialSituations[player.id]?.add(situation);
                          } else {
                            _specialSituations[player.id]?.remove(situation);
                          }
                        });
                      },
                      selectedColor: Colors.orange.shade100,
                      checkmarkColor: Colors.orange.shade700,
                    ),
                  ).toList(),
                ),
              ],
            ),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildSpecialSituations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '특수 상황',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CheckboxListTile(
                  title: const Text(
                    '대통령',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('모든 패자가 추가 페널티'),
                  value: _isPresident,
                  onChanged: (value) {
                    setState(() {
                      _isPresident = value ?? false;
                    });
                  },
                  activeColor: Colors.amber.shade700,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text(
                    '3연뻑',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('연속 3번 실패'),
                  value: _isTripleFailure,
                  onChanged: (value) {
                    setState(() {
                      _isTripleFailure = value ?? false;
                    });
                  },
                  activeColor: Colors.amber.shade700,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}