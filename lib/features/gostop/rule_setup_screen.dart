import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/game_rules_service.dart';
import '../../services/snackbar_service.dart';
import '../../core/app_colors.dart';
import 'models/game_rules.dart';

class RuleSetupScreen extends ConsumerStatefulWidget {
  const RuleSetupScreen({super.key});

  @override
  ConsumerState<RuleSetupScreen> createState() => _RuleSetupScreenState();
}

class _RuleSetupScreenState extends ConsumerState<RuleSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Text Controllers
  late final TextEditingController _pointPriceController;
  late final TextEditingController _ppeoPriceController;
  late final TextEditingController _ddadakPriceController;
  late final TextEditingController _gwangSellPriceController;
  late final TextEditingController _presidentPriceController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadInitialValues();
  }

  void _initControllers() {
    _pointPriceController = TextEditingController();
    _ppeoPriceController = TextEditingController();
    _ddadakPriceController = TextEditingController();
    _gwangSellPriceController = TextEditingController();
    _presidentPriceController = TextEditingController();
  }

  void _loadInitialValues() {
    final currentRules = ref.read(gameRulesProvider);
    _pointPriceController.text = currentRules.pointPrice.toString();
    _ppeoPriceController.text = currentRules.ppeoPrice.toString();
    _ddadakPriceController.text = currentRules.ddadakPrice.toString();
    _gwangSellPriceController.text = currentRules.gwangSellPrice.toString();
    _presidentPriceController.text = currentRules.presidentPrice.toString();
  }

  @override
  void dispose() {
    _pointPriceController.dispose();
    _ppeoPriceController.dispose();
    _ddadakPriceController.dispose();
    _gwangSellPriceController.dispose();
    _presidentPriceController.dispose();
    super.dispose();
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return '금액을 입력해주세요';
    }
    final price = int.tryParse(value);
    if (price == null) {
      return '올바른 숫자를 입력해주세요';
    }
    if (price < 0) {
      return '0 이상의 금액을 입력해주세요';
    }
    if (price > 1000000) {
      return '100만원 이하로 입력해주세요';
    }
    return null;
  }

  Future<void> _saveRules() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final rules = GameRules(
        pointPrice: int.parse(_pointPriceController.text),
        ppeoPrice: int.parse(_ppeoPriceController.text),
        ddadakPrice: int.parse(_ddadakPriceController.text),
        gwangSellPrice: int.parse(_gwangSellPriceController.text),
        presidentPrice: int.parse(_presidentPriceController.text),
      );

      await ref.read(gameRulesProvider.notifier).updateRules(rules);
      
      if (mounted) {
        ref.read(snackbarServiceProvider).showSuccess('게임 규칙이 저장되었습니다');
        // 플레이어 설정 화면으로 이동 (현재는 게임 설정 화면으로)
        context.push('/player-setup');
      }
    } catch (e) {
      if (mounted) {
        ref.read(snackbarServiceProvider).showError('저장 중 오류가 발생했습니다');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetToDefault() async {
    try {
      await ref.read(gameRulesProvider.notifier).resetToDefault();
      _loadInitialValues();
      
      if (mounted) {
        ref.read(snackbarServiceProvider).showInfo('기본값으로 재설정되었습니다');
      }
    } catch (e) {
      if (mounted) {
        ref.read(snackbarServiceProvider).showError('재설정 중 오류가 발생했습니다');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게임 규칙 설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: _resetToDefault,
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('초기화'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 설명 텍스트
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.1),
                            AppColors.secondary.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 10,
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
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.casino,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                '게임 규칙 설정',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '아래 금액들을 설정해주세요. 설정한 값은 자동으로 저장됩니다.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 규칙 설정 필드들
                    _buildRuleField(
                      label: '점당 금액',
                      controller: _pointPriceController,
                      suffix: '원',
                      icon: Icons.monetization_on,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildRuleField(
                      label: '뻑',
                      controller: _ppeoPriceController,
                      suffix: '원',
                      icon: Icons.block,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildRuleField(
                      label: '따닥',
                      controller: _ddadakPriceController,
                      suffix: '원',
                      icon: Icons.flash_on,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildRuleField(
                      label: '광 팔기',
                      controller: _gwangSellPriceController,
                      suffix: '원',
                      icon: Icons.star,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildRuleField(
                      label: '대통령',
                      controller: _presidentPriceController,
                      suffix: '원',
                      icon: Icons.emoji_events,
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            
            // 하단 버튼
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
                    onPressed: _isLoading ? null : _saveRules,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.arrow_forward),
                    label: Text(_isLoading ? '저장 중...' : '다음'),
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
      ),
    );
  }

  Widget _buildRuleField({
    required String label,
    required TextEditingController controller,
    required String suffix,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(7),
            ],
            validator: _validatePrice,
            decoration: InputDecoration(
              suffixText: suffix,
              suffixStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              hintText: '금액을 입력하세요',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 15,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.attach_money,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
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
                vertical: 16,
              ),
            ),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}