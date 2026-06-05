import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../trade/application/trade_controller.dart';
import '../../../trade/domain/models/export_listing.dart';
import '../../../trade/presentation/widgets/export_listing_card.dart';

/// Desktop-web layout for the trader listings dashboard.
///
/// TAB route — the trader operator shell already supplies the sidebar and top
/// chrome, so this renders body content only. Re-lays the mobile vertical list
/// into a capped dashboard: a page header with the title + post-new CTA on the
/// right, the same status filter tags, and the listing cards in a comfortable
/// multi-column grid. Reuses [TradeController] + the [ExportListing] model and
/// the shared [ExportListingCard], mirroring the mobile data loading, filtering,
/// status logic, number / money formatting and the edit / mark-sold / delete
/// action sheet precisely — this is layout only.
class TraderListingsDesktopScreen extends StatefulWidget {
  const TraderListingsDesktopScreen({super.key});

  @override
  State<TraderListingsDesktopScreen> createState() =>
      _TraderListingsDesktopScreenState();
}

class _TraderListingsDesktopScreenState
    extends State<TraderListingsDesktopScreen> {
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

  String _illustrationFor(ExportListingStatus? filter) {
    return switch (filter) {
      ExportListingStatus.draft => WBEmptyIllustration.noDraftListing,
      ExportListingStatus.sold => WBEmptyIllustration.noSoldListing,
      ExportListingStatus.expired => WBEmptyIllustration.noExpiredListing,
      _ => WBEmptyIllustration.noActiveListing,
    };
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
              label: context.l10n.traderEditListing,
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
                wbShowSnack(
                    context, context.l10n.traderStatusUpdated(l.produce));
              },
            ),
            _SheetAction(
              icon: WBIconName.close,
              label: context.l10n.traderDeleteListing,
              danger: true,
              onTap: () {
                TradeController.instance.remove(l.id);
                Navigator.of(sheetCtx).pop();
                wbShowSnack(
                    context, context.l10n.traderListingRemoved(l.produce));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: TradeController.instance.listings,
      builder: (_, listings, _) {
        final filtered = [for (final l in listings) if (_matches(l)) l];
        return WBMaxWidth(
          maxWidth: WBBreakpoints.maxContent,
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.xl,
            WBSpacing.xl,
            WBSpacing.xl,
            40,
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.navListings, style: WBTypography.page),
                        const SizedBox(height: 2),
                        Text(
                          '${listings.length} total · ${listings.where((l) => l.status == ExportListingStatus.active).length} active',
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: WBSpacing.lg),
                  WBButton(
                    label: context.l10n.traderPostListing,
                    size: WBButtonSize.md,
                    trailingIcon: WBIconName.plus,
                    onPressed: () =>
                        context.push('${AppRoutes.traderListings}/edit'),
                  ),
                ],
              ),
              const SizedBox(height: WBSpacing.xl),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  WBTag(
                    label: context.l10n.traderFilterAll,
                    active: _filter == null,
                    onTap: () => setState(() => _filter = null),
                  ),
                  for (final s in ExportListingStatus.values)
                    WBTag(
                      label: s.label,
                      active: _filter == s,
                      onTap: () => setState(() => _filter = s),
                    ),
                ],
              ),
              const SizedBox(height: WBSpacing.lg),
              if (filtered.isEmpty)
                WBEmptyState(
                  illustration: _illustrationFor(_filter),
                  label: _filter == null
                      ? context.l10n.traderListingsEmpty
                      : 'No ${_filter!.label.toLowerCase()} listings.',
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 560,
                    mainAxisSpacing: WBSpacing.md,
                    crossAxisSpacing: WBSpacing.md,
                    mainAxisExtent: 168,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final l = filtered[i];
                    return GestureDetector(
                      onLongPress: () => _showActions(l),
                      child: ExportListingCard(
                        listing: l,
                        showStatus: true,
                        onTap: () => context.push(
                          '${AppRoutes.traderListings}/edit?id=${l.id}',
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
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
