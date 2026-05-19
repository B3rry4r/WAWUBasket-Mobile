import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../home/presentation/widgets/search_field.dart';
import '../../application/mock_data.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _filters = ['All', 'Vendors', 'Dishes', 'Near me', '4.5+', 'Free delivery'];
  static const _recent = ['Jollof rice', 'Suya platter', 'Smoothies', 'Pasta'];
  static const _navSafePad = 120.0;

  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
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
              WBBackChip(
                onPressed: () => context.go(AppRoutes.home),
              ),
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
                        child: Text(
                          'Jollof rice',
                          style: WBTypography.body.copyWith(
                            color: WBColors.fgHeader,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.home),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent searches',
                style: WBTypography.cardTitle.copyWith(fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () => wbShowSnack(context, 'Recent searches cleared'),
                child: Text(
                  'Clear',
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
                .map((r) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: WBColors.bgSoft,
                        borderRadius: BorderRadius.circular(WBRadius.pill),
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
                          const WBIcon(
                            WBIconName.close,
                            size: 12,
                            color: WBColors.fgPlaceholder,
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: WBSpacing.lg),
          const WBDivider(),
          const SizedBox(height: WBSpacing.lg),
          const SectionHeader(title: 'Vendors'),
          const SizedBox(height: WBSpacing.sm + 4),
          for (final vendor in MockData.vendors.take(2)) ...[
            GestureDetector(
              onTap: () =>
                  context.push('${AppRoutes.vendor}/${vendor.id}'),
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
            ),
            const SizedBox(height: WBSpacing.sm + 4),
          ],
        ],
        ),
      ),
    );
  }
}
