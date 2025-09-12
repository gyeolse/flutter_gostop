import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'services/notification_service.dart';
import 'services/ad_service.dart';
import 'services/snackbar_service.dart';
import 'features/settings/settings_provider.dart';
import 'features/gostop/models/game_result.dart';
import 'features/gostop/models/player.dart';
import 'features/gostop/services/players_service.dart';
import 'features/gostop/services/game_history_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(GameResultAdapter());
  Hive.registerAdapter(PlayerResultAdapter());
  Hive.registerAdapter(SettlementAdapter());
  Hive.registerAdapter(PlayerAdapter());
  
  // Initialize services
  await AdService.initialize();
  await PlayersService.initialize();
  await GameHistoryService.initialize();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize notification service
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.initialize();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Flutter GoStop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
      scaffoldMessengerKey: SnackbarService.scaffoldMessengerKey,
    );
  }
}