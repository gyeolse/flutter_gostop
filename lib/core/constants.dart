class AppConstants {
  static const String appName = 'Flutter GoStop';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String userTokenKey = 'user_token';
  static const String firstLaunchKey = 'first_launch';
  
  // Google Mobile Ads
  static const String androidBannerAdId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String iosBannerAdId = 'ca-app-pub-3940256099942544/2934735716'; // Test ID
  static const String androidInterstitialAdId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static const String iosInterstitialAdId = 'ca-app-pub-3940256099942544/4411468910'; // Test ID
  
  // Notifications
  static const String notificationChannelId = 'flutter_gostop_channel';
  static const String notificationChannelName = 'Flutter GoStop Notifications';
  static const String notificationChannelDescription = 'General notifications for Flutter GoStop app';
  
  // API
  static const String baseUrl = 'https://api.example.com';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // UI
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
}