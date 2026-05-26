import 'package:flutter/foundation.dart';

import '../network/api_client.dart';

/// Server-driven feature flags. The backend exposes `/v1/feature-flags` —
/// a map of `{ "flag_key": bool }`. The service loads it once at boot and
/// exposes a [ValueNotifier] so widgets can react when the user toggles
/// flags via the dev-account broadcast control.
///
/// Note: the `/v1/feature-flags` endpoint does NOT exist on the API yet.
/// When the call 404s or otherwise fails we silently keep the compiled-in
/// defaults below — so flag-gated screens render the new variant by
/// default until the API agent ships the route.
class FeatureFlagService {
  FeatureFlagService._();
  static final FeatureFlagService instance = FeatureFlagService._();

  /// The full flag map. Reactive — widgets that read it via
  /// [ValueListenableBuilder] re-render on the next `load()`.
  final ValueNotifier<Map<String, bool>> flags =
      ValueNotifier<Map<String, bool>>(_defaults);

  /// Compiled-in fallback values used until the API responds.
  static const _defaults = <String, bool>{
    // Bug 14 — gates the redesigned home categories grid. Toggling this
    // off via the dev account / API rolls everyone back to the previous
    // 3x3 layout without an app update.
    'new_categories_ui': true,
  };

  /// Pulls the latest flag values from the backend. Failures are
  /// swallowed so a 404/timeout never blocks first paint — the previous
  /// flag map (or the defaults) is left intact.
  Future<void> load() async {
    try {
      final res = await ApiClient.instance.get('/feature-flags');
      if (res is! Map) return;
      final next = <String, bool>{..._defaults};
      for (final entry in res.entries) {
        final v = entry.value;
        if (v is bool) next[entry.key.toString()] = v;
      }
      flags.value = next;
    } catch (_) {
      // Endpoint not implemented yet, network down, or malformed
      // response — leave the previously cached / default values.
    }
  }

  // ─── Convenience getters ───────────────────────────────────────────

  /// Bug 14 — when false, the home screen falls back to the legacy
  /// category grid. Wire the home screen to this getter once the recipe
  /// agent's branch lands.
  bool get newCategoriesUI => flags.value['new_categories_ui'] ?? true;

  /// Generic lookup so screens can read any flag by key without having
  /// to extend this class.
  bool isOn(String key, {bool defaultValue = false}) =>
      flags.value[key] ?? defaultValue;
}
