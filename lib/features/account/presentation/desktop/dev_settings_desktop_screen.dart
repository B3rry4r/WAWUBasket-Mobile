import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/services/feature_flag_service.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';

/// Desktop-web layout for [DevSettingsScreen]. Same admin gate, same
/// feature-flag controller calls, same rows — re-laid-out as a centered
/// settings column inside the customer web chrome. Renders only at >=1024.
/// Isolated from the mobile build; the mobile screen is untouched.
class DevSettingsDesktopScreen extends StatefulWidget {
  const DevSettingsDesktopScreen({super.key});

  @override
  State<DevSettingsDesktopScreen> createState() =>
      _DevSettingsDesktopScreenState();
}

class _DevSettingsDesktopScreenState extends State<DevSettingsDesktopScreen> {
  Map<String, bool> _flags = {};
  bool _loading = true;
  final Set<String> _saving = {};

  // Only home UI flags belong here. App-level features (cross_border_trading,
  // wawu_plus, live_tracking) are always on and not togglable from this screen.
  static const _uiFlags = {'new_categories_ui', 'recipe_combos'};

  static const _descriptions = <String, String>{
    'new_categories_ui':
        'Redesigned home categories grid (toggle off = old 3×3 layout)',
    'recipe_combos': 'Meal Kits / Recipe Combo Intelligence rail on home',
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
    // Defense-in-depth: the profile entry is already admin-gated, but block
    // direct deep-links to this route for anyone without the admin role.
    if (RoleController.instance.statusOf(AppRole.admin) != RoleStatus.approved) {
      return CustomerWebScaffold(
        child: WBMaxWidth(
          maxWidth: 640,
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding, 24, WBSpacing.screenPadding, 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WBBackChip(onPressed: () => context.pop()),
              const SizedBox(height: 80),
              Center(
                child: Text(
                  "You don't have access to this screen.",
                  style: WBTypography.body,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CustomerWebScaffold(
      child: WBMaxWidth(
        maxWidth: 640,
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.screenPadding, 24, WBSpacing.screenPadding, 40,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WBBackChip(onPressed: () => context.pop()),
              const SizedBox(height: WBSpacing.md),
              Text('Dev Settings', style: WBTypography.page),
              Text(
                'Feature flag controls — admin only',
                style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
              ),
              const SizedBox(height: WBSpacing.lg),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
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
              else if (_flags.isEmpty)
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
                      for (final entry in _flags.entries
                          .where((e) => _uiFlags.contains(e.key))
                          .toList()
                          .asMap()
                          .entries) ...[
                        if (entry.key > 0)
                          const WBDivider(indent: 16, endIndent: 16),
                        _FlagRow(
                          flagKey: entry.value.key,
                          enabled: entry.value.value,
                          description: _descriptions[entry.value.key],
                          saving: _saving.contains(entry.value.key),
                          onToggle: (v) => _toggle(entry.value.key, v),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
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
