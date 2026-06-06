import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_format.dart';
import '../../../../core/widgets/wb_form_fields.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../account/application/profile_controller.dart';
import '../../../trade/domain/models/corridor.dart';
import '../../../transport/application/transport_controller.dart';
import '../../../transport/data/transport_api.dart';
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
  String _originState = '';
  String _originCity = '';
  String _destinationState = '';
  String _destinationCity = '';
  final _weight = TextEditingController();
  final _offer = TextEditingController();
  final _distance = TextEditingController();

  @override
  void initState() {
    super.initState();
    TransportController.instance.loadMyLoads();
  }

  @override
  void dispose() {
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
                      _originState = '';
                      _originCity = '';
                    } else {
                      _destination = c;
                      _destinationState = '';
                      _destinationCity = '';
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
    final traderName =
        ProfileController.instance.profile.value?.fullName ?? '';
    final originLabel = _originCity.isNotEmpty
        ? _originCity
        : _originState.isNotEmpty
            ? _originState
            : _origin.label;
    final destinationLabel = _destinationCity.isNotEmpty
        ? _destinationCity
        : _destinationState.isNotEmpty
            ? _destinationState
            : _destination.label;
    final offer = LoadOffer(
      id: 'LOAD-${DateTime.now().millisecondsSinceEpoch}',
      origin: _origin,
      destination: _destination,
      originLabel: originLabel,
      destinationLabel: destinationLabel,
      weightKg: w,
      offerNaira: o,
      traderName: traderName,
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
            final myName =
                ProfileController.instance.profile.value?.fullName ?? '';
            final mine = [
              for (final l in loads)
                if (myName.isNotEmpty && l.traderName == myName) l,
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
                                child: WBStateField(
                                  countryName: _origin.label,
                                  value: _originState.isEmpty ? null : _originState,
                                  label: 'Pickup state',
                                  onChanged: (s) => setState(() {
                                    _originState = s;
                                    _originCity = '';
                                  }),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: WBStateField(
                                  countryName: _destination.label,
                                  value: _destinationState.isEmpty ? null : _destinationState,
                                  label: 'Dropoff state',
                                  onChanged: (s) => setState(() {
                                    _destinationState = s;
                                    _destinationCity = '';
                                  }),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: WBSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: WBCityField(
                                  countryName: _origin.label,
                                  stateName: _originState,
                                  value: _originCity.isEmpty ? null : _originCity,
                                  label: 'Pickup city',
                                  onChanged: (c) => setState(() => _originCity = c),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: WBCityField(
                                  countryName: _destination.label,
                                  stateName: _destinationState,
                                  value: _destinationCity.isEmpty ? null : _destinationCity,
                                  label: 'Dropoff city',
                                  onChanged: (c) => setState(() => _destinationCity = c),
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
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: WBInput(
                                  label: 'Offer (₦)',
                                  controller: _offer,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: WBSpacing.md),
                          WBInput(
                            label: 'Distance (km)',
                            controller: _distance,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]'),
                              ),
                            ],
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
                      const WBEmptyState(
                        illustration: WBEmptyIllustration.noActiveLoads,
                        label: 'No loads posted yet.',
                      )
                    else
                      for (final load in (mine.isEmpty ? loads : mine)) ...[
                        WBCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: _LoadRow(load: load),
                              ),
                              if (load.bids.isNotEmpty) ...[
                                const WBDivider(),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                                  child: Text(
                                    '${load.bids.length} bid${load.bids.length == 1 ? '' : 's'}',
                                    style: WBTypography.caption.copyWith(
                                      color: WBColors.fgSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                for (final bid in load.bids)
                                  _BidRow(
                                    load: load,
                                    bid: bid,
                                    canAccept: load.status == LoadStatus.open,
                                  ),
                                const SizedBox(height: 6),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
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

class _BidRow extends StatefulWidget {
  const _BidRow({
    required this.load,
    required this.bid,
    required this.canAccept,
  });
  final LoadOffer load;
  final LoadBid bid;
  final bool canAccept;

  @override
  State<_BidRow> createState() => _BidRowState();
}

class _BidRowState extends State<_BidRow> {
  bool _loading = false;

  Future<void> _accept() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await TransportApi.instance.assignDriver(widget.load.id, widget.bid.id);
      if (!mounted) return;
      widget.load.status = LoadStatus.assigned;
      TransportController.instance.notifyLoadsChanged();
      wbShowSnack(context, '${widget.bid.driverName} assigned to this load');
    } on ApiException catch (e) {
      if (mounted) wbShowError(context, e.message);
    } catch (_) {
      if (mounted) wbShowSnack(context, 'Could not assign driver. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.bid.driverName,
                  style: WBTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${wbNaira(widget.bid.priceNaira)} · ${widget.bid.etaHours}h ETA'
                  '${widget.bid.notes.isNotEmpty ? ' · ${widget.bid.notes}' : ''}',
                  style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (widget.canAccept)
            _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : WBButton(
                    label: 'Accept',
                    size: WBButtonSize.sm,
                    onPressed: _accept,
                  ),
        ],
      ),
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
