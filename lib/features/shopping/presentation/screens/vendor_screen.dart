import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../application/mock_data.dart';
import '../widgets/sticky_action_bar.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key, this.vendorId});

  /// Id of the tapped storefront. Null only on legacy direct pushes —
  /// the screen then falls back to the first vendor.
  final String? vendorId;

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  static const _tabs = ['All', 'Mains', 'Sides', 'Drinks'];
  String _activeTab = 'All';

  @override
  Widget build(BuildContext context) {
    final vendor = MockData.vendorById(widget.vendorId);
    final menu = MockData.productsForVendor(vendor.name);
    // Fall back to the full menu when this vendor has no dedicated
    // items in the mock data so the storefront is never empty.
    final items = menu.isEmpty ? MockData.menu : menu;
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    height: 260,
                    width: double.infinity,
                    child: WBNetworkImage(url: vendor.imageUrl),
                  ),
                  Positioned(
                    top: 56,
                    left: WBSpacing.screenPadding,
                    child: WBBackChip(onPressed: () => context.pop()),
                  ),
                  Positioned(
                    top: 56,
                    right: WBSpacing.screenPadding,
                    child: WBCircleIconButton(
                      icon: WBIconName.heart,
                      onPressed: () => wbShowSnack(context, 'Saved to favorites'),
                    ),
                  ),
                ],
              ),
              Transform.translate(
                offset: const Offset(0, -36),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: WBSpacing.screenPadding,
                  ),
                  child: WBCard(
                    padding: const EdgeInsets.all(WBSpacing.md + 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(vendor.name, style: WBTypography.page),
                        const SizedBox(height: 4),
                        Text(
                          '${vendor.cuisine} · Lagos Island',
                          style: WBTypography.secondary,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const WBIcon(WBIconName.star, size: 14),
                            const SizedBox(width: 5),
                            Text(
                              vendor.rating.toString(),
                              style: WBTypography.caption.copyWith(
                                color: WBColors.fgHeader,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${vendor.reviews.toString()})',
                              style: WBTypography.caption.copyWith(
                                color: WBColors.fgSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const WBIcon(
                              WBIconName.clock,
                              size: 14,
                              color: WBColors.fgSecondary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              vendor.etaLabel,
                              style: WBTypography.caption.copyWith(
                                color: WBColors.fgSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const WBIcon(
                              WBIconName.bike,
                              size: 14,
                              color: WBColors.fgSecondary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              vendor.feeLabel,
                              style: WBTypography.caption.copyWith(
                                color: WBColors.fgSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: WBSpacing.screenPadding,
                  ),
                  itemCount: _tabs.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => WBTag(
                    label: _tabs[i],
                    active: _tabs[i] == _activeTab,
                    onTap: () => setState(() => _activeTab = _tabs[i]),
                  ),
                ),
              ),
              const SizedBox(height: WBSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: WBSpacing.screenPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Text(
                        'Mains',
                        style: WBTypography.cardTitle,
                      ),
                    ),
                    for (var i = 0; i < items.length; i++) ...[
                      WBProductCard(
                        imageUrl: items[i].imageUrl,
                        name: items[i].name,
                        vendorName: items[i].vendorName,
                        priceLabel: items[i].formattedPrice,
                        description: items[i].description,
                        variant: WBProductCardVariant.row,
                        onTap: () => context.push(
                          '${AppRoutes.product}/${items[i].id}',
                        ),
                        onAdd: () => context.push(
                          '${AppRoutes.product}/${items[i].id}',
                        ),
                      ),
                      if (i != items.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StickyActionBar(
              child: WBButton(
                label: 'View basket',
                fullWidth: true,
                size: WBButtonSize.lg,
                leading: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                trailing: const Text(
                  '₦9,700',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () => context.push(AppRoutes.cart),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
