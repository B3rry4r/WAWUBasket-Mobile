import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/guest_mode.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../home/domain/models/vendor.dart';
import '../../../home/presentation/widgets/ds_vendor_card.dart';
import '../../../shopping/domain/models/product.dart';
import '../../data/account_extras_api.dart';

/// Desktop-web layout for the customer Favorites tab. Body content only — the
/// [CustomerWebScaffold] already supplies the top bar. Mirrors the mobile
/// [FavoritesScreen] data loading, guest gating, tab state and navigation; the
/// vendor/dish lists are re-laid-out as multi-column grids reusing the same
/// card widgets.
class FavoritesDesktopScreen extends StatefulWidget {
  const FavoritesDesktopScreen({super.key});

  @override
  State<FavoritesDesktopScreen> createState() => _FavoritesDesktopScreenState();
}

class _FavoritesDesktopScreenState extends State<FavoritesDesktopScreen> {
  String _tab = 'vendors';

  List<Vendor>? _vendors;
  List<Product> _items = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    if (!GuestModeController.instance.isGuest.value) _load();
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
    return ValueListenableBuilder<bool>(
      valueListenable: GuestModeController.instance.isGuest,
      builder: (_, isGuest, _) {
        if (isGuest) return _buildGuest(context);
        return _buildSignedIn(context);
      },
    );
  }

  Widget _buildGuest(BuildContext context) {
    // TODO(i18n): key=favoritesGuestTitle / favoritesGuestBody
    return WBMaxWidth(
      maxWidth: WBBreakpoints.maxReading,
      padding: const EdgeInsets.fromLTRB(
        WBSpacing.screenPadding,
        64,
        WBSpacing.screenPadding,
        64,
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: WBColors.bgSoft,
              borderRadius: BorderRadius.circular(28),
            ),
            alignment: Alignment.center,
            child: const WBIcon(
              WBIconName.heart,
              size: 36,
              color: WBColors.fgHeader,
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          Text(
            'Save what you love',
            textAlign: TextAlign.center,
            style: WBTypography.hero.copyWith(fontSize: 22),
          ),
          const SizedBox(height: WBSpacing.sm),
          Text(
            'Sign in to favorite vendors and dishes so you can find them faster next time.',
            textAlign: TextAlign.center,
            style: WBTypography.body.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: WBSpacing.xl),
          WBButton(
            label: 'Sign in',
            size: WBButtonSize.lg,
            fullWidth: true,
            trailingIcon: WBIconName.arrowRight,
            onPressed: () => context.push(AppRoutes.login),
          ),
        ],
      ),
    );
  }

  Widget _buildSignedIn(BuildContext context) {
    final vendors = _vendors;
    final count = _tab == 'vendors'
        ? '${vendors?.length ?? 0} vendors'
        : '${_items.length} dishes';

    return WBMaxWidth(
      maxWidth: WBBreakpoints.maxContent,
      padding: const EdgeInsets.fromLTRB(
        WBSpacing.screenPadding,
        WBSpacing.xl,
        WBSpacing.screenPadding,
        WBSpacing.xxl,
      ),
      child: ListView(
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
          // Segment tabs — capped so they don't stretch across the wide page.
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Container(
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
          ),
          const SizedBox(height: WBSpacing.xl),
          if (vendors == null && _error == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 72),
              child: Center(
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(WBColors.surfaceDark),
                  ),
                ),
              ),
            )
          else if (_error != null)
            _hint(_error!)
          else if (_tab == 'vendors')
            if (vendors!.isEmpty)
              _hint(context.l10n.favoritesNoVendors)
            else
              _VendorGrid(vendors: vendors)
          else if (_items.isEmpty)
            _hint(context.l10n.favoritesNoDishes)
          else
            _DishGrid(items: _items),
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

/// A flowing multi-column grid of the fixed-width [DSVendorCard]s. The cards
/// are 300px wide, so a [Wrap] fits as many columns as the capped content
/// width allows and reflows on resize.
class _VendorGrid extends StatelessWidget {
  const _VendorGrid({required this.vendors});

  final List<Vendor> vendors;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: WBSpacing.lg,
      runSpacing: WBSpacing.lg,
      children: [
        for (final v in vendors)
          DSVendorCard(
            vendor: v,
            onTap: () => context.push('${AppRoutes.vendor}/${v.id}'),
          ),
      ],
    );
  }
}

/// A two-column grid of favorite dish rows, reusing the mobile row card.
class _DishGrid extends StatelessWidget {
  const _DishGrid({required this.items});

  final List<Product> items;

  @override
  Widget build(BuildContext context) {
    const columns = 2;
    const gap = WBSpacing.lg;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final p in items)
              SizedBox(
                width: cardWidth,
                child: WBProductCard(
                  imageUrl: p.imageUrl,
                  name: p.name,
                  vendorName: p.vendorName,
                  priceLabel: p.formattedPrice,
                  description: p.description,
                  variant: WBProductCardVariant.row,
                  onTap: () => context.push('${AppRoutes.product}/${p.id}'),
                ),
              ),
          ],
        );
      },
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
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
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
      ),
    );
  }
}
