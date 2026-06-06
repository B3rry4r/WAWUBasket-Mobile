import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';
import '../../data/account_extras_api.dart';
import '../../data/iap_service.dart';

/// Desktop-web layout for the WAWU+ subscription screen. Mirrors
/// [WawuPlusScreen] behavior (status load, monthly/yearly toggle, trial CTA,
/// IAP subscribe) but re-lays the content into a centered settings column
/// inside the shared [CustomerWebScaffold]. Desktop-only; the mobile build
/// never imports this file.
class WawuPlusDesktopScreen extends StatefulWidget {
  const WawuPlusDesktopScreen({super.key});

  @override
  State<WawuPlusDesktopScreen> createState() => _WawuPlusDesktopScreenState();
}

class _WawuPlusDesktopScreenState extends State<WawuPlusDesktopScreen> {
  bool _yearly = true;
  bool _busy = false;
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final s = await AccountExtrasApi.instance.subscriptionStatus();
      if (mounted) setState(() => _active = s['active'] == true);
    } on ApiException {
      // Non-critical — leave the CTA as the trial offer.
    }
  }

  Future<void> _subscribe() async {
    if (kIsWeb) {
      wbShowSnack(context, context.l10n.wawuPlusWebOnly);
      return;
    }
    setState(() => _busy = true);
    try {
      await WawuPlusIap.instance.buy(
        _yearly ? WawuPlusIap.yearlyId : WawuPlusIap.monthlyId,
      );
      if (!mounted) return;
      wbShowSnack(context, context.l10n.wawuPlusWelcome);
      context.pop();
    } on IapException catch (e) {
      if (mounted) wbShowError(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  List<String> _benefits(BuildContext context) => [
    context.l10n.wawuPlusBenefit1,
    context.l10n.wawuPlusBenefit2,
    context.l10n.wawuPlusBenefit3,
    context.l10n.wawuPlusBenefit4,
    context.l10n.wawuPlusBenefit5,
  ];

  @override
  Widget build(BuildContext context) {
    final benefits = _benefits(context);
    return CustomerWebScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: WBSpacing.screenPadding,
          vertical: WBSpacing.xl,
        ),
        child: WBMaxWidth(
          maxWidth: 640,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: WBBackChip(onPressed: () => context.pop()),
              ),
              const SizedBox(height: WBSpacing.md),
              Text(context.l10n.wawuPlusTitle, style: WBTypography.page),
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
                      context.l10n.wawuPlusHero,
                      style: WBTypography.hero.copyWith(
                        color: Colors.white,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.wawuPlusSubtitle,
                      style: WBTypography.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: WBSpacing.md),
                    Text(
                      context.l10n.wawuPlusMembers,
                      style: WBTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: WBSpacing.lg),
              Text(
                context.l10n.wawuPlusIncluded,
                style: WBTypography.cardTitle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              WBCard(
                child: Column(
                  children: [
                    for (var i = 0; i < benefits.length; i++) ...[
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: WBColors.bgSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const WBIcon(
                              WBIconName.check,
                              size: 13,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              benefits[i],
                              style: WBTypography.body.copyWith(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (i != benefits.length - 1)
                        const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: WBSpacing.lg),
              Text(
                context.l10n.wawuPlusPickPlan,
                style: WBTypography.cardTitle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              _PlanCard(
                title: context.l10n.wawuPlusYearly,
                price: '₦18,000/year',
                note: context.l10n.wawuPlusYearlyNote,
                selected: _yearly,
                onTap: () => setState(() => _yearly = true),
              ),
              const SizedBox(height: 10),
              _PlanCard(
                title: context.l10n.wawuPlusMonthly,
                price: '₦1,800/month',
                note: context.l10n.wawuPlusMonthlyNote,
                selected: !_yearly,
                onTap: () => setState(() => _yearly = false),
              ),
              const SizedBox(height: WBSpacing.xl),
              WBButton(
                label: _active
                    ? context.l10n.wawuPlusActiveMember
                    : context.l10n.wawuPlusStartTrial,
                fullWidth: true,
                size: WBButtonSize.lg,
                trailingIcon:
                    _active ? WBIconName.check : WBIconName.arrowRight,
                loading: _busy,
                disabled: _active,
                onPressed: _active ? null : _subscribe,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.note,
    required this.selected,
    required this.onTap,
  });
  final String title;
  final String price;
  final String note;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: WBMotion.base,
        padding: const EdgeInsets.all(WBSpacing.md),
        decoration: BoxDecoration(
          color: WBColors.surfaceCard,
          borderRadius: BorderRadius.circular(WBRadius.card),
          border: Border.all(
            color: selected ? WBColors.surfaceDark : WBColors.bgDivider,
            width: 1.5,
          ),
          boxShadow: WBShadows.card,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: WBTypography.body.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    note,
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: WBTypography.body.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? WBColors.surfaceDark : Colors.transparent,
                border: Border.all(
                  color: selected ? WBColors.surfaceDark : WBColors.bgDivider,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? const WBIcon(
                      WBIconName.check,
                      size: 12,
                      color: Colors.white,
                      strokeWidth: 2.5,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
