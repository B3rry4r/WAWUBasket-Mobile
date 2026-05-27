import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../home/domain/models/vendor.dart';
import '../../../home/presentation/widgets/search_field.dart';
import '../../data/catalog_api.dart';
import '../../domain/models/product.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _filters = [
    'All',
    'Vendors',
    'Dishes',
    'Near me',
    '4.5+',
    'Free delivery',
  ];
  static const _navSafePad = 120.0;

  final _query = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;

  String _activeFilter = 'All';
  List<String> _recent = ['Jollof rice', 'Suya platter', 'Smoothies', 'Pasta'];

  List<Vendor> _idleVendors = const [];
  List<Vendor> _vendors = const [];
  List<Product> _products = const [];
  bool _loading = false;
  String? _error;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
    _loadIdleVendors();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _loadIdleVendors() async {
    try {
      final vendors = await CatalogApi.instance.vendors();
      if (mounted) setState(() => _idleVendors = vendors);
    } on ApiException {
      // The idle storefront list is non-critical — leave it empty.
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() {
        _searched = false;
        _vendors = const [];
        _products = const [];
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _run(value));
  }

  Future<void> _run(String value) async {
    setState(() {
      _loading = true;
      _error = null;
      _searched = true;
    });
    try {
      final vendors = await CatalogApi.instance.vendors(query: value);
      final products = await CatalogApi.instance.items(query: value);
      if (!mounted) return;
      setState(() {
        _vendors = vendors;
        _products = products;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    }
  }

  void _runRecent(String term) {
    _query.text = term;
    _onChanged(term);
    _run(term);
  }

  @override
  Widget build(BuildContext context) {
    final showVendors = _activeFilter != 'Dishes';
    final showDishes = _activeFilter != 'Vendors';

    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            12,
            WBSpacing.screenPadding,
            _navSafePad,
          ),
          children: [
            Row(
              children: [
                WBBackChip(onPressed: () => context.go(AppRoutes.home)),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: WBColors.surfaceInput,
                      borderRadius: BorderRadius.circular(WBRadius.input),
                      border: Border.all(color: WBColors.borderFilled),
                    ),
                    child: Row(
                      children: [
                        const WBIcon(WBIconName.search, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _query,
                            focusNode: _focus,
                            onChanged: _onChanged,
                            textInputAction: TextInputAction.search,
                            onSubmitted: _run,
                            decoration: InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: context.l10n.searchPlaceholder,
                              hintStyle: WBTypography.body.copyWith(
                                color: WBColors.fgPlaceholder,
                              ),
                            ),
                            style: WBTypography.body,
                          ),
                        ),
                        if (_query.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _query.clear();
                              _onChanged('');
                            },
                            child: const WBIcon(
                              WBIconName.close,
                              size: 16,
                              color: WBColors.fgPlaceholder,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => WBTag(
                  label: _filters[i],
                  active: _filters[i] == _activeFilter,
                  onTap: () => setState(() => _activeFilter = _filters[i]),
                ),
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            if (!_searched) ...[
              if (_recent.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.searchRecentTitle,
                      style: WBTypography.cardTitle
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _recent = const []);
                        wbShowSnack(context, context.l10n.searchRecentCleared);
                      },
                      child: Text(
                        context.l10n.searchRecentClear,
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: WBSpacing.sm + 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _recent
                      .map((r) => GestureDetector(
                            onTap: () => _runRecent(r),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: WBColors.bgSoft,
                                borderRadius:
                                    BorderRadius.circular(WBRadius.pill),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const WBIcon(
                                    WBIconName.clock,
                                    size: 14,
                                    color: WBColors.fgPlaceholder,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    r,
                                    style: WBTypography.caption.copyWith(
                                      color: WBColors.fgHeader,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => setState(
                                        () => _recent = _recent
                                            .where((e) => e != r)
                                            .toList()),
                                    child: const WBIcon(
                                      WBIconName.close,
                                      size: 12,
                                      color: WBColors.fgPlaceholder,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: WBSpacing.lg),
                const WBDivider(),
                const SizedBox(height: WBSpacing.lg),
              ],
              SectionHeader(title: context.l10n.searchVendors),
              const SizedBox(height: WBSpacing.sm + 4),
              for (final vendor in _idleVendors.take(2)) ...[
                _VendorRow(vendor: vendor),
                const SizedBox(height: WBSpacing.sm + 4),
              ],
            ] else if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
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
            else if (_vendors.isEmpty && _products.isEmpty)
              _hint('Nothing matched "${_query.text}".')
            else ...[
              if (showVendors && _vendors.isNotEmpty) ...[
                SectionHeader(title: context.l10n.searchVendors),
                const SizedBox(height: WBSpacing.sm + 4),
                for (final v in _vendors) ...[
                  _VendorRow(vendor: v),
                  const SizedBox(height: WBSpacing.sm + 4),
                ],
              ],
              if (showDishes && _products.isNotEmpty) ...[
                const SizedBox(height: WBSpacing.sm),
                SectionHeader(title: context.l10n.searchDishes),
                const SizedBox(height: WBSpacing.sm + 4),
                for (final p in _products) ...[
                  WBProductCard(
                    imageUrl: p.imageUrl,
                    name: p.name,
                    vendorName: p.vendorName,
                    priceLabel: p.formattedPrice,
                    description: p.description,
                    variant: WBProductCardVariant.row,
                    onTap: () =>
                        context.push('${AppRoutes.product}/${p.id}'),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ],
          ],
        ),
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

class _VendorRow extends StatelessWidget {
  const _VendorRow({required this.vendor});
  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${AppRoutes.vendor}/${vendor.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: WBColors.surfaceCard,
          borderRadius: BorderRadius.circular(WBRadius.card),
          boxShadow: WBShadows.card,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 72,
                height: 72,
                child: WBNetworkImage(url: vendor.imageUrl),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor.name,
                    style: WBTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vendor.cuisine,
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const WBIcon(WBIconName.star, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        vendor.rating.toString(),
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgHeader,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '· ${vendor.etaLabel}',
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '· ${vendor.feeLabel}',
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (vendor.badge != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: WBColors.bgSoft,
                  borderRadius: BorderRadius.circular(WBRadius.pill),
                ),
                child: Text(
                  vendor.badge!,
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgHeader,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
