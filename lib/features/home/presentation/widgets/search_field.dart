import 'package:flutter/material.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';

/// Read-only search bar that taps through to the Search screen.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    this.onTap,
    this.placeholder = 'Search for vendors or dishes',
  });

  final VoidCallback? onTap;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: WBColors.surfaceInput,
          borderRadius: BorderRadius.circular(WBRadius.input),
          boxShadow: WBShadows.card,
        ),
        child: Row(
          children: [
            const WBIcon(
              WBIconName.search,
              size: 20,
              color: WBColors.fgPlaceholder,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                placeholder,
                style: WBTypography.body.copyWith(
                  color: WBColors.fgPlaceholder,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section header — title + optional trailing action label.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});
  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: WBTypography.section.copyWith(fontSize: 20),
        ),
        if (action != null)
          Text(
            action!,
            style: WBTypography.caption.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 13,
            ),
          ),
      ],
    );
  }
}
