import 'package:flutter/material.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';

/// One row inside an [AccountMenuSection]. Visually a 36-square icon tile +
/// label + optional sub + chevron. `danger=true` paints the icon tile and
/// label red (used for sign-out and delete-account rows).
class AccountMenuRow {
  const AccountMenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.sub,
    this.trailingPill,
    this.danger = false,
  });
  final WBIconName icon;
  final String label;
  final String? sub;
  final VoidCallback onTap;

  /// Optional small status pill drawn between the label column and the
  /// chevron. Used by the role switcher to surface KYC status inline.
  final Widget? trailingPill;
  final bool danger;
}

/// A titled group of rows. `title` may be empty for the "destructive
/// actions" section at the bottom of the screen.
class AccountMenuSection {
  const AccountMenuSection({required this.title, required this.rows});
  final String title;
  final List<AccountMenuRow> rows;
}

/// Renders one [AccountMenuSection] as a single rounded card with dividers
/// between rows.
class AccountMenuSectionCard extends StatelessWidget {
  const AccountMenuSectionCard({super.key, required this.section});
  final AccountMenuSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WBColors.surfaceCard,
        borderRadius: BorderRadius.circular(WBRadius.card),
        boxShadow: WBShadows.card,
      ),
      padding: const EdgeInsets.symmetric(horizontal: WBSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 2),
              child: Text(
                section.title.toUpperCase(),
                style: WBTypography.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: WBColors.fgPlaceholder,
                  letterSpacing: 0.66,
                ),
              ),
            ),
          for (var i = 0; i < section.rows.length; i++)
            _MenuRowView(
              spec: section.rows[i],
              showDivider: i != section.rows.length - 1,
            ),
        ],
      ),
    );
  }
}

class _MenuRowView extends StatelessWidget {
  const _MenuRowView({required this.spec, required this.showDivider});
  final AccountMenuRow spec;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: spec.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: WBColors.bgDivider))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: spec.danger
                    ? const Color(0x14EF4444)
                    : WBColors.bgSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: WBIcon(
                spec.icon,
                size: 17,
                color: spec.danger
                    ? WBColors.statusError
                    : WBColors.fgHeader,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spec.label,
                    style: WBTypography.body.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: spec.danger
                          ? WBColors.statusError
                          : WBColors.fgHeader,
                    ),
                  ),
                  if (spec.sub != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      spec.sub!,
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (spec.trailingPill != null) ...[
              const SizedBox(width: 8),
              spec.trailingPill!,
              const SizedBox(width: 6),
            ],
            const WBIcon(
              WBIconName.chevronRight,
              size: 16,
              color: WBColors.fgPlaceholder,
            ),
          ],
        ),
      ),
    );
  }
}
