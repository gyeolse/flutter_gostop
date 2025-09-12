import 'package:flutter/material.dart';
import '../app_colors.dart';

class ModernInputDialog extends StatefulWidget {
  final String title;
  final String? content;
  final String? hintText;
  final String? labelText;
  final String? initialValue;
  final String confirmText;
  final String cancelText;
  final Function(String)? onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;
  final Color? iconColor;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool obscureText;
  final String? Function(String?)? validator;

  const ModernInputDialog({
    super.key,
    required this.title,
    this.content,
    this.hintText,
    this.labelText,
    this.initialValue,
    this.confirmText = '확인',
    this.cancelText = '취소',
    this.onConfirm,
    this.onCancel,
    this.icon,
    this.iconColor,
    this.keyboardType,
    this.maxLength,
    this.obscureText = false,
    this.validator,
  });

  @override
  State<ModernInputDialog> createState() => _ModernInputDialogState();

  static Future<String?> show(
    BuildContext context, {
    required String title,
    String? content,
    String? hintText,
    String? labelText,
    String? initialValue,
    String confirmText = '확인',
    String cancelText = '취소',
    Function(String)? onConfirm,
    VoidCallback? onCancel,
    IconData? icon,
    Color? iconColor,
    TextInputType? keyboardType,
    int? maxLength,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => ModernInputDialog(
        title: title,
        content: content,
        hintText: hintText,
        labelText: labelText,
        initialValue: initialValue,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        icon: icon,
        iconColor: iconColor,
        keyboardType: keyboardType,
        maxLength: maxLength,
        obscureText: obscureText,
        validator: validator,
      ),
    );
  }
}

class _ModernInputDialogState extends State<ModernInputDialog> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    final text = _controller.text.trim();
    
    if (widget.validator != null) {
      final error = widget.validator!(text);
      if (error != null) {
        setState(() {
          _errorText = error;
        });
        return;
      }
    }

    Navigator.of(context).pop(text);
    widget.onConfirm?.call(text);
  }

  void _handleCancel() {
    Navigator.of(context).pop();
    widget.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      elevation: 12,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더 영역
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  children: [
                    // 아이콘
                    if (widget.icon != null) ...[
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: (widget.iconColor ?? AppColors.primary).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.icon,
                          size: 32,
                          color: widget.iconColor ?? AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // 타이틀
                    Text(
                      widget.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textLight : AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // 컨텐츠 및 입력 필드
              Container(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 컨텐츠 텍스트
                    if (widget.content != null) ...[
                      Text(
                        widget.content!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.textLight.withOpacity(0.87) 
                                 : AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // 입력 필드
                    TextField(
                      controller: _controller,
                      keyboardType: widget.keyboardType,
                      maxLength: widget.maxLength,
                      obscureText: widget.obscureText,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: widget.labelText,
                        hintText: widget.hintText,
                        errorText: _errorText,
                        counterText: '',
                        filled: true,
                        fillColor: isDark 
                            ? AppColors.cardDark.withOpacity(0.5)
                            : AppColors.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.textLight.withOpacity(0.3) : AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.textLight.withOpacity(0.2) : AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.error,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (_errorText != null) {
                          setState(() {
                            _errorText = null;
                          });
                        }
                      },
                      onSubmitted: (_) => _handleConfirm(),
                    ),
                  ],
                ),
              ),
              
              // 액션 버튼 영역
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _handleCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? AppColors.textLight : AppColors.textPrimary,
                          side: BorderSide(
                            color: isDark ? AppColors.textLight.withOpacity(0.3) : AppColors.primary.withOpacity(0.3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.cancelText,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.confirmText,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}