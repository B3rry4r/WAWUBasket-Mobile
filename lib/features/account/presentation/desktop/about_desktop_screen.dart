import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';

/// Desktop-web layout for the About screen. Isolated from the mobile build:
/// reuses the exact same l10n keys, copy, rows and actions as [AboutScreen],
/// re-laid-out as a centered, readable document column inside the shared
/// [CustomerWebScaffold] chrome.
class AboutDesktopScreen extends StatelessWidget {
  const AboutDesktopScreen({super.key});

  List<({WBIconName icon, String label, String sub})> _rows(BuildContext context) => [
    (icon: WBIconName.message, label: context.l10n.aboutSendFeedback, sub: context.l10n.aboutSendFeedbackSub),
    (icon: WBIconName.card, label: context.l10n.aboutTerms, sub: context.l10n.aboutTermsSub),
    (icon: WBIconName.user, label: context.l10n.aboutPrivacy, sub: context.l10n.aboutPrivacySub),
  ];

  List<(String, String)> _userSteps(BuildContext context) => [
    (context.l10n.aboutStep1Title, context.l10n.aboutStep1Body),
    (context.l10n.aboutStep2Title, context.l10n.aboutStep2Body),
    (context.l10n.aboutStep3Title, context.l10n.aboutStep3Body),
  ];

  List<(String, String)> _vendorSteps(BuildContext context) => [
    (context.l10n.aboutVendorStep1Title, context.l10n.aboutVendorStep1Body),
    (context.l10n.aboutVendorStep2Title, context.l10n.aboutVendorStep2Body),
    (context.l10n.aboutVendorStep3Title, context.l10n.aboutVendorStep3Body),
  ];

  Widget _stepsCard(BuildContext context, List<(String, String)> steps) {
    return WBCard(
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
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
                        steps[i].$1,
                        style: WBTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        steps[i].$2,
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (i != steps.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows(context);
    return CustomerWebScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          WBSpacing.lg,
          WBSpacing.screenPadding,
          40,
        ),
        child: WBMaxWidth(
          maxWidth: 720,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  WBBackChip(onPressed: () => context.pop()),
                  const SizedBox(width: 14),
                  Text(context.l10n.aboutTitle, style: WBTypography.page),
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
                      'We\'re building the infrastructure for African commerce.',
                      style: WBTypography.hero.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.aboutTagline,
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
                      'Version 1.0.0',
                      style: WBTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: WBSpacing.lg),
              Text(
                context.l10n.aboutHowItWorks,
                style: WBTypography.cardTitle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              _stepsCard(context, _userSteps(context)),
              const SizedBox(height: WBSpacing.lg),
              Text(
                context.l10n.aboutSellOn,
                style: WBTypography.cardTitle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              _stepsCard(context, _vendorSteps(context)),
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
                    for (var i = 0; i < rows.length; i++)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (i == 0) {
                            wbLaunchEmail(context, 'support@wawu.africa');
                          } else if (i == 1) {
                            context.push(AppRoutes.terms);
                          } else {
                            context.push(AppRoutes.privacy);
                          }
                        },
                        child: Padding(
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
                                child: WBIcon(rows[i].icon, size: 17),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rows[i].label,
                                      style: WBTypography.body.copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      rows[i].sub,
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
                      ),
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
