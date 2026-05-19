import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';

class VendorReviewsScreen extends StatelessWidget {
  const VendorReviewsScreen({super.key});

  static const _reviews = [
    (name: 'Adunni O.', rating: 5, text: 'Best jollof in Lagos — period.', date: 'Today'),
    (name: 'Tobi K.', rating: 4, text: 'Great food, suya could be hotter.', date: 'Yesterday'),
    (name: 'Kemi A.', rating: 5, text: 'Fast delivery, food still hot 🔥', date: '2 days ago'),
    (name: 'Daniel U.', rating: 3, text: 'Rice was a bit dry today.', date: '3 days ago'),
    (name: 'Funke I.', rating: 5, text: 'My family loves this place!', date: '1 week ago'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgSecondary,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            12,
            WBSpacing.screenPadding,
            40,
          ),
          children: [
            Row(
              children: [
                WBBackChip(onPressed: () => context.pop()),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("What they're saying", style: WBTypography.page),
                      Text(
                        'The good, the bad, and the delicious.',
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: WBSpacing.lg),
            Container(
              padding: const EdgeInsets.all(WBSpacing.lg),
              decoration: BoxDecoration(
                color: WBColors.surfaceCard,
                borderRadius: BorderRadius.circular(WBRadius.card),
                boxShadow: WBShadows.card,
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '★ 4.8',
                        style: WBTypography.hero.copyWith(fontSize: 36),
                      ),
                      Text(
                        'Based on 247 reviews',
                        style: WBTypography.caption.copyWith(
                          color: WBColors.fgSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      children: [
                        _Bucket(stars: 5, pct: 0.72),
                        _Bucket(stars: 4, pct: 0.20),
                        _Bucket(stars: 3, pct: 0.05),
                        _Bucket(stars: 2, pct: 0.02),
                        _Bucket(stars: 1, pct: 0.01),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            for (final r in _reviews)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: WBCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            r.name,
                            style: WBTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          for (var i = 0; i < 5; i++)
                            WBIcon(
                              WBIconName.star,
                              size: 12,
                              color: i < r.rating
                                  ? WBColors.fgHeader
                                  : WBColors.bgDivider,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r.text,
                        style: WBTypography.body.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            r.date,
                            style: WBTypography.caption.copyWith(
                              color: WBColors.fgSecondary,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () =>
                                wbShowSnack(context, 'Reply opened'),
                            child: Text(
                              'Reply',
                              style: WBTypography.caption.copyWith(
                                color: WBColors.fgHeader,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Bucket extends StatelessWidget {
  const _Bucket({required this.stars, required this.pct});
  final int stars;
  final double pct;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Text(
            '$stars★',
            style: WBTypography.caption.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(WBRadius.pill),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 5,
                backgroundColor: WBColors.bgSoft,
                valueColor: const AlwaysStoppedAnimation(WBColors.surfaceDark),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${(pct * 100).toInt()}%',
            style: WBTypography.caption.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
