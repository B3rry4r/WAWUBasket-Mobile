import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../transport/application/transport_controller.dart';
import '../../../transport/domain/models/load_offer.dart';

/// Driver places a bid (or accepts the offered price) on one load.
/// Submitting auto-assigns the driver in the prototype and routes to
/// the active trip screen.
class DriverBidScreen extends StatefulWidget {
  const DriverBidScreen({super.key, required this.loadId});
  final String loadId;

  @override
  State<DriverBidScreen> createState() => _DriverBidScreenState();
}

class _DriverBidScreenState extends State<DriverBidScreen> {
  final _price = TextEditingController();
  final _eta = TextEditingController(text: '24');
  final _notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    final l = TransportController.instance.byId(widget.loadId);
    if (l != null) _price.text = '${l.offerNaira}';
  }

  @override
  void dispose() {
    _price.dispose();
    _eta.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _submit(LoadOffer load) {
    final p = int.tryParse(_price.text.replaceAll(',', '')) ?? 0;
    final h = int.tryParse(_eta.text) ?? 0;
    if (p <= 0 || h <= 0) {
      wbShowSnack(context, 'Add a price and an ETA.');
      return;
    }
    TransportController.instance.bid(
      load.id,
      LoadBid(
        driverName: TransportController.driverName,
        priceNaira: p,
        etaHours: h,
        notes: _notes.text.trim(),
      ),
    );
    TransportController.instance.accept(load.id);
    wbShowSnack(
      context,
      'Bid accepted · trip starts whenever you log the first checkpoint',
    );
    context.go(AppRoutes.driverActiveTrip);
  }

  @override
  Widget build(BuildContext context) {
    final load = TransportController.instance.byId(widget.loadId);
    if (load == null) {
      return Scaffold(
        backgroundColor: WBColors.bgSecondary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(WBSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WBBackChip(onPressed: () => context.pop()),
                const SizedBox(height: WBSpacing.xl),
                Text('Load not found', style: WBTypography.page),
              ],
            ),
          ),
        ),
      );
    }
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
                160,
              ),
              children: [
                Row(
                  children: [
                    WBBackChip(onPressed: () => context.pop()),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Place your bid', style: WBTypography.page),
                          Text(
                            '#${load.id} · ${load.traderName}',
                            style: WBTypography.caption.copyWith(
                              color: WBColors.fgSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        'ROUTE',
                        style: WBTypography.label.copyWith(
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        load.routeLabel,
                        style: WBTypography.hero.copyWith(
                          color: Colors.white,
                          fontSize: 26,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${wbThousands(load.weightKg)} kg · ${load.distanceKm.toStringAsFixed(0)} km · ${load.checkpointNames.length} checkpoints',
                        style: WBTypography.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: WBSpacing.lg),
                _SectionLabel('Your bid'),
                const SizedBox(height: 10),
                WBInput(
                  label: 'Price (₦)',
                  controller: _price,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: WBSpacing.md),
                WBInput(
                  label: 'ETA to destination (hours)',
                  controller: _eta,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: WBSpacing.md),
                WBInput(
                  label: 'Notes (optional)',
                  placeholder: 'I run this route every week.',
                  controller: _notes,
                ),
                const SizedBox(height: WBSpacing.lg),
                _SectionLabel('Trader offer'),
                const SizedBox(height: 10),
                WBCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Posted at',
                              style: WBTypography.caption.copyWith(
                                color: WBColors.fgSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              wbNaira(load.offerNaira),
                              style: WBTypography.body.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _Tag(label: '${load.bids.length} other bids'),
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
                    20,
                  ),
                  child: WBButton(
                    label: 'Submit bid',
                    fullWidth: true,
                    size: WBButtonSize.lg,
                    trailingIcon: WBIconName.arrowRight,
                    onPressed: () => _submit(load),
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

class _Tag extends StatelessWidget {
  const _Tag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
