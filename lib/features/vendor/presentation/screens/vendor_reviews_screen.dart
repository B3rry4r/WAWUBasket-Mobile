import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/widgets/wb_widgets.dart';

class VendorReviewsScreen extends StatefulWidget {
  const VendorReviewsScreen({super.key});

  @override
  State<VendorReviewsScreen> createState() => _VendorReviewsScreenState();
}

class _VendorReviewsScreenState extends State<VendorReviewsScreen> {
  /// Whether a given review has had a reply submitted in this session. Keyed
  /// by reviewer name to keep the mock simple.
  final Set<String> _replied = <String>{};

  static const _reviews = [
    (name: 'Adunni O.', rating: 5, text: 'Best jollof in Lagos, period.', date: 'Today'),
    (name: 'Tobi K.', rating: 4, text: 'Great food, suya could be hotter.', date: 'Yesterday'),
    (name: 'Kemi A.', rating: 5, text: 'Fast delivery, food still hot 🔥', date: '2 days ago'),
    (name: 'Daniel U.', rating: 3, text: 'Rice was a bit dry today.', date: '3 days ago'),
    (name: 'Funke I.', rating: 5, text: 'My family loves this place!', date: '1 week ago'),
  ];

  void _openReplySheet({
    required String reviewer,
    required String text,
  }) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: WBColors.bgPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(WBRadius.sheet)),
      ),
      builder: (sheetCtx) =>
          _ReplySheet(reviewer: reviewer, originalText: text),
    );
    if (result != null && mounted) {
      setState(() => _replied.add(reviewer));
      wbShowSnack(context, 'Reply posted to $reviewer');
    }
  }

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
                          if (_replied.contains(r.name))
                            const WBStatusPill(
                              label: 'Replied',
                              kind: WBStatusKind.success,
                            )
                          else
                            GestureDetector(
                              onTap: () =>
                                  _openReplySheet(reviewer: r.name, text: r.text),
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

class _ReplySheet extends StatefulWidget {
  const _ReplySheet({required this.reviewer, required this.originalText});
  final String reviewer;
  final String originalText;

  @override
  State<_ReplySheet> createState() => _ReplySheetState();
}

class _ReplySheetState extends State<_ReplySheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _ctrl.text.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.only(
        left: WBSpacing.screenPadding,
        right: WBSpacing.screenPadding,
        top: WBSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + WBSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: WBSpacing.lg),
              decoration: BoxDecoration(
                color: WBColors.bgDivider,
                borderRadius: BorderRadius.circular(WBRadius.pill),
              ),
            ),
          ),
          Text(
            'Reply to ${widget.reviewer}',
            style: WBTypography.cardTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: WBColors.bgSoft,
              borderRadius: BorderRadius.circular(WBRadius.card),
            ),
            child: Text(
              '“${widget.originalText}”',
              style: WBTypography.body.copyWith(
                fontSize: 14,
                color: WBColors.fgSecondary,
                fontStyle: FontStyle.italic,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          WBInput(
            label: 'Your reply',
            placeholder: 'Thanks for the feedback, we hear you...',
            controller: _ctrl,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: WBSpacing.lg),
          WBButton(
            label: 'Post reply',
            size: WBButtonSize.lg,
            fullWidth: true,
            disabled: !canSend,
            onPressed: canSend
                ? () => Navigator.of(context).pop(_ctrl.text.trim())
                : null,
          ),
        ],
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
