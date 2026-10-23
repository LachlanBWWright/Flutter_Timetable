import 'package:lbww_flutter/transit/domain/transit_types.dart';

/// Build-time switches for regions exposed by the app.
///
/// Re-enable a region with `--dart-define=ENABLE_VICTORIA=true` (and the
/// matching define for other regions) when it is ready for users.
abstract final class RegionFeatureFlags {
  static const nsw = bool.fromEnvironment('ENABLE_NSW', defaultValue: true);
  static const victoria = bool.fromEnvironment(
    'ENABLE_VICTORIA',
    defaultValue: false,
  );
  static const queensland = bool.fromEnvironment(
    'ENABLE_QUEENSLAND',
    defaultValue: false,
  );
  static const southAustralia = bool.fromEnvironment(
    'ENABLE_SOUTH_AUSTRALIA',
    defaultValue: false,
  );
  static const tasmania = bool.fromEnvironment(
    'ENABLE_TASMANIA',
    defaultValue: false,
  );
  static const northernTerritory = bool.fromEnvironment(
    'ENABLE_NORTHERN_TERRITORY',
    defaultValue: false,
  );
  static const westernAustralia = bool.fromEnvironment(
    'ENABLE_WESTERN_AUSTRALIA',
    defaultValue: false,
  );

  static bool isEnabled(TransitRegion region) => switch (region) {
    TransitRegion.nsw =>
      nsw ||
          !(victoria ||
              queensland ||
              southAustralia ||
              tasmania ||
              northernTerritory ||
              westernAustralia),
    TransitRegion.victoria => victoria,
    TransitRegion.queensland => queensland,
    TransitRegion.southAustralia => southAustralia,
    TransitRegion.tasmania => tasmania,
    TransitRegion.northernTerritory => northernTerritory,
    TransitRegion.westernAustralia => westernAustralia,
  };

  static Set<TransitRegion> get enabledRegions {
    final enabled = TransitRegion.values.where(isEnabled).toSet();
    return enabled;
  }
}
