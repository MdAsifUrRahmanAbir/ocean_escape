/// The four ocean zones the world scrolls through, in progression order (§16).
enum EnvironmentType { coralReef, deepOcean, shipwreck, volcanoOcean }

extension EnvironmentTypeX on EnvironmentType {
  String get displayName {
    switch (this) {
      case EnvironmentType.coralReef:
        return 'Coral Reef';
      case EnvironmentType.deepOcean:
        return 'Deep Ocean';
      case EnvironmentType.shipwreck:
        return 'Shipwreck';
      case EnvironmentType.volcanoOcean:
        return 'Volcano Ocean';
    }
  }

  int get index0 => EnvironmentType.values.indexOf(this);
}
