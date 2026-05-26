import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';

/// Dietary preferences, things the customer would rather not eat. Drives
/// what gets surfaced first across the catalogue (UI-only here).
class DietaryPreferencesScreen extends StatefulWidget {
  const DietaryPreferencesScreen({super.key});

  @override
  State<DietaryPreferencesScreen> createState() =>
      _DietaryPreferencesScreenState();
}

class _DietaryPreferencesScreenState extends State<DietaryPreferencesScreen> {
  final Set<String> _selected = {};
  final _custom = TextEditingController();

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
                    onPressed: () {
                      wbShowSnack(context, context.l10n.dietarySaved);
                      context.pop();
                    },
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
