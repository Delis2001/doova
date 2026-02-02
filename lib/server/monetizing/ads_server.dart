import 'dart:io';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:doova/provider/monetizing/user_provider.dart';
import 'package:doova/utils/helpers/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  RewardedAd? _rewardedAd;

  /// On web, ads are not supported, so returns a string explaining that.
  String get rewardedAdUnitId {
    if (kIsWeb) {
      return 'web-not-supported';
    } else if (Platform.isAndroid) {
      // Replace with your real Android ad ID
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      // Replace with your real iOS ad ID
      return 'ca-app-pub-3940256099942544/1712485313';
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  void loadRewardAd({
    required VoidCallback onLoaded,
    required Function(String) onError,
  }) {
    if (kIsWeb) {
      // No-op on web
      if (kDebugMode) debugPrint("Web: RewardedAd not available.");
      return;
    }
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          onLoaded();
        },
        onAdFailedToLoad: (error) {
          onError(error.message);
        },
      ),
    );
  }

  void showRewardAd({
    required String uid,
    required UserProvider userProvider,
    required BuildContext context,
  }) {
    if (kIsWeb) {
      Toast.errorToast(
      context, "Rewarded ads are not supported on web. Enjoy the app!",
      color: Colors.red, position: DelightSnackbarPosition.top);
      return;
    }
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          Navigator.of(context, rootNavigator: true).pop(); // Dismiss dialog
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          Navigator.of(context, rootNavigator: true)
              .pop(); // Also dismiss dialog
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) async {
          await userProvider.earnCoin(uid);
        },
      );
    } else {
      if (kDebugMode) {
        debugPrint("RewardedAd is not loaded yet.");
      }
    }
  }
}
