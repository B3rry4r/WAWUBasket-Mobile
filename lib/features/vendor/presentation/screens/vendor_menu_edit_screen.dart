import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';

class VendorMenuEditScreen extends StatefulWidget {
  const VendorMenuEditScreen({super.key});

  @override
  State<VendorMenuEditScreen> createState() => _VendorMenuEditScreenState();
}

class _VendorMenuEditScreenState extends State<VendorMenuEditScreen> {
  bool _available = true;
  double _prep = 15;

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
                    Text('Add a new dish', style: WBTypography.page),
                  ],
                ),
                const SizedBox(height: WBSpacing.lg),
                GestureDetector(
                  onTap: () =>
                      wbShowSnack(context, 'Pick a photo from your camera'),
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: WBColors.bgSoft,
                      borderRadius: BorderRadius.circular(WBRadius.card),
                      border: Border.all(
                        color: WBColors.bgDivider,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: WBColors.bgPrimary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const WBIcon(WBIconName.plus, size: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Upload photo',
                          style: WBTypography.body.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap to add — at least one shot',
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: WBSpacing.lg),
                const WBInput(label: 'Dish name', placeholder: 'e.g. Jollof rice'),
                const SizedBox(height: WBSpacing.md),
                const WBInput(
                  label: 'Description',
                  placeholder: 'Tasty, spicy, fresh…',
                ),
                const SizedBox(height: WBSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: WBInput(
                        label: 'Price (₦)',
                        placeholder: '0',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: WBInput(
                        label: 'Category',
                        initialValue: 'Mains',
                        trailing: WBIcon(WBIconName.chevronDown, size: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: WBSpacing.lg),
                Text(
                  'PREP TIME · ${_prep.toInt()} min',
                  style: WBTypography.label.copyWith(
                    fontWeight: FontWeight.w600,
                    color: WBColors.fgPlaceholder,
                    letterSpacing: 0.66,
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: WBColors.surfaceDark,
                    inactiveTrackColor: WBColors.bgDivider,
                    thumbColor: WBColors.surfaceDark,
                    overlayColor:
                        WBColors.surfaceDark.withValues(alpha: 0.1),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: _prep,
                    min: 5,
                    max: 60,
                    divisions: 11,
                    onChanged: (v) => setState(() => _prep = v),
                  ),
                ),
                const SizedBox(height: WBSpacing.md),
                WBCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available',
                              style: WBTypography.body.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Toggle off to hide this dish.',
                              style: WBTypography.caption.copyWith(
                                color: WBColors.fgSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _available,
                        activeThumbColor: WBColors.surfaceDark,
                        onChanged: (v) => setState(() => _available = v),
                      ),
                    ],
                  ),
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
                    label: 'Save dish',
                    fullWidth: true,
                    size: WBButtonSize.lg,
                    onPressed: () {
                      wbShowSnack(context, 'Dish saved');
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
