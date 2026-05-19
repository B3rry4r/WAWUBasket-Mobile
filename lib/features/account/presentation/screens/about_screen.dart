import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _rows = [
    (icon: WBIconName.message, label: 'Send feedback', sub: 'Help us improve'),
    (icon: WBIconName.card, label: 'Terms of service', sub: 'Read terms'),
    (icon: WBIconName.user, label: 'Privacy policy', sub: 'How we handle data'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            12,
            WBSpacing.screenPadding,
            40,
          ),
          children: [
            Row(
              children: [
                WBBackChip(onPressed: () => context.pop()),
                const SizedBox(width: 14),
                Text('About WAWUBasket', style: WBTypography.page),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            Container(
              padding: const EdgeInsets.all(WBSpacing.lg),
              decoration: BoxDecoration(
                color: WBColors.surfaceDark,
                borderRadius: BorderRadius.circular(WBRadius.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WAWUBasket',
                    style: WBTypography.hero.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'One basket. Everything. Restaurants, fresh produce, '
                    'livestock and kitchen essentials — delivered fast.',
                    style: WBTypography.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Version 2.1.0 · Build 2046',
                    style: WBTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            Container(
              decoration: BoxDecoration(
                color: WBColors.surfaceCard,
                borderRadius: BorderRadius.circular(WBRadius.card),
                boxShadow: WBShadows.card,
              ),
              padding: const EdgeInsets.symmetric(horizontal: WBSpacing.md),
              child: Column(
                children: [
                  for (var i = 0; i < _rows.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: WBColors.bgSoft,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: WBIcon(_rows[i].icon, size: 17),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _rows[i].label,
                                  style: WBTypography.body.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  _rows[i].sub,
                                  style: WBTypography.caption.copyWith(
                                    color: WBColors.fgSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const WBIcon(
                            WBIconName.chevronRight,
                            size: 16,
                            color: WBColors.fgPlaceholder,
                          ),
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
