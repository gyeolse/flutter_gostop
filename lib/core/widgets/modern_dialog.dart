import 'package:flutter/material.dart';
import '../app_colors.dart';
import 'capsule_button.dart';

class ModernDialog extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final String? content;
  final Widget? contentWidget;
  final List<ModernDialogAction>? actions;
  final EdgeInsetsGeometry? contentPadding;
  final Color? backgroundColor;
  final bool barrierDismissible;
  final IconData? icon;
  final Color? iconColor;

  const ModernDialog({
    super.key,
    this.title,
    this.titleWidget,
    this.content,
    this.contentWidget,
    this.actions,
    this.contentPadding,
    this.backgroundColor,
    this.barrierDismissible = true,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Dialog(
      elevation: 12,
      backgroundColor: backgroundColor ?? 
          (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더 영역
            if (title != null || titleWidget != null || icon != null)
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  children: [
                    // 아이콘
                    if (icon != null) ...[
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 32,
                          color: iconColor ?? AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // 타이틀
                    if (titleWidget != null)
                      titleWidget!
                    else if (title != null)
                      Text(
                        title!,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textLight : AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            
            // 컨텐츠 영역
            if (content != null || contentWidget != null)
              Container(
                padding: contentPadding ?? 
                    const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: contentWidget ?? 
                    Text(
                      content!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.textLight.withOpacity(0.87) 
                               : AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
              ),
            
            // 액션 버튼 영역
            if (actions != null && actions!.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: actions!.length == 1
                    ? SizedBox(
                        width: double.infinity,
                        child: _buildAction(context, actions!.first),
                      )
                    : Row(
                        children: actions!.asMap().entries.map((entry) {
                          final index = entry.key;
                          final action = entry.value;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: index > 0 ? 8 : 0,
                              ),
                              child: _buildAction(context, action),
                            ),
                          );
                        }).toList(),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(BuildContext context, ModernDialogAction action) {
    if (action.isPrimary) {
      return CapsuleButtons.primary(
        text: action.text,
        onPressed: action.onPressed,
        width: double.infinity,
        height: 48,
        fontSize: 16,
      );
    } else {
      return CapsuleButtons.outlined(
        text: action.text,
        onPressed: action.onPressed,
        width: double.infinity,
        height: 48,
        fontSize: 16,
      );
    }
  }

  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    Widget? titleWidget,
    String? content,
    Widget? contentWidget,
    List<ModernDialogAction>? actions,
    EdgeInsetsGeometry? contentPadding,
    Color? backgroundColor,
    bool barrierDismissible = true,
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => ModernDialog(
        title: title,
        titleWidget: titleWidget,
        content: content,
        contentWidget: contentWidget,
        actions: actions,
        contentPadding: contentPadding,
        backgroundColor: backgroundColor,
        barrierDismissible: barrierDismissible,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }
}

class ModernDialogAction {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final Color? color;

  const ModernDialogAction({
    required this.text,
    this.onPressed,
    this.isPrimary = false,
    this.color,
  });

  static ModernDialogAction primary({
    required String text,
    VoidCallback? onPressed,
    Color? color,
  }) {
    return ModernDialogAction(
      text: text,
      onPressed: onPressed,
      isPrimary: true,
      color: color,
    );
  }

  static ModernDialogAction secondary({
    required String text,
    VoidCallback? onPressed,
    Color? color,
  }) {
    return ModernDialogAction(
      text: text,
      onPressed: onPressed,
      isPrimary: false,
      color: color,
    );
  }
}

// 특수한 다이얼로그 유형들
class ModernConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;
  final Color? iconColor;
  final Color? confirmColor;

  const ModernConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = '확인',
    this.cancelText = '취소',
    this.onConfirm,
    this.onCancel,
    this.icon,
    this.iconColor,
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return ModernDialog(
      title: title,
      content: content,
      icon: icon,
      iconColor: iconColor,
      actions: [
        ModernDialogAction(
          text: cancelText,
          onPressed: onCancel,
          isPrimary: false,
        ),
        ModernDialogAction(
          text: confirmText,
          onPressed: onConfirm,
          isPrimary: true,
          color: confirmColor,
        ),
      ],
    );
  }

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = '확인',
    String cancelText = '취소',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    IconData? icon,
    Color? iconColor,
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ModernConfirmDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: () {
          Navigator.of(context).pop(true);
          onConfirm?.call();
        },
        onCancel: () {
          Navigator.of(context).pop(false);
          onCancel?.call();
        },
        icon: icon,
        iconColor: iconColor,
        confirmColor: confirmColor,
      ),
    );
  }
}

class ModernInfoDialog extends StatelessWidget {
  final String title;
  final String content;
  final String okText;
  final VoidCallback? onOk;
  final IconData? icon;
  final Color? iconColor;

  const ModernInfoDialog({
    super.key,
    required this.title,
    required this.content,
    this.okText = '확인',
    this.onOk,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ModernDialog(
      title: title,
      content: content,
      icon: icon,
      iconColor: iconColor,
      actions: [
        ModernDialogAction(
          text: okText,
          onPressed: onOk,
          isPrimary: true,
        ),
      ],
    );
  }

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String content,
    String okText = '확인',
    VoidCallback? onOk,
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => ModernInfoDialog(
        title: title,
        content: content,
        okText: okText,
        onOk: () {
          Navigator.of(context).pop();
          onOk?.call();
        },
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }
}