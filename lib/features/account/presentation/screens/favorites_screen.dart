import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../home/presentation/widgets/ds_vendor_card.dart';
import '../../../shopping/application/mock_data.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _tab = 'vendors';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          WBSpacing.screenPadding,
          12 + MediaQuery.of(context).padding.top,
          WBSpacing.screenPadding,
          120,
        ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Favorites', style: WBTypography.page),
              Text(
                _tab == 'vendors'
                    ? '${MockData.vendors.length} vendors'
                    : '${MockData.menu.length} dishes',
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: WBSpacing.md),
          // Segment tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: WBColors.bgSecondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _SegmentTab(
                  label: 'Vendors',
                  active: _tab == 'vendors',
                  onTap: () => setState(() => _tab = 'vendors'),
                ),
                _SegmentTab(
                  label: 'Dishes',
                  active: _tab == 'dishes',
                  onTap: () => setState(() => _tab = 'dishes'),
                ),
              ],
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          if (_tab == 'vendors') ...[
            for (var i = 0; i < MockData.vendors.length; i++) ...[
              DSVendorCard(
                vendor: MockData.vendors[i],
                onTap: () => context.push(AppRoutes.vendor),
              ),
              if (i != MockData.vendors.length - 1)
                const SizedBox(height: WBSpacing.md),
            ],
          ] else ...[
            for (var i = 0; i < MockData.menu.length; i++) ...[
              WBProductCard(
                imageUrl: MockData.menu[i].imageUrl,
                name: MockData.menu[i].name,
                vendorName: MockData.menu[i].vendorName,
                priceLabel: MockData.menu[i].formattedPrice,
                description: MockData.menu[i].description,
                variant: WBProductCardVariant.row,
                onTap: () => context.push(AppRoutes.product),
                onAdd: () => wbShowSnack(context, 'Added to basket'),
              ),
              if (i != MockData.menu.length - 1) const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: WBMotion.base,
          curve: WBMotion.easeSoft,
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? WBColors.surfaceDark : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: WBTypography.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : WBColors.fgSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
