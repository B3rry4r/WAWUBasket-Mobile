import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../home/presentation/widgets/search_field.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const _faqs = [
    (
      q: 'How do I track my order?',
      a: 'Open the order from your Orders tab and tap Track order.',
    ),
    (
      q: 'Can I cancel after placing?',
      a: 'Within 2 minutes of placing, cancellations are free. After that, a ₦200 fee applies.',
    ),
    (
      q: 'My order arrived wrong',
      a: "Tap Report an issue on the order receipt and we'll resolve it within 24 hrs.",
    ),
    (
      q: 'How long does delivery take?',
      a: 'Typically 20–45 minutes depending on your distance from the vendor.',
    ),
  ];

  static const _contacts = [
    (
      icon: WBIconName.message,
      label: 'Live chat',
      sub: 'Usually replies in under 2 min',
      cta: 'Start chat',
    ),
    (
      icon: WBIconName.phone,
      label: 'Call us',
      sub: '+234 800 WAWUBasket',
      cta: 'Call',
    ),
    (
      icon: WBIconName.bell,
      label: 'Email us',
      sub: 'support@wawu.africa',
      cta: 'Send email',
    ),
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
                Text('Help & support', style: WBTypography.page),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            // FAQ search
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: WBColors.surfaceCard,
                borderRadius: BorderRadius.circular(WBRadius.input),
                boxShadow: WBShadows.card,
              ),
              child: Row(
                children: [
                  const WBIcon(
                    WBIconName.search,
                    size: 20,
                    color: WBColors.fgPlaceholder,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Search help articles',
                    style: WBTypography.body.copyWith(
                      color: WBColors.fgPlaceholder,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            Text(
              'CONTACT US',
              style: WBTypography.label.copyWith(
                fontWeight: FontWeight.w600,
                color: WBColors.fgPlaceholder,
                letterSpacing: 0.66,
              ),
            ),
            const SizedBox(height: 10),
            for (final c in _contacts) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: WBColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: WBShadows.card,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: WBColors.bgSoft,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: WBIcon(c.icon, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.label,
                            style: WBTypography.body.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            c.sub,
                            style: WBTypography.caption.copyWith(
                              color: WBColors.fgSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    WBButton(
                      label: c.cta,
                      size: WBButtonSize.sm,
                      onPressed: () {
                        if (c.icon == WBIconName.message) {
                          context.push(AppRoutes.chatSupport);
                        } else if (c.icon == WBIconName.phone) {
                          wbShowSnack(context, 'Calling +234 800 WAWUBasket…');
                        } else {
                          wbShowSnack(context, 'Email to support@wawu.africa');
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: WBSpacing.md),
            const SectionHeader(title: 'Common questions', action: 'See all'),
            const SizedBox(height: WBSpacing.sm + 2),
            Container(
              decoration: BoxDecoration(
                color: WBColors.surfaceCard,
                borderRadius: BorderRadius.circular(WBRadius.card),
                boxShadow: WBShadows.card,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < _faqs.length; i++) ...[
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => wbShowSnack(context, _faqs[i].q),
                      child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  _faqs[i].q,
                                  style: WBTypography.body.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const WBIcon(
                                WBIconName.chevronRight,
                                size: 16,
                                color: WBColors.fgPlaceholder,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _faqs[i].a,
                            style: WBTypography.caption.copyWith(
                              color: WBColors.fgSecondary,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                      ),
                    ),
                    if (i != _faqs.length - 1) const WBDivider(),
                  ],
                ],
              ),
            ),
            const SizedBox(height: WBSpacing.md),
            // Active ticket
            Container(
              padding: const EdgeInsets.all(WBSpacing.md + 2),
              decoration: BoxDecoration(
                color: WBColors.surfaceCard,
                borderRadius: BorderRadius.circular(WBRadius.card),
                boxShadow: WBShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'OPEN TICKET',
                        style: WBTypography.label.copyWith(
                          fontWeight: FontWeight.w600,
                          color: WBColors.fgPlaceholder,
                          letterSpacing: 0.66,
                        ),
                      ),
                      const WBStatusPill(
                        label: 'Pending',
                        kind: WBStatusKind.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Missing item — Order #8804',
                    style: WBTypography.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Opened Mon 12 May. Our team will respond within 24 hrs.',
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  WBButton(
                    label: 'View ticket',
                    variant: WBButtonVariant.secondary,
                    size: WBButtonSize.sm,
                    onPressed: () => context.push(AppRoutes.chatSupport),
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
