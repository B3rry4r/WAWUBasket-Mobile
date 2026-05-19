import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../trade/domain/models/corridor.dart';
import '../../../transport/application/transport_controller.dart';
import '../../../transport/domain/models/load_offer.dart';

/// Trader posts a load that drivers (the new operator role from batch E)
/// can bid on. Reads + writes the shared [TransportController] so the
/// same list lights up the driver's load board.
class TraderTransportScreen extends StatefulWidget {
  const TraderTransportScreen({super.key});

  @override
  State<TraderTransportScreen> createState() => _TraderTransportScreenState();
}

class _TraderTransportScreenState extends State<TraderTransportScreen> {
  Corridor _origin = Corridor.nigeria;
  Corridor _destination = Corridor.benin;
  final _originLabel = TextEditingController(text: 'Kano');
  final _destinationLabel = TextEditingController(text: 'Cotonou');
  final _weight = TextEditingController(text: '5000');
  final _offer = TextEditingController(text: '450000');
  final _distance = TextEditingController(text: '1280');

  @override
  void dispose() {
    _originLabel.dispose();
    _destinationLabel.dispose();
    _weight.dispose();
    _offer.dispose();
    _distance.dispose();
    super.dispose();
  }

  void _pickCorridor({required bool origin}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: WBSpacing.screenPadding,
          right: WBSpacing.screenPadding,
          top: WBSpacing.lg,
          bottom: MediaQuery.of(sheetCtx).padding.bottom + WBSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: WBSpacing.lg),
                decoration: BoxDecoration(
                  color: WBColors.bgDivider,
                  borderRadius: BorderRadius.circular(WBRadius.pill),
                ),
              ),
            ),
            Text(
              origin ? 'Pickup corridor' : 'Dropoff corridor',
              style: WBTypography.cardTitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: WBSpacing.md),
            for (final c in Corridor.values)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    if (origin) {
                      _origin = c;
                    } else {
                      _destination = c;
                    }
                  });
                  Navigator.of(sheetCtx).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.label,
                          style: WBTypography.body.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if ((origin && c == _origin) ||
                          (!origin && c == _destination))
                        const WBIcon(WBIconName.check, size: 16),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _post() {
    final w = int.tryParse(_weight.text.replaceAll(',', '')) ?? 0;
    final o = int.tryParse(_offer.text.replaceAll(',', '')) ?? 0;
    final d = double.tryParse(_distance.text) ?? 0;
    if (w <= 0 || o <= 0) {
      wbShowSnack(context, 'Add weight and an offer price.');
      return;
    }
    final offer = LoadOffer(
      id: 'LOAD-${DateTime.now().millisecondsSinceEpoch}',
      origin: _origin,
      destination: _destination,
      originLabel: _originLabel.text.trim().isEmpty
          ? _origin.label
          : _originLabel.text.trim(),
      destinationLabel: _destinationLabel.text.trim().isEmpty
          ? _destination.label
          : _destinationLabel.text.trim(),
      weightKg: w,
      offerNaira: o,
      traderName: 'Hauwa & Sons Bulk Co.',
      distanceKm: d,
      checkpointNames: const [
        'Origin depot',
        'Border post',
        'Destination warehouse',
      ],
      postedAt: DateTime.now(),
    );
    TransportController.instance.post(offer);
    wbShowSnack(
      context,
      'Load posted · drivers in ${_origin.label} → ${_destination.label} are bidding',
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder(
          valueListenable: TransportController.instance.loads,
          builder: (_, loads, _) {
            final mine = [
              for (final l in loads)
                if (l.traderName == 'Hauwa & Sons Bulk Co.') l,
            ];
            return Stack(
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Transport requests',
                                style: WBTypography.page,
                              ),
                              Text(
                                'Post a load. Drivers across the corridor bid.',
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
                    Text(
                      'Post a load',
                      style: WBTypography.cardTitle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    WBCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _PickerField(
                                  label: 'From corridor',
                                  value: _origin.label,
                                  onTap: () => _pickCorridor(origin: true),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _PickerField(
                                  label: 'To corridor',
                                  value: _destination.label,
                                  onTap: () => _pickCorridor(origin: false),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: WBSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: WBInput(
                                  label: 'Pickup city',
                                  controller: _originLabel,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: WBInput(
                                  label: 'Dropoff city',
                                  controller: _destinationLabel,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: WBSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: WBInput(
                                  label: 'Weight (kg)',
                                  controller: _weight,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: WBInput(
                                  label: 'Offer (₦)',
                                  controller: _offer,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: WBSpacing.md),
                          WBInput(
                            label: 'Distance (km)',
                            controller: _distance,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: WBSpacing.lg),
                    Text(
                      mine.isEmpty ? 'Recent loads' : 'Your posted loads',
                      style: WBTypography.cardTitle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    if ((mine.isEmpty ? loads : mine).isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: WBColors.bgSoft,
                          borderRadius: BorderRadius.circular(WBRadius.card),
                        ),
                        child: Text(
                          'No loads posted yet.',
                          style: WBTypography.body.copyWith(
                            color: WBColors.fgSecondary,
                            fontSize: 14,
                          ),
                        ),
                      )
                    else
                      WBCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (var i = 0;
                                i < (mine.isEmpty ? loads : mine).length;
                                i++) ...[
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: _LoadRow(
                                  load: (mine.isEmpty ? loads : mine)[i],
                                ),
                              ),
                              if (i !=
                                  (mine.isEmpty ? loads : mine).length - 1)
                                const WBDivider(),
                            ],
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
                        label: 'Post load',
                        fullWidth: true,
                        size: WBButtonSize.lg,
                        trailingIcon: WBIconName.arrowRight,
                        onPressed: _post,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LoadRow extends StatelessWidget {
  const _LoadRow({required this.load});
  final LoadOffer load;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                load.routeLabel,
                style: WBTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '#${load.id} · ${wbThousands(load.weightKg)} kg · ${load.bids.length} bid${load.bids.length == 1 ? '' : 's'}',
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgSecondary,
                ),
              ),
            ],
          ),
        ),
        WBStatusPill(
          label: load.status.label,
          kind: switch (load.status) {
            LoadStatus.open => WBStatusKind.warning,
            LoadStatus.assigned => WBStatusKind.info,
            LoadStatus.inTransit => WBStatusKind.info,
            LoadStatus.delivered => WBStatusKind.success,
            LoadStatus.cancelled => WBStatusKind.error,
          },
        ),
        const SizedBox(width: 10),
        Text(
          wbNaira(load.offerNaira),
          style: WBTypography.body.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AbsorbPointer(
        child: WBInput(
          key: ValueKey('$label-$value'),
          label: label,
          initialValue: value,
          trailing: const WBIcon(WBIconName.chevronDown, size: 14),
        ),
      ),
    );
  }
}
