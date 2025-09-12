import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'settings_provider.dart';
import '../../core/constants.dart';
import '../../core/widgets/modern_dialog.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '테마 설정',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('다크 모드'),
                    subtitle: const Text('어두운 테마를 사용합니다'),
                    value: settingsState.isDarkMode,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).toggleTheme();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Notification Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '알림 설정',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('푸시 알림'),
                    subtitle: const Text('중요한 알림을 받습니다'),
                    value: settingsState.isNotificationEnabled,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).toggleNotification();
                    },
                  ),
                  SwitchListTile(
                    title: const Text('사운드'),
                    subtitle: const Text('알림음을 재생합니다'),
                    value: settingsState.isSoundEnabled,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).toggleSound();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // App Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '앱 정보',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('앱 이름'),
                    subtitle: const Text(AppConstants.appName),
                  ),
                  ListTile(
                    leading: const Icon(Icons.numbers),
                    title: const Text('버전'),
                    subtitle: const Text(AppConstants.appVersion),
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('개인정보 처리방침'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Open privacy policy
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('개인정보 처리방침을 확인합니다'),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('이용약관'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Open terms of service
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('이용약관을 확인합니다'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Storage Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '저장소',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.delete_forever),
                    title: const Text('캐시 삭제'),
                    subtitle: const Text('임시 파일을 삭제합니다'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final result = await ModernConfirmDialog.show(
                        context,
                        title: '캐시 삭제',
                        content: '정말로 캐시를 삭제하시겠습니까?',
                        confirmText: '삭제',
                        cancelText: '취소',
                        icon: Icons.delete_outline,
                        iconColor: Colors.orange,
                        confirmColor: Colors.orange,
                      );
                      
                      if (result == true && context.mounted) {
                        await ref.read(settingsProvider.notifier).clearCache();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('캐시가 삭제되었습니다'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}