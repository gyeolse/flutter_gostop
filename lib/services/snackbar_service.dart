import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final snackbarServiceProvider = Provider<SnackbarService>((ref) {
  return SnackbarService();
});

class SnackbarService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = 
      GlobalKey<ScaffoldMessengerState>();

  void showSuccess(String message) {
    _showSnackbar(
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  void showError(String message) {
    _showSnackbar(
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
  }

  void showInfo(String message) {
    _showSnackbar(
      message: message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
    );
  }

  void showWarning(String message) {
    _showSnackbar(
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
    );
  }

  void _showSnackbar({
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    // 기존 스낵바를 즉시 숨기기
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    
    // 새로운 스낵바 표시 - 하단 버튼을 가리지 않도록 위치 조정
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        // 하단 버튼을 가리지 않도록 위치 조정 (더 위쪽으로)
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        elevation: 6,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void hideCurrentSnackbar() {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  }

  void clearSnackbars() {
    scaffoldMessengerKey.currentState?.clearSnackBars();
  }
}