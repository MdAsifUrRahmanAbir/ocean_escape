import 'package:flutter/foundation.dart';

import '../models/fish_skin.dart';
import 'storage_service.dart';

/// Owns the player's gold wallet and fish collection (owned / selected /
/// ad-unlock progress). Screens listen to it to refresh balances.
class ShopManager extends ChangeNotifier {
  ShopManager(this._storage);
  final StorageService _storage;

  int get gold => _storage.gold;

  FishSkin get selectedFish => FishCatalog.byId(_storage.selectedFish);

  bool isOwned(FishSkin fish) =>
      fish.unlockType == FishUnlockType.free || _storage.ownedFish.contains(fish.id);

  bool isSelected(FishSkin fish) => selectedFish.id == fish.id;

  int adProgress(FishSkin fish) => _storage.fishAdProgress(fish.id);

  Future<void> addGold(int amount) async {
    if (amount <= 0) return;
    await _storage.setGold(gold + amount);
    notifyListeners();
  }

  /// Buys [fish] with gold. Returns false if the player can't afford it.
  Future<bool> buyWithGold(FishSkin fish) async {
    if (isOwned(fish) || fish.unlockType != FishUnlockType.gold) return false;
    if (gold < fish.price) return false;
    await _storage.setGold(gold - fish.price);
    await _unlock(fish);
    return true;
  }

  /// Records one watched ad toward [fish]; unlocks it when enough are seen.
  /// Returns true if this ad completed the unlock.
  Future<bool> registerAdWatched(FishSkin fish) async {
    if (isOwned(fish) || fish.unlockType != FishUnlockType.ad) return false;
    final progress = adProgress(fish) + 1;
    await _storage.setFishAdProgress(fish.id, progress);
    if (progress >= fish.adsRequired) {
      await _unlock(fish);
      return true;
    }
    notifyListeners();
    return false;
  }

  Future<void> select(FishSkin fish) async {
    if (!isOwned(fish)) return;
    await _storage.setSelectedFish(fish.id);
    notifyListeners();
  }

  Future<void> _unlock(FishSkin fish) async {
    final owned = {..._storage.ownedFish, fish.id}.toList();
    await _storage.setOwnedFish(owned);
    await _storage.setSelectedFish(fish.id);
    notifyListeners();
  }
}
