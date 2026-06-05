import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';
import '../../data/orders_api.dart';

/// Desktop-web layout for the delivery-complete flow. Mirrors the mobile
/// [DeliveryCompleteScreen] business logic exactly (rate + optional review via
/// [OrdersApi.rate]) but re-lays-out as a calm, centered single column inside
/// the persistent [CustomerWebScaffold] chrome. Desktop-only; the mobile build
/// never imports this.
class DeliveryCompleteDesktopScreen extends StatefulWidget {
  const DeliveryCompleteDesktopScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<DeliveryCompleteDesktopScreen> createState() =>
      _DeliveryCompleteDesktopScreenState();
}

class _DeliveryCompleteDesktopScreenState
    extends State<DeliveryCompleteDesktopScreen> {
  int _stars = 0;
  final _reviewCtrl = TextEditingController();
  bool _submitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_stars == 0) {
      wbShowSnack(context, context.l10n.deliveryRateError);
      return;
    }
    setState(() => _submitting = true);
    try {
      await OrdersApi.instance.rate(
        widget.orderId,
        _stars,
        review: _reviewCtrl.text.trim().isNotEmpty
            ? _reviewCtrl.text.trim()
            : null,
      );
      if (mounted) setState(() => _submitted = true);
    } on ApiException catch (e) {
      if (mounted) wbShowSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomerWebScaffold(
      showSearch: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: WBSpacing.xl),
        child: Center(
          child: WBMaxWidth(
            maxWidth: WBBreakpoints.maxReading,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: WBSpacing.screenPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: WBBackChip(
                      onPressed: () => context.go(AppRoutes.home),
                    ),
                  ),
                  const SizedBox(height: WBSpacing.lg),
                  if (_submitted)
                    _ThankYouCard(orderId: widget.orderId)
                  else
                    _RatingCard(
                      stars: _stars,
                      reviewCtrl: _reviewCtrl,
                      submitting: _submitting,
                      onStarTap: (s) => setState(() => _stars = s),
                      onSubmit: _submit,
                      onSkip: () => context.go(AppRoutes.home),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({
    required this.stars,
    required this.reviewCtrl,
    required this.submitting,
    required this.onStarTap,
    required this.onSubmit,
    required this.onSkip,
  });

  final int stars;
  final TextEditingController reviewCtrl;
  final bool submitting;
  final ValueChanged<int> onStarTap;
  final VoidCallback onSubmit;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WBColors.bgPrimary,
        borderRadius: BorderRadius.circular(WBRadius.card),
        boxShadow: WBShadows.card,
      ),
      padding: const EdgeInsets.all(WBSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.deliveryTitle,
            textAlign: TextAlign.center,
            style: WBTypography.hero.copyWith(fontSize: 28, height: 1.2),
          ),
          const SizedBox(height: WBSpacing.sm),
          Text(
            context.l10n.deliverySubtitle,
            textAlign: TextAlign.center,
            style: WBTypography.body.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: WBSpacing.xl),
          Text(
            context.l10n.deliveryRateTitle,
            textAlign: TextAlign.center,
            style: WBTypography.cardTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                _StarTile(
                  value: i,
                  active: i <= stars,
                  onTap: () => onStarTap(i),
                ),
            ],
          ),
          if (stars > 0) ...[
            const SizedBox(height: WBSpacing.sm),
            Center(
              child: Text(
                _ratingLabel(stars, context),
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const SizedBox(height: WBSpacing.lg),
          Text(
            context.l10n.deliveryFeedbackTitle,
            style: WBTypography.cardTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: WBColors.surfaceInput,
              borderRadius: BorderRadius.circular(WBRadius.input),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: TextField(
              controller: reviewCtrl,
              maxLines: 3,
              style: WBTypography.body.copyWith(fontSize: 15),
              decoration: InputDecoration.collapsed(
                hintText: context.l10n.deliveryFeedbackPlaceholder,
                hintStyle: WBTypography.body.copyWith(
                  color: WBColors.fgPlaceholder,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: WBSpacing.xl),
          WBButton(
            label: context.l10n.deliverySubmit,
            size: WBButtonSize.lg,
            fullWidth: true,
            trailingIcon: WBIconName.arrowRight,
            loading: submitting,
            disabled: submitting,
            onPressed: onSubmit,
          ),
          const SizedBox(height: WBSpacing.sm + 4),
          Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: submitting ? null : onSkip,
                child: Text(
                  context.l10n.deliverySkip,
                  style: WBTypography.secondary.copyWith(
                    color: WBColors.fgSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _ratingLabel(int s, BuildContext context) => switch (s) {
        1 => context.l10n.deliveryRatingBad,
        2 => context.l10n.deliveryRatingFair,
        3 => context.l10n.deliveryRatingOkay,
        4 => context.l10n.deliveryRatingGood,
        _ => context.l10n.deliveryRatingLove,
      };
}

class _StarTile extends StatelessWidget {
  const _StarTile({
    required this.value,
    required this.active,
    required this.onTap,
  });

  final int value;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: AnimatedContainer(
            duration: WBMotion.base,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: active ? WBColors.surfaceDark : WBColors.bgSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              '$value',
              style: WBTypography.body.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: active ? Colors.white : WBColors.fgSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThankYouCard extends StatelessWidget {
  const _ThankYouCard({required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WBColors.bgPrimary,
        borderRadius: BorderRadius.circular(WBRadius.card),
        boxShadow: WBShadows.card,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: WBSpacing.xl,
        vertical: WBSpacing.xl + WBSpacing.lg,
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: WBColors.surfaceDark,
              borderRadius: BorderRadius.circular(26),
            ),
            alignment: Alignment.center,
            child: const WBIcon(WBIconName.star, size: 36, color: Colors.white),
          ),
          const SizedBox(height: WBSpacing.xl),
          Text(
            context.l10n.deliveryThankYou,
            textAlign: TextAlign.center,
            style: WBTypography.hero.copyWith(fontSize: 28),
          ),
          const SizedBox(height: WBSpacing.sm),
          Text(
            context.l10n.deliveryThankYouBody,
            textAlign: TextAlign.center,
            style: WBTypography.body.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: WBSpacing.xl + WBSpacing.lg),
          WBButton(
            label: context.l10n.deliveryBackHome,
            size: WBButtonSize.lg,
            fullWidth: true,
            trailingIcon: WBIconName.arrowRight,
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
    );
  }
}
