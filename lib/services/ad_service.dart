import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';

final adServiceProvider = Provider<AdService>((ref) {
  return AdService();
});

class AdService {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    
    if (kDebugMode) {
      print('Google Mobile Ads initialized');
    }
  }

  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return AppConstants.androidBannerAdId;
    } else if (Platform.isIOS) {
      return AppConstants.iosBannerAdId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return AppConstants.androidInterstitialAdId;
    } else if (Platform.isIOS) {
      return AppConstants.iosInterstitialAdId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  BannerAd createBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('Banner ad loaded: ${ad.adUnitId}');
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            print('Banner ad failed to load: ${error.message}');
          }
          ad.dispose();
        },
        onAdOpened: (ad) {
          if (kDebugMode) {
            print('Banner ad opened');
          }
        },
        onAdClosed: (ad) {
          if (kDebugMode) {
            print('Banner ad closed');
          }
        },
      ),
    );

    return _bannerAd!;
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('Interstitial ad showed full screen content');
              }
            },
            onAdDismissedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('Interstitial ad dismissed');
              }
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // Load the next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (kDebugMode) {
                print('Interstitial ad failed to show: ${error.message}');
              }
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // Load the next ad
            },
          );
          
          if (kDebugMode) {
            print('Interstitial ad loaded');
          }
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('Interstitial ad failed to load: ${error.message}');
          }
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      if (kDebugMode) {
        print('Interstitial ad not ready');
      }
      loadInterstitialAd(); // Try to load if not ready
    }
  }

  bool get isInterstitialAdReady => _isInterstitialAdReady;

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}