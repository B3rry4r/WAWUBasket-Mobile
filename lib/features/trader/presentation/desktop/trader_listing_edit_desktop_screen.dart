import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/upload_service.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../shell/presentation/desktop/operator_desktop_scaffold.dart';
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

/// Desktop-web layout for the add-or-edit export-listing form. Isolated from
/// the mobile [TraderListingEditScreen] — same [TradeController]/[CatalogApi],
/// state, validation, money/copy and navigation, re-laid-out as a two-column
/// dashboard form (photo + corridor on the left, listing basics on the right)
/// inside the persistent operator sidebar chrome. Pickers that are bottom
/// sheets on mobile become centered dialogs here.
class TraderListingEditDesktopScreen extends StatefulWidget {
  const TraderListingEditDesktopScreen({super.key, this.listingId});
  final String? listingId;

  @override
  State<TraderListingEditDesktopScreen> createState() =>
      _TraderListingEditDesktopScreenState();
}

class _TraderListingEditDesktopScreenState
    extends State<TraderListingEditDesktopScreen> {
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
  ExportListing? get _source => widget.listingId == null
      ? null
      : TradeController.instance.byId(widget.listingId!);

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
      if (mounted) {
        setState(() {
          _catOptions = opts;
          _loadingCats = false;
        });
      }
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
      wbShowSnack(context, context.l10n.traderFieldsRequired);
      return;
    }
    if (_farmName.text.trim().isEmpty || _farmRegion.text.trim().isEmpty) {
      wbShowSnack(context, context.l10n.traderFarmRequired);
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
      wbShowSnack(context, context.l10n.traderListingUpdated(updated.produce));
    } else {
      TradeController.instance.add(updated);
      wbShowSnack(context, context.l10n.traderListingPosted(updated.produce));
    }
    context.pop();
  }

  Future<void> _pickHarvest() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _harvest,
      firstDate: DateTime.now().subtract(const Duration(days: 60)),
      lastDate: DateTime.now(),
      helpText: context.l10n.traderHarvestDateLabel,
    );
    if (picked != null) setState(() => _harvest = picked);
  }

  void _pickCorridor({required bool origin}) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: WBColors.bgPrimary,
          insetPadding: const EdgeInsets.all(WBSpacing.xl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WBRadius.sheet),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(WBSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                        Navigator.of(dialogCtx).pop();
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
          ),
        );
      },
    );
  }

  void _pickCategory() {
    if (_catOptions.isEmpty) return;
    final grouped = <String, List<_CategoryOption>>{};
    for (final c in _catOptions) {
      grouped.putIfAbsent(c.parentLabel, () => []).add(c);
    }
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: WBColors.bgPrimary,
          insetPadding: const EdgeInsets.all(WBSpacing.xl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WBRadius.sheet),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
            child: Padding(
              padding: const EdgeInsets.all(WBSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
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
                                Navigator.of(dialogCtx).pop();
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
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
                              Navigator.of(dialogCtx).pop();
                            },
                            child: Text(context.l10n.traderClearCategory),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
    return OperatorDesktopScaffold(
      role: AppRole.trader,
      child: WBMaxWidth(
        maxWidth: WBBreakpoints.maxContent,
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.xl,
          WBSpacing.xl,
          WBSpacing.xl,
          40,
        ),
        child: ListView(
          children: [
            Row(
              children: [
                WBBackChip(onPressed: () => context.pop()),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    _isEdit ? 'Edit listing' : 'New export listing',
                    style: WBTypography.page,
                  ),
                ),
                WBButton(
                  label: _isEdit
                      ? context.l10n.traderSaveChanges
                      : context.l10n.traderPostListingBtn,
                  size: WBButtonSize.md,
                  onPressed: _save,
                ),
              ],
            ),
            const SizedBox(height: WBSpacing.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: _media(context),
                ),
                const SizedBox(width: WBSpacing.xl),
                Expanded(
                  flex: 4,
                  child: _details(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _media(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: _uploadingPhoto ? null : _pickPhoto,
          child: Container(
            height: 220,
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
                        valueColor:
                            AlwaysStoppedAnimation(WBColors.surfaceDark),
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
                                    BorderRadius.circular(WBRadius.pill),
                              ),
                              child: Text(
                                'Change photo',
                                style: WBTypography.caption.copyWith(
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
        Row(
          children: [
            Expanded(
              child: _PickerField(
                label: context.l10n.traderFromLabel,
                value: _origin.label,
                onTap: () => _pickCorridor(origin: true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PickerField(
                label: context.l10n.traderToLabel,
                value: _destination.label,
                onTap: () => _pickCorridor(origin: false),
              ),
            ),
          ],
        ),
        const SizedBox(height: WBSpacing.md),
        _PickerField(
          label: context.l10n.traderHarvestDateLabel,
          value: _formatDate(_harvest),
          onTap: _pickHarvest,
        ),
        const SizedBox(height: WBSpacing.md),
        _PickerField(
          label: context.l10n.traderCategoryLabel,
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
    );
  }

  Widget _details(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WBInput(
          label: 'Produce',
          placeholder: context.l10n.traderProducePlaceholder,
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
        WBInput(
          label: 'Farm name',
          placeholder: context.l10n.traderFarmPlaceholder,
          controller: _farmName,
        ),
        const SizedBox(height: WBSpacing.md),
        WBInput(
          label: 'Farm region',
          placeholder: context.l10n.traderRegionPlaceholder,
          controller: _farmRegion,
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
