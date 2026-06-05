import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/wb_responsive_exports.dart';
import '../../../../core/theme/wb_theme_exports.dart';
import '../../../../core/utils/wb_actions.dart';
import '../../../../core/utils/wb_l10n.dart';
import '../../../../core/widgets/wb_widgets.dart';
import '../../../auth/application/role_controller.dart';
import '../../../shell/presentation/desktop/operator_desktop_scaffold.dart';
import '../../data/vendor_api.dart';

/// Desktop-web layout for the vendor reviews screen.
///
/// PUSHED operator screen: wrapped in [OperatorDesktopScaffold] so the vendor
/// sidebar stays visible. Re-lays the mobile vertical list into a dashboard
/// surface — the summary/distribution card sits beside a comfortable two-column
/// grid of review cards. Reuses [VendorApi], the same reply sheet, money/date
/// formatting, status logic and l10n keys; this is layout only.
class VendorReviewsDesktopScreen extends StatefulWidget {
  const VendorReviewsDesktopScreen({super.key});

  @override
  State<VendorReviewsDesktopScreen> createState() =>
      _VendorReviewsDesktopScreenState();
}

class _VendorReviewsDesktopScreenState
    extends State<VendorReviewsDesktopScreen> {
  /// Review ids that carry a reply (either from the server or posted in
  /// this session).
  final Set<String> _replied = <String>{};

  List<_Review>? _reviews;
  String _avgRating = '0.0';
  Map<int, double> _distribution = const {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final res = await VendorApi.instance.reviews();
      final raw = (res as Map).cast<String, dynamic>();
      final list = (raw['reviews'] as List? ?? const [])
          .map((e) => _Review.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
      final total = list.isEmpty ? 1 : list.length;
      final dist = (raw['distribution'] as Map?)?.cast<String, dynamic>() ??
          const {};
      if (!mounted) return;
      setState(() {
        _reviews = list;
        _avgRating = (raw['avgRating'] ?? '0.0').toString();
        _distribution = {
          for (var s = 1; s <= 5; s++)
            s: ((dist['$s'] as num?)?.toDouble() ?? 0) / total,
        };
        _replied
          ..clear()
          ..addAll(list.where((r) => r.hasReply).map((r) => r.id));
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _openReplySheet({
    required String id,
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
    if (result == null || !mounted) return;
    setState(() => _replied.add(id));
    try {
      await VendorApi.instance.replyReview(id, result);
      if (mounted) {
        wbShowSnack(context, context.l10n.vendorReviewReplyPosted(reviewer));
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _replied.remove(id));
        wbShowSnack(context, e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OperatorDesktopScaffold(
      role: AppRole.vendor,
      child: WBMaxWidth(
        maxWidth: WBBreakpoints.maxContent,
        padding: const EdgeInsets.fromLTRB(
          WBSpacing.xl,
          WBSpacing.xl,
          WBSpacing.xl,
          WBSpacing.xxl,
        ),
        child: ListView(
          children: [
            _Header(onBack: () => context.pop()),
            const SizedBox(height: WBSpacing.xl),
            _buildBody(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final reviews = _reviews;
    if (reviews == null && _error == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 72),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation(WBColors.surfaceDark),
            ),
          ),
        ),
      );
    }
    if (_error != null) {
      return _Hint(text: _error!);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryCard(
          avgRating: _avgRating,
          count: reviews!.length,
          distribution: _distribution,
        ),
        const SizedBox(height: WBSpacing.xl),
        if (reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: WBEmptyState(
              illustration: WBEmptyIllustration.noOrders,
              label: 'No reviews yet.',
              sub: 'They land here as orders complete.',
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = WBSpacing.md;
              final twoUp = constraints.maxWidth >= 720;
              final colWidth = twoUp
                  ? (constraints.maxWidth - gap) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final r in reviews)
                    SizedBox(
                      width: colWidth,
                      child: _ReviewCard(
                        review: r,
                        replied: _replied.contains(r.id),
                        onReply: () => _openReplySheet(
                          id: r.id,
                          reviewer: r.name,
                          text: r.text,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WBBackChip(onPressed: onBack),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.vendorReviewsTitle, style: WBTypography.page),
              const SizedBox(height: 2),
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
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.avgRating,
    required this.count,
    required this.distribution,
  });

  final String avgRating;
  final int count;
  final Map<int, double> distribution;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WBSpacing.xl),
      decoration: BoxDecoration(
        color: WBColors.surfaceCard,
        borderRadius: BorderRadius.circular(WBRadius.card),
        boxShadow: WBShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '★ $avgRating',
                style: WBTypography.hero.copyWith(fontSize: 40),
              ),
              Text(
                'Based on $count ${count == 1 ? 'review' : 'reviews'}',
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: WBSpacing.xl),
          Expanded(
            child: Column(
              children: [
                for (var s = 5; s >= 1; s--)
                  _Bucket(stars: s, pct: distribution[s] ?? 0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.replied,
    required this.onReply,
  });

  final _Review review;
  final bool replied;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context) {
    final r = review;
    return WBCard(
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
                  color: i < r.rating ? WBColors.fgHeader : WBColors.bgDivider,
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
              if (replied)
                WBStatusPill(
                  label: context.l10n.vendorReviewRepliedLabel,
                  kind: WBStatusKind.success,
                )
              else
                GestureDetector(
                  onTap: onReply,
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
    );
  }
}

/// A vendor review mapped from the `/v1/vendor/reviews` payload.
class _Review {
  const _Review({
    required this.id,
    required this.name,
    required this.rating,
    required this.text,
    required this.date,
    required this.hasReply,
  });

  final String id;
  final String name;
  final int rating;
  final String text;
  final String date;
  final bool hasReply;

  factory _Review.fromJson(Map<String, dynamic> j) {
    final created = DateTime.tryParse('${j['createdAt'] ?? ''}')?.toLocal();
    return _Review(
      id: (j['id'] ?? '').toString(),
      name: _shortName(j['reviewerName'] as String?),
      rating: (j['score'] as num?)?.toInt() ?? 0,
      text: (j['review'] ?? '').toString(),
      date: _ago(created),
      hasReply: (j['reply'] ?? '').toString().isNotEmpty,
    );
  }
}

String _shortName(String? full) {
  final name = (full ?? '').trim();
  if (name.isEmpty) return 'Customer';
  final parts = name.split(RegExp(r'\s+'));
  if (parts.length == 1) return parts.first;
  return '${parts.first} ${parts.last[0].toUpperCase()}.';
}

String _ago(DateTime? t) {
  if (t == null) return '';
  final now = DateTime.now();
  final d = DateTime(now.year, now.month, now.day)
      .difference(DateTime(t.year, t.month, t.day))
      .inDays;
  if (d <= 0) return 'Today';
  if (d == 1) return 'Yesterday';
  if (d < 7) return '$d days ago';
  final w = d ~/ 7;
  return w == 1 ? '1 week ago' : '$w weeks ago';
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            label: context.l10n.vendorReviewYourReply,
            placeholder: context.l10n.vendorReviewReplyPlaceholder,
            controller: _ctrl,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: WBSpacing.lg),
          WBButton(
            label: context.l10n.vendorReviewPostReply,
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
