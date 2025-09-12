import 'package:flutter/material.dart';

enum ButtonType { primary, secondary, outlined }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: _buildButton(context, child),
    );
  }

  Widget _buildButton(BuildContext context, Widget child) {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
      case ButtonType.secondary:
        return FilledButton.tonal(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
      case ButtonType.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
    }
  }
}