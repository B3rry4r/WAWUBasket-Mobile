import 'package:flutter/material.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../domain/models/subcategory.dart';

/// Horizontal scrolling row of subcategory chips with an animated reveal.
/// Renders [Subcategory] objects via the existing `WBTag` widget so the
/// visual style matches Search filters exactly.
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
                  return WBTag(
                    label: sub.label,
                    active: sub.id == activeId,
                    onTap: () => onTap(sub.id),
                  );
                },
              ),
            ),
    );
  }
}
