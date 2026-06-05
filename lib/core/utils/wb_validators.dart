/// Shared input validators so every form applies the same rules instead of
/// re-implementing (or omitting) them per screen.
abstract final class WbValidators {
  // Pragmatic email shape check — one `@`, a dot in the domain, no spaces.
  // Deliberately lenient (full RFC 5322 is overkill and rejects valid mail).
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool isValidEmail(String value) => _email.hasMatch(value.trim());

  /// Nigerian-friendly phone check: optional leading `+`, then 10–15 digits
  /// once spaces, dashes and parentheses are stripped.
  static bool isValidPhone(String value) {
    final cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');
    return RegExp(r'^\+?\d{10,15}$').hasMatch(cleaned);
  }
}
