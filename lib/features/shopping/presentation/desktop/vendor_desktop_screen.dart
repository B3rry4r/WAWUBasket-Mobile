import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../account/data/account_extras_api.dart';
import '../../../home/domain/models/vendor.dart';
import '../../../shell/presentation/desktop/customer_web_scaffold.dart';
import '../../application/cart_controller.dart';
import '../../data/catalog_api.dart';
import '../../domain/models/product.dart';

/// Desktop-web layout for a vendor storefront. Mirrors [VendorScreen]'s data
/// loading, favorite toggle, subcategory tabs and product navigation, re-laid
/// out for a wide window: a full-bleed hero banner above a two-column body
/// (menu list on the left, vendor info + view-basket action on the right).
class VendorDesktopScreen extends ConsumerStatefulWidget {
  const VendorDesktopScreen({super.key, this.vendorId});

  /// Id of the tapped storefront.
  final String? vendorId;

  @override
  ConsumerState<VendorDesktopScreen> createState() =>
      _VendorDesktopScreenState();
}

class _VendorDesktopScreenState extends ConsumerState<VendorDesktopScreen> {
  List<String> _tabs = const ['All'];
  String _activeTab = 'All';

  Vendor? _vendor;
  List<Product> _menu = const [];
  String? _error;
  bool _isFavorited = false;
  bool _togglingFavorite = false;

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
      final subs = result.menu
          .map((p) => p.subcategoryId)
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();
      setState(() {
        _vendor = result.vendor;
        _menu = result.menu;
        _tabs = ['All', ...subs];
        _activeTab = 'All';
      });
      _loadFavoriteState(id);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _loadFavoriteState(String vendorId) async {
    try {
      final data = await AccountExtrasApi.instance.favorites();
      final vendors = (data['vendors'] as List?) ?? const [];
      final favorited = vendors.any((v) {
        final id = v is Map ? (v['id'] ?? v['vendorId']) : v;
        return id?.toString() == vendorId;
      });
      if (mounted) setState(() => _isFavorited = favorited);
    } on ApiException {
      // Leave default (false) — non-critical.
    }
  }

  Future<void> _toggleFavorite() async {
    final id = widget.vendorId;
    if (id == null || _togglingFavorite) return;
    setState(() => _togglingFavorite = true);
    // Optimistic update
    final wasF = _isFavorited;
    setState(() => _isFavorited = !wasF);
    try {
      await AccountExtrasApi.instance.toggleFavoriteVendor(id);
      if (!mounted) return;
      wbShowSnack(
        context,
        _isFavorited ? 'Saved to favorites' : 'Removed from favorites',
      );
    } on ApiException catch (e) {
      // Revert on error
      if (mounted) setState(() => _isFavorited = wasF);
      if (mounted) wbShowError(context, e.message);
    } finally {
      if (mounted) setState(() => _togglingFavorite = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return CustomerWebScaffold(
        child: _StateBody(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style:
                    WBTypography.body.copyWith(color: WBColors.fgSecondary),
              ),
              const SizedBox(height: 14),
              WBButton(
                label: context.l10n.actionRetry,
                size: WBButtonSize.sm,
                variant: WBButtonVariant.secondary,
                onPressed: _load,
              ),
            ],
          ),
        ),
      );
    }
    if (_vendor == null) {
      return const CustomerWebScaffold(
        child: _StateBody(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              valueColor: AlwaysStoppedAnimation(WBColors.surfaceDark),
            ),
          ),
        ),
      );
    }

    final vendor = _vendor!;
    final items = _activeTab == 'All'
        ? _menu
        : _menu.where((p) => p.subcategoryId == _activeTab).toList();

    return CustomerWebScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: WBSpacing.lg),
        child: WBMaxWidth(
          maxWidth: WBBreakpoints.maxContent,
          padding: const EdgeInsets.symmetric(
            horizontal: WBSpacing.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WBBackChip(onPressed: () => context.pop()),
              const SizedBox(height: WBSpacing.md),
              _Hero(
                vendor: vendor,
                isFavorited: _isFavorited,
                onToggleFavorite: _toggleFavorite,
              ),
              const SizedBox(height: WBSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _MenuColumn(
                      vendor: vendor,
                      tabs: _tabs,
                      activeTab: _activeTab,
                      items: items,
                      onSelectTab: (t) => setState(() => _activeTab = t),
                    ),
                  ),
                  const SizedBox(width: WBSpacing.lg),
                  SizedBox(
                    width: 320,
                    child: _InfoSidebar(vendor: vendor),
                  ),
                ],
              ),
              const SizedBox(height: WBSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-bleed hero banner with the storefront image, back is handled above; the
/// favorite toggle sits in the top-right corner exactly as on mobile.
class _Hero extends StatelessWidget {
  const _Hero({
    required this.vendor,
    required this.isFavorited,
    required this.onToggleFavorite,
  });

  final Vendor vendor;
  final bool isFavorited;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(WBRadius.card),
      child: Stack(
        children: [
          SizedBox(
            height: 320,
            width: double.infinity,
            child: WBNetworkImage(url: vendor.imageUrl),
          ),
          Positioned(
            top: WBSpacing.md,
            right: WBSpacing.md,
            child: WBCircleIconButton(
              icon: WBIconName.heart,
              iconColor:
                  isFavorited ? WBColors.statusError : WBColors.fgHeader,
              onPressed: onToggleFavorite,
            ),
          ),
        ],
      ),
    );
  }
}

