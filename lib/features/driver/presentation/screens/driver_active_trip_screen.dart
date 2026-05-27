import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../transport/application/transport_controller.dart';
import '../../../transport/domain/models/load_offer.dart';

/// Active trip screen, vertical checkpoint timeline, GPS-active banner,
/// masked-call trader. "Log checkpoint" advances state; the last
/// checkpoint marks the trip delivered.
///
/// StatefulWidget so [initState] reloads the active trip from the API
/// every time the tab is entered — prevents stale checkpoint state.
class DriverActiveTripScreen extends StatefulWidget {
  const DriverActiveTripScreen({super.key});

  @override
  State<DriverActiveTripScreen> createState() => _DriverActiveTripScreenState();
}

class _DriverActiveTripScreenState extends State<DriverActiveTripScreen> {
  @override
  void initState() {
    super.initState();
    TransportController.instance.loadActiveTrip();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ValueListenableBuilder(
        valueListenable: TransportController.instance.activeTrip,
        builder: (_, trip, _) {
          if (trip == null) return const _NoTrip();
          return _Body(trip: trip);
        },
      ),
    );
  }
}

class _NoTrip extends StatelessWidget {
  const _NoTrip();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        WBSpacing.screenPadding,
        12,
        WBSpacing.screenPadding,
        140,
      ),
      children: [
        Text('No active trip', style: WBTypography.page),
        const SizedBox(height: 4),
        Text(
          'Pick a load from your board to start.',
          style: WBTypography.body.copyWith(
            color: WBColors.fgSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: WBSpacing.lg),
        WBButton(
          label: 'Browse loads',
          fullWidth: true,
          size: WBButtonSize.lg,
          trailingIcon: WBIconName.arrowRight,
          onPressed: () => context.go(AppRoutes.driverHome),
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.trip});
  final LoadOffer trip;

  void _logCheckpoint(BuildContext context) {
    final wasFinal = trip.checkpointNames.length -
            trip.reachedCheckpoints.length ==
        1;
    TransportController.instance.logCheckpoint();
    if (wasFinal) {
      wbShowSnack(
        context,
        'Trip delivered · ${wbNaira(trip.offerNaira)} settled to your wallet',
      );
    } else {
      final next = trip.checkpointNames[trip.reachedCheckpoints.length];
      wbShowSnack(context, 'Heading to $next');
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = trip.reachedCheckpoints.length;
    final total = trip.checkpointNames.length;
    final delivered = trip.status == LoadStatus.delivered;
    final nextCheckpoint =
        progress >= total ? null : trip.checkpointNames[progress];

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            12,
            WBSpacing.screenPadding,
            160,
          ),
          children: [
            Text('Active trip', style: WBTypography.page),
            const SizedBox(height: 4),
            Text(
              '#${trip.id} · ${trip.traderName}',
              style: WBTypography.caption.copyWith(
                color: WBColors.fgSecondary,
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            _Hero(trip: trip),
            const SizedBox(height: WBSpacing.lg),
            _GpsBanner(),
            const SizedBox(height: WBSpacing.lg),
            _SectionLabel('Checkpoints'),
            const SizedBox(height: 10),
            WBCard(
              child: Column(
                children: [
                  for (var i = 0; i < trip.checkpointNames.length; i++)
                    _CheckpointRow(
                      label: trip.checkpointNames[i],
                      reached: i < progress,
                      isNext: i == progress,
                      isLast: i == trip.checkpointNames.length - 1,
                    ),
                ],
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            _SectionLabel('Trader'),
            const SizedBox(height: 10),
            WBCard(
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: WBColors.bgSoft,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const WBIcon(WBIconName.user, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.traderName,
                          style: WBTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap to call (masked)',
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  WBButton(
                    label: 'Call',
                    size: WBButtonSize.sm,
                    variant: WBButtonVariant.secondary,
                    trailingIcon: WBIconName.phone,
                    onPressed: () =>
                        wbShowSnack(context, 'Calling ${trip.traderName}…'),
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
                18,
              ),
              child: WBButton(
                label: delivered
                    ? 'Complete trip'
                    : nextCheckpoint == null
                        ? 'Trip complete'
                        : trip.status == LoadStatus.assigned && progress == 0
                            ? 'Start trip — I\'m at ${nextCheckpoint}'
                            : 'I\'m at $nextCheckpoint',
                fullWidth: true,
                size: WBButtonSize.lg,
                trailingIcon: WBIconName.arrowRight,
                disabled: nextCheckpoint == null && !delivered,
                onPressed: delivered
                    ? () {
                        TransportController.instance.completeTrip();
                        context.go(AppRoutes.driverHome);
                      }
                    : () => _logCheckpoint(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.trip});
  final LoadOffer trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WBSpacing.lg),
      decoration: BoxDecoration(
        color: WBColors.surfaceDark,
        borderRadius: BorderRadius.circular(WBRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trip.status.label.toUpperCase(),
            style: WBTypography.label.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trip.routeLabel,
            style: WBTypography.hero.copyWith(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${wbThousands(trip.weightKg)} kg · ${trip.distanceKm.toStringAsFixed(0)} km · ${wbNaira(trip.offerNaira)} settle',
            style: WBTypography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _GpsBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x1410B981),
        borderRadius: BorderRadius.circular(WBRadius.card),
        border: Border.all(color: const Color(0x3310B981)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'GPS active · we log each checkpoint automatically',
              style: WBTypography.caption.copyWith(
                color: WBColors.fgHeader,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckpointRow extends StatelessWidget {
  const _CheckpointRow({
    required this.label,
    required this.reached,
    required this.isNext,
    required this.isLast,
  });
  final String label;
  final bool reached;
  final bool isNext;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: reached
                    ? WBColors.surfaceDark
                    : isNext
                        ? const Color(0xFF10B981)
                        : WBColors.bgSoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: reached
                  ? const WBIcon(
                      WBIconName.check,
                      size: 10,
                      color: Colors.white,
                      strokeWidth: 2.5,
                    )
                  : isNext
                      ? Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  label,
                  style: WBTypography.body.copyWith(
                    fontSize: 14,
                    fontWeight: reached || isNext
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: reached || isNext
                        ? WBColors.fgHeader
                        : WBColors.fgPlaceholder,
                  ),
                ),
              ),
            ),
            if (isNext)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x1410B981),
                  borderRadius: BorderRadius.circular(WBRadius.pill),
                ),
                child: Text(
                  'Next',
                  style: WBTypography.label.copyWith(
                    color: const Color(0xFF047857),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 9, top: 4, bottom: 4),
            child: Container(
              width: 2,
              height: 18,
              color: reached ? WBColors.surfaceDark : WBColors.bgDivider,
            ),
          ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: WBTypography.cardTitle.copyWith(fontSize: 16),
    );
  }
}
