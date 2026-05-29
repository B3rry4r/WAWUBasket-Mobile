import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_home_app_bar.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../account/application/profile_controller.dart';
import '../../../transport/application/transport_controller.dart';
import '../../../transport/domain/models/load_offer.dart';

/// Driver's home, load board. Shows open loads with route, weight,
/// distance, offer; the resume banner appears whenever there's an
/// active trip so the driver can hop back into it.
class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  @override
  void initState() {
    super.initState();
    TransportController.instance.loadOpenLoads();
    TransportController.instance.loadActiveTrip();
    ProfileController.instance.load();
    ProfileController.instance.loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ValueListenableBuilder(
        valueListenable: TransportController.instance.activeTrip,
        builder: (_, active, _) {
          return ValueListenableBuilder(
            valueListenable: TransportController.instance.loads,
            builder: (_, loads, _) {
              final open = [
                for (final l in loads)
                  if (l.status == LoadStatus.open) l,
              ];
              final today = loads.where((l) {
                final placed = l.reachedCheckpoints.isNotEmpty
                    ? l.reachedCheckpoints.first.reachedAt
                    : l.postedAt;
                return placed.isAfter(
                  DateTime.now().subtract(const Duration(hours: 24)),
                );
              });
              final pending = today.length;

              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  WBSpacing.screenPadding,
                  12,
                  WBSpacing.screenPadding,
                  140,
                ),
                children: [
                  ValueListenableBuilder(
                    valueListenable: ProfileController.instance.profile,
                    builder: (_, profile, _) => WBHomeAppBar(
                      title: profile?.driverDisplayName?.isNotEmpty == true
                          ? profile!.driverDisplayName!
                          : profile?.fullName.isNotEmpty == true
                              ? profile!.fullName
                              : 'Driver',
                      subtitle: profile?.driverPlateNumber?.isNotEmpty == true
                          ? 'Driver · ${profile!.driverPlateNumber}'
                          : 'Driver dashboard',
                    ),
                  ),
                  const SizedBox(height: WBSpacing.lg),
                  ValueListenableBuilder(
                    valueListenable: ProfileController.instance.profile,
                    builder: (_, profile, _) =>
                        ValueListenableBuilder(
                          valueListenable: ProfileController.instance.stats,
                          builder: (_, stats, _) => _Hero(
                            open: open.length,
                            pendingToday: pending,
                            displayName: profile?.driverDisplayName?.isNotEmpty == true
                                ? profile!.driverDisplayName!
                                : profile?.fullName.isNotEmpty == true
                                    ? profile!.fullName
                                    : null,
                            plateNumber: profile?.driverPlateNumber,
                            driverRating: stats?.driverRating,
                          ),
                        ),
                  ),
                  if (active != null) ...[
                    const SizedBox(height: WBSpacing.md),
                    _ResumeBanner(
                      load: active,
                      onTap: () => context.go(AppRoutes.driverActiveTrip),
                    ),
                  ],
                  const SizedBox(height: WBSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Loads near you',
                          style: WBTypography.cardTitle.copyWith(fontSize: 17),
                        ),
                      ),
                      Text(
                        'Pick one and go.',
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (open.isEmpty)
                    const WBEmptyState(
                      illustration: WBEmptyIllustration.noOpenLoads,
                      label: 'No open loads near you right now.',
                      sub: 'Check back at corridor peak hours.',
                    )
                  else
                    for (final l in open)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _LoadCard(
                          load: l,
                          onTap: () => context.push(
                            '${AppRoutes.driverHome}/bid/${l.id}',
                          ),
                        ),
                      ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.open,
    required this.pendingToday,
    this.displayName,
    this.plateNumber,
    this.driverRating,
  });
  final int open;
  final int pendingToday;
  final String? displayName;
  final String? plateNumber;
  final String? driverRating;

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
            'Hey,',
            style: WBTypography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            displayName ?? 'Driver',
            style: WBTypography.hero.copyWith(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          if (plateNumber?.isNotEmpty == true) ...[
            const SizedBox(height: 2),
            Text(
              plateNumber!,
              style: WBTypography.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ],
          const SizedBox(height: WBSpacing.lg),
          Row(
            children: [
              _Stat(label: context.l10n.driverOpenLoads, value: '$open'),
              const SizedBox(width: 10),
              _Stat(label: context.l10n.driverToday, value: '$pendingToday'),
              const SizedBox(width: 10),
              _Stat(label: context.l10n.vendorAnalyticsRating, value: driverRating != null && (double.tryParse(driverRating!) ?? 0) > 0 ? '★ $driverRating' : 'New'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: WBTypography.label.copyWith(
                color: Colors.white.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500,
                fontSize: 9,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: WBTypography.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadCard extends StatelessWidget {
  const _LoadCard({required this.load, required this.onTap});
  final LoadOffer load;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: WBCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    load.routeLabel,
                    style: WBTypography.cardTitle.copyWith(fontSize: 16),
                  ),
                ),
                Text(
                  wbNaira(load.offerNaira),
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${wbThousands(load.weightKg)} kg · ${load.distanceKm.toStringAsFixed(0)} km · ${load.traderName}',
              style: WBTypography.caption.copyWith(
                color: WBColors.fgSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _Tag(label: '${load.bids.length} bid${load.bids.length == 1 ? '' : 's'}'),
                const SizedBox(width: 8),
                _Tag(label: _ago(load.postedAt)),
                const Spacer(),
                WBButton(
                  label: context.l10n.driverBid,
                  size: WBButtonSize.sm,
                  trailingIcon: WBIconName.arrowRight,
                  onPressed: onTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _ago(DateTime d) {
    final mins = DateTime.now().difference(d).inMinutes;
    if (mins < 60) return '$mins min ago';
    final hrs = mins ~/ 60;
    if (hrs < 24) return '$hrs hr ago';
    return '${hrs ~/ 24}d ago';
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: WBColors.bgSoft,
        borderRadius: BorderRadius.circular(WBRadius.pill),
      ),
      child: Text(
        label,
        style: WBTypography.caption.copyWith(
          color: WBColors.fgHeader,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _ResumeBanner extends StatelessWidget {
  const _ResumeBanner({required this.load, required this.onTap});
  final LoadOffer load;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = load.reachedCheckpoints.length;
    final total = load.checkpointNames.length;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: WBColors.surfaceDark,
          borderRadius: BorderRadius.circular(WBRadius.card),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2E000000),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const WBIcon(
                WBIconName.bike,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active trip · #${load.id}',
                    style: WBTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${load.routeLabel} · checkpoint $progress / $total',
                    style: WBTypography.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const WBIcon(
              WBIconName.arrowRight,
              size: 16,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTile extends StatelessWidget {
  const _EmptyTile({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WBColors.bgSoft,
        borderRadius: BorderRadius.circular(WBRadius.card),
      ),
      child: Text(
        label,
        style: WBTypography.body.copyWith(
          color: WBColors.fgSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
}
