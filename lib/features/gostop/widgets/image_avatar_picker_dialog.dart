import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/widgets/capsule_button.dart';

class ImageAvatarPickerDialog extends StatefulWidget {
  final String currentAvatar;
  final Function(String) onAvatarSelected;

  const ImageAvatarPickerDialog({
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
      builder: (context) => ImageAvatarPickerDialog(
        currentAvatar: currentAvatar,
        onAvatarSelected: onAvatarSelected,
      ),
    );
  }

  @override
  State<ImageAvatarPickerDialog> createState() =>
      _ImageAvatarPickerDialogState();
}

class _ImageAvatarPickerDialogState extends State<ImageAvatarPickerDialog> {
  late PageController _pageController;
  int _currentIndex = 0;

  // 사용 가능한 아바타 이미지들
  final List<String> _avatarImages = [
    'lib/assets/images/pangangjang.png',
    'lib/assets/images/kwakchulyeong.png',
    'lib/assets/images/jungmadam.png',
    'lib/assets/images/agui.png',
    'lib/assets/images/gogangryul.png',
    'lib/assets/images/daemori.png',
    'lib/assets/images/goni.png',
  ];

  // 이미지 이름들 (표시용)
  final List<String> _avatarNames = [
    '판깡장',
    '곽칠용',
    '쟁마담',
    '아구',
    '고광욜',
    '박무섬',
    '구니',
  ];

  @override
  void initState() {
    super.initState();

    // 현재 선택된 아바타가 이미지 목록에 있는지 확인하고 인덱스 설정
    int initialIndex = _avatarImages.indexOf(widget.currentAvatar);
    if (initialIndex == -1) {
      initialIndex = 0; // 기본값으로 첫 번째 이미지
    }

    _currentIndex = initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectAvatar() {
    final selectedAvatar = _avatarImages[_currentIndex];
    widget.onAvatarSelected(selectedAvatar);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
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

            // 아바타 선택 영역
            _buildAvatarSelector(),

            // 액션 버튼들
            _buildActionButtons(),
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
            child: const Icon(Icons.face, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            '아바타 선택',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '좌우로 스와이프해서 원하는 캐릭터를 선택하세요',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSelector() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 아바타 이미지 페이지뷰
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _avatarImages.length,
                itemBuilder: (context, index) {
                  return _buildAvatarPage(index);
                },
              ),
            ),

            const SizedBox(height: 20),

            // 페이지 인디케이터
            _buildPageIndicator(),

            const SizedBox(height: 16),

            // 캐릭터 이름
            Text(
              _avatarNames[_currentIndex],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPage(int index) {
    final isSelected = index == _currentIndex;

    return Center(
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.1),
              AppColors.secondary.withValues(alpha: 0.08),
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 4 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: ClipOval(
            child: Image.asset(
              _avatarImages[index],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _avatarImages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentIndex ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _currentIndex
                ? AppColors.primary
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
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
              onPressed: _selectAvatar,
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
