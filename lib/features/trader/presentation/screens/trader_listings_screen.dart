import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../trade/application/trade_controller.dart';
import '../../../trade/domain/models/export_listing.dart';
import '../../../trade/presentation/widgets/export_listing_card.dart';

/// Trader's listing dashboard. Filter by status (Active / Draft / Sold)
/// across the top, post-new CTA in the header, long-press a card to
/// edit/mark sold/delete.
class TraderListingsScreen extends StatefulWidget {
  const TraderListingsScreen({super.key});

  @override
  State<TraderListingsScreen> createState() => _TraderListingsScreenState();
}

class _TraderListingsScreenState extends State<TraderListingsScreen> {
  ExportListingStatus? _filter; // null = all

  @override
  void initState() {
    super.initState();
    TradeController.instance.loadMyListings();
  }

  bool _matches(ExportListing l) {
    if (_filter == null) return true;
    return l.status == _filter;
  }

  void _showActions(ExportListing l) {
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
          bottom: MediaQuery.of(sheetCtx).padding.bottom + WBSpacing.xl,
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
              l.produce,
              style: WBTypography.cardTitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: WBSpacing.lg),
            _SheetAction(
              icon: WBIconName.more,
              label: 'Edit listing',
              onTap: () {
                Navigator.of(sheetCtx).pop();
                context.push('${AppRoutes.traderListings}/edit?id=${l.id}');
              },
            ),
            _SheetAction(
              icon: WBIconName.check,
              label: l.status == ExportListingStatus.sold
                  ? 'Mark active again'
                  : 'Mark sold',
              onTap: () {
                TradeController.instance.update(
                  ExportListing(
                    id: l.id,
                    produce: l.produce,
                    quantityKg: l.quantityKg,
                    pricePerKgNaira: l.pricePerKgNaira,
                    harvestDate: l.harvestDate,
                    originCorridor: l.originCorridor,
                    destinationCorridor: l.destinationCorridor,
                    farmName: l.farmName,
                    farmRegion: l.farmRegion,
                    imageUrl: l.imageUrl,
                    enquiries: l.enquiries,
                    status: l.status == ExportListingStatus.sold
                        ? ExportListingStatus.active
                        : ExportListingStatus.sold,
                  ),
                );
                Navigator.of(sheetCtx).pop();
                wbShowSnack(context, '${l.produce} status updated');
              },
            ),
            _SheetAction(
              icon: WBIconName.close,
              label: 'Delete listing',
              danger: true,
              onTap: () {
                TradeController.instance.remove(l.id);
                Navigator.of(sheetCtx).pop();
                wbShowSnack(context, '${l.produce} removed');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ValueListenableBuilder(
        valueListenable: TradeController.instance.listings,
        builder: (_, listings, _) {
          final filtered = [for (final l in listings) if (_matches(l)) l];
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              WBSpacing.screenPadding,
              12,
              WBSpacing.screenPadding,
              140,
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your listings', style: WBTypography.page),
                        Text(
                          '${listings.length} total · ${listings.where((l) => l.status == ExportListingStatus.active).length} active',
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  WBButton(
                    label: 'Post',
                    size: WBButtonSize.sm,
                    trailingIcon: WBIconName.plus,
                    onPressed: () =>
                        context.push('${AppRoutes.traderListings}/edit'),
                  ),
                ],
              ),
              const SizedBox(height: WBSpacing.lg),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: ExportListingStatus.values.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    if (i == 0) {
                      return WBTag(
                        label: 'All',
                        active: _filter == null,
                        onTap: () => setState(() => _filter = null),
                      );
                    }
                    final s = ExportListingStatus.values[i - 1];
                    return WBTag(
                      label: s.label,
                      active: _filter == s,
                      onTap: () => setState(() => _filter = s),
                    );
                  },
                ),
              ),
              const SizedBox(height: WBSpacing.lg),
              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: WBColors.bgSoft,
                    borderRadius: BorderRadius.circular(WBRadius.card),
                  ),
                  child: Text(
                    _filter == null
                        ? context.l10n.traderListingsEmpty
                        : 'No ${_filter!.label.toLowerCase()} listings.',
                    style: WBTypography.body.copyWith(
                      color: WBColors.fgSecondary,
                      fontSize: 14,
                    ),
                  ),
                )
              else
                for (final l in filtered)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onLongPress: () => _showActions(l),
                      child: ExportListingCard(
                        listing: l,
                        showStatus: true,
                        onTap: () => context.push(
                          '${AppRoutes.traderListings}/edit?id=${l.id}',
                        ),
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });
  final WBIconName icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: danger ? const Color(0x14EF4444) : WBColors.bgSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: WBIcon(
                icon,
                size: 16,
                color: danger ? WBColors.statusError : WBColors.fgHeader,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: WBTypography.body.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: danger ? WBColors.statusError : WBColors.fgHeader,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
