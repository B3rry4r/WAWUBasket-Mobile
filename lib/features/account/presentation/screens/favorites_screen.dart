import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../home/domain/models/vendor.dart';
import '../../../home/presentation/widgets/ds_vendor_card.dart';
import '../../../shopping/domain/models/product.dart';
import '../../data/account_extras_api.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _tab = 'vendors';

  List<Vendor>? _vendors;
  List<Product> _items = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final res = await AccountExtrasApi.instance.favorites();
      final vendors = (res['vendors'] as List?) ?? const [];
      final items = (res['items'] as List?) ?? const [];
      if (!mounted) return;
      setState(() {
        _vendors = [
          for (final v in vendors)
            Vendor.fromJson((v as Map).cast<String, dynamic>()),
        ];
        _items = [
          for (final i in items)
            Product.fromJson((i as Map).cast<String, dynamic>()),
        ];
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendors = _vendors;
    final count = _tab == 'vendors'
        ? '${vendors?.length ?? 0} vendors'
        : '${_items.length} dishes';

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
              Text(context.l10n.favoritesTitle, style: WBTypography.page),
              Text(
                count,
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
              borderRadius: BorderRadius.circular(WBRadius.pill),
            ),
            child: Row(
              children: [
                _SegmentTab(
                  label: context.l10n.favoritesVendorsTab,
                  active: _tab == 'vendors',
                  onTap: () => setState(() => _tab = 'vendors'),
                ),
                _SegmentTab(
                  label: context.l10n.favoritesDishesTab,
                  active: _tab == 'dishes',
                  onTap: () => setState(() => _tab = 'dishes'),
                ),
              ],
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          if (vendors == null && _error == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 56),
              child: Center(
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor:
                        AlwaysStoppedAnimation(WBColors.surfaceDark),
                  ),
                ),
              ),
            )
          else if (_error != null)
            _hint(_error!)
          else if (_tab == 'vendors') ...[
            if (vendors!.isEmpty)
              _hint(context.l10n.favoritesNoVendors)
            else
              for (var i = 0; i < vendors.length; i++) ...[
                DSVendorCard(
                  vendor: vendors[i],
                  onTap: () => context.push(
                    '${AppRoutes.vendor}/${vendors[i].id}',
                  ),
                ),
                if (i != vendors.length - 1)
                  const SizedBox(height: WBSpacing.md),
              ],
          ] else ...[
            if (_items.isEmpty)
              _hint(context.l10n.favoritesNoDishes)
            else
              for (var i = 0; i < _items.length; i++) ...[
                WBProductCard(
                  imageUrl: _items[i].imageUrl,
                  name: _items[i].name,
                  vendorName: _items[i].vendorName,
                  priceLabel: _items[i].formattedPrice,
                  description: _items[i].description,
                  variant: WBProductCardVariant.row,
                  onTap: () => context.push(
                    '${AppRoutes.product}/${_items[i].id}',
                  ),
                ),
                if (i != _items.length - 1) const SizedBox(height: 12),
              ],
          ],
        ],
      ),
    );
  }

  Widget _hint(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(WBSpacing.md + 4),
        decoration: BoxDecoration(
          color: WBColors.bgSoft,
          borderRadius: BorderRadius.circular(WBRadius.card),
        ),
        child: Text(
          text,
          style: WBTypography.caption.copyWith(color: WBColors.fgSecondary),
        ),
      );
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
            borderRadius: BorderRadius.circular(WBRadius.pill),
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
