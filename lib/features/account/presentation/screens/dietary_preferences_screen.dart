import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';

/// Dietary preferences — things the customer would rather not eat. Drives
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

  static const _options = [
    'No beef',
    'No pork',
    'No shellfish',
    'Halal only',
    'Vegetarian',
    'Vegan',
    'No dairy',
    'No nuts',
    'Low sugar',
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
                          Text('Dietary preferences',
                              style: WBTypography.page),
                          Text(
                            "Things you'd rather not eat.",
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
                    for (final o in _options)
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
                  'Anything else?',
                  style: WBTypography.cardTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 10),
                WBInput(
                  controller: _custom,
                  placeholder: 'e.g. no MSG, no palm oil',
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
                    label: 'Save preferences',
                    fullWidth: true,
                    size: WBButtonSize.lg,
                    onPressed: () {
                      wbShowSnack(context, 'Dietary preferences saved');
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
