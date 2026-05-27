import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/upload_service.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shopping/data/catalog_api.dart';
import '../../../trade/application/trade_controller.dart';
import '../../../trade/domain/models/corridor.dart';
import '../../../trade/domain/models/export_listing.dart';

class _CategoryOption {
  const _CategoryOption({
    required this.id,
    required this.label,
    required this.parentLabel,
  });
  final String id;
  final String label;
  final String parentLabel;
}

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
  late final _farmName = TextEditingController();
  late final _farmRegion = TextEditingController();
  late Corridor _origin;
  late Corridor _destination;
  late DateTime _harvest;
  String? _imageUrl;
  bool _uploadingPhoto = false;
  String _category = '';
  List<_CategoryOption> _catOptions = [];
  bool _loadingCats = true;

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
    _farmName.text = s?.farmName ?? '';
    _farmRegion.text = s?.farmRegion ?? '';
    _origin = s?.originCorridor ?? Corridor.nigeria;
    _destination = s?.destinationCorridor ?? Corridor.benin;
    _harvest = s?.harvestDate ?? DateTime.now();
    _imageUrl = (s?.imageUrl.isNotEmpty ?? false) ? s!.imageUrl : null;
    _category = s?.category ?? '';
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final raw = await CatalogApi.instance.categories();
      final opts = <_CategoryOption>[];
      for (final cat in raw) {
        if (cat is! Map) continue;
        final parentLabel = (cat['label'] ?? '').toString();
        final subs = (cat['subcategories'] as List?) ?? const [];
        for (final sub in subs) {
          if (sub is! Map) continue;
          opts.add(_CategoryOption(
            id: (sub['id'] ?? '').toString(),
            label: (sub['label'] ?? '').toString(),
            parentLabel: parentLabel,
          ));
        }
      }
      if (mounted) setState(() { _catOptions = opts; _loadingCats = false; });
    } on ApiException {
      if (mounted) setState(() => _loadingCats = false);
    }
  }

  Future<void> _pickPhoto() async {
    setState(() => _uploadingPhoto = true);
    try {
      final res = await UploadService.instance
          .pickAndUpload(folder: UploadFolder.exportListings);
      if (!mounted) return;
      setState(() {
        if (res != null) _imageUrl = res.publicUrl;
        _uploadingPhoto = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _uploadingPhoto = false);
        wbShowSnack(context, context.l10n.traderListingPhotoFailed);
      }
    }
  }

  @override
  void dispose() {
    _produce.dispose();
    _quantity.dispose();
    _price.dispose();
    _farmName.dispose();
    _farmRegion.dispose();
    super.dispose();
  }

  void _save() {
    final q = int.tryParse(_quantity.text.replaceAll(',', '')) ?? 0;
    final p = int.tryParse(_price.text.replaceAll(',', '')) ?? 0;
    if (_produce.text.trim().isEmpty || q <= 0 || p <= 0) {
      wbShowSnack(context, 'Produce, quantity and price are required.');
      return;
    }
    if (_farmName.text.trim().isEmpty || _farmRegion.text.trim().isEmpty) {
      wbShowSnack(context, 'Farm name and region are required.');
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
      farmName: _farmName.text.trim(),
      farmRegion: _farmRegion.text.trim(),
      imageUrl: _imageUrl ?? s?.imageUrl ?? '',
      enquiries: s?.enquiries ?? 0,
      status: s?.status ?? ExportListingStatus.active,
      category: _category.isNotEmpty ? _category : null,
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

  void _pickCategory() {
    if (_catOptions.isEmpty) return;
    final grouped = <String, List<_CategoryOption>>{};
    for (final c in _catOptions) {
      grouped.putIfAbsent(c.parentLabel, () => []).add(c);
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
      ),
      isScrollControlled: true,
      builder: (sheetCtx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollCtrl) => Padding(
            padding: EdgeInsets.only(
              left: WBSpacing.screenPadding,
              right: WBSpacing.screenPadding,
              top: WBSpacing.lg,
              bottom: MediaQuery.of(sheetCtx).padding.bottom + WBSpacing.lg,
            ),
            child: Column(
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
                  'Marketplace category',
                  style: WBTypography.cardTitle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: WBSpacing.sm),
                Text(
                  'Optional — pick a category so this listing appears in the customer marketplace.',
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                  ),
                ),
                const SizedBox(height: WBSpacing.md),
                Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                    children: [
                      for (final entry in grouped.entries) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 4),
                          child: Text(
                            entry.key,
                            style: WBTypography.label.copyWith(
                              color: WBColors.fgPlaceholder,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        for (final sub in entry.value)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() => _category = sub.id);
                              Navigator.of(sheetCtx).pop();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      sub.label,
                                      style: WBTypography.body.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  if (sub.id == _category)
                                    const WBIcon(WBIconName.check, size: 16),
                                ],
                              ),
                            ),
                          ),
                      ],
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() => _category = '');
                            Navigator.of(sheetCtx).pop();
                          },
                          child: const Text('Clear category'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                  onTap: _uploadingPhoto ? null : _pickPhoto,
                  child: Container(
                    height: 160,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: WBColors.bgSoft,
                      borderRadius: BorderRadius.circular(WBRadius.card),
                      border: Border.all(color: WBColors.bgDivider),
                    ),
                    child: _uploadingPhoto
                        ? const Center(
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation(
                                    WBColors.surfaceDark),
                              ),
                            ),
                          )
                        : _imageUrl != null
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  WBNetworkImage(url: _imageUrl!),
                                  Positioned(
                                    right: 10,
                                    bottom: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: WBColors.surfaceDark,
                                        borderRadius:
                                            BorderRadius.circular(
                                                WBRadius.pill),
                                      ),
                                      child: Text(
                                        'Change photo',
                                        style:
                                            WBTypography.caption.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: WBInput(
                        label: 'Price per kg (₦)',
                        controller: _price,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: WBSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: WBInput(
                        label: 'Farm name',
                        placeholder: 'e.g. Hauwa & Sons Farm',
                        controller: _farmName,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: WBInput(
                        label: 'Farm region',
                        placeholder: 'e.g. Kano',
                        controller: _farmRegion,
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
                const SizedBox(height: WBSpacing.md),
                _PickerField(
                  label: 'Marketplace category (optional)',
                  value: _loadingCats
                      ? 'Loading…'
                      : _catOptions.isEmpty
                          ? 'No categories'
                          : (_catOptions.firstWhere(
                              (o) => o.id == _category,
                              orElse: () => _CategoryOption(
                                id: '',
                                label: 'None',
                                parentLabel: '',
                              ),
                            ).label),
                  onTap: _pickCategory,
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
