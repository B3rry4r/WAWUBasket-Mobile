import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _rows = [
    (icon: WBIconName.message, label: 'Send feedback', sub: 'Help us improve'),
    (icon: WBIconName.card, label: 'Terms of service', sub: 'The rules of the basket'),
    (icon: WBIconName.user, label: 'Privacy policy', sub: 'How we handle your info'),
  ];

  static const _userSteps = [
    ('Browse', 'Pick what you want from restaurants, produce, livestock, or essentials.'),
    ('Checkout', 'Choose when you want it and how you\'ll pay.'),
    ('Track', 'Watch your basket come to life, then enjoy.'),
  ];

  static const _vendorSteps = [
    ('Sign up', 'Tell us about your business. Let\'s have some documents sorted.'),
    ('List your products', 'Add photos, prices, and descriptions.'),
    ('Start selling', 'Get orders, prepare food, and grow.'),
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
                    "We're WAWUBasket — offspring of WAWAfrica.",
                    style: WBTypography.hero.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'One basket. Everything.',
                    style: WBTypography.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'We started WAWUBasket because we noticed something strange. '
                    'You could order a hot meal in minutes. You could order groceries '
                    'in an hour. But if you wanted fresh tomatoes, cut chicken, and a '
                    'new pot to cook it in? That was three different apps. Or a trip to '
                    'three different markets.\n\n'
                    'So we built one basket. One place where you can get everything for '
                    'the meal you\'re dreaming of. Restaurants. Fresh produce. Meat and '
                    'fish. Kitchen essentials. All in one cart. All delivered fast.\n\n'
                    "We're not trying to be fancy. We're trying to be useful. We want "
                    'you to spend less time running around and more time doing what '
                    'matters — cooking, eating, sharing.\n\n'
                    "Welcome to WAWUBasket. Let's fill your basket.",
                    style: WBTypography.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Version 2.1.0 · Build 2046',
                    style: WBTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            Text(
              'Three steps to a full basket',
              style: WBTypography.cardTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 10),
            WBCard(
              child: Column(
                children: [
                  for (var i = 0; i < _userSteps.length; i++) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: WBColors.bgSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${i + 1}',
                            style: WBTypography.label.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userSteps[i].$1,
                                style: WBTypography.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _userSteps[i].$2,
                                style: WBTypography.caption.copyWith(
                                  color: WBColors.fgSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (i != _userSteps.length - 1) const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            Text(
              'Sell on WAWUBasket',
              style: WBTypography.cardTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 10),
            WBCard(
              child: Column(
                children: [
                  for (var i = 0; i < _vendorSteps.length; i++) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: WBColors.bgSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${i + 1}',
                            style: WBTypography.label.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _vendorSteps[i].$1,
                                style: WBTypography.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _vendorSteps[i].$2,
                                style: WBTypography.caption.copyWith(
                                  color: WBColors.fgSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (i != _vendorSteps.length - 1) const SizedBox(height: 14),
                  ],
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
