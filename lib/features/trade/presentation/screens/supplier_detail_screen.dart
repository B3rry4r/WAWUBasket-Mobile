import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../shopping/application/mock_data.dart';
import '../widgets/bulk_lot_card.dart';

class SupplierDetailScreen extends StatelessWidget {
  const SupplierDetailScreen({super.key, required this.supplierId});

  final String supplierId;

  @override
  Widget build(BuildContext context) {
    final supplier = MockData.suppliers.firstWhere(
      (s) => s.id == supplierId,
      orElse: () => MockData.suppliers.first,
    );
    final lots = [
      for (final l in MockData.bulkLots)
        if (l.supplierName == supplier.name) l,
    ];

    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                WBSpacing.screenPadding,
                12,
                WBSpacing.screenPadding,
                140,
              ),
              children: [
                Row(
                  children: [
                    WBBackChip(onPressed: () => context.pop()),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text('Supplier', style: WBTypography.page),
                    ),
                  ],
                ),
                const SizedBox(height: WBSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(WBSpacing.lg),
                  decoration: BoxDecoration(
                    color: WBColors.surfaceDark,
                    borderRadius: BorderRadius.circular(WBRadius.card),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: 64,
                              height: 64,
                              child: WBNetworkImage(url: supplier.avatarUrl),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  supplier.name,
                                  style: WBTypography.cardTitle.copyWith(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  supplier.region,
                                  style: WBTypography.caption.copyWith(
                                    color: Colors.white.withValues(alpha: 0.65),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _DarkStat(
                            label: 'Rating',
                            value: supplier.rating.toString(),
                          ),
                          const SizedBox(width: 10),
                          _DarkStat(
                            label: 'Reviews',
                            value: supplier.reviews.toString(),
                          ),
                          const SizedBox(width: 10),
                          _DarkStat(
                            label: 'Capacity',
                            value: supplier.capacity,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: WBSpacing.lg),
                Text(
                  'Specialties',
                  style: WBTypography.cardTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in supplier.specialties)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: WBColors.surfaceTag,
                          borderRadius: BorderRadius.circular(WBRadius.pill),
                        ),
                        child: Text(
                          s,
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgHeader,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: WBSpacing.lg),
                Text(
                  'About this supplier',
                  style: WBTypography.cardTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 10),
                WBCard(
                  child: Text(
                    'Verified farm partner sourcing directly from co-op members in ${supplier.region}. '
                    'Quality-controlled at the warehouse and shipped nationwide with traceable batch lots.',
                    style: WBTypography.body.copyWith(
                      fontSize: 14,
                      height: 1.5,
                      color: WBColors.fgSecondary,
                    ),
                  ),
                ),
                if (lots.isNotEmpty) ...[
                  const SizedBox(height: WBSpacing.lg),
                  Text(
                    'Available bulk lots',
                    style: WBTypography.cardTitle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: lots.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.62,
                    ),
                    itemBuilder: (_, i) => BulkLotCard(
                      lot: lots[i],
                      onTap: () => context.push(
                        '${AppRoutes.tradeLot}/${lots[i].id}',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  WBSpacing.screenPadding,
                  0,
                  WBSpacing.screenPadding,
                  20,
                ),
                child: WBButton(
                  label: 'Connect with supplier',
                  fullWidth: true,
                  size: WBButtonSize.lg,
                  trailingIcon: WBIconName.arrowRight,
                  onPressed: () {
                    wbShowSnack(
                      context,
                      'Connection request sent to ${supplier.name}',
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkStat extends StatelessWidget {
  const _DarkStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: WBTypography.label.copyWith(
                color: Colors.white.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500,
                fontSize: 9,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: WBTypography.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
