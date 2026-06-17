import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../account/data/account_extras_api.dart';
import '../../../home/domain/models/vendor.dart';
import '../../../moderation/application/blocked_content_filter.dart';
import '../../../moderation/application/blocked_users_controller.dart';
import '../../../moderation/domain/report_reason.dart';
import '../../../moderation/presentation/widgets/moderation_actions.dart';
import '../../application/cart_controller.dart';
import '../../data/catalog_api.dart';
import '../../domain/models/product.dart';
import '../widgets/sticky_action_bar.dart';

class VendorScreen extends ConsumerStatefulWidget {
  const VendorScreen({super.key, this.vendorId});

  /// Id of the tapped storefront.
  final String? vendorId;

  @override
  ConsumerState<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends ConsumerState<VendorScreen> {
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
              label: context.l10n.actionRetry,
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
    // Hide items from blocked vendors (client-side, instant).
    final blocked = ref.watch(blockedUsersProvider);
    final visibleMenu = blocked.filterProducts(_menu);
    final items = _activeTab == 'All'
        ? visibleMenu
        : visibleMenu.where((p) => p.subcategoryId == _activeTab).toList();

    final cart = ref.watch(cartControllerProvider);
    final cartCount = cart.items.fold<int>(0, (s, l) => s + l.quantity);
    final cartTotal = cart.items.fold<int>(0, (s, l) => s + l.total);

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
                    child: Row(
                      children: [
                        WBCircleIconButton(
                          icon: WBIconName.heart,
                          iconColor: _isFavorited
                              ? WBColors.statusError
                              : WBColors.fgHeader,
                          onPressed: _toggleFavorite,
                        ),
                        const SizedBox(width: 10),
                        // Report / Block this storefront (App Review 1.2).
                        WBCircleIconButton(
                          icon: WBIconName.more,
                          onPressed: () => ModerationActions.showOverflow(
                            context,
                            ref,
                            targetType: ReportTargetType.user,
                            targetId:
                                vendor.ownerUserId ?? widget.vendorId ?? '',
                            reportedUserId: vendor.ownerUserId,
                            title: vendor.name,
                            onBlocked: () {
                              if (context.mounted) context.pop();
                            },
                          ),
                        ),
                      ],
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
                    label: context.subcategoryLabel(_tabs[i] == 'All' ? 'all' : _tabs[i], fallback: _tabLabel(_tabs[i])),
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
            ),
          ),
        ],
      ),
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
