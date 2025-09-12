import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/widgets/capsule_button.dart';

class AvatarPickerDialog extends StatefulWidget {
  final String currentAvatar;
  final Function(String) onAvatarSelected;

  const AvatarPickerDialog({
    super.key,
    required this.currentAvatar,
    required this.onAvatarSelected,
  });

  static void show(
    BuildContext context, {
    required String currentAvatar,
    required Function(String) onAvatarSelected,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AvatarPickerDialog(
        currentAvatar: currentAvatar,
        onAvatarSelected: onAvatarSelected,
      ),
    );
  }

  @override
  State<AvatarPickerDialog> createState() => _AvatarPickerDialogState();
}

class _AvatarPickerDialogState extends State<AvatarPickerDialog> {
  String? selectedAvatar;
  
  static const List<String> allAvatars = [
    // 기본 아바타들
    '👤', '🎭', '🎪', '🎯', '🎲', 
    '♠️', '♥️', '♦️', '♣️', '🃏',
    // 추가 이모지들
    '😀', '😎', '🤠', '👑', '🎩',
    '🐶', '🐱', '🐸', '🦊', '🐯',
    '⚽', '🏀', '🎸', '🎺', '🎪',
    '🌟', '⭐', '💎', '🔥', '⚡',
    '🍕', '🍔', '🍰', '☕', '🍺',
    '🚗', '✈️', '🚀', '🎮', '📱',
  ];

  @override
  void initState() {
    super.initState();
    selectedAvatar = widget.currentAvatar;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: 400,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            _buildHeader(),
            
            // 아바타 그리드
            Flexible(
              child: _buildAvatarGrid(),
            ),
            
            // 액션 버튼들
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.face_retouching_natural,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '아바타 선택',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '마음에 드는 아바타를 골라보세요',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          childAspectRatio: 1.0,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: allAvatars.length,
        itemBuilder: (context, index) {
          final avatar = allAvatars[index];
          final isSelected = avatar == selectedAvatar;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedAvatar = avatar;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? AppColors.primary 
                      : Colors.grey.shade200,
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Center(
                child: Text(
                  avatar,
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: CapsuleButtons.outlined(
              text: '취소',
              onPressed: () => Navigator.of(context).pop(),
              width: double.infinity,
              height: 48,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CapsuleButtons.primary(
              text: '선택',
              onPressed: selectedAvatar != null 
                  ? () {
                      widget.onAvatarSelected(selectedAvatar!);
                      Navigator.of(context).pop();
                    }
                  : null,
              width: double.infinity,
              height: 48,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}