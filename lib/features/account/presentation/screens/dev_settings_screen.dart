import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/services/feature_flag_service.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';

/// Dev / admin screen to toggle server-side feature flags in real time.
/// Only accessible when the active user has the admin role.
/// Toggling a flag calls PATCH /v1/feature-flags/:key and refreshes all
/// connected clients (including this device) on the next app boot.
class DevSettingsScreen extends StatefulWidget {
  const DevSettingsScreen({super.key});

  @override
  State<DevSettingsScreen> createState() => _DevSettingsScreenState();
}

class _DevSettingsScreenState extends State<DevSettingsScreen> {
  Map<String, bool> _flags = {};
  bool _loading = true;
  final Set<String> _saving = {};

  static const _descriptions = <String, String>{
    'new_categories_ui': 'Redesigned home categories grid (toggle off = old 3×3 layout)',
    'recipe_combos': 'Cook Tonight / Recipe Combo Intelligence rail on home',
    'cross_border_trading': 'ECOWAS cross-border trader and driver flows',
    'wawu_plus': 'WAWU+ premium subscription',
    'live_tracking': 'Real-time rider location on map',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await FeatureFlagService.instance.load();
      if (mounted) {
        setState(() {
          _flags = Map<String, bool>.from(FeatureFlagService.instance.flags.value);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(String key, bool enabled) async {
    setState(() => _saving.add(key));
    try {
      await ApiClient.instance.patch(
        '/feature-flags/$key',
        body: {'enabled': enabled},
      );
      await FeatureFlagService.instance.load();
      if (mounted) {
        setState(() {
          _flags = Map<String, bool>.from(FeatureFlagService.instance.flags.value);
        });
        wbShowSnack(context, enabled ? '$key enabled' : '$key disabled');
      }
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    } catch (_) {
      if (mounted) wbShowSnack(context, 'Failed to update flag');
    } finally {
      if (mounted) setState(() => _saving.remove(key));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding, 12, WBSpacing.screenPadding, WBSpacing.md,
              ),
              child: Row(
                children: [
                  WBBackChip(onPressed: () => context.pop()),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dev Settings', style: WBTypography.page),
                        Text(
                          'Feature flag controls — admin only',
                          style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_loading)
              const Expanded(
                child: Center(
                  child: SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(WBColors.surfaceDark),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    WBSpacing.screenPadding, 0, WBSpacing.screenPadding, 40,
                  ),
                  children: [
                    if (_flags.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(WBSpacing.md),
                        decoration: BoxDecoration(
                          color: WBColors.bgSoft,
                          borderRadius: BorderRadius.circular(WBRadius.card),
                        ),
                        child: Text(
                          'No feature flags found. Make sure the API is running and seeded.',
                          style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
                        ),
                      )
                    else
                      WBCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (var i = 0; i < _flags.entries.length; i++) ...[
                              if (i > 0) const WBDivider(indent: 16, endIndent: 16),
                              _FlagRow(
                                flagKey: _flags.keys.elementAt(i),
                                enabled: _flags.values.elementAt(i),
                                description: _descriptions[_flags.keys.elementAt(i)],
                                saving: _saving.contains(_flags.keys.elementAt(i)),
                                onToggle: (v) => _toggle(_flags.keys.elementAt(i), v),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FlagRow extends StatelessWidget {
  const _FlagRow({
    required this.flagKey,
    required this.enabled,
    required this.saving,
    required this.onToggle,
    this.description,
  });

  final String flagKey;
  final bool enabled;
  final bool saving;
  final String? description;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flagKey,
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description!,
                    style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
                  ),
                ],
              ],
            ),
          ),
          if (saving)
            const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(WBColors.surfaceDark),
              ),
            )
          else
            Switch.adaptive(
              value: enabled,
              activeThumbColor: WBColors.surfaceDark,
              onChanged: onToggle,
            ),
        ],
      ),
    );
  }
}
