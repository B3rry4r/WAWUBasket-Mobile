import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../data/account_extras_api.dart';

/// WAWU+ subscription screen, benefits, monthly/yearly pricing, trial CTA.
class WawuPlusScreen extends StatefulWidget {
  const WawuPlusScreen({super.key});

  @override
  State<WawuPlusScreen> createState() => _WawuPlusScreenState();
}

class _WawuPlusScreenState extends State<WawuPlusScreen> {
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

  Future<void> _startTrial() async {
    setState(() => _busy = true);
    try {
      await AccountExtrasApi.instance
          .startTrial(_yearly ? 'yearly' : 'monthly');
      if (!mounted) return;
      wbShowSnack(
        context,
        'WAWU+ trial started · ${_yearly ? 'yearly' : 'monthly'} plan',
      );
      context.pop();
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static const _benefits = [
    'Up to 50% off delivery on every order',
    'Member-only deals every week',
    'Priority support, skip the line',
    'Free returns on wrong items',
    'Early access to new features',
  ];

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
                    Text('WAWU+', style: WBTypography.page),
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
                        'Go plus. Go more.',
                        style: WBTypography.hero.copyWith(
                          color: Colors.white,
                          fontSize: 26,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Discounted delivery. Exclusive treats. Priority support.',
                        style: WBTypography.body.copyWith(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: WBSpacing.md),
                      Text(
                        'Join 12,400 other happy baskets',
                        style: WBTypography.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: WBSpacing.lg),
                Text(
                  "What's included",
                  style: WBTypography.cardTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 10),
                WBCard(
                  child: Column(
                    children: [
                      for (var i = 0; i < _benefits.length; i++) ...[
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
                                _benefits[i],
                                style: WBTypography.body.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (i != _benefits.length - 1)
                          const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: WBSpacing.lg),
                Text(
                  'Pick a plan',
                  style: WBTypography.cardTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 10),
                _PlanCard(
                  title: 'Yearly',
                  price: '₦18,000/year',
                  note: 'Save 20% · billed once',
                  selected: _yearly,
                  onTap: () => setState(() => _yearly = true),
                ),
                const SizedBox(height: 10),
                _PlanCard(
                  title: 'Monthly',
                  price: '₦1,800/month',
                  note: 'Cancel anytime',
                  selected: !_yearly,
                  onTap: () => setState(() => _yearly = false),
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
                    label: _active
                        ? "You're a WAWU+ member"
                        : 'Start free trial, 7 days',
                    fullWidth: true,
                    size: WBButtonSize.lg,
                    trailingIcon:
                        _active ? WBIconName.check : WBIconName.arrowRight,
                    loading: _busy,
                    disabled: _active,
                    onPressed: _active ? null : _startTrial,
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
