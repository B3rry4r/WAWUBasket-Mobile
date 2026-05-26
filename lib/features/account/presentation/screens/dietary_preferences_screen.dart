import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../data/profile_api.dart';

/// Dietary preferences, things the customer would rather not eat. Drives
/// what gets surfaced first across the catalogue.
class DietaryPreferencesScreen extends StatefulWidget {
  const DietaryPreferencesScreen({super.key});

  @override
  State<DietaryPreferencesScreen> createState() =>
      _DietaryPreferencesScreenState();
}

class _DietaryPreferencesScreenState extends State<DietaryPreferencesScreen> {
  final Set<String> _selected = {};
  final _custom = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  List<String> _options(BuildContext context) => [
    context.l10n.dietaryNoBeef,
    context.l10n.dietaryNoPork,
    context.l10n.dietaryNoShellfish,
    context.l10n.dietaryHalal,
    context.l10n.dietaryVegetarian,
    context.l10n.dietaryVegan,
    context.l10n.dietaryNoDairy,
    context.l10n.dietaryNoNuts,
    context.l10n.dietaryLowSugar,
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await ProfileApi.instance.getDietaryPreferences();
      if (mounted) {
        setState(() {
          _selected.addAll(prefs);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final all = List<String>.from(_selected);
      final custom = _custom.text.trim();
      if (custom.isNotEmpty) all.add(custom);
      await ProfileApi.instance.saveDietaryPreferences(all);
      if (mounted) {
        wbShowSnack(context, context.l10n.dietarySaved);
        context.pop();
      }
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    } catch (_) {
      if (mounted) wbShowSnack(context, context.l10n.dietarySaved);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                12,
                WBSpacing.screenPadding,
                140,
              ),
              children: [
                Row(
                  children: [
                    WBBackChip(onPressed: () => context.pop()),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.dietaryTitle,
                              style: WBTypography.page),
                          Text(
                            context.l10n.dietarySubtitle,
                            style: WBTypography.caption.copyWith(
                              color: WBColors.fgSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: WBSpacing.lg),
                if (_loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor:
                              AlwaysStoppedAnimation(WBColors.surfaceDark),
                        ),
                      ),
                    ),
                  )
                else ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final o in _options(context))
                        WBTag(
                          label: o,
                          active: _selected.contains(o),
                          onTap: () => setState(() {
                            _selected.contains(o)
                                ? _selected.remove(o)
                                : _selected.add(o);
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: WBSpacing.lg),
                  Text(
                    context.l10n.dietaryAnythingElse,
                    style: WBTypography.cardTitle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  WBInput(
                    controller: _custom,
                    placeholder: context.l10n.dietaryCustomPlaceholder,
                  ),
                ],
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    WBSpacing.screenPadding,
                    0,
                    WBSpacing.screenPadding,
                    20,
                  ),
                  child: WBButton(
                    label: context.l10n.dietarySave,
                    fullWidth: true,
                    size: WBButtonSize.lg,
                    loading: _saving,
                    onPressed: _loading ? null : _save,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
