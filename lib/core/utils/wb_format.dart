/// Formats a positive integer as a comma-grouped string (e.g. `1234567`
/// → `"1,234,567"`). Used everywhere we render a Naira value so we don't
/// duplicate the grouping logic across screens.
String wbThousands(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i != 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

/// Naira-formatted shortcut.
String wbNaira(int v) => '₦${wbThousands(v)}';
