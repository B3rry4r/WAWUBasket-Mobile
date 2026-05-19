import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../trade/application/trade_controller.dart';
import '../../../trade/domain/models/corridor.dart';
import '../../../trade/domain/models/export_listing.dart';

/// Add-or-edit form for one export listing. With a `listingId` it loads
/// that listing; without one it stages a new active listing.
class TraderListingEditScreen extends StatefulWidget {
  const TraderListingEditScreen({super.key, this.listingId});
  final String? listingId;

  @override
  State<TraderListingEditScreen> createState() =>
      _TraderListingEditScreenState();
}

class _TraderListingEditScreenState extends State<TraderListingEditScreen> {
  late final _produce = TextEditingController();
  late final _quantity = TextEditingController();
  late final _price = TextEditingController();
  late Corridor _origin;
  late Corridor _destination;
  late DateTime _harvest;

  bool get _isEdit => widget.listingId != null;
  ExportListing? get _source =>
      widget.listingId == null ? null : TradeController.instance.byId(widget.listingId!);

  @override
  void initState() {
    super.initState();
    final s = _source;
    _produce.text = s?.produce ?? '';
    _quantity.text = s == null ? '' : '${s.quantityKg}';
    _price.text = s == null ? '' : '${s.pricePerKgNaira}';
    _origin = s?.originCorridor ?? Corridor.nigeria;
    _destination = s?.destinationCorridor ?? Corridor.benin;
    _harvest = s?.harvestDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _produce.dispose();
    _quantity.dispose();
    _price.dispose();
    super.dispose();
  }

  void _save() {
    final q = int.tryParse(_quantity.text.replaceAll(',', '')) ?? 0;
    final p = int.tryParse(_price.text.replaceAll(',', '')) ?? 0;
    if (_produce.text.trim().isEmpty || q <= 0 || p <= 0) {
      wbShowSnack(context, 'Produce, quantity and price are required.');
      return;
    }
    final s = _source;
    final updated = ExportListing(
      id: s?.id ?? 'EXP-${DateTime.now().millisecondsSinceEpoch}',
      produce: _produce.text.trim(),
      quantityKg: q,
      pricePerKgNaira: p,
      harvestDate: _harvest,
      originCorridor: _origin,
      destinationCorridor: _destination,
      farmName: s?.farmName ?? 'Hauwa & Sons Bulk Co.',
      farmRegion: s?.farmRegion ?? 'Kano',
      imageUrl: s?.imageUrl ??
          'https://images.unsplash.com/photo-1582284540020-8acbe03f4924?w=600&q=80&auto=format&fit=crop',
      enquiries: s?.enquiries ?? 0,
      status: s?.status ?? ExportListingStatus.active,
    );
    if (_isEdit) {
      TradeController.instance.update(updated);
      wbShowSnack(context, '${updated.produce} updated');
    } else {
      TradeController.instance.add(updated);
      wbShowSnack(context, '${updated.produce} listed');
    }
    context.pop();
  }

  Future<void> _pickHarvest() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _harvest,
      firstDate: DateTime.now().subtract(const Duration(days: 60)),
      lastDate: DateTime.now(),
      helpText: 'Harvest date',
    );
    if (picked != null) setState(() => _harvest = picked);
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
              origin ? 'Origin corridor' : 'Destination corridor',
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

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }

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
                    Text(
                      _isEdit ? 'Edit listing' : 'New export listing',
                      style: WBTypography.page,
                    ),
                  ],
                ),
                const SizedBox(height: WBSpacing.lg),
                GestureDetector(
                  onTap: () =>
                      wbShowSnack(context, 'Pick a photo from your camera'),
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: WBColors.bgSoft,
                      borderRadius: BorderRadius.circular(WBRadius.card),
                      border: Border.all(color: WBColors.bgDivider),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: WBColors.bgPrimary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const WBIcon(WBIconName.plus, size: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Upload photo',
                          style: WBTypography.body.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Shot of the lot ready for shipping',
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: WBSpacing.lg),
                WBInput(
                  label: 'Produce',
                  placeholder: 'e.g. Tomatoes',
                  controller: _produce,
                ),
                const SizedBox(height: WBSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: WBInput(
                        label: 'Quantity (kg)',
                        controller: _quantity,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: WBInput(
                        label: 'Price per kg (₦)',
                        controller: _price,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: WBSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _PickerField(
                        label: 'From',
                        value: _origin.label,
                        onTap: () => _pickCorridor(origin: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PickerField(
                        label: 'To',
                        value: _destination.label,
                        onTap: () => _pickCorridor(origin: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: WBSpacing.md),
                _PickerField(
                  label: 'Harvest date',
                  value: _formatDate(_harvest),
                  onTap: _pickHarvest,
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
                    label: _isEdit ? 'Save changes' : 'Post listing',
                    fullWidth: true,
                    size: WBButtonSize.lg,
                    onPressed: _save,
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
