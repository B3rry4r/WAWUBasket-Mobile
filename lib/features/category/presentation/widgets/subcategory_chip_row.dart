import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../domain/models/subcategory.dart';

/// Horizontal scrolling row of subcategory chips with an animated reveal.
/// The leading "All" chip uses the standard [WBTag]; each subcategory chip
/// shows its SVG icon inside a circle, matching the home category pill row.
///
/// Pass [visible] = `false` to collapse the row; the parent will animate
/// the slot's height via [AnimatedSize]. This widget itself just handles
/// the opacity / vertical-slide fade.
class SubcategoryChipRow extends StatelessWidget {
  const SubcategoryChipRow({
    super.key,
    required this.subcategories,
    required this.activeId,
    required this.onTap,
    required this.visible,
    this.horizontalPadding = WBSpacing.screenPadding,
  });

  final List<Subcategory> subcategories;
  final String? activeId;
  final ValueChanged<String?> onTap;
  final bool visible;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: WBMotion.base,
      switchInCurve: WBMotion.easeSoft,
      switchOutCurve: WBMotion.easeSoft,
      transitionBuilder: (child, anim) {
        final slide = Tween<Offset>(
          begin: const Offset(0, -0.2),
          end: Offset.zero,
        ).animate(anim);
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: !visible || subcategories.isEmpty
          ? const SizedBox(key: ValueKey('subcat-empty'), width: double.infinity)
          : SizedBox(
              key: const ValueKey('subcat-row'),
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                itemCount: subcategories.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return WBTag(
                      label: 'All',
                      active: activeId == null,
                      onTap: () => onTap(null),
                    );
                  }
                  final sub = subcategories[i - 1];
                  final active = sub.id == activeId;
                  return GestureDetector(
                    onTap: () => onTap(sub.id),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: WBMotion.base,
                      curve: WBMotion.easeSoft,
                      padding: const EdgeInsets.only(left: 4, right: 12),
                      decoration: BoxDecoration(
                        color: active
                            ? WBColors.surfaceDark
                            : WBColors.surfaceTag,
                        borderRadius: BorderRadius.circular(WBRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : WBColors.bgPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: (sub.svgAsset != null &&
                                    sub.svgAsset!.isNotEmpty)
                                ? SvgPicture.asset(
                                    sub.svgAsset!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) =>
                                        const SizedBox.shrink(),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            sub.label,
                            style: WBTypography.caption.copyWith(
                              color: active
                                  ? Colors.white
                                  : WBColors.fgHeader,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
