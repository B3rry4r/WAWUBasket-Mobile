import 'package:flutter/material.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../domain/models/supplier.dart';
import '../../../../core/utils/wb_l10n.dart';

class SupplierCard extends StatelessWidget {
  const SupplierCard({
    super.key,
    required this.supplier,
    this.onTap,
    this.onConnect,
  });

  final Supplier supplier;
  final VoidCallback? onTap;
  final VoidCallback? onConnect;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
      padding: const EdgeInsets.all(WBSpacing.md),
      decoration: BoxDecoration(
        color: WBColors.surfaceCard,
        borderRadius: BorderRadius.circular(WBRadius.card),
        boxShadow: WBShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: WBNetworkImage(url: supplier.avatarUrl),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      style: WBTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      supplier.region,
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const WBIcon(WBIconName.star, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          supplier.rating.toString(),
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgHeader,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '· ${supplier.reviews} reviews',
                          style: WBTypography.caption.copyWith(
                            color: WBColors.fgSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: WBColors.bgSoft,
              borderRadius: BorderRadius.circular(WBRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const WBIcon(WBIconName.basket, size: 12),
                const SizedBox(width: 6),
                Text(
                  supplier.capacity,
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgHeader,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in supplier.specialties)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
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
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          WBButton(
            label: context.l10n.supplierConnect,
            size: WBButtonSize.sm,
            fullWidth: true,
            trailingIcon: WBIconName.arrowRight,
            onPressed: onConnect ?? onTap ?? () {},
          ),
        ],
      ),
    ),
    );
  }
}
