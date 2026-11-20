import 'dart:ui';

import '../components/player/fish_painter.dart';

/// How a fish is unlocked in the shop.
enum FishUnlockType { free, gold, ad }

/// A playable fish: its look, how it's unlocked, and an optional gold perk.
class FishSkin {
  const FishSkin({
    required this.id,
    required this.name,
    required this.bodyColor,
    required this.bellyColor,
    required this.finColor,
    this.stripeColor,
    this.unlockType = FishUnlockType.free,
    this.price = 0,
    this.adsRequired = 0,
    this.goldBonus = 1.0,
  });

  final String id;
  final String name;
  final Color bodyColor;
  final Color bellyColor;
  final Color finColor;
  final Color? stripeColor;
  final FishUnlockType unlockType;

  /// Gold cost when [unlockType] is [FishUnlockType.gold].
  final int price;

  /// Number of ads to watch when [unlockType] is [FishUnlockType.ad].
  final int adsRequired;

  /// Multiplier applied to gold earned during a run with this fish.
  final double goldBonus;

  bool get hasPerk => goldBonus > 1.0;
  String get perkLabel => '+${((goldBonus - 1) * 100).round()}% gold';

  FishPainter createPainter() => FishPainter(
        bodyColor: bodyColor,
        bellyColor: bellyColor,
        finColor: finColor,
        stripeColor: stripeColor,
      );
}

/// Every fish available in the shop, in display order. The first one is the
/// default fish every player owns.
class FishCatalog {
  FishCatalog._();

  static const FishSkin defaultFish = FishSkin(
    id: 'sunny',
    name: 'Sunny',
    bodyColor: Color(0xFFFF8A3D),
    bellyColor: Color(0xFFFFD180),
    finColor: Color(0xFFFFD54F),
  );

  static const List<FishSkin> all = [
    defaultFish,
    FishSkin(
      id: 'bubbles',
      name: 'Bubbles',
      bodyColor: Color(0xFF3FA9D6),
      bellyColor: Color(0xFFB3E5FC),
      finColor: Color(0xFF81D4FA),
      unlockType: FishUnlockType.gold,
      price: 150,
    ),
    FishSkin(
      id: 'coral',
      name: 'Coral',
      bodyColor: Color(0xFFFF6F91),
      bellyColor: Color(0xFFFFC1D0),
      finColor: Color(0xFFFFA8C0),
      unlockType: FishUnlockType.ad,
      adsRequired: 1,
    ),
    FishSkin(
      id: 'clowny',
      name: 'Clowny',
      bodyColor: Color(0xFFFF7A1A),
      bellyColor: Color(0xFFFFE0B2),
      finColor: Color(0xFF2B1B12),
      stripeColor: Color(0xFFFFFFFF),
      unlockType: FishUnlockType.gold,
      price: 350,
      goldBonus: 1.05,
    ),
    FishSkin(
      id: 'lime',
      name: 'Lime Puff',
      bodyColor: Color(0xFF7CD64A),
      bellyColor: Color(0xFFDCF8C6),
      finColor: Color(0xFFC5E86C),
      unlockType: FishUnlockType.ad,
      adsRequired: 2,
      goldBonus: 1.05,
    ),
    FishSkin(
      id: 'royal',
      name: 'Royal',
      bodyColor: Color(0xFF8E5CF0),
      bellyColor: Color(0xFFD9C8FF),
      finColor: Color(0xFFFFD54F),
      unlockType: FishUnlockType.gold,
      price: 700,
      goldBonus: 1.10,
    ),
    FishSkin(
      id: 'shadow',
      name: 'Shadow',
      bodyColor: Color(0xFF37415A),
      bellyColor: Color(0xFF8C9BB8),
      finColor: Color(0xFF6FE0FF),
      stripeColor: Color(0xFF6FE0FF),
      unlockType: FishUnlockType.ad,
      adsRequired: 3,
      goldBonus: 1.15,
    ),
    FishSkin(
      id: 'golden',
      name: 'Golden Koi',
      bodyColor: Color(0xFFFFC107),
      bellyColor: Color(0xFFFFF3C4),
      finColor: Color(0xFFFF8F00),
      stripeColor: Color(0xFFFFFFFF),
      unlockType: FishUnlockType.gold,
      price: 1500,
      goldBonus: 1.25,
    ),
  ];

  static FishSkin byId(String? id) =>
      all.firstWhere((f) => f.id == id, orElse: () => defaultFish);
}
