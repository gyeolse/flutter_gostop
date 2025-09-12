import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/local_storage_service.dart';
import '../../core/constants.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final localStorage = ref.read(localStorageServiceProvider);
  return AuthNotifier(localStorage);
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final String? userToken;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
    this.userToken,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    String? userToken,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      userToken: userToken ?? this.userToken,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LocalStorageService _localStorage;

  AuthNotifier(this._localStorage) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await _localStorage.getString(AppConstants.userTokenKey);
    if (token != null && token.isNotEmpty) {
      state = state.copyWith(
        isAuthenticated: true,
        userToken: token,
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      if (email == 'test@test.com' && password == 'password') {
        const token = 'dummy_token_12345';
        await _localStorage.setString(AppConstants.userTokenKey, token);
        
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          userToken: token,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '이메일 또는 비밀번호가 잘못되었습니다',
        );
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: '로그인 중 오류가 발생했습니다',
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _localStorage.remove(AppConstants.userTokenKey);
      
      state = const AuthState();
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
      state = state.copyWith(isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}