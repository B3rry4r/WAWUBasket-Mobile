import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../data/orders_api.dart';

/// Shown when an order reaches the delivered state.
/// Lets the customer rate their experience and optionally tip the rider.
class DeliveryCompleteScreen extends StatefulWidget {
  const DeliveryCompleteScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<DeliveryCompleteScreen> createState() => _DeliveryCompleteScreenState();
}

class _DeliveryCompleteScreenState extends State<DeliveryCompleteScreen> {
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
      wbShowSnack(context, 'Tap a star to rate your order.');
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
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        child: _submitted ? _ThankYouBody(orderId: widget.orderId) : _RatingBody(
          stars: _stars,
          reviewCtrl: _reviewCtrl,
          submitting: _submitting,
          onStarTap: (s) => setState(() => _stars = s),
          onSubmit: _submit,
          onSkip: () => context.go(AppRoutes.home),
        ),
      ),
    );
  }
}

class _RatingBody extends StatelessWidget {
  const _RatingBody({
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        WBSpacing.screenPadding,
        WBSpacing.xl,
        WBSpacing.screenPadding,
        WBSpacing.xl,
      ),
      children: [
        const SizedBox(height: WBSpacing.lg),
        Text(
          'Delivered. Enjoy your basket!',
          style: WBTypography.hero.copyWith(fontSize: 28, height: 1.2),
        ),
        const SizedBox(height: WBSpacing.sm),
        Text(
          'How was your experience? Your feedback helps vendors and riders do better.',
          style: WBTypography.body.copyWith(
            color: WBColors.fgSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: WBSpacing.xl),
        Text(
          'Rate this order',
          style: WBTypography.cardTitle.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 1; i <= 5; i++)
              GestureDetector(
                onTap: () => onStarTap(i),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AnimatedContainer(
                    duration: WBMotion.base,
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: i <= stars
                          ? WBColors.surfaceDark
                          : WBColors.bgSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$i',
                      style: WBTypography.body.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: i <= stars
                            ? Colors.white
                            : WBColors.fgSecondary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (stars > 0) ...[
          const SizedBox(height: WBSpacing.sm),
          Center(
            child: Text(
              _ratingLabel(stars),
              style: WBTypography.caption.copyWith(
                color: WBColors.fgSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        const SizedBox(height: WBSpacing.lg),
        Text(
          'Tell us more (optional)',
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
              hintText: 'What made it great or not so great?',
              hintStyle: WBTypography.body.copyWith(
                color: WBColors.fgPlaceholder,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: WBSpacing.xl),
        WBButton(
          label: 'Submit rating',
          size: WBButtonSize.lg,
          fullWidth: true,
          trailingIcon: WBIconName.arrowRight,
          loading: submitting,
          disabled: submitting,
          onPressed: onSubmit,
        ),
        const SizedBox(height: WBSpacing.sm + 4),
        Center(
          child: GestureDetector(
            onTap: submitting ? null : onSkip,
            child: Text(
              'Skip for now',
              style: WBTypography.secondary.copyWith(
                color: WBColors.fgSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _ratingLabel(int s) => switch (s) {
        1 => 'Not great',
        2 => 'Could be better',
        3 => 'It was okay',
        4 => 'Pretty good!',
        _ => 'Loved it!',
      };
}

class _ThankYouBody extends StatelessWidget {
  const _ThankYouBody({required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        WBSpacing.screenPadding,
        WBSpacing.xl,
        WBSpacing.screenPadding,
        WBSpacing.xl,
      ),
      child: Column(
        children: [
          const Spacer(),
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
            'Thanks for the feedback!',
            textAlign: TextAlign.center,
            style: WBTypography.hero.copyWith(fontSize: 28),
          ),
          const SizedBox(height: WBSpacing.sm),
          Text(
            'Your rating helps the whole basket get better. See you next time.',
            textAlign: TextAlign.center,
            style: WBTypography.body.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const Spacer(),
          WBButton(
            label: 'Back to home',
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
