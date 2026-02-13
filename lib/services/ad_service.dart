import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  /// Banner Ad Unit IDs
  /// 
  /// DEBUG MODE (kDebugMode = true):
  /// - Uses Google's test Ad Unit IDs → guaranteed test ads, perfect for development
  /// 
  /// RELEASE MODE (kDebugMode = false):
  /// - Android: ca-app-pub-8195806446886861/1390869911 (User's production ID)
  /// - iOS: [TODO - Add your iOS production Ad Unit ID when available]
  /// 
  /// Note: App approval status must be "Approved" for production IDs to serve real ads.
  /// Until then, test IDs in debug mode will work reliably.
  static String get bannerAdUnitId {
    // Use Google's test ad unit IDs in debug mode to ensure reliable test ads
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      }
    }

    if (Platform.isAndroid) {
      // Production Ad Unit ID (Android): ca-app-pub-8195806446886861/1390869911
      return 'ca-app-pub-8195806446886861/1390869911';
    } else if (Platform.isIOS) {
      // TODO: Replace with your iOS production Ad Unit ID
      // Format should be: ca-app-pub-XXXXXXXX/NNNNNNNN
      return 'ca-app-pub-3940256099942544/2934735716'; // placeholder/test ID for now
    }
    return '';
  }

  // Banner reklamı yükle
  Future<void> loadBannerAd({
    required Function(BannerAd) onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) async {
    print('[AdService] Loading banner ad with Unit ID: $bannerAdUnitId');
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('[AdService] Banner ad loaded successfully');
          _isBannerAdLoaded = true;
          onAdLoaded(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          print('[AdService] Banner ad failed to load: code=${error.code}, message=${error.message}');
          _isBannerAdLoaded = false;
          ad.dispose();
          onAdFailedToLoad(error);
        },
      ),
    );

    print('[AdService] Calling _bannerAd!.load()...');
    try {
      await _bannerAd!.load();
      print('[AdService] load() completed successfully');
    } catch (e) {
      print('[AdService] load() error: $e');
    }
  }

  // Banner reklamı dispose et
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
  }

  bool get isBannerAdLoaded => _isBannerAdLoaded;
  BannerAd? get bannerAd => _bannerAd;
}