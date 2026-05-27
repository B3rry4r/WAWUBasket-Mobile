import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/vendor_menu_controller.dart';
import '../../../../core/utils/wb_l10n.dart';

class VendorMenuScreen extends StatefulWidget {
  const VendorMenuScreen({super.key});

  @override
  State<VendorMenuScreen> createState() => _VendorMenuScreenState();
}

class _VendorMenuScreenState extends State<VendorMenuScreen> {
  /// The selected filter — either "All" or a subcategory **id** so we can
  /// match against [VendorMenuItem.category] (which stores the subcategory id).
  String _filter = 'All';
  String _query = '';

  /// Tabs displayed in the horizontal pill strip. The first is always "All";
  /// subsequent entries show subcategory labels. When tapped we map back to
  /// the subcategory id via [VendorMenuController.categoryOptions].
  List<String> get _filterTabLabels {
    final opts = VendorMenuController.instance.categoryOptions.value;
    return ['All', ...opts.map((o) => o.label)];
  }

  /// The currently-selected filter as a display label for the WBTag active
  /// highlight.
  String get _currentFilterLabel {
    if (_filter == 'All') return 'All';
    final opts = VendorMenuController.instance.categoryOptions.value;
    return opts.firstWhere(
      (o) => o.id == _filter,
      orElse: () => VendorCategoryOption(id: _filter, label: _filter, parentLabel: ''),
    ).label;
  }

  /// True when [it] passes the current filter + search query.
  bool _matches(VendorMenuItem it) {
    if (_filter != 'All' && it.category != _filter) return false;
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return it.name.toLowerCase().contains(q) ||
        it.description.toLowerCase().contains(q);
  }

  /// Converts a tapped tab label back to its subcategory id and sets
  /// [_filter]. For "All" the filter stays "All".
  void _onFilterTap(String label) {
    if (label == 'All') {
      _filter = 'All';
    } else {
      final opts = VendorMenuController.instance.categoryOptions.value;
      final found = opts.firstWhere(
        (o) => o.label == label,
        orElse: () => VendorCategoryOption(id: label, label: label, parentLabel: ''),
      );
      _filter = found.id;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ValueListenableBuilder(
        valueListenable: VendorMenuController.instance.items,
        builder: (_, items, _) {
          final filtered = [
            for (final it in items)
              if (_matches(it)) it,
          ];

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
                        Text('Your menu', style: WBTypography.page),
                        Text(
                          "${items.length} dish${items.length == 1 ? '' : 'es'} · "
                          "${items.where((i) => i.available).length} available",
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  WBButton(
                    label: context.l10n.vendorMenuAdd,
                    size: WBButtonSize.sm,
                    trailingIcon: WBIconName.plus,
                    onPressed: () => context.push(AppRoutes.vendorMenuEdit),
                  ),
                ],
              ),
              const SizedBox(height: WBSpacing.md),
              WBInput(
                placeholder: context.l10n.vendorMenuSearchPlaceholder,
                leadingIcon: WBIconName.search,
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: WBSpacing.md),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filterTabLabels.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final label = _filterTabLabels[i];
                    return WBTag(
                      label: label,
                      active: label == _currentFilterLabel,
                      onTap: () => _onFilterTap(label),
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
                    _query.isNotEmpty
                        ? 'Nothing matches "$_query".'
                        : 'No dishes in this category yet.',
                    style: WBTypography.body.copyWith(
                      color: WBColors.fgSecondary,
                    ),
                  ),
                )
              else
                for (final it in filtered)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ItemCard(item: it),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});
  final VendorMenuItem item;

  void _open(BuildContext context) {
    context.push('${AppRoutes.vendorMenuEdit}?id=${item.id}');
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
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
              Text(item.name, style: WBTypography.cardTitle.copyWith(fontSize: 18)),
              const SizedBox(height: WBSpacing.lg),
              _SheetAction(
                icon: WBIconName.more,
                label: sheetCtx.l10n.vendorMenuEditDish,
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  _open(context);
                },
              ),
              _SheetAction(
                icon: WBIconName.plus,
                label: sheetCtx.l10n.vendorMenuDuplicate,
                onTap: () {
                  VendorMenuController.instance.clone(item.id);
                  Navigator.of(sheetCtx).pop();
                  wbShowSnack(context, '${item.name} duplicated');
                },
              ),
              _SheetAction(
                icon: item.available ? WBIconName.close : WBIconName.check,
                label: item.available
                    ? 'Mark out of stock'
                    : 'Mark available again',
                onTap: () {
                  VendorMenuController.instance.toggleAvailable(item.id);
                  Navigator.of(sheetCtx).pop();
                  wbShowSnack(
                    context,
                    '${item.name} is now ${item.available ? 'unavailable' : 'available'}',
                  );
                },
              ),
              _SheetAction(
                icon: WBIconName.close,
                label: sheetCtx.l10n.vendorMenuDeleteDish,
                danger: true,
                onTap: () {
                  VendorMenuController.instance.delete(item.id);
                  Navigator.of(sheetCtx).pop();
                  wbShowSnack(context, '${item.name} removed');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final faded = !item.available;
    return GestureDetector(
      onTap: () => _open(context),
      onLongPress: () => _showActions(context),
      behavior: HitTestBehavior.opaque,
      child: WBCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Opacity(
                opacity: faded ? 0.45 : 1,
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: WBNetworkImage(url: item.imageUrl),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: WBTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: faded
                                ? WBColors.fgPlaceholder
                                : WBColors.fgHeader,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.formattedPrice,
                        style: WBTypography.body.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.category} · ${item.prepMins} min prep',
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      WBStatusPill(
                        label: item.available ? 'Available' : 'Out of stock',
                        kind: item.available
                            ? WBStatusKind.success
                            : WBStatusKind.error,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _showActions(context),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: WBColors.bgSoft,
                            borderRadius: BorderRadius.circular(WBRadius.pill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const WBIcon(WBIconName.more, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Manage',
                                style: WBTypography.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
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
