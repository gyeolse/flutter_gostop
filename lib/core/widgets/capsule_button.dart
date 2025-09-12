import 'package:flutter/material.dart';
import '../app_colors.dart';

enum CapsuleButtonType {
  primary,
  secondary, 
  outlined,
  danger,
}

class CapsuleButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CapsuleButtonType type;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final double fontSize;

  const CapsuleButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = CapsuleButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: _getDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(height / 2),
          onTap: isLoading ? null : onPressed,
          child: _buildContent(),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration() {
    switch (type) {
      case CapsuleButtonType.primary:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case CapsuleButtonType.secondary:
        return BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case CapsuleButtonType.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(
            color: AppColors.primary,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case CapsuleButtonType.danger:
        return BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(
            color: Colors.red.shade200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.shade100.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
    }
  }

  Color _getTextColor() {
    switch (type) {
      case CapsuleButtonType.primary:
        return Colors.white;
      case CapsuleButtonType.secondary:
        return AppColors.textPrimary;
      case CapsuleButtonType.outlined:
        return AppColors.primary;
      case CapsuleButtonType.danger:
        return Colors.red.shade600;
    }
  }

  Color _getIconColor() {
    return _getTextColor();
  }

  Widget _buildContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
            ),
          ),
        ] else ...[
          if (icon != null) ...[
            Icon(
              icon,
              color: _getIconColor(),
              size: 20,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}

// 편의를 위한 팩토리 생성자들
class CapsuleButtons {
  static Widget primary({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    double? width,
    double height = 56,
    double fontSize = 16,
  }) {
    return CapsuleButton(
      text: text,
      onPressed: onPressed,
      type: CapsuleButtonType.primary,
      icon: icon,
      isLoading: isLoading,
      width: width,
      height: height,
      fontSize: fontSize,
    );
  }

  static Widget secondary({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    double? width,
    double height = 56,
    double fontSize = 16,
  }) {
    return CapsuleButton(
      text: text,
      onPressed: onPressed,
      type: CapsuleButtonType.secondary,
      icon: icon,
      isLoading: isLoading,
      width: width,
      height: height,
      fontSize: fontSize,
    );
  }

  static Widget outlined({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    double? width,
    double height = 56,
    double fontSize = 16,
  }) {
    return CapsuleButton(
      text: text,
      onPressed: onPressed,
      type: CapsuleButtonType.outlined,
      icon: icon,
      isLoading: isLoading,
      width: width,
      height: height,
      fontSize: fontSize,
    );
  }

  static Widget danger({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    double? width,
    double height = 56,
    double fontSize = 16,
  }) {
    return CapsuleButton(
      text: text,
      onPressed: onPressed,
      type: CapsuleButtonType.danger,
      icon: icon,
      isLoading: isLoading,
      width: width,
      height: height,
      fontSize: fontSize,
    );
  }
}