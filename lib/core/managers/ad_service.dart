import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'storage_service.dart';

/// Google AdMob integration.
///
/// - Interstitial: shown automatically every [playsPerInterstitial] runs, and
///   on demand for rewards (revive, double gold, fish unlocks).
/// - Banner: shown on the About screen (see `BannerAdView`).
///
/// Debug builds use Google's official test ad units so you never click your
/// own live ads during development (which can get an AdMob account banned).
/// Release builds use the real units below.
class AdService {
  AdService(this._storage);
  final StorageService _storage;

  // App ID lives in android/app/src/main/AndroidManifest.xml:
  // ca-app-pub-2387895083010927~2994163025
  static const String _liveInterstitialId = 'ca-app-pub-2387895083010927/6027345468';
  static const String _liveBannerId = 'ca-app-pub-2387895083010927/2307767316';

  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';

  static String get interstitialUnitId => kReleaseMode ? _liveInterstitialId : _testInterstitialId;
  static String get bannerUnitId => kReleaseMode ? _liveBannerId : _testBannerId;

  /// Show an interstitial after this many runs started (PLAY / RETRY).
  static const int playsPerInterstitial = 5;

  /// Ads are only configured for Android (the AdMob app ID is Android-only).
  static bool get isSupported => !kIsWeb && Platform.isAndroid;

  InterstitialAd? _interstitial;
  bool _loading = false;
  int _retryAttempt = 0;
  bool _showing = false;

  bool get interstitialReady => _interstitial != null;

  Future<void> init() async {
    if (!isSupported) return;
    try {
      await MobileAds.instance.initialize();
      _loadInterstitial();
    } catch (e) {
      debugPrint('AdMob init failed: $e');
    }
  }

  void _loadInterstitial() {
    if (!isSupported || _loading || _interstitial != null) return;
    _loading = true;
    InterstitialAd.load(
      adUnitId: interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _retryAttempt = 0;
          _interstitial = ad;
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          _interstitial = null;
          // Exponential back-off: 2s, 4s, 8s ... capped at 64s.
          _retryAttempt = (_retryAttempt + 1).clamp(1, 6);
          Timer(Duration(seconds: 1 << _retryAttempt), _loadInterstitial);
        },
      ),
    );
  }

  /// Shows an interstitial and waits until it is closed. Returns true only if
  /// the ad was actually shown and dismissed - use this to grant rewards.
  Future<bool> showInterstitial() async {
    final ad = _interstitial;
    if (ad == null || _showing) {
      _loadInterstitial();
      return false;
    }
    _interstitial = null;
    _showing = true;
    final done = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _showing = false;
        _loadInterstitial();
        if (!done.isCompleted) done.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _showing = false;
        _loadInterstitial();
        if (!done.isCompleted) done.complete(false);
      },
    );
    await ad.show();
    return done.future;
  }

  /// Call whenever a run starts (PLAY / RETRY / RESTART). Every
  /// [playsPerInterstitial] runs an interstitial is shown first. If no ad is
  /// ready the counter stays primed so the next run tries again.
  Future<void> onRunStarted() async {
    if (!isSupported) return;
    final plays = _storage.playsSinceInterstitial + 1;
    if (plays >= playsPerInterstitial && await showInterstitial()) {
      await _storage.setPlaysSinceInterstitial(0);
    } else {
      await _storage.setPlaysSinceInterstitial(plays);
    }
  }
}
