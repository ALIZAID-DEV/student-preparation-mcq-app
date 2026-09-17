import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // 🔥 PRODUCTION IDs (Aap ke diye hue)
  // Banner: Quiz_Result_Banner → ca-app-pub-4265628431809059/5699203710
  // Interstitial: Level_Up_Interstitial → ca-app-pub-4265628431809059/1460626137

  static String get bannerAdUnitId {
    if (kDebugMode) {
      // Debug mode mein Test IDs (safe)
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }
    // 🚀 PRODUCTION (Real IDs)
    return Platform.isAndroid
        ? 'ca-app-pub-4265628431809059/5699203710' // Quiz_Result_Banner
        : 'ca-app-pub-4265628431809059/5699203710'; // iOS ke liye bhi same dal diya (agar iOS ID hai toh yahan change karein)
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }
    // 🚀 PRODUCTION (Real IDs)
    return Platform.isAndroid
        ? 'ca-app-pub-4265628431809059/1460626137' // Level_Up_Interstitial
        : 'ca-app-pub-4265628431809059/1460626137'; // iOS ke liye bhi same (agar iOS ID hai toh yahan change karein)
  }

  static BannerAd? _bannerAd;
  static InterstitialAd? _interstitialAd;

  static Future<void> initAds() async {
    await MobileAds.instance.initialize();
    loadInterstitialAd();
  }

  static BannerAd loadBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {},
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
    return _bannerAd!;
  }

  static Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  static void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd();
        },
      );
      _interstitialAd?.show();
      _interstitialAd = null;
    } else {
      loadInterstitialAd();
    }
  }

  static void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}