/// Left column: subcategory tab chips above a single-column menu of product
/// rows. Reuses [WBProductCard] in its [WBProductCardVariant.row] variant.
class _MenuColumn extends StatelessWidget {
  const _MenuColumn({
    required this.vendor,
    required this.tabs,
    required this.activeTab,
    required this.items,
    required this.onSelectTab,
  });

  final Vendor vendor;
  final List<String> tabs;
  final String activeTab;
  final List<Product> items;
  final ValueChanged<String> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tab in tabs)
              WBTag(
                label: context.subcategoryLabel(
                  tab == 'All' ? 'all' : tab,
                  fallback: _tabLabel(tab),
                ),
                active: tab == activeTab,
                onTap: () => onSelectTab(tab),
              ),
          ],
        ),
        const SizedBox(height: WBSpacing.md),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Nothing on the menu under this filter.',
              style:
                  WBTypography.caption.copyWith(color: WBColors.fgSecondary),
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
              onTap: () => context.push('${AppRoutes.product}/${items[i].id}'),
              onAdd: () => context.push('${AppRoutes.product}/${items[i].id}'),
            ),
            if (i != items.length - 1) const SizedBox(height: 12),
          ],
      ],
    );
  }
}

/// Right column: the vendor's name, cuisine, rating/eta/fee meta and the
/// view-basket action. Reuses the live cart totals from [cartControllerProvider].
class _InfoSidebar extends ConsumerWidget {
  const _InfoSidebar({required this.vendor});

  final Vendor vendor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final cartCount = cart.items.fold<int>(0, (s, l) => s + l.quantity);
    final cartTotal = cart.items.fold<int>(0, (s, l) => s + l.total);

    return WBCard(
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
          const SizedBox(height: WBSpacing.md),
          _MetaRow(
            icon: WBIconName.star,
            iconColor: WBColors.fgHeader,
            child: Row(
              children: [
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
              ],
            ),
          ),
          const SizedBox(height: 10),
          _MetaRow(
            icon: WBIconName.clock,
            iconColor: WBColors.fgSecondary,
            child: Text(
              vendor.etaLabel,
              style: WBTypography.caption.copyWith(
                color: WBColors.fgSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _MetaRow(
            icon: WBIconName.bike,
            iconColor: WBColors.fgSecondary,
            child: Text(
              vendor.feeLabel,
              style: WBTypography.caption.copyWith(
                color: WBColors.fgSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          WBButton(
            label: context.l10n.shoppingViewBasket,
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
              child: Text(
                '$cartCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing: Text(
              '₦${_naira(cartTotal)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () => context.push(AppRoutes.cart),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  final WBIconName icon;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        WBIcon(icon, size: 14, color: iconColor),
        const SizedBox(width: 6),
        Expanded(child: child),
      ],
    );
  }
}

/// Centered body used for the loading + error states, capped to the content
/// width so the spinner / message sits centered under the web chrome.
class _StateBody extends StatelessWidget {
  const _StateBody({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WBMaxWidth(
      maxWidth: WBBreakpoints.maxContent,
      padding: const EdgeInsets.all(WBSpacing.screenPadding),
      alignment: Alignment.center,
      child: Center(child: child),
    );
  }
}

String _tabLabel(String id) {
  if (id == 'All') return 'All';
  return id
      .split('-')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

String _naira(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i != 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
