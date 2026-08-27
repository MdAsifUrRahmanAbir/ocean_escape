/// Monetization-ready stub (§53). No ad SDK is integrated - the core game
/// must never require this to function. Kept as a real seam so a rewarded
/// ad provider can be dropped in later without touching call sites.
class AdService {
  bool get rewardedAdAvailable => false;

  /// Returns true if a reward was granted. Always false until a real ad
  /// SDK is wired in.
  Future<bool> showRewardedAd() async => false;

  Future<bool> isRemoveAdsPurchased() async => false;
}
