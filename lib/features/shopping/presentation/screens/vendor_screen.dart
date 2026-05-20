import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../home/domain/models/vendor.dart';
import '../../data/catalog_api.dart';
import '../../domain/models/product.dart';
import '../widgets/sticky_action_bar.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key, this.vendorId});

  /// Id of the tapped storefront.
  final String? vendorId;

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  static const _tabs = ['All', 'Mains', 'Sides', 'Drinks'];
  String _activeTab = 'All';

  Vendor? _vendor;
  List<Product> _menu = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final id = widget.vendorId;
    if (id == null || id.isEmpty) {
      setState(() => _error = 'Storefront not found.');
      return;
    }
    try {
      final result = await CatalogApi.instance.vendorDetail(id);
      if (!mounted) return;
      setState(() {
        _vendor = result.vendor;
        _menu = result.menu;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _StateScaffold(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!,
                textAlign: TextAlign.center,
                style: WBTypography.body
                    .copyWith(color: WBColors.fgSecondary)),
            const SizedBox(height: 14),
            WBButton(
              label: 'Try again',
              size: WBButtonSize.sm,
              variant: WBButtonVariant.secondary,
              onPressed: _load,
            ),
          ],
        ),
      );
    }
    if (_vendor == null) {
      return const _StateScaffold(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.6,
            valueColor: AlwaysStoppedAnimation(WBColors.surfaceDark),
          ),
        ),
      );
    }

    final vendor = _vendor!;
    final items = _activeTab == 'All'
        ? _menu
        : _menu.where((p) => p.categoryId == _activeTab).toList();

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
                      onPressed: () =>
                          wbShowSnack(context, 'Saved to favorites'),
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
                          vendor.cuisine.isEmpty
                              ? 'Lagos Island'
                              : '${vendor.cuisine} · Lagos Island',
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
                              '(${vendor.reviews})',
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
                      child: Text('Menu', style: WBTypography.cardTitle),
                    ),
                    if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Nothing on the menu under this filter.',
                          style: WBTypography.caption
                              .copyWith(color: WBColors.fgSecondary),
                        ),
                      )
                    else
                      for (var i = 0; i < items.length; i++) ...[
                        WBProductCard(
                          imageUrl: items[i].imageUrl,
                          name: items[i].name,
                          vendorName: vendor.name,
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
                        if (i != items.length - 1)
                          const SizedBox(height: 12),
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
                trailingIcon: WBIconName.arrowRight,
                onPressed: () => context.push(AppRoutes.cart),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared scaffold for the vendor screen's loading + error states.
class _StateScaffold extends StatelessWidget {
  const _StateScaffold({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(WBSpacing.screenPadding),
              child: WBBackChip(onPressed: () => context.pop()),
            ),
            Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(WBSpacing.screenPadding),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
