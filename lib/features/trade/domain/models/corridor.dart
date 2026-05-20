/// One cross-border trade corridor we surface prices for. Names match the
/// HYBRID-TRADE deck so the rest of the trade module reads consistently.
enum Corridor { nigeria, benin, togo, niger, cameroon }

extension CorridorX on Corridor {
  String get label => switch (this) {
        Corridor.nigeria => 'Nigeria',
        Corridor.benin => 'Benin',
        Corridor.togo => 'Togo',
        Corridor.niger => 'Niger',
        Corridor.cameroon => 'Cameroon',
      };

  /// Two-letter flag-ish abbreviation used in compact pill UIs.
  String get short => switch (this) {
        Corridor.nigeria => 'NG',
        Corridor.benin => 'BJ',
        Corridor.togo => 'TG',
        Corridor.niger => 'NE',
        Corridor.cameroon => 'CM',
      };
}

/// Maps an API corridor / country string onto the [Corridor] enum,
/// falling back to Nigeria when the value is unknown.
Corridor corridorFromName(String? s) {
  final v = (s ?? '').toLowerCase();
  for (final c in Corridor.values) {
    if (c.name == v) return c;
  }
  return Corridor.nigeria;
}
