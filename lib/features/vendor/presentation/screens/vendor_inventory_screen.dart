import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/vendor_inventory_controller.dart';
import '../../data/vendor_api.dart';

class VendorInventoryScreen extends StatefulWidget {
  const VendorInventoryScreen({super.key});

  @override
  State<VendorInventoryScreen> createState() => _VendorInventoryScreenState();
}

class _VendorInventoryScreenState extends State<VendorInventoryScreen> {
  String _filter = 'all';
  static const _filters = [
    ('all', 'All'),
    ('low', 'Low'),
    ('out', 'Out'),
    ('healthy', 'Healthy'),
  ];

  bool _matches(InventoryItem it) {
    switch (_filter) {
      case 'low':
        return it.isLow;
      case 'out':
        return it.isOut;
      case 'healthy':
        return !it.isLow && !it.isOut;
      default:
        return true;
    }
  }

  Future<void> _showAddDialog() async {
    final nameCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '0');
    final thresholdCtrl = TextEditingController(text: '0');
    final unitCtrl = TextEditingController(text: 'kg');
    bool busy = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: WBColors.bgPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            WBSpacing.lg,
            WBSpacing.screenPadding,
            MediaQuery.of(ctx).viewInsets.bottom + WBSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(ctx.l10n.vendorInventoryTitle,
                  style: WBTypography.cardTitle.copyWith(fontSize: 18)),
              const SizedBox(height: WBSpacing.lg),
              WBInput(label: ctx.l10n.vendorInventoryItemName, controller: nameCtrl),
              const SizedBox(height: WBSpacing.md),
              Row(
                children: [
                  Expanded(child: WBInput(
                    label: ctx.l10n.vendorInventoryQuantity,
                    controller: stockCtrl,
                    keyboardType: TextInputType.number,
                  )),
                  const SizedBox(width: WBSpacing.sm),
                  Expanded(child: WBInput(
                    label: ctx.l10n.vendorInventoryUnit,
                    controller: unitCtrl,
                  )),
                ],
              ),
              const SizedBox(height: WBSpacing.md),
              WBInput(
                label: ctx.l10n.vendorInventoryThreshold,
                controller: thresholdCtrl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: WBSpacing.lg),
              WBButton(
                label: ctx.l10n.vendorInventoryAddItem,
                size: WBButtonSize.lg,
                fullWidth: true,
                loading: busy,
                onPressed: busy ? null : () async {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) {
                    wbShowSnack(ctx, 'Enter a name for the item.');
                    return;
                  }
                  setSt(() => busy = true);
                  try {
                    await VendorApi.instance.createInventoryItem({
                      'name': name,
                      'stock': double.tryParse(stockCtrl.text) ?? 0,
                      'threshold': double.tryParse(thresholdCtrl.text) ?? 0,
                      'unit': unitCtrl.text.trim().isEmpty ? 'kg' : unitCtrl.text.trim(),
                    });
                    await VendorInventoryController.instance.load();
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  } on ApiException catch (e) {
                    if (ctx.mounted) wbShowError(ctx, e.message);
                    setSt(() => busy = false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
    nameCtrl.dispose();
    stockCtrl.dispose();
    thresholdCtrl.dispose();
    unitCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      floatingActionButton: FloatingActionButton(
        backgroundColor: WBColors.surfaceDark,
        onPressed: _showAddDialog,
        child: const WBIcon(WBIconName.plus, size: 22, color: Colors.white),
      ),
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder(
          valueListenable: VendorInventoryController.instance.items,
          builder: (_, items, _) {
            final lowOrOut = [
              for (final i in items)
                if (i.isLow || i.isOut) i,
            ];
            final filtered = [
              for (final i in items)
                if (_matches(i)) i,
            ];

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                12,
                WBSpacing.screenPadding,
                40,
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
                          Text(context.l10n.vendorInventoryTitle, style: WBTypography.page),
                          Text(
                            'Keep your shelves honest.',
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
                if (lowOrOut.isNotEmpty) ...[
                  _AlertCard(count: lowOrOut.length),
                  const SizedBox(height: WBSpacing.md),
                ],
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => WBTag(
                      label: _filters[i].$2,
                      active: _filters[i].$1 == _filter,
                      onTap: () => setState(() => _filter = _filters[i].$1),
                    ),
                  ),
                ),
                const SizedBox(height: WBSpacing.md),
                if (items.isEmpty)
                  const WBEmptyState(
                    illustration: WBEmptyIllustration.noProducts,
                    label: 'No inventory items yet.',
                    sub: 'Tap + to add your first item.',
                  )
                else
                  for (final i in filtered)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _InventoryCard(item: i),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WBColors.surfaceDark,
        borderRadius: BorderRadius.circular(WBRadius.card),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const WBIcon(
              WBIconName.bell,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$count items need restocking',
              style: WBTypography.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({required this.item});
  final InventoryItem item;

  (String, WBStatusKind) get _status {
    if (item.isOut) return ('Out', WBStatusKind.error);
    if (item.isLow) return ('Low', WBStatusKind.warning);
    return ('Healthy', WBStatusKind.success);
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) return '${v.toInt()}';
    return v.toStringAsFixed(1);
  }

  String _batchAge() {
    final d = item.batchDate;
    if (d == null) return '';
    final daysAgo = DateTime.now().difference(d).inDays;
    if (daysAgo == 0) return 'fresh today';
    if (daysAgo == 1) return '1 day old';
    return '$daysAgo days old';
  }

  @override
  Widget build(BuildContext context) {
    final s = _status;
    final showBatch = item.batchId != null && item.batchDate != null;
    return WBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: WBTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_fmt(item.stock)} ${item.unit} in stock · low at ${_fmt(item.threshold)} ${item.unit}',
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              WBStatusPill(label: s.$1, kind: s.$2),
            ],
          ),
          if (showBatch) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: WBColors.bgSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const WBIcon(WBIconName.basket, size: 12),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Batch ${item.batchId} · ${_batchAge()}',
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (showBatch)
                Expanded(
                  child: WBButton(
                    label: context.l10n.vendorInventoryNewBatch,
                    size: WBButtonSize.sm,
                    variant: WBButtonVariant.secondary,
                    onPressed: () => _showBatchSheet(context, item),
                  ),
                ),
              if (showBatch) const SizedBox(width: 10),
              Expanded(
                child: WBButton(
                  label: context.l10n.vendorInventoryUpdateStock,
                  size: WBButtonSize.sm,
                  onPressed: () => _showUpdateSheet(context, item),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _showUpdateSheet(BuildContext context, InventoryItem item) {
  final stockCtrl = TextEditingController(text: '${item.stock}');
  final thresholdCtrl = TextEditingController(text: '${item.threshold}');

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: WBColors.bgPrimary,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
    ),
    builder: (sheetCtx) {
      return Padding(
        padding: EdgeInsets.only(
          left: WBSpacing.screenPadding,
          right: WBSpacing.screenPadding,
          top: WBSpacing.lg,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + WBSpacing.xl,
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
            Text(item.name,
                style: WBTypography.cardTitle.copyWith(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              'Update what you have on hand.',
              style:
                  WBTypography.caption.copyWith(color: WBColors.fgSecondary),
            ),
            const SizedBox(height: WBSpacing.lg),
            WBInput(
              label: 'In stock (${item.unit})',
              controller: stockCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: WBSpacing.md),
            WBInput(
              label: 'Low-stock threshold (${item.unit})',
              controller: thresholdCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: WBSpacing.lg),
            WBButton(
              label: context.l10n.actionSave,
              size: WBButtonSize.lg,
              fullWidth: true,
              onPressed: () {
                VendorInventoryController.instance.update(
                  id: item.id,
                  stock: double.tryParse(stockCtrl.text) ?? item.stock,
                  threshold:
                      double.tryParse(thresholdCtrl.text) ?? item.threshold,
                );
                Navigator.of(sheetCtx).pop();
                wbShowSnack(context, context.l10n.vendorInventoryItemUpdated(item.name));
              },
            ),
          ],
        ),
      );
    },
  );
}

void _showBatchSheet(BuildContext context, InventoryItem item) {
  showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now().subtract(const Duration(days: 30)),
    lastDate: DateTime.now(),
    helpText: item.kind == InventoryKind.livestock
        ? 'Slaughter date'
        : 'Harvest date',
  ).then((picked) {
    if (picked == null) return;
    final batchId = 'B-${picked.year}-${picked.month.toString().padLeft(2, '0')}${picked.day.toString().padLeft(2, '0')}';
    VendorInventoryController.instance.update(
      id: item.id,
      batchDate: picked,
      batchId: batchId,
    );
    if (!context.mounted) return;
    wbShowSnack(context, context.l10n.vendorInventoryBatchLogged(item.name));
  });
}
